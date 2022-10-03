AC = Artificial.Control
AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.PixelCanvas.Camera
  constructor: (@pixelCanvas, options) ->
    @cameraData = new ComputedField =>
      @pixelCanvas.interface.getActiveFileData()?.child 'camera'

    @scaleData = new ComputedField =>
      @cameraData()?.child 'scale'

    # At camera scale 1, a canvas pixel matches a display pixel (and not window pixel).
    # Scale is used to go from canvas pixels to display pixels.
    @scale = new ComputedField =>
      @scaleData()?.value() or @pixelCanvas.initialCameraScale() or 1

    # Effective scale includes the amount we're scaling our display pixels.
    # It is used to go from canvas pixels to window pixels.
    @effectiveScale = new ComputedField =>
      displayScale = @pixelCanvas.display.scale()
      @scale() * displayScale

    @scrollingEnabled = new ComputedField =>
      @pixelCanvas.scrollingEnabled()
      
    @originData = new ComputedField =>
      @cameraData()?.child 'origin'

    @origin = new ComputedField =>
      @originData()?.value() or x: 0, y: 0
    ,
      EJSON.equals

    # Calculate various bounds.
    @assetBounds = new AE.Rectangle()
    @drawingAreaBounds = new AE.Rectangle()
    @pixelCanvasBounds = new AE.Rectangle()
    @renderableBounds = new AE.Rectangle()
    @viewportBounds = new AE.Rectangle()
    @drawingAreaWindowBounds = new AE.Rectangle()
    @canvasWindowBounds = new AE.Rectangle()

    @pixelCanvas.autorun =>
      # Asset bounds are directly copied from the asset.
      return unless assetData = @pixelCanvas.assetData()
      
      @assetBounds.copy assetData.bounds
     
      # Calculate drawing area bounds in canvas coordinates.
      displayMode = @pixelCanvas.displayMode()
      
      if assetData.bounds.fixed or displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        # When the asset bounds are fixed, or if we're drawing the full canvas, the drawing area matches it directly.
        @drawingAreaBounds.copy assetData.bounds
      
      else if displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Framed
        # When the asset bounds are freeform and we need to frame the drawing, we make the drawing area 50% bigger than the existing asset bounds.
        verticalFreeformBorder = (assetData.bounds?.width or 128) * 0.25
        horizontalFreeformBorder = (assetData.bounds?.height or 128) * 0.25
        
        @drawingAreaBounds.copy(assetData.bounds).extrude verticalFreeformBorder, horizontalFreeformBorder
        
      else
        # Without the frame, the drawing area extends into infinity.
        @drawingAreaBounds.left Number.NEGATIVE_INFINITY
        @drawingAreaBounds.top Number.NEGATIVE_INFINITY
        @drawingAreaBounds.right Number.POSITIVE_INFINITY
        @drawingAreaBounds.bottom Number.POSITIVE_INFINITY
        
      if displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        # When the full canvas is rendered, pixel canvas is assumed to fully cover it.
        @pixelCanvasBounds.copy assetData.bounds
        @renderableBounds.copy assetData.bounds
      
      else
        # Calculate the size of the parent pixel canvas in canvas coordinates.
        pixelCanvasWindowSize = @pixelCanvas.windowSize()
        effectiveScale = @effectiveScale()
        width = pixelCanvasWindowSize.width / effectiveScale
        height = pixelCanvasWindowSize.height / effectiveScale
        origin = @origin()
      
        @pixelCanvasBounds.width width
        @pixelCanvasBounds.height height
        @pixelCanvasBounds.x origin.x - width / 2
        @pixelCanvasBounds.y origin.y - height / 2
    
        # Renderable bounds need to overextend the pixel canvas area to prevent the canvas being cut-off during transitions.
        extrudeScale = 0.5
        @renderableBounds.copy(@pixelCanvasBounds).extrude width * extrudeScale, height * extrudeScale

      # Viewport bounds are the intersection of the pixel canvas bounds and the drawing area bounds.
      @viewportBounds.copy(@renderableBounds).intersect @drawingAreaBounds
    
      if displayMode is LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        effectiveScale = @effectiveScale()
        @drawingAreaWindowBounds.x 0
        @drawingAreaWindowBounds.y 0
        @drawingAreaWindowBounds.width assetData.bounds.width * effectiveScale
        @drawingAreaWindowBounds.height assetData.bounds.height * effectiveScale
  
        @canvasWindowBounds.copy @drawingAreaWindowBounds
        
      else
        # Calculate the bounds of the drawing area in window coordinates relative to the pixel canvas center.
        drawingAreaTopLeft = @transformCanvasToWindowCenter x: @drawingAreaBounds.left(), y: @drawingAreaBounds.top()
        drawingAreaBottomRight = @transformCanvasToWindowCenter x: @drawingAreaBounds.right(), y: @drawingAreaBounds.bottom()
        
        @drawingAreaWindowBounds.copy
          left: drawingAreaTopLeft.x
          top: drawingAreaTopLeft.y
          right: drawingAreaBottomRight.x
          bottom: drawingAreaBottomRight.y
    
        # Calculate the bounds of the canvas in window coordinates relative to the drawing area top left corner.
        canvasTopLeft = @transformCanvasToWindowCenter x: @viewportBounds.left(), y: @viewportBounds.top()
        canvasBottomRight = @transformCanvasToWindowCenter x: @viewportBounds.right(), y: @viewportBounds.bottom()

        # Fit the transformed coordinates and add extra padding to the size for the outer grid line.
        @canvasWindowBounds.copy
          left: canvasTopLeft.x - drawingAreaTopLeft.x
          top: canvasTopLeft.y - drawingAreaTopLeft.y
          right: canvasBottomRight.x - drawingAreaTopLeft.x + 2
          bottom: canvasBottomRight.y - drawingAreaTopLeft.y + 2
          
    # Enable panning with scrolling.
    @pixelCanvas.autorun (computation) =>
      # Wire up mouse wheel event once the sprite editor is rendered.
      $parent = options.$parent()
      return unless $parent

      scrollingEnabled = @scrollingEnabled()
      
      if scrollingEnabled and not @_scrollingFunction
        # Enable the wheel event.
        @_scrollingFunction = (event) => @_onWheel event
        $parent.on 'wheel', @_scrollingFunction
        
      else if @_scrollingFunction and not scrollingEnabled
        # Disable the wheel event.
        $parent.off 'wheel', @_scrollingFunction
    
  _onWheel: (event) ->
    event.preventDefault()

    effectiveScale = @effectiveScale()

    if event.ctrlKey
      # User is zooming in/out.
      delta = event.originalEvent.deltaY

      scale = @scale()
      scaleChange = Math.pow(0.99, delta)

      @setScale scale * scaleChange

      # Also move the origin, depending on how much off-center we were zooming.
      canvasOrigin = $parent.offset()

      mouseWindowCoordinate =
        x: event.originalEvent.pageX - canvasOrigin.left
        y: event.originalEvent.pageY - canvasOrigin.top

      mouseCanvasCoordinate = @transformWindowToCanvas mouseWindowCoordinate

      oldOrigin = @origin()

      offCenter =
        x: mouseCanvasCoordinate.x - oldOrigin.x
        y: mouseCanvasCoordinate.y - oldOrigin.y

      @originData().value
        x: oldOrigin.x + offCenter.x * (scaleChange - 1)
        y: oldOrigin.y + offCenter.y * (scaleChange - 1)

    else
      # User is translating.

      windowDelta =
        x: event.originalEvent.deltaX
        y: event.originalEvent.deltaY

      canvasDelta =
        x: windowDelta.x / effectiveScale
        y: windowDelta.y / effectiveScale

      oldOrigin = @origin()

      @originData().value
        x: oldOrigin.x + canvasDelta.x
        y: oldOrigin.y + canvasDelta.y

  setScale: (scale) ->
    @scaleData().value scale

  setOrigin: (origin) ->
    @originData().value origin

  applyTransformToCanvas: ->
    context = @pixelCanvas.context()
    effectiveScale = @effectiveScale()

    # Start from the identity.
    context.setTransform 1, 0, 0, 1, 0, 0

    # Scale the canvas around the origin.
    context.scale effectiveScale, effectiveScale

    # Move to viewport corner.
    translateX = Math.floor(@viewportBounds.x() * effectiveScale) / effectiveScale
    translateY = Math.floor(@viewportBounds.y() * effectiveScale) / effectiveScale
    context.translate -translateX, -translateY

  transformCanvasToWindow: (canvasCoordinate) ->
    windowCoordinateCenter = @transformCanvasToWindowCenter canvasCoordinate
  
    pixelCanvasWindowSize = @pixelCanvas.windowSize()
    width = pixelCanvasWindowSize.width
    height = pixelCanvasWindowSize.height
    
    windowCoordinateCenter.x += width / 2
    windowCoordinateCenter.y += height / 2
  
    windowCoordinateCenter
  
  transformCanvasToWindowCenter: (canvasCoordinate) ->
    effectiveScale = @effectiveScale()
    origin = @origin()
  
    x = canvasCoordinate.x
    y = canvasCoordinate.y
  
    x: (x - origin.x) * effectiveScale
    y: (y - origin.y) * effectiveScale

  transformCanvasToDisplay: (canvasCoordinate) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    displayScale = @pixelCanvas.display.scale()

    x: windowCoordinate.x / displayScale
    y: windowCoordinate.y / displayScale

  transformWindowToCanvas: (windowCoordinate) ->
    pixelCanvasWindowSize = @pixelCanvas.windowSize()
    effectiveScale = @effectiveScale()
    origin = @origin()

    x = windowCoordinate.x
    y = windowCoordinate.y
    width = pixelCanvasWindowSize.width
    height = pixelCanvasWindowSize.height

    x: (x - width / 2) / effectiveScale + origin.x
    y: (y - height / 2) / effectiveScale + origin.y

  transformDisplayToCanvas: (displayCoordinate) ->
    displayScale = @pixelCanvas.display.scale()

    windowCoordinate =
      x: displayCoordinate.x * displayScale
      y: displayCoordinate.y * displayScale

    @transformWindowToCanvas windowCoordinate

  roundCanvasToWindowPixel: (canvasCoordinate) ->
    windowCoordinate = @transformCanvasToWindow canvasCoordinate
    pixelPerfectWindowCoordinate =
      x: Math.floor(windowCoordinate.x) + 0.5
      y: Math.floor(windowCoordinate.y) + 0.5

    @transformWindowToCanvas pixelPerfectWindowCoordinate
