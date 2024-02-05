AE = Artificial.Everywhere
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

if Meteor.isClient
  require 'path-data-polyfill/path-data-polyfill.js'

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.PathStep.Path
  @minimumAntiAliasingAlpha = 10
  @minimumRequiredPixelAlpha = 250
  
  constructor: (@tutorialBitmap, @pathStep, svgPath) ->
    @canvas = new AM.ReadableCanvas @tutorialBitmap.width(), @tutorialBitmap.height()
    @canvas.context.translate offset.x, offset.y if offset = @pathStep.stepArea.bounds
    
    @path = new Path2D svgPath.getAttribute 'd'
    style = svgPath.getAttribute 'style'
    
    fillColorString = style.match(/fill:(.*?);/)?[1]
    @filled = fillColorString and fillColorString isnt 'none'
    
    # Rasterize the path to the canvas.
    @canvas.context.lineCap = 'round'
    @canvas.context.lineWidth = @pathStep.options.tolerance * 2

    if @filled
      @canvas.context.fill @path

      # Reduce the size of the required filled area by the tolerance
      if @pathStep.options.tolerance
        @canvas.context.globalCompositeOperation = 'destination-out'
        @canvas.context.stroke @path
        @canvas.context.globalCompositeOperation = 'source-over'
      
    # When we have tolerance, draw the lines slightly lighter than
    # required so that none of their pixels are directly required.
    @canvas.context.strokeStyle = "rgb(0 0 0 / #{(@constructor.minimumRequiredPixelAlpha - 10) / 255})" if @pathStep.options.tolerance
    @canvas.context.stroke @path
    
    @_imageData = @canvas.getFullImageData()
    
    @pathBounds =
      left: Number.POSITIVE_INFINITY
      right: Number.NEGATIVE_INFINITY
      top: Number.POSITIVE_INFINITY
      bottom: Number.NEGATIVE_INFINITY
    
    for x in [0...@canvas.width]
      for y in [0...@canvas.height]
        pixelIndex = x + y * @_imageData.width
        alpha = @_imageData.data[pixelIndex * 4 + 3]
        
        if alpha < @constructor.minimumAntiAliasingAlpha
          @_imageData.data[pixelIndex * 4 + 3] = 0
          
        else
          @pathBounds.left = Math.min @pathBounds.left, x
          @pathBounds.right = Math.max @pathBounds.right, x
          @pathBounds.top = Math.min @pathBounds.top, y
          @pathBounds.bottom = Math.max @pathBounds.bottom, y
          
          # Turn anti-aliased pixels blue and required green for debugging purposes.
          channelOffset = if alpha >= @constructor.minimumRequiredPixelAlpha then 1 else 2
          @_imageData.data[pixelIndex * 4 + channelOffset] = 255
          
          # Make allowed pixels more visible, but don't change their
          # upper end since that's used for detecting required pixels.
          @_imageData.data[pixelIndex * 4 + 3] = Math.max 128, alpha
    
    @pathBounds.width = @pathBounds.right - @pathBounds.left + 1
    @pathBounds.height = @pathBounds.bottom - @pathBounds.top + 1
    
    # Calculate positions of corner points.
    @cornersOfParts = []
    pathData = svgPath.getPathData normalize: true
    
    currentCornersOfPart = null
    cornerMaxOffset = @pathStep.options.tolerance
    cornerAlpha = if @pathStep.options.tolerance then @constructor.minimumRequiredPixelAlpha - 10 else 255

    addCorner = (x, y) =>
      if offset
        x += offset.x
        y += offset.y
        
      x = Math.floor x
      y = Math.floor y
      
      currentCornersOfPart.push {x, y}

      # Turn corners red for debugging purposes.
      for dx in [-cornerMaxOffset..cornerMaxOffset]
        for dy in [-cornerMaxOffset..cornerMaxOffset]
          pixelIndex = x + dx + (y + dy) * @_imageData.width
          @_imageData.data[pixelIndex * 4] = 255
          @_imageData.data[pixelIndex * 4 + 1] = 0
          @_imageData.data[pixelIndex * 4 + 2] = 0
      
      # HACK: Electron's Chrome produces different rasterization results that
      # sometimes leave ends unpainted, so we force them to have alpha here.
      @_imageData.data[pixelIndex * 4 + 3] = cornerAlpha
    
    for segment in pathData
      if segment.type is 'M'
        @cornersOfParts.push currentCornersOfPart if currentCornersOfPart
        currentCornersOfPart = []
      
      switch segment.type
        when 'M', 'L'
          addCorner segment.values[0], segment.values[1]
          
        when 'C'
          addCorner segment.values[4], segment.values[5]
    
    @cornersOfParts.push currentCornersOfPart
    
    @canvas.putFullImageData @_imageData
  
  _getPixelAlpha: (x, y) ->
    pixelIndex = x + y * @_imageData.width
    @_imageData.data[pixelIndex * 4 + 3]
    
  hasPixel: (x, y) ->
    @_getPixelAlpha x, y
    
  completed: ->
    # Store completed locally to know whether to draw the hint.
    @_completed = false
    
    # Make sure all corners are covered.
    return unless bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]

    for cornersForPart in @cornersOfParts
      for corner in cornersForPart
        corner.foundCoveredPixelPositions = []
        
        if @pathStep.options.tolerance
          # Try to find a pixel in increasing offset levels.
          for maxOffset in [0..@pathStep.options.tolerance]
            for dx in [-maxOffset..maxOffset]
              for dy in [-maxOffset..maxOffset]
                x = corner.x + dx
                y = corner.y + dy
                if @hasPixel(x, y) and bitmapLayer.getPixel x, y
                  corner.foundCoveredPixelPositions.push {x, y}
          
          return false unless corner.foundCoveredPixelPositions.length
        
        else
          return false unless bitmapLayer.getPixel corner.x, corner.y
          corner.foundCoveredPixelPositions = [corner]
        
    # See which pixels have been covered in the allowed area.
    pixelCoverage = new Uint8Array bitmapLayer.width * bitmapLayer.height * 2
    
    coveredPixelsCount = 0
    
    coverPixel = (x, y) =>
      pixelIndex = x + y * bitmapLayer.width
      pixelCoverage[pixelIndex * 2] = 1
      coveredPixelsCount++
      
    for x in [0...bitmapLayer.width]
      for y in [0...bitmapLayer.height] when pixelAlpha = @_getPixelAlpha x, y
        # Tolerance of 0 requires all required area to be drawn (at least in the vicinity for anti-aliased pixel).
        # Higher tolerances don't have this requirement to allow for own interpretation, but still require pixels in
        # fully-filled areas (above minimum alpha for required pixels).
        unless @pathStep.options.tolerance and pixelAlpha < @constructor.minimumRequiredPixelAlpha
          found = false
          
          # Allow anti-aliased pixels to be covered from immediate neighbors.
          maxOffset = if pixelAlpha >= @constructor.minimumRequiredPixelAlpha then 0 else 1
          
          for dx in [-maxOffset..maxOffset]
            for dy in [-maxOffset..maxOffset]
              if @hasPixel(x + dx, y + dy) and bitmapLayer.getPixel x + dx, y + dy
                found = true
                break
            break if found
          
          return false unless found
          
        coverPixel x, y if bitmapLayer.getPixel x, y
      
    # Make sure all covered pixels of parts are connected together.
    visitPixel = (x, y) =>
      # Return if we've already visited this pixel.
      pixelIndex = x + y * bitmapLayer.width
      return if pixelCoverage[pixelIndex * 2 + 1] > 0

      # Return if this pixel wasn't covered.
      return if pixelCoverage[pixelIndex * 2] is 0
      
      # Mark that we've visited this pixel.
      pixelCoverage[pixelIndex * 2 + 1] = 1
      
      # Visit all neighbors.
      # Note: We need unique variables and not use dx, dy since those are
      # scoped to the outer method and not redeclared for each call of recursion.
      for neighborDx in [-1..1]
        for neighborDy in [-1..1]
          continue if neighborDx is 0 and neighborDy is 0

          neighborX = x + neighborDx
          neighborY = y + neighborDy
          
          continue unless @hasPixel neighborX, neighborY

          visitPixel neighborX, neighborY
      
      # Prevent collection of results from the loops.
      return
      
    pixelVisited = (x, y) =>
      pixelIndex = x + y * bitmapLayer.width
      pixelCoverage[pixelIndex * 2 + 1]
    
    for cornersForPart in @cornersOfParts
      # Visit pixels from the initial corners.
      for position in cornersForPart[0].foundCoveredPixelPositions
        visitPixel position.x, position.y
      
      for corner in cornersForPart
        # Find at least one of the positions that is covered.
        found = false
        for position in corner.foundCoveredPixelPositions
          if pixelVisited position.x, position.y
            found = true
            break
        return false unless found
    
    @_completed = true
    @_completed
  
  drawUnderlyingHints: (context, renderOptions) ->
    # Determine if the path is even visible on the canvas.
    visibleBoundsLeft = Math.floor Math.max renderOptions.camera.viewportCanvasBounds.left(), @pathBounds.left
    visibleBoundsRight = Math.ceil Math.min renderOptions.camera.viewportCanvasBounds.right(), @pathBounds.right
    visibleBoundsTop = Math.floor Math.max renderOptions.camera.viewportCanvasBounds.top(), @pathBounds.top
    visibleBoundsBottom = Math.ceil Math.min renderOptions.camera.viewportCanvasBounds.bottom(), @pathBounds.bottom
    visibleBoundsWidth = visibleBoundsRight - visibleBoundsLeft + 1
    visibleBoundsHeight = visibleBoundsBottom - visibleBoundsTop + 1
    
    # Note: We have to allow 0 width and height for vertical and horizontal lines at integer positions.
    return if visibleBoundsWidth < 0 or visibleBoundsHeight < 0
    
    # Completed lines draw much fainter if we're not supposed to draw hints after completion.
    if @_completed and not @pathStep.options.drawHintsAfterCompleted
      initialStrokeStyle = context.strokeStyle
      pathOpacity = Math.min 0.25, renderOptions.camera.scale() / 32
      context.strokeStyle = "hsl(0 0% 50% / #{pathOpacity})"
      
    context.stroke @path

    if @filled
      context.save()
      context.clip @path

      context.beginPath()
      
      height = visibleBoundsBottom - visibleBoundsTop
      pixelSize = 1 / renderOptions.camera.effectiveScale()
      spacing = Math.max 5 * pixelSize, 1 / 3
      
      for x in [visibleBoundsLeft - height...visibleBoundsRight] by spacing
        context.moveTo x, visibleBoundsTop
        context.lineTo x + height, visibleBoundsTop + height
      
      context.stroke()
      context.restore()
      
    context.strokeStyle = initialStrokeStyle if initialStrokeStyle
