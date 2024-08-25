LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.Pencil extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.Pencil'

  @displayName: -> "铅笔工具"

  @description: -> """
      学习如何使用画像素画所需的最基本的工具：
      
      1格大小的铅笔工具。
    """

  @fixedDimensions: -> width: 8, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black

  @goalBitmapString: -> """
      |   00
      |  0000
      | 000000
      |00 00 00
      |00000000
      | 0 00 0
      |0      0
      | 0    0
    """

  @bitmapInfo: -> "出自1978年太东(Taito)开发的《太空侵略者》(Space Invaders)"
  
  @initialize()
  
  constructor: ->
    super arguments...
    
    @unlockEraser = new ReactiveField false

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser if @unlockEraser()
  ]
  
  Asset = @
  
  class @Tool extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tool"
    @assetClass: -> Asset
    
    @message: -> """
      点击铅笔来使用它。
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Don't show if we're already done.
      return if asset.completed()
      
      # Show when pencil is not the active tool.
      editor = @getEditor()
      editor.interface.activeToolId() isnt LOI.Assets.SpriteEditor.Tools.Pencil.id()
    
    @initialize()
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
  
    @message: -> """
      用铅笔去涂带点的像素块。
    """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
  
      # Show when pencil is the active tool.
      editor = @getEditor()
      return unless editor.interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.Pencil.id()
    
      # Show until the asset is completed.
      not asset.completed()
      
    @initialize()
    
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      哎呀，你画得太多了！用左侧的橡皮擦来擦掉多余的像素块。
    """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any extra pixels present.
      asset.hasExtraPixels()

    @priority: -> 1
    
    @initialize()
  
    onDisplayed: ->
      # Unlock the eraser.
      asset = @constructor.getActiveAsset()
      asset.unlockEraser true
      
  class @Complete extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
        漂亮！现在回到你的文件夹，去找下一张像素画。
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
