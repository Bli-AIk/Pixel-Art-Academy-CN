LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.ThickLines extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.ThickLines"

  @displayName: -> "粗线"
  
  @description: -> """
    使用较粗的线条能够更清楚地分隔形状，但它会占用更多空间。
  """
  
  @bitmapInfo: -> """
    出自[《64x64 rpg》](https://castpixel.artstation.com/projects/0XOaE8), 2019年

    画师: Christina 'castpixel' Neofotistou
  """
  
  @fixedDimensions: -> width: 36, height: 53
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/thicklines-#{step}.png" for step in [1..2]
  
  @customPaletteImageUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/thicklines-template.png"
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    # The first step should show invalid pixels even where the colors will add them later.
    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    steps[0].options.canCompleteWithExtraPixels = true
    steps[1].options.hasPixelsWhenInactive = false
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
  class @LineArt extends @StepInstruction
    @id: -> "#{Asset.id()}.LineArt"
    @stepNumber: -> 1
    
    @message: -> """
      1格宽的粗线能够确保每个形状之间始终有至少1像素的间隔。\n
      它能使每个形状的边界和重叠部分更加清晰，但这也需要更多的空间，外观上也会更加显眼。
    """

    @initialize()
