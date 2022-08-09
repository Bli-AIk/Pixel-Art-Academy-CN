PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Challenges.Drawing.TutorialSprite.EngineComponent
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless spriteData = @options.spriteData()
      return unless spriteData.layers?.length and spriteData.bounds
      return unless spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette._id

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()

    @_render renderOptions

    bounds = @options.spriteData().bounds

    context.imageSmoothingEnabled = false
    context.drawImage @_canvas, bounds.x, bounds.y, bounds.width, bounds.height

  _render: (renderOptions) ->
    spriteData = @options.spriteData()
    palette = spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette._id

    # Hints are ideally 5x smaller dots in the middle of a pixel.
    pixelSize = renderOptions.camera.effectiveScale()
    hintSize = pixelSize / 5

    # Hint size should be at least one pixel big so it's always visible.
    hintSize = Math.max 1, hintSize
    pixelToHintRatio = Math.round pixelSize / hintSize

    # Build a new canvas if needed.
    @_canvas ?= $('<canvas>')[0]

    # Resize the canvas if needed.
    @_canvas.width = spriteData.bounds.width * pixelToHintRatio unless @_canvas.width is spriteData.bounds.width * pixelToHintRatio
    @_canvas.height = spriteData.bounds.height * pixelToHintRatio unless @_canvas.height is spriteData.bounds.height * pixelToHintRatio

    @_context = @_canvas.getContext '2d'
    @_imageData = @_context.getImageData 0, 0, @_canvas.width, @_canvas.height
    @_canvasPixelsCount = @_canvas.width * @_canvas.height

    # Clear the image buffer to transparent.
    @_imageData.data.fill 0

    # If hints would completely cover the pixels, it's better to not draw them.
    return if pixelToHintRatio is 1

    # Draw background dots to all pixels.
    for x in [0...spriteData.bounds.width]
      for y in [0...spriteData.bounds.height]
        @_paintPixel spriteData, x, y, @options.backgroundColor, pixelToHintRatio

    for layer in spriteData.layers
      continue unless layer.pixels

      for pixel in layer.pixels
        if pixel.paletteColor
          shades = palette.ramps[pixel.paletteColor.ramp].shades
          shadeIndex = THREE.Math.clamp pixel.paletteColor.shade, 0, shades.length - 1
          color = shades[shadeIndex]

        else if pixel.directColor
          color = pixel.directColor

        @_paintPixel spriteData, pixel.x, pixel.y, color, pixelToHintRatio

    @_context.putImageData @_imageData, 0, 0

  _paintPixel: (spriteData, pixelX, pixelY, color, pixelToHintRatio) =>
    spritePixelX = pixelX - spriteData.bounds.x
    spritePixelY = pixelY - spriteData.bounds.y

    hintOffset = Math.floor pixelToHintRatio / 2
    x = spritePixelX * pixelToHintRatio + hintOffset
    y = spritePixelY * pixelToHintRatio + hintOffset

    pixelIndex = (x + y * @_canvas.width) * 4

    @_imageData.data[pixelIndex] = color.r * 255
    @_imageData.data[pixelIndex + 1] = color.g * 255
    @_imageData.data[pixelIndex + 2] = color.b * 255
    @_imageData.data[pixelIndex + 3] = 255
