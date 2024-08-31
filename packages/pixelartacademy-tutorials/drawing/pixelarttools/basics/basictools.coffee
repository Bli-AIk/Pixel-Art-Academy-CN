LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.BasicTools extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.BasicTools'

  @displayName: -> "基础工具-组合使用"

  @description: -> """
      现在你已经学会使用这三个最基础的工具啦，结合着使用它们，可以帮助你更快地绘制你的像素画。
    """

  @fixedDimensions: -> width: 16, height: 7
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black

  @bitmapString: -> """
      |     000000
      |   00      00
      |  0          0
      | 0            0
      |0000000000000000
    """

  @goalBitmapString: -> """
      |     000000
      |   0000000000
      |  000000000000
      | 00 00 00 00 00
      |0000000000000000
      |  000  00  000
      |   0        0
    """

  @bitmapInfo: -> "出自1978年太东(Taito)开发的《太空侵略者》(Space Invaders)"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
  ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
  
    @message: -> """
      结合着使用铅笔工具、颜色填充工具和橡皮擦工具，展示一下你使用这三种基础工具的成果吧。
    """
    
    @initialize()
