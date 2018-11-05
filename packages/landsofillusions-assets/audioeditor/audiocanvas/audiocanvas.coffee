AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AudioCanvas extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.AudioCanvas'
  @register @id()
  
  constructor: (@audioEditor) ->
    super arguments...
    
    # Prepare all reactive fields.
    @camera = new ReactiveField null
    @mouse = new ReactiveField null
    @grid = new ReactiveField null
    @flowchart = new ReactiveField null
    @bounds = new AE.Rectangle()
    @$audioCanvas = new ReactiveField null
    @canvas = new ReactiveField null
    @context = new ReactiveField null
    @dragNodeId = new ReactiveField null
    @dragRequireMove = new ReactiveField false
    @dragHasMoved = new ReactiveField false

  onCreated: ->
    super arguments...

    @display = @callAncestorWith 'display'

    # Initialize components.
    @camera new @constructor.Camera @
    @mouse new @constructor.Mouse @
    @grid new @constructor.Grid @
    @flowchart new @constructor.Flowchart @

    # Resize the canvas when browser window and zoom changes.
    @autorun =>
      canvas = @canvas()
      return unless canvas

      # Depend on window size.
      AM.Window.clientBounds()

      # Resize the back buffer to canvas element size, if it actually changed. If the pixel
      # canvas is not actually sized relative to window, we shouldn't force a redraw of the sprite.
      newSize =
        width: $(canvas).width()
        height: $(canvas).height()

      for key, value of newSize
        canvas[key] = value unless canvas[key] is value

      # Bounds are reported in window pixels as well.
      @bounds.width newSize.width
      @bounds.height newSize.height

    # Redraw canvas routine.
    @autorun =>
      camera = @camera()
      context = @context()
      return unless context

      context.setTransform 1, 0, 0, 1, 0, 0
      context.clearRect 0, 0, @bounds.width(), @bounds.height()

      camera.applyTransformToCanvas()

      for component in [@grid(), @flowchart()]
        continue unless component

        context.save()
        component.drawToContext context
        context.restore()

    # Create node components.
    @_nodeComponentsById = {}

    @nodeComponentsById = new ComputedField =>
      return unless nodes = @audioEditor.audioData()?.nodes

      previousNodeComponents = _.values @_nodeComponentsById

      for node in nodes
        nodeComponent = @_nodeComponentsById[node.id]

        if nodeComponent
          _.pull previousNodeComponents, nodeComponent

        else
          nodeComponent = new LOI.Assets.AudioEditor.Node
            id: node.id
            nodeClass: LOI.Assets.Engine.Audio.Node.getClassForType node.type
            audioCanvas: @

          @_nodeComponentsById[node.id] = nodeComponent

      # Destroy all components that aren't present any more.
      for unusedNodeComponent in previousNodeComponents
        nodeId = unusedNodeComponent.id

        delete @_nodeComponentsById[nodeId]

      @_nodeComponentsById

    # Handle connections.
    @draggedConnection = new ReactiveField null
    @hoveredInput = new ReactiveField null
    @hoveredOutput = new ReactiveField null

    @connections = new ComputedField =>
      # Create a deep clone of the connections so that we can manipulate them.
      connections = _.cloneDeep @audioEditor.audio()?.connections() or []

      if draggedConnection = @draggedConnection()
        # See if dragged connection is one of the existing ones.
        draggedNodeConnection = _.find connections, (connection) =>
          _.every [
            connection.endNodeId is draggedConnection.endNodeId
            connection.input is draggedConnection.input
            connection.startNodeId is draggedConnection.startNodeId
            connection.output is draggedConnection.output
          ]

        if draggedNodeConnection
          # Disconnect it so it will be moved with the mouse.
          draggedNodeConnection.input = null
          draggedNodeConnection.endNodeId = null

        else
          # Add the dragged connection to connections.
          connections.push draggedConnection

        hoveredInput = @hoveredInput()
        hoveredOutput = @hoveredOutput()

      for connection in connections
        if connection.startNodeId or hoveredOutput
          continue unless startNodeComponent = @_nodeComponentsById[connection.startNodeId or hoveredOutput.nodeId]
          continue unless componentPosition = startNodeComponent.position()
          continue unless outputPosition = startNodeComponent.outputPositionForName connection.output or hoveredOutput?.output
  
          connection.start =
            x: componentPosition.x + outputPosition.x
            y: componentPosition.y + outputPosition.y

        else
          connection.start = @mouse().canvasCoordinate()

        if connection.endNodeId or hoveredInput
          continue unless endNodeComponent = @_nodeComponentsById[connection.endNodeId or hoveredInput.nodeId]
          continue unless componentPosition = endNodeComponent.position()

          input = connection.input or hoveredInput?.input
          continue unless inputPosition = endNodeComponent.inputPositionForName input

          connection.sideEntry = endNodeComponent.isParameter input

          connection.end =
            x: componentPosition.x + inputPosition.x
            y: componentPosition.y + inputPosition.y

        else
          connection.end = @mouse().canvasCoordinate()
          connection.sideEntry = false

      # Remove any connections that we couldn't determine.
      _.filter connections, (connection) => connection.start and connection.end

    # Handle node dragging.
    @autorun (computation) =>
      return unless nodeId = @dragNodeId()
      return unless nodeComponent = @nodeComponentsById()?[nodeId]
      
      newCanvasCoordinate = @mouse().canvasCoordinate()

      dragDelta =
        x: newCanvasCoordinate.x - @dragStartCanvasCoordinate.x
        y: newCanvasCoordinate.y - @dragStartCanvasCoordinate.y

      # Notify that we moved.
      @dragHasMoved true if dragDelta.x or dragDelta.y

      nodeComponent.temporaryPosition
        x: @dragStartNodePosition.x + dragDelta.x
        y: @dragStartNodePosition.y + dragDelta.y

  onRendered: ->
    super arguments...

    # DOM has been rendered, initialize.
    $audioCanvas = @$('.landsofillusions-assets-audioeditor-audiocanvas')
    @$audioCanvas $audioCanvas

    canvas = @$('.canvas')[0]
    @canvas canvas
    @context canvas.getContext '2d'

    # Prevent click events from happening when dragging was active. We need to manually add this event
    # listener so that we can set setCapture to true and make this listener be called before child click events.
    $audioCanvas[0].addEventListener 'click', =>
      # If drag has happened, don't process other clicks.
      event.stopImmediatePropagation() if @dragHasMoved()

      # Reset drag has moved to allow further clicks.
      @dragHasMoved false
    ,
      true

  nodeComponents: ->
    _.values @nodeComponentsById()

  originStyle: ->
    camera = @camera()
    originInWindow = camera.transformCanvasToWindow x: 0, y: 0

    transform: "translate3d(#{originInWindow.x}px, #{originInWindow.y}px, 0)"

  startDrag: (options) ->
    @dragStartCanvasCoordinate = @mouse().canvasCoordinate()
    @dragStartNodePosition = options.nodePosition
    @dragRequireMove options.requireMove
    @dragHasMoved false

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on 'mouseup.pixelartacademy-pixelboy-apps-studyplan-audioCanvas', =>
      # If required to move, don't stop drag until we do so.
      return if @dragRequireMove() and not @dragHasMoved()

      # See if we ended up dragging over the trash.
      if @mouseOverTrash()
        # Delete the node.
        @audioEditor.removeNode options.nodeId

      else
        # Save temporary position into the database.
        nodeComponent = @nodeComponentsById()[options.nodeId]
        @audioEditor.changeNodePosition options.nodeId, nodeComponent.position()
        nodeComponent.temporaryPosition null

      @dragNodeId null
      $(document).off '.pixelartacademy-pixelboy-apps-studyplan-audioCanvas'

    # Set node component last since it triggers reactivity.
    @dragNodeId options.nodeId

  draggingClass: ->
    'dragging' if @dragNodeId()

  dragged: ->
    @dragNodeId() and (@dragHasMoved() or @dragRequireMove())

  draggedClass: ->
    'dragged' if @dragged()

  connectingClass: ->
    'connecting' if @draggedConnection()

  mouseOverTrash: ->
    # Trash is only visible when dragged.
    return unless @dragged()

    $trash = @$('.trash')

    position = $trash.position()
    width = $trash.outerWidth()
    height = $trash.outerHeight()
    mouse = @mouse().windowCoordinate()

    (position.left < mouse.x < position.left + width) and (position.top < mouse.y < position.top + height)

  trashActiveClass: ->
    'active' if @mouseOverTrash()

  focusNode: (nodeId) ->
    return unless nodeComponent = @nodeComponentsById()[nodeId]

    camera = @camera()
    camera.setOrigin nodeComponent.position()

  startConnection: (options) ->
    if options.input
      @draggedConnection
        endNodeId: options.nodeId
        input: options.input

    else
      @draggedConnection
        startNodeId: options.nodeId
        output: options.output

  modifyConnection: (connection) ->
    @draggedConnection connection

  endConnection: (options) ->
    return unless draggedConnection = @draggedConnection()
    
    connection =
      nodeId: if options.input then options.nodeId else draggedConnection.endNodeId
      input: options.input or draggedConnection.input
      output: options.output or draggedConnection.output

    invalid = false

    # Make sure the connection goes from an input to an output.
    invalid = true unless connection.input and connection.output

    # Make sure the input is not already connected. We need to compare to actual connections in the audio
    # engine (and not our modified ones) since the dragged connection might be going from input to output.
    invalid = true if _.find @audioEditor.audio()?.connections(), (existingConnection) =>
      existingConnection.endNodeId is connection.nodeId and existingConnection.input is connection.input

    unless invalid
      startNodeId = if options.input then draggedConnection.startNodeId else options.nodeId

      # See if this was an existing connection.
      if draggedConnection.startNodeId and draggedConnection.endNodeId
        oldConnection =
          nodeId: draggedConnection.endNodeId
          input: draggedConnection.input
          output: draggedConnection.output

        # If the user just reconnected the same input output there's nothing to do.
        # We still need to fall through to the end so the dragged connection ends.
        unless EJSON.equals connection, oldConnection
          @audioEditor.modifyConnection startNodeId, connection, oldConnection

      else
        @audioEditor.addConnection startNodeId, connection

    # End dragging.
    @draggedConnection null

  startHoverInput: (options) ->
    # Make sure the input is not already connected.
    return if _.find @connections(), (connection) => connection.endNodeId is options.nodeId and connection.input is options.input

    @hoveredInput options

  endHoverInput: ->
    @hoveredInput null

  startHoverOutput: (options) ->
    @hoveredOutput options

  endHoverOutput: ->
    @hoveredOutput null

  events: ->
    super(arguments...).concat
      'mousedown': @onMouseDown
      'mouseup': @onMouseUp

  onMouseDown: (event) ->
    # Reset dragging on any start of clicks.
    @dragHasMoved false

  onMouseUp: (event) ->
    return unless draggedConnection = @draggedConnection()

    # If we were modifying an existing connection, remove it.
    if draggedConnection.endNodeId and draggedConnection.startNodeId
      connection =
        nodeId: draggedConnection.endNodeId
        input: draggedConnection.input
        output: draggedConnection.output

      @audioEditor.removeConnection draggedConnection.startNodeId, connection

    # End connecting.
    @draggedConnection null
