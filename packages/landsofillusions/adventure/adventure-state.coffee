AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
LOI = LandsOfIllusions
Persistence = Artificial.Mummification.Document.Persistence

class LOI.Adventure extends LOI.Adventure
  @debugState = false
  @profileIdLocalStorageKey = 'LandsOfIllusions.Adventure.profileId'
  
  getLocalSyncedStorage: -> null # Override to return a synced storage that will save the game locally.
  getServerSyncedStorage: -> null # Override to return a synced storage that will save the game to the server.

  _initializeState: ->
    # Prepare local and server storage.
    @localSyncedStorage = @getLocalSyncedStorage()
    Persistence.registerSyncedStorage @localSyncedStorage if @localSyncedStorage
    
    @serverSyncedStorage = @getServerSyncedStorage()
    Persistence.registerSyncedStorage @serverSyncedStorage if @serverSyncedStorage
    
    # Prepare profile handling.
    @profileId = new ReactiveField null
    
    @profile = new ComputedField =>
      Persistence.Profile.documents.findOne @profileId()
    
    # Provide game state fields.
    @gameState = new ComputedField =>
      return unless profileId = @profileId()
      return unless gameStateDocument = LOI.GameState.documents.findOne {profileId}, fields: state: 1
      
      gameState = LOI.GameState.transformStateFromDatabase gameStateDocument.state or {}
      console.log "Retrieved new game state", gameState if LOI.debug or LOI.Adventure.debugState
      gameState
  
    @gameState.updated = =>
      return unless profileId = @profileId()
      
      gameState = @gameState()
      console.log "Game state updated, sending to documents ...", gameState if LOI.debug or LOI.Adventure.debugState
      LOI.GameState.documents.update {profileId},
        $set:
          state: LOI.GameState.prepareStateForDatabase gameState
          lastEditTime: new Date
  
    @readOnlyGameState = new ComputedField =>
      return unless profileId = @profileId()
      return unless gameStateDocument = LOI.GameState.documents.findOne {profileId}, fields: readOnlyState: 1
      
      readOnlyGameState = LOI.GameState.transformStateFromDatabase gameStateDocument?.readOnlyState or {}
      console.log "Retrieved new read only game state", readOnlyGameState if LOI.debug or LOI.Adventure.debugState
      readOnlyGameState
      
    # See if we have a profile ID stored locally.
    @loadingStoredProfile = new ReactiveField false
    
    if storedProfileId = @_loadStoredProfileId()
      console.log "Loading stored profile ID", storedProfileId
      @loadingStoredProfile true
      
      # Wait until the profile becomes available (or another profile gets loaded).
      @autorun (computation) =>
        if profileId = @profileId()
          console.log "Another profile was loaded", profileId
          @loadingStoredProfile false
          computation.stop()
          return
          
        return unless Persistence.ready()
        computation.stop()

        if Persistence.Profile.documents.findOne storedProfileId
          console.log "Stored profile was found! Loading it …"
          
          # The profile has been added from synced storage(s), so we can now load it.
          @loadGame(storedProfileId).catch((error) =>
            LOI.adventure.showDialogMessage """
              Unfortunately, the last active save game was not able to be automatically loaded.
              The game will now restart from the menu, but if the problem persists,
              this info could be useful: #{error.reason}
            """
        
          ).finally =>
            @loadingStoredProfile false
            
        else
          console.log "Stored profile was not provided by any of the synced storages."
          @loadingStoredProfile false

  startNewGame: ->
    await @_unloadProfileIfLoaded()
    
    # Create a fresh profile and reset the game.
    Persistence.createProfile().then (profileId) =>
      # Create a new game state.
      LOI.GameState.documents.insert
        profileId: profileId
        lastEditTime: new Date
      
      @_changeProfileId profileId
  
  loadGame: (profileId) ->
    console.log "Loading profile", profileId
    
    await @_unloadProfileIfLoaded()

    # Load the game profile from persistence and activate it if it loaded OK.
    Persistence.loadProfile(profileId).then =>
      console.log "Persistence profile was loaded. Checking for game state …"
      
      # Ensure we received a valid game state.
      unless LOI.GameState.documents.findOne {profileId}
        return Persistence.unloadProfile().then => throw new AE.InvalidOperationException "Game state for profile #{profileId} was not found."
      
      console.log "Game state was found."
      
      @_changeProfileId profileId
    
    , (errorOrConflictResolution) =>
      if errorOrConflictResolution instanceof Error
        console.error "Persistence profile loading encountered an error.", errorOrConflictResolution
        # This was not a planned rejection of profile loading. Throw it as an error.
        throw errorOrConflictResolution
        
      # TODO: Implement conflict resolution.
    
  _unloadProfileIfLoaded: ->
    if Persistence.activeProfile()
      # Something must have gone wrong with UI flows if there is a profile loaded before trying to load a new one.
      console.error "Profile was already loaded when trying to load another one."
      
      # We want to prevent the player to getting soft-locked however, so we simply unload it here.
      new Promise (resolve, reject) =>
        @quitGame callback: =>
          resolve()
          
          # Notify that we've handled the quitting procedure.
          true
    
  _changeProfileId: (profileId) ->
    # Reset the interface.
    @interface.reset()

    # Clear active item.
    @activeItemId null

    # Cleanup storyline classes.
    @resetEpisodes()

    # Cleanup running scripts.
    @director.stopAllScripts()

    # Activate the new profile.
    @profileId profileId
    @_storeProfileId()
    
    console.log "Changed profile to", profileId

  saveGame: (options) ->
    # Start syncing the profile to desired storages.
    if options.local and @localSyncedStorage
      Persistence.addSyncingToProfile @localSyncedStorage.id()
      
    if options.server and @serverSyncedStorage
      Persistence.addSyncingToProfile @serverSyncedStorage.id()
  
    # Store profile ID locally.
    @_storeProfileId()

  quitGame: (options = {}) ->
    console.log "Quitting game."
    
    # Update any lazy fields.
    @gameState.updated()
    
    @profileId null
    @_clearStoredProfileId()
  
    Persistence.unloadProfile().then =>
      console.log "Quit game unload profile succeeded."
      # Execute the callback if present and end if it has handled the redirect.
      return if options.callback?()
  
      # Do a hard reload of the root URL.
      window.location = @constructor.rootUrl()
      
    , (error) =>
      console.error "Quit game failed to unload the profile.", error
      
  _loadStoredProfileId: ->
    localStorage.getItem @constructor.profileIdLocalStorageKey
    
  _storeProfileId: ->
    localStorage.setItem @constructor.profileIdLocalStorageKey, @profileId()
    
  _clearStoredProfileId: ->
    localStorage.removeItem @constructor.profileIdLocalStorageKey
