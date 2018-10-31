LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Node
  @_nodeClassesByType = {}

  @getClassForType: (type) ->
    @_nodeClassesByType[type]

  @getClasses: ->
    _.values @_nodeClassesByType

  # String for this node used to identify the node in code.
  @type: -> throw new AE.NotImplementedException "You must specify node's type."

  # Name is how the node is represented in the editor. Not that we can't 
  # call it simply name because it conflicts with the class name property.
  @nodeName: -> throw new AE.NotImplementedException "You must specify node's name."

  # Override to provide inputs and outputs of the node.
  @inputs: -> []
  @outputs: -> []
    
  # Override to provide available parameters of this node.
  @parameters: -> []

  @initialize: ->
    # Store node class by type.
    @_nodeClassesByType[@type()] = @
    
  constructor: (@id, @audio, initialParameters) ->
    # Parameters are compared by data equality to minimize changes in the audio engine.
    @parameters = new ReactiveField initialParameters, EJSON.equals

    # Provides support for autorun calls that stop when node is destroyed.
    @_autorunHandles = []

    # Prepare autoruns for reactively connecting when audio connection info changes.
    @_connectionAutoruns = []

    # Reactive values hold fields for connected inputs and parameters.
    @reactiveValuesByName = new ReactiveField {}

  destroy: ->
    handle.stop() for handle in @_autorunHandles

    @_disconnectAutoruns @_connectionAutoruns

  autorun: (handler) ->
    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle

  type: -> @constructor.type()
  nodeName: -> @constructor.nodeName()

  readInput: (input) ->
    @reactiveValuesByName()[input]?()

  readParameter: (parameter) ->
    # See if the parameter has a connection.
    if reactiveValue = @reactiveValuesByName()[parameter]
      # We always return whatever is coming from the connection.
      reactiveValue()

    else
      # We return the constant value set on the node.
      @parameters()[parameter]

  connect: (node, output, input) ->
    console.log "Connecting audio node #{@_connectionDescription node, output, input}" if LOI.Assets.Engine.Audio.debug

    @_connect arguments...
    
    node.onConnect input, @, output

  _connect: (node, output, input) ->
    # Reactively connect to node input.
    autorun = Tracker.autorun (computation) =>
      # Remove existing audio connection.
      @_disconnect node, output, input, false

      destinationConnection = node.getDestinationConnection input
      return unless destination = destinationConnection?.destination

      sourceConnection = @getSourceConnection output
      return unless source = sourceConnection?.source

      inputIndex = destinationConnection.index or 0
      outputIndex = sourceConnection.output or 0

      console.log "Audio node connection created #{@_connectionDescription node, output, input}" if LOI.Assets.Engine.Audio.debug

      source.connect destination, outputIndex, inputIndex

      Tracker.afterFlush => autorun.audioConnected = true

    # Store connection parameters on autorun so we can disconnect it later.
    autorun.audioNode = node
    autorun.audioOutput = output
    autorun.audioInput = input

    @_connectionAutoruns.push autorun

  disconnect: (node, output, input) ->
    console.log "Disconnecting audio node #{@_connectionDescription node, output, input}" if LOI.Assets.Engine.Audio.debug

    @_disconnect arguments...

    node.onDisconnect input, @, output

  _disconnect: (node, output, input, stop) ->
    # Stop the autoruns that establish connections.
    connectionAutoruns = _.filter @_connectionAutoruns, (autorun) =>
      autorun.audioNode is node and autorun.audioOutput is output and autorun.audioInput is input

    @_disconnectAutoruns connectionAutoruns, stop

  _disconnectAutoruns: (autoruns, stop = true) ->
    for autorun in autoruns
      if autorun.audioConnected
        destinationConnection = autorun.audioNode.getDestinationConnection autorun.audioInput
        destination = destinationConnection?.destination

        sourceConnection = @getSourceConnection autorun.audioOutput
        source = sourceConnection?.source

        if destination and source
          inputIndex = destinationConnection.index or 0
          outputIndex = sourceConnection.output or 0

          console.log "Audio node connection removed #{@_connectionDescription node, output, input}" if LOI.Assets.Engine.Audio.debug

          source.disconnect destination, outputIndex, inputIndex

      autorun.stop() if stop

    _.pullAll @_connectionAutoruns, autoruns if stop

  audioManager: ->
    @audio.options.world()?.audioManager()

  onConnect: (input, node, output) ->
    reactiveValuesByName = @reactiveValuesByName()
    reactiveValuesByName[input] = node.getReactiveValue output
    @reactiveValuesByName reactiveValuesByName

  onDisconnect: (input, node, output) ->
    reactiveValuesByName = @reactiveValuesByName()
    delete reactiveValuesByName[input]
    @reactiveValuesByName reactiveValuesByName

  getDestinationConnection: (input) ->
    # Override to provide destination and input index for the caller to connect to.
    destination: null
    index: 0

  getSourceConnection: (output) ->
    # Override to provide the source and output index for connecting from.
    source: null
    index: @getOutputIndex output

  getReactiveValue: (output) ->
    # Override to provide a reactive value for desired output.
    null

  getOutputIndex: (outputName) ->
    # By default, audio index matches index in the outputs definition.
    outputs = @constructor.outputs()
    index = _.findIndex outputs, (output) => output.name is outputName

    if index < 0
      console.warn "Trying to connect invalid output #{@id}:#{outputName}"
      null

    else
      index
      
  _connectionDescription: (node, output, input) ->
    "#{@_connectorDescription @, output} -> #{@_connectorDescription node, input}"

  _connectorDescription: (node, connector) ->
    "#{node.constructor.nodeName()}(#{_.toLower(node.id).substring 0, 5}):#{_.toUpper connector}"
