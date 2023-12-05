AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.Step
  constructor: (@tutorialBitmap, @stepArea, @options) ->
    @stepArea.addStep @
  
  completed: -> throw new AE.NotImplementedException "A step has to specify when it has been completed."
  
  hasPixel: -> throw new AE.NotImplementedException "A step has to specify if it requires a specific pixel for its completion."
  
  solve: -> throw new AE.NotImplementedException "A step has to provide a method to solve itself to a completed state."
  
  activate: ->
    return unless @options.startPixels
    
    # Add start pixels.
    bitmap = @tutorialBitmap.bitmap()
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [0], @options.startPixels.pixels()
    
    # If this activation happened as part of a user action, append the new pixels to that action.
    appendToLastAction = bitmap.historyPosition > 0
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date, appendToLastAction

    # If this was the initial step, make it appear as if the bitmap started with these pixels.
    AM.Document.Versioning.clearHistory bitmap unless appendToLastAction
  
  drawUnderlyingHints: (context, renderOptions = {}) -> # Override to draw hints under the bitmap.
  drawOverlaidHints: (context, renderOptions = {}) -> # Override to draw hints over the bitmap.
  
  _preparePixelHintSize: (renderOptions) ->
    # Hints are ideally 5x smaller dots in the middle of a pixel.
    pixelSize = renderOptions.camera.effectiveScale()
    hintSize = Math.ceil pixelSize / 5
    offset = Math.floor (pixelSize - hintSize) / 2
    
    # We need to store sizes relative to the pixel.
    @_pixelHintSize = hintSize / pixelSize
    @_pixelHintOffset = offset / pixelSize
    
    # If pixel is less than 2 big, we should lower the opacity of the hint to mimic less coverage.
    @_pixelHintOpacity = if pixelSize < 2 then pixelSize / 5 else 1
  
  _drawPixelHint: (context, x, y, color) ->
    absoluteX = x + @stepArea.bounds.x + @_pixelHintOffset
    absoluteY = y + @stepArea.bounds.y + @_pixelHintOffset
    
    if color
      context.fillStyle = "rgba(#{color.r * 255}, #{color.g * 255}, #{color.b * 255}, #{@_pixelHintOpacity})"
      context.fillRect absoluteX, absoluteY, @_pixelHintSize, @_pixelHintSize
    
    else
      context.clearRect absoluteX, absoluteY, @_pixelHintSize, @_pixelHintSize
