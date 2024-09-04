LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.ThinLines extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.ThinLines"

  @displayName: -> "细线"
  
  @description: -> """
    像素画中处处可见的线条，通常占据最少的空间。
  """
  
  @bitmapInfo: -> """
    出自[《Sheep Lad》](https://store.steampowered.com/app/2231820/Sheep_Lad), 尚未完成

    画师: Robin Poe
  """
  
  @fixedDimensions: -> width: 58, height: 36
  @backgroundColor: -> new THREE.Color '#665d5b'
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/thinlines-#{step}.png" for step in [1..3]
  
  @customPaletteImageUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/thinlines-template.png"
  
  @markup: -> true
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    # The steps should show invalid pixels even where the colors will add them later.
    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    steps[0].options.canCompleteWithExtraPixels = true
    steps[1].options.hasPixelsWhenInactive = false
    steps[1].options.canCompleteWithExtraPixels = true
    steps[2].options.hasPixelsWhenInactive = false
    
    # Once you complete the steps, don't return to it if you accidentally recolor some of its pixels later.
    steps[0].options.preserveCompleted = true
    steps[1].options.preserveCompleted = true
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset

  class @StepInstructionWithBleed extends @StepInstruction
    markup: ->
      return unless asset = @getActiveAsset()
      return unless bitmap = asset.bitmap()
      
      markup = []
      
      palette = LOI.palette()
      bleedColor = palette.color Atari2600.hues.gray, 6
      
      addBleedArrow = (x1, y1, x2, y2) ->
        return if bitmap.findPixelAtAbsoluteCoordinates x1, y1
        return if bitmap.findPixelAtAbsoluteCoordinates x2, y2
        
        extension = 0.2
        extensionX = extension * Math.sign x2 - x1
        extensionY = extension * Math.sign y2 - y1
      
        markup.push
          line:
            style: "##{bleedColor.getHexString()}"
            width: 0
            arrow:
              start: true
              end: true
              width: 0.8
              length: 0.4
            points: [
              x: x1 + 0.5 - extensionX
              y: y1 + 0.5 - extensionY
            ,
              x: x2 + 0.5 + extensionX
              y: y2 + 0.5 + extensionY
            ]
            
      addBleedArrow 26, 26, 27, 25
      addBleedArrow 29, 23, 30, 22
      addBleedArrow 36, 22, 37, 23
      
      markup
      
  class @LineArt extends @StepInstruction
    @id: -> "#{Asset.id()}.LineArt"
    @stepNumber: -> 1
    
    @message: -> """
      由于精灵图的尺寸通常比较小，在画像素画时，我们更倾向于使用1格宽的细线，以便为上色和绘制其他细节腾出更多空间。\n 
      细线不仅紧凑，还可以让视线自然地沿着它移动。
    """

    @initialize()

  class @Colors extends @StepInstructionWithBleed
    @id: -> "#{Asset.id()}.Colors"
    @stepNumber: -> 2
    
    @message: -> """
      因为拐角处、斜线衔接处的线条宽度为0像素，这使得细线不能明确地分隔相邻斜线组成的形状，使其中的空间透过空隙相互渗透。\n
      使用不同的颜色可以缓解这个问题。
    """
    
    @initialize()
    
  class @MoreColors extends @StepInstructionWithBleed
    @id: -> "#{Asset.id()}.MoreColors"
    @stepNumber: -> 3
    
    @activeDisplayState: ->
      # We only have markup without a message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
    
    @initialize()
