LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.ColorFill2 extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.ColorFill2'

  @displayName: -> "颜色填充工具-第二课"

  @description: -> """
      有时候，先填充像素，再擦除多余的部分，会让你画得更快。
    """

  @fixedDimensions: -> width: 12, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black

  @bitmapString: -> """
      |    0000
      | 000    000
      |0          0
      |0          0
      |000      000
      |   00  00
      |  00 00 00
      |00        00
    """

  @goalBitmapString: -> """
      |    0000
      | 0000000000
      |000000000000
      |000  00  000
      |000000000000
      |   00  00
      |  00 00 00
      |00        00
    """

  @bitmapInfo: -> "出自1978年太东(Taito)开发的《太空侵略者》(Space Invaders)"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Eraser
  ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      使用颜色填充工具和橡皮擦工具，来完成这幅画。
    """
    
    @initialize()
