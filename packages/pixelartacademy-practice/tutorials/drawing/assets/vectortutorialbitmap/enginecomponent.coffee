PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap.EngineComponent
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless @options.svgPaths()

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()
    
    pixelSize = 1 / renderOptions.camera.effectiveScale()
    
    svgPaths = @options.svgPaths()
    currentActivePathIndex = @options.currentActivePathIndex()
    
    context.save()
    halfPixelSize = pixelSize / 2
    context.translate halfPixelSize, halfPixelSize

    context.lineWidth = pixelSize
    
    # Determine path opacity.
    pathOpacity = Math.min 1, renderOptions.camera.scale()
    context.strokeStyle = "rgba(128,128,128,#{pathOpacity})"
    
    for pathIndex in [0..currentActivePathIndex]
      path = new Path2D svgPaths[pathIndex].getAttribute 'd'
      context.stroke path

    context.restore()
