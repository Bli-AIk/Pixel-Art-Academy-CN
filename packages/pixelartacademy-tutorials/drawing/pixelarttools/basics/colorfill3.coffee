AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.ColorFill3 extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.ColorFill3'

  @displayName: -> "颜色填充工具-第三课"

  @description: -> """
      使用颜色填充工具时，要留意轮廓中的缺口。
    """

  @fixedDimensions: -> width: 24, height: 18
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black

  @bitmapString: -> """
      |
      |     00000000000000
      |    0              0
      |   0                0
      |  0                  0
      | 0                    0
      | 0
      | 0                    0
      | 0                    0
      | 0                    0
      | 0                    0
      | 0                    0
      | 0      00 0000       0
      | 0     0       0      0
      | 0    0         0     0
      | 0   0           0    0
      | 00000           000000
    """

  @goalBitmapString: -> """
      |
      |     00000000000000
      |    0000000000000000
      |   000000000000000000
      |  00000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000       00000000
      | 000000         0000000
      | 00000           000000
      | 00000           000000
    """

  @bitmapInfo: -> "出自1978年太东(Taito)开发的《太空侵略者》(Space Invaders)"
  
  
  constructor: ->
    super arguments...
    
    @unlockUndo = new ReactiveField false
    
  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Undo if @unlockUndo()
  ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      在使用颜色填充工具之前，先用铅笔工具把轮廓中的缺口堵上。
    """
    
    @initialize()
  
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @priority: -> 1
    
    @toolId: -> throw new AE.NotImplementedException "You must provide which tool was required to produce this error."

    @activeConditions: ->
      return unless asset = @getActiveAsset()
  
      # Show when there are any extra pixels present and the last operation was a color fill.
      return unless asset.hasExtraPixels()
  
      bitmap = asset.bitmap()
      return unless lastAction = bitmap.partialAction or AM.Document.Versioning.getActionAtPosition bitmap, bitmap.historyPosition - 1
      lastAction.operatorId is @toolId()

    onDisplayed: ->
      # Unlock the undo.
      asset = @constructor.getActiveAsset()
      asset.unlockUndo true
      
  class @ColorFillError extends @Error
    @id: -> "#{Asset.id()}.ColorFillError"
    @assetClass: -> Asset
    
    @message: -> """
      坏了，颜色溢到外面去了！快用左边的“撤销”按钮来撤销一下。
    """
    
    @toolId: -> LOI.Assets.SpriteEditor.Tools.ColorFill.id()

    @initialize()
    
  class @PencilError extends @Error
    @id: -> "#{Asset.id()}.PencilError"
    @assetClass: -> Asset
    
    @message: -> """
      你画得太多了！快用左边的“撤销”按钮来撤销一下。
    """
    
    @toolId: -> LOI.Assets.SpriteEditor.Tools.Pencil.id()
    
    @initialize()
