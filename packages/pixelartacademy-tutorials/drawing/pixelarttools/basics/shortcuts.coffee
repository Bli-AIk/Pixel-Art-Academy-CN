LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.Shortcuts extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.Shortcuts'

  @displayName: -> "快捷键"

  @description: -> """
      高效的像素画师，会利用快捷键来切换工具。

      - B键: 铅笔工具 (或画笔工具)
      - E键: 橡皮擦工具
      - G键: 颜色填充工具 (或渐变工具)
    """

  @fixedDimensions: -> width: 12, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black

  @bitmapString: -> """
      |
      |
      |  00000000
      | 0        0
      |0          0
      |000000000000
    """

  @goalBitmapString: -> """
      |  0      0
      |   0    0
      |  00000000
      | 00 0000 00
      |000000000000
      |0 00000000 0
      |0 0      0 0
      |   00  00
    """

  @bitmapInfo: -> "出自1978年太东(Taito)开发的《太空侵略者》(Space Invaders)"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
  ]

  editorStyleClasses: -> 'hidden-tools'

  @initialize()

  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
  
    @message: -> """
      - B键: 铅笔工具
      - E键: 橡皮擦工具
      - G键: 颜色填充工具
    """
  
    @activeConditions: ->
      return unless asset = @getActiveAsset()
    
      # Show until the asset is completed.
      not asset.completed()
  
    @activeDisplayState: ->
      # Show this tip closed.
      PAA.PixelPad.Systems.Instructions.DisplayState.Closed
      
    @delayDuration: -> 3
  
    @resetDelayOnOperationExecuted: -> true
    
    @initialize()
    
    onOperationExecuted: (document, operation, changedFields) ->
      return unless document._id is @bitmapId
      
      # Don't reset the delay anymore once it has ran out so that when shortcuts are shown they don't disappear anymore.
      return unless @delayed()
      
      @resetDelay()
