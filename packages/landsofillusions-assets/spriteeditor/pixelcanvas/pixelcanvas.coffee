AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.PixelCanvas extends FM.View
  # initialCameraScale: default scale for camera if not specified on the file
  # components: array of helper IDs that should be drawn to context
  #
  # FILE DATA
  # camera:
  #   scale: canvas magnification
  #   origin: the point on the sprite that should appear in the center of the canvas
  #     x
  #     y
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.PixelCanvas'
  @register @id()

  @subscribeToDocumentsForEditorView: (editorView, fileIds) ->
    LOI.Assets.Asset.forIdsFull.subscribe editorView, LOI.Assets.Sprite.className, fileIds

  @getDocumentForEditorView: (editorView, fileId) ->
    LOI.Assets.Sprite.documents.findOne fileId

  constructor: ->
    super arguments...
    
    # Prepare all reactive fields.
    @camera = new ReactiveField null
    @grid = new ReactiveField null
    @mouse = new ReactiveField null
    @cursor = new ReactiveField null
    @sprite = new ReactiveField null
    @spriteId = new ReactiveField null

    @$pixelCanvas = new ReactiveField null
    @canvas = new ReactiveField null
    @canvasPixelSize = new ReactiveField width: 0, height: 0
    @context = new ReactiveField null

  onCreated: ->
    super arguments...

    @display = @callAncestorWith 'display'
    @editorView = @ancestorComponentOfType FM.EditorView

    @componentData = @interface.getComponentData @
    @componentFileData = new ComputedField =>
      @interface.getComponentDataForActiveFile @

    # Initialize components.
    @camera new @constructor.Camera @
    @grid new @constructor.Grid @
    @mouse new @constructor.Mouse @
    @cursor new @constructor.Cursor @

    @toolsActive = new ComputedField =>
      @componentData.get('toolsActive') ? true

    @autorun (computation) =>
      @spriteId @editorView.activeFileData().value().id
      
    @spriteLoader = new ComputedField =>
      return unless spriteId = @spriteId()
      @interface.getLoaderForFile spriteId

    @spriteData = new ComputedField =>
      @spriteLoader().sprite()

    @paintNormalsData = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'paintNormals'

    @lightDirectionHelper = new ComputedField =>
      @interface.getHelperForFile LOI.Assets.SpriteEditor.Helpers.LightDirection, @spriteId()
      
    @sprite new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      visualizeNormals: @paintNormalsData.value

    @pixelCanvasSize = new ReactiveField width: 0, height: 0

    @drawComponents = new ComputedField =>
      return unless componentIds = @componentData.get 'components'

      for componentId in componentIds
        @interface.getHelperForFile componentId, @spriteId()

    # Resize the canvas when browser window and zoom changes.
    @autorun (computation) =>
      canvas = @canvas()
      return unless canvas

      # Resize to component.
      newSize = @pixelCanvasSize()

      # Resize the back buffer to canvas element size, if it actually changed. If the pixel
      # canvas is not actually sized relative to window, we shouldn't force a redraw of the sprite.
      for key, value of newSize
        canvas[key] = value unless canvas[key] is value

      @canvasPixelSize newSize

    # Redraw canvas routine.
    @autorun =>
      return unless context = @context()

      canvasPixelSize = @canvasPixelSize()

      context.setTransform 1, 0, 0, 1, 0, 0
      context.clearRect 0, 0, canvasPixelSize.width, canvasPixelSize.height

      camera = @camera()
      camera.applyTransformToCanvas()

      components = [@sprite(), @grid(), @cursor()]

      if drawComponents = @drawComponents()
        components.push drawComponents...

      lightDirection = @lightDirectionHelper()

      for component in components
        continue unless component

        context.save()
        component.drawToContext context,
          lightDirection: lightDirection
          camera: camera

        context.restore()

  onRendered: ->
    super arguments...

    # DOM has been rendered, initialize.
    $pixelCanvas = @$('.landsofillusions-assets-spriteeditor-pixelcanvas')
    @$pixelCanvas $pixelCanvas

    canvas = $pixelCanvas.find('.canvas')[0]
    @canvas canvas
    @context canvas.getContext '2d'

    @autorun (computation) =>
      # Depend on editor view size.
      AM.Window.clientBounds()

      # Depend on application area changes.
      @interface.currentApplicationAreaData().value()

      # After update, measure the size.
      Tracker.afterFlush =>
        @pixelCanvasSize
          width: $pixelCanvas.width()
          height: $pixelCanvas.height()

    if @toolsActive()
      $(document).on 'keydown.landsofillusions-assets-spriteeditor-pixelcanvas', (event) => @interface.activeTool()?.onKeyDown? event
      $(document).on 'keyup.landsofillusions-assets-spriteeditor-pixelcanvas', (event) => @interface.activeTool()?.onKeyUp? event
      $(document).on 'mouseup.landsofillusions-assets-spriteeditor-pixelcanvas', (event) => @interface.activeTool()?.onMouseUp? event
      $(document).on 'mouseleave.landsofillusions-assets-spriteeditor-pixelcanvas', (event) => @interface.activeTool()?.onMouseLeaveWindow? event

  onDestroyed: ->
    super arguments...

    $(document).off '.landsofillusions-assets-spriteeditor-pixelcanvas'

  # Events

  events: ->
    events = super arguments...

    if @toolsActive()
      events = events.concat
        'mousedown .canvas': @onMouseDownCanvas
        'mousemove .canvas': @onMouseMoveCanvas
        'mouseenter .canvas': @onMouseEnterCanvas
        'mouseleave .canvas': @onMouseLeaveCanvas
        'dragstart .canvas': @onDragStartCanvas

    events

  onMouseDownCanvas: (event) ->
    @interface.activeTool()?.onMouseDown? event

  onMouseMoveCanvas: (event) ->
    @interface.activeTool()?.onMouseMove? event

  onMouseEnterCanvas: (event) ->
    @interface.activeTool()?.onMouseEnter? event

  onMouseLeaveCanvas: (event) ->
    @interface.activeTool()?.onMouseLeave? event

  onDragStartCanvas: (event) ->
    @interface.activeTool()?.onDragStart? event
