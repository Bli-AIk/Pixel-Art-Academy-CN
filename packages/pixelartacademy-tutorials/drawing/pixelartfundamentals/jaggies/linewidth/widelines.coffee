LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.WideLines extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.WideLines"

  @displayName: -> "宽线"
  
  @description: -> """
    两格宽的线条能使画出的形状更加清晰明了。
  """
  
  @bitmapInfo: -> """
    出自[《Die in the Dungeon》](https://store.steampowered.com/app/2026820/Die_in_the_Dungeon/), 尚未完成

    画师: Álvaro Farfán
  """
  
  @fixedDimensions: -> width: 33, height: 51
  @backgroundColor: -> new THREE.Color '#b09d87'
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/widelines-#{step}.png" for step in [1..2]
  
  @customPaletteImageUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/widelines-template.png"
  
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
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
  class @LineArt extends @StepInstruction
    @id: -> "#{Asset.id()}.LineArt"
    @stepNumber: -> 1
    
    @message: -> """
      在空间充足的情况下，两格宽的线条使《Die in the Dungeon》中的角色呈现出一种引人注目的卡通风格。\n
      额外的线宽使它更具空间感，同时也保持了细线的柔和感。
    """

    @initialize()

  class @ColoredLines extends @StepInstruction
    @id: -> "#{Asset.id()}.ColoredLines"
    @stepNumber: -> 2
    
    @message: -> """
      《Die in the Dungeon》的艺术风格还使用了深色的轮廓，这将在将来的艺术指导课程中详细探讨。\n
      根据你的想法，重新调整轮廓的颜色。
    """
    
    @initialize()
