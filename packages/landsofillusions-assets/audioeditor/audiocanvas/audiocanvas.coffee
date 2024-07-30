AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AudioCanvas extends FM.EditorView.Editor
  # initialCameraScale: default scale for camera if not specified on the file
  
  # EDITOR FILE DATA
  # camera:
  #   scale: canvas magnification
  #   origin: the point on the sprite that should appear in the center of the canvas
  #     x
  #     y
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.AudioCanvas'
  @register @id()
  
  @componentDataFields: -> [
    'initialCameraScale'
  ]
  
  constructor: (@audioEditor) ->
    super arguments...
    
    # Prepare all reactive fields.
    @camera = new ReactiveField null
    @mouse = new ReactiveField null
    @grid = new ReactiveField null
    @flowchart = new ReactiveField null

    @$audioCanvas = new ReactiveField null
    @canvas = new ReactiveField null
    @canvasPixelSize = new ReactiveField {width: 0, height: 0}, EJSON.equals
    @context = new ReactiveField null

    @dragNodeId = new ReactiveField null
    @dragRequireMove = new ReactiveField false
    @dragHasMoved = new ReactiveField false
    
    @dragCanvas = new ReactiveField false
    
    @hoveredNodeId = new ReactiveField null
    @selectedNodeId = new ReactiveField null

  onCreated: ->
    super arguments...

    @display = @callAncestorWith 'display'

    @audioId = new ComputedField =>
      @editorView.activeFileId()

    @audioLoader = new ComputedField =>
      return unless audioId = @audioId()
      @interface.getLoaderForFile audioId

    @audioData = new ComputedField =>
      @audioLoader()?.audioData()

    @audio = new ComputedField =>
      @audioLoader()?.audio()

    @audioManager = new ComputedField =>
      adventureViews = @interface.allChildComponentsOfType LOI.Assets.AudioEditor.AdventureView
      adventureViews[0]?.adventure.audioManager

    @componentData = @interface.getComponentData @
    @componentFileData = new ComputedField =>
      return unless spriteId = @spriteId?()
      @interface.getComponentDataForFile @, spriteId

    # Initialize components.
    @camera new @constructor.Camera @
    @mouse new @constructor.Mouse @
    @grid new @constructor.Grid @
    @flowchart new @constructor.Flowchart @

    # Redraw canvas routine.
    @autorun =>
      return unless context = @context()

      canvasPixelSize = @canvasPixelSize()

      context.setTransform 1, 0, 0, 1, 0, 0
      context.clearRect 0, 0, canvasPixelSize.width, canvasPixelSize.height

      camera = @camera()
      camera.applyTransformToCanvas()

      for component in [@grid(), @flowchart()]
        continue unless component

        context.save()
        component.drawToContext context
        context.restore()

    # Create node components.
    @_nodeComponentsById = {}

    @nodeComponentsById = new ComputedField =>
      return unless nodes = @audioData()?.nodes

      previousNodeComponents = _.values @_nodeComponentsById

      for node in nodes
        nodeComponent = @_nodeComponentsById[node.id]

        if nodeComponent
          _.pull previousNodeComponents, nodeComponent

        else
          nodeComponent = new LOI.Assets.AudioEditor.Node
            id: node.id
            nodeType: node.type
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
      connections = _.cloneDeep @audio()?.connections() or []

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
        
      nodeComponentsById = @nodeComponentsById()

      for connection in connections
        if connection.startNodeId or hoveredOutput
          continue unless startNodeComponent = nodeComponentsById[connection.startNodeId or hoveredOutput.nodeId]
          continue unless componentPosition = startNodeComponent.position()
          continue unless outputPosition = startNodeComponent.outputPositionForName connection.output or hoveredOutput?.output
  
          connection.start =
            x: componentPosition.x + outputPosition.x
            y: componentPosition.y + outputPosition.y

        else
          connection.start = @mouse().canvasCoordinate()

        if connection.endNodeId or hoveredInput
          continue unless endNodeComponent = nodeComponentsById[connection.endNodeId or hoveredInput.nodeId]
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
        
    # Handle canvas dragging.
    @autorun (computation) =>
      return unless @dragCanvas()

      newDisplayCoordinate = @mouse().displayCoordinate()
      cameraScale = @camera().scale()

      dragDelta =
        x: (@dragStartDisplayCoordinate.x - newDisplayCoordinate.x) / cameraScale
        y: (@dragStartDisplayCoordinate.y - newDisplayCoordinate.y) / cameraScale

      @dragStartDisplayCoordinate = newDisplayCoordinate

      @camera().offsetOrigin dragDelta

  onRendered: ->
    super arguments...

    # DOM has been rendered, initialize.
    $audioCanvas = @$('.landsofillusions-assets-audioeditor-audiocanvas')
    @$audioCanvas $audioCanvas

    canvas = @$('.canvas')[0]
    @canvas canvas
    @context canvas.getContext '2d'

    # Resize canvas on editor changes.
    @_audioCanvasResizeObserver = new ResizeObserver =>
      newSize =
        width: $audioCanvas.width()
        height: $audioCanvas.height()
      
      # Resize the back buffer to canvas element size, if it actually changed. If the pixel
      # canvas is not actually sized relative to window, we shouldn't force a redraw of the sprite.
      for key, value of newSize
        canvas[key] = value unless canvas[key] is value
      
      @canvasPixelSize newSize
    
    @_audioCanvasResizeObserver.observe $audioCanvas[0]
    
    # Prevent click events from happening when dragging was active. We need to manually add this event
    # listener so that we can set setCapture to true and make this listener be called before child click events.
    $audioCanvas[0].addEventListener 'click', =>
      # If drag has happened, don't process other clicks.
      event.stopImmediatePropagation() if @dragHasMoved()

      # Reset drag has moved to allow further clicks.
      @dragHasMoved false
    ,
      true
    
  onDestroyed: ->
    super arguments...
    
    @_audioCanvasResizeObserver?.disconnect()

  nodeComponents: ->
    _.values @nodeComponentsById()

  originStyle: ->
    camera = @camera()
    originInWindow = camera.transformCanvasToWindow x: 0, y: 0

    transform: "translate3d(#{originInWindow.x}px, #{originInWindow.y}px, 0)"

  startDrag: (options) ->
    # Nothing to do if we're already dragging this node (this
    # happens when initiating drag by clicking in the node library).
    return if @dragNodeId() is options.nodeId

    @dragStartCanvasCoordinate = @mouse().canvasCoordinate()
    @dragStartNodePosition = options.nodePosition
    @dragRequireMove options.requireMove
    @dragHasMoved false

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on 'mouseup.pixelartacademy-pixelpad-apps-studyplan-audioCanvas', =>
      # If required to move, don't stop drag until we do so.
      return if @dragRequireMove() and not @dragHasMoved()

      audioLoader = @audioLoader()
      
      # See if we ended up dragging over the trash.
      if @mouseOverTrash()
        # Delete the node.
        audioLoader.removeNode options.nodeId

      else
        # Expand goal if desired.
        audioLoader.changeNodeExpanded options.nodeId, true if options.expandOnEnd
    
        # Save temporary position into the database.
        nodeComponent = @nodeComponentsById()[options.nodeId]
        audioLoader.changeNodePosition options.nodeId, nodeComponent.position()
        nodeComponent.temporaryPosition null

      @dragNodeId null
      $(document).off '.pixelartacademy-pixelpad-apps-studyplan-audioCanvas'

    # Set node component last since it triggers reactivity.
    @dragNodeId options.nodeId

  draggingClass: ->
    'dragging' if @dragNodeId() or @dragCanvas()

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

    # Make sure the connection goes from an input to an output.
    if connection.input and connection.output
      # Disconnect the input if it is already connected. We need to compare to actual connections in the audio
      # engine (and not our modified ones) since the dragged connection might be going from input to output.
      if audioConnections = @audio()?.connections()
        for existingConnection in audioConnections
          if existingConnection.endNodeId is connection.nodeId and existingConnection.input is connection.input
            @audioLoader().removeConnection existingConnection.startNodeId,
              nodeId: existingConnection.endNodeId
              input: existingConnection.input
              output: existingConnection.output
        
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
          @audioLoader().modifyConnection startNodeId, connection, oldConnection

      else
        @audioLoader().addConnection startNodeId, connection

    # End dragging.
    @draggedConnection null

  startHoverInput: (options) ->
    @hoveredInput options

  endHoverInput: ->
    @hoveredInput null

  startHoverOutput: (options) ->
    @hoveredOutput options

  endHoverOutput: ->
    @hoveredOutput null
    
  startDragCanvas: ->
    # Dragging of canvas needs to be handled in display coordinates since the canvas ones should technically stay
    # the same (the whole point is for the same canvas coordinate to stay under the mouse as we move it around).
    return unless @dragStartDisplayCoordinate = @mouse().displayCoordinate()
    @dragCanvas true

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on 'mouseup.landsofillusions-assets-audioeditor-audiocanvas', =>
      $(document).off '.landsofillusions-assets-audioeditor-audiocanvas'

      @dragCanvas false

  events: ->
    super(arguments...).concat
      'mousedown': @onMouseDown
      'mouseup': @onMouseUp

  onMouseDown: (event) ->
    clickOnNode = $(event.target).closest('.landsofillusions-assets-audioeditor-node').length
    dragging = @dragNodeId()
    
    # Reset dragging on any start of clicks when not dragging a goal.
    @dragHasMoved false unless dragging
    
    # We should drag the flowchart if we're not dragging a goal and haven't clicked inside a node.
    @startDragCanvas() unless dragging or clickOnNode
    
    # We should deselect the current node if we click outside the nodes.
    @selectedNodeId null unless clickOnNode

  onMouseUp: (event) ->
    return unless draggedConnection = @draggedConnection()

    # If we were modifying an existing connection, remove it.
    if draggedConnection.endNodeId and draggedConnection.startNodeId
      connection =
        nodeId: draggedConnection.endNodeId
        input: draggedConnection.input
        output: draggedConnection.output

      @audioLoader().removeConnection draggedConnection.startNodeId, connection

    # End connecting.
    @draggedConnection null
