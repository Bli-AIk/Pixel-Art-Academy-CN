LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.VaryingLineWidth extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.VaryingLineWidth"

  @displayName: -> "变化线宽"
  
  @description: -> """
    不是所有的线条都需要一个固定的宽度。
  """
  
  @bitmapInfo: -> """
    出自[《Arclands》](https://arclands.de), 尚未完成

    画师: Jon Keller
  """
  
  @fixedDimensions: -> width: 48, height: 55
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/varyinglinewidth-#{step}.png" for step in [1..2]
  
  @customPaletteImageUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/varyinglinewidth-template.png"
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    # The first step should show invalid pixels even where the colors will add them later.
    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    steps[0].options.canCompleteWithExtraPixels = true
    steps[1].options.hasPixelsWhenInactive = false
    
    # Second step changes the lineart colors of the first step.
    steps[0].options.preserveCompleted = true
  
  Asset = @
  
  class @LineArt extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.LineArt"
    @assetClass: -> Asset
    
    @message: -> """
      出于艺术指导的目的，我们有许多理由来调整线条的宽度，但目前暂时先不深入探讨这一点。\n
      请注意《Arclands》中是如何通过使用2格宽的线条来区分前后层次，并将线条末端逐渐变细的。它还在一些内部细节中使用了1格宽的线条。
    """
  
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show until the asset is completed.
      not asset.completed()
      
    @initialize()
