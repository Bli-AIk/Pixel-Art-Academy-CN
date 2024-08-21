LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Colors.ColorSwatches extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Colors.ColorSwatches'

  @displayName: -> "调色板"

  @description: -> """
      画一张五彩缤纷的像素画。
    """

  @fixedDimensions: -> width: 14, height: 14
  @restrictedPaletteName: -> PAA.Tutorials.Drawing.PixelArtTools.Colors.pacManPaletteName
  @backgroundColor: -> LOI.Assets.Palette.defaultPalette()?.color LOI.Assets.Palette.Atari2600.hues.gray, 2

  @goalBitmapString: -> """
      |     4444
      |   44444444
      |  4444444444
      | 444cc4444cc4
      | 44cccc44cccc
      | 44cc8844cc88
      |444cc8844cc884
      |4444cc4444cc44
      |44444444444444
      |44444444444444
      |44444444444444
      |44444444444444
      |4444 4444 4444
      | 44   44   44
    """

  @bitmapInfo: -> "出自1980年万代南梦宫(Namco)开发的《吃豆人》(PAC-MAN)"

  availableToolKeys: ->
    Helpers = PAA.Tutorials.Drawing.PixelArtTools.Helpers

    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
      PAA.Practice.Software.Tools.ToolKeys.Zoom if Helpers.isAssetCompleted Helpers.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas if Helpers.isAssetCompleted Helpers.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo if Helpers.isAssetCompleted Helpers.UndoRedo
      PAA.Practice.Software.Tools.ToolKeys.Redo if Helpers.isAssetCompleted Helpers.UndoRedo
    ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      使用调色板来更换颜色。
    """
    
    @initialize()
