LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.Eraser extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.Eraser'

  @displayName: -> "橡皮擦工具"

  @description: -> """
      如你所想，橡皮擦非常适合擦去多余的像素块。
    """

  @fixedDimensions: -> width: 8, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black

  @bitmapString: -> """
      00000000
      00000000
      00000000
      00000000
      00000000
      00000000
      00000000
      00000000
    """

  @goalBitmapString: -> """
      |   00
      |  0000
      | 000000
      |00 00 00
      |00000000
      |  0  0
      | 0 00 0
      |0 0  0 0
    """

  @bitmapInfo: -> "出自1978年太东(Taito)开发的《太空侵略者》(Space Invaders)"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
  ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      用橡皮擦来擦掉带点的像素块。
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when asset has extra pixels so that we don't display it when there are missing pixels.
      asset.hasExtraPixels()
    
    @initialize()

  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      你擦过头了！用铅笔把它画回来。
    """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any missing pixels present.
      asset.hasMissingPixels()

    @priority: -> 1
    
    @initialize()
    
  class @Complete extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
        你做的好啊！继续去把接下来的几张像素画画完，以完成基础工具教程。
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
