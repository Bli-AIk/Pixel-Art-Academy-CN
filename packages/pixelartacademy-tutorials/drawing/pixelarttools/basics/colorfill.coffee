LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.ColorFill extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.ColorFill'

  @displayName: -> "颜色填充工具-第一课"

  @description: -> """
      学习如何快速填充大面积的颜色。
    """

  @fixedDimensions: -> width: 13, height: 9
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black

  @bitmapString: -> """
      |      0
      |     0 0
      |     0 0
      |     0 0
      | 00000 00000
      |0           0
      |0           0
      |0           0
      |0000000000000
    """

  @goalBitmapString: -> """
      |      0
      |     000
      |     000
      |     000
      | 00000000000
      |0000000000000
      |0000000000000
      |0000000000000
      |0000000000000
    """

  @bitmapInfo: -> "出自1978年太东(Taito)开发的《太空侵略者》(Space Invaders)"
  
  constructor: ->
    super arguments...
  
    @unlockUndo = new ReactiveField false
    
  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Undo if @unlockUndo()
  ]

  @initialize()
  
  Asset = @
  
  class @Tool extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tool"
    @assetClass: -> Asset
    
    @message: -> """
        点击玻璃杯来使用颜色填充工具。
      """
    
    @activeConditions: ->
      return unless @getActiveAsset()
      
      # Show when color fill is not the active tool.
      editor = @getEditor()
      editor.interface.activeToolId() isnt LOI.Assets.SpriteEditor.Tools.ColorFill.id()
    
    @delayDuration: -> @defaultDelayDuration
    
    @initialize()
    
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      点击像素画，把黑色“泼”到白色的像素上。
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
  
      # Show when color fill is the active tool.
      editor = @getEditor()
      return unless editor.interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.ColorFill.id()
  
      # Show until the asset is completed.
      super arguments...
    
    @initialize()
    
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      哎呦，你填错位置了！快用左边的“撤销”按钮来撤销一下。
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any extra pixels present.
      asset.hasExtraPixels()

    @priority: -> 1
    
    @initialize()
  
    onDisplayed: ->
      # Unlock the undo.
      asset = @constructor.getActiveAsset()
      asset.unlockUndo true
