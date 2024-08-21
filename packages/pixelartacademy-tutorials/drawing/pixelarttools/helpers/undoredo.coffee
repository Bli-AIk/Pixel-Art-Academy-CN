LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Helpers.UndoRedo extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Helpers.UndoRedo'

  @displayName: -> "撤销 / 重做"

  @description: -> """
      数码时代的画师们最大的优势之一
      就是随时能吃后悔药。
      
      快捷键：
      - Cmd / ctrl键 + Z键: 撤销
      - Cmd / ctrl键 + Y键: 重做
      - Cmd / ctrl键 + shift键 + Z键: 重做
    """

  @fixedDimensions: -> width: 59, height: 59
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black
  @minClipboardScale: -> 1
  @maxClipboardScale: -> 1

  @imageUrl: ->
    "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/codemasters.png"

  @goalImageUrl: ->
    "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/codemasters-goal.png"

  @bitmapInfo: -> "出自1989年Codemasters开发的《Fast Food》(ZX Spectrum版)的加载画面中的标志。"

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
    PAA.Practice.Software.Tools.ToolKeys.Undo
    PAA.Practice.Software.Tools.ToolKeys.Redo
  ]
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      完成 CodeMasters Logo 上的抖动图案。
    """
    
    @initialize()
  
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      哎呀！用铅笔工具下方的撤销键来重回正轨。
      
      快捷键：
      - Cmd / ctrl键 + Z键: 撤销
      - Cmd / ctrl键 + Y键: 重做
      - Cmd / ctrl键 + shift键 + Z键: 重做
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any extra pixels present.
      asset.hasExtraPixels()
    
    @priority: -> 1
    
    @initialize()
