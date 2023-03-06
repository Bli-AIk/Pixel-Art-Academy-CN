AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.GameState extends AM.Document
  @id: -> 'LandsOfIllusions.GameState'
  # state: object that holds editable game information
  #   things: a map of all things
  #     {thingId}: state of the thing
  #   scripts: a map of all scripts
  #     {scriptId}: state of the script
  #   people: a map of all other players' characters
  #     {characterId}: state of the person
  #   currentLocationId: the last known location of the player
  #   currentTimelineId: the last known timeline in which the player is
  #   immersionExitLocationId: the last know location of the player outside immersion
  #   time: integer number of seconds the player has spent in the game
  #   gameTime: fractional number of days passed in the game
  # stateLastUpdatedAt: time when game state was last written to
  # readOnlyState: object with game information that only server can write to
  #   things: a map of all things
  #     {thingId}: state of the thing
  #   simulatedGameTime: how far the server has gotten with simulating game events
  # events: array of events that need to execute on the server
  #   id: id of the event instance
  #   type: type id of the event class that handles this event
  #   gameTime: fractional number of days when the event happens in game time
  #   ... any custom data of the event
  # nextSimulateTime: auto-generated real life time when the next simulation should happen on the server
  # profileId: the user or character ID this state belongs to
  @Meta
    name: @id()
    fields: =>
      user: Document.ReferenceField RA.User, ['displayName']
      character: Document.ReferenceField LOI.Character, ['debugName']
      # Events and state both influence next simulation time (we need earliest event,
      # and latest game time, as well as when that game time was written (last updated at)).
      nextSimulateTime: Document.GeneratedField 'self', ['events', 'state', 'stateLastUpdatedAt'], (fields) ->
        return [fields._id, null] unless fields.events?.length

        earliestEvent = _.first _.sortBy fields.events, 'gameTime'
        eventInstance = LOI.Adventure.Event.getEvent earliestEvent, LOI.GameState.documents.findOne fields._id

        time = eventInstance.simulateAtTime()

        [fields._id, time]

    triggers: =>
      simulate: Document.Trigger ['nextSimulateTime'], (newDocument, oldDocument) ->
        # Don't do anything when document is removed.
        return unless newDocument?._id

        # If current time is after the first event is scheduled, do the simulation now.
        if new Date() > newDocument.nextSimulateTime
          # We need to fetch the full document since newDocument just gives us the nextSimulateTime field.
          LOI.Simulation.Server.simulateGameState LOI.GameState.documents.findOne newDocument._id
          
  @enablePersistence()

  # We define these privately because we have custom public methods
  # that transform the state locally before passing it on to the server.
  @_insert: @method 'insert'
  @_clear: @method 'clear'
  @_replace: @method 'replace'
  @_update: @method 'update'
  @_resetNamespaces: @method 'resetNamespaces'
  
  @forProfile: @subscription 'forProfile'

  @Type:
    Editable: 'gameState'
    ReadOnly: 'readOnlyGameState'

  constructor: ->
    super arguments...

    # On the client also transform state from underscores to dots.
    @state = @constructor._transformStateFromDatabase @state if Meteor.isClient

  @insert: (profileId, callback) ->
    LOI.GameState._insert profileId, callback

  @clear: (profileId, callback) ->
    LOI.GameState._clear profileId, callback

  @replace: (profileId, state, callback) ->
    LOI.GameState._replace profileId, @_prepareStateForDatabase(state), callback

  @_prepareStateForDatabase: (state) ->
    @_renameKeys state, /\./g, '_'

  @_transformStateFromDatabase: (state) ->
    @_renameKeys state, /_/g, '.'

  @_renameKeys: (entity, from, to) ->
    if _.isArray entity
      clone = []
      for arrayEntity in entity
        clone.push @_renameKeys arrayEntity, from, to

    else if _.isObject entity
      clone = {}
      for key, value of entity
        renamedKey = key.replace from, to
        clone[renamedKey] = @_renameKeys value, from, to

    else
      # Simply return the entity.
      clone = entity

    clone

  updated: (options = {}) ->
    # Prepare the helper function that sends updates to the server only every 10 seconds.
    unless @_throttledUpdate
      @_throttledUpdate = _.throttle (options) =>
        @_update options
      ,
        10000
      ,
        leading: false

    # Call the throttled update.
    @_throttledUpdate options

    if options.flush
      # Flush to force immediate execution.
      @_throttledUpdate.flush()

  _update: (options) ->
    # Update the whole state on the server.
    # TODO: Probably we could update only changed objects.
    @constructor._update @_id, @constructor._prepareStateForDatabase(@state), (error, result) =>
      options.callback? error, result

  resetNamespaces: (namespaces) ->
    # First flush current changes.
    @updated flush: true
    
    # Now clean up the state.
    @constructor._resetNamespaces @_id, namespaces
