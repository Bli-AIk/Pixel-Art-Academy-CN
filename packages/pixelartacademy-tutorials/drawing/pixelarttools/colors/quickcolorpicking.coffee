LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Colors.QuickColorPicking extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Colors.QuickColorPicking'

  @displayName: -> "快速拾色"

  @description: -> """
      学习如何在使用铅笔工具时快速拾色。

      快捷键：Alt键 / option键
    """

  @fixedDimensions: -> width: 11, height: 12
  @restrictedPaletteName: -> PAA.Tutorials.Drawing.PixelArtTools.Colors.pacManPaletteName
  @backgroundColor: -> LOI.Assets.Palette.defaultPalette()?.color LOI.Assets.Palette.Atari2600.hues.gray, 2

  @bitmapString: -> """
      |
      |  999
      | 1199
      |11111
      |1c111
      |111c1
      |11111
      | 1c11
      | 1111
      |  11c
      |   11
    """

  @goalBitmapString: -> """
      |     c
      |  999c999
      | 119999911
      |111119111c1
      |1c11111c111
      |111c1c11111
      |11111111c11
      | 1c11c1111
      | 111111111
      |  11c11c
      |   11111
      |     1
    """

  @bitmapInfo: -> "出自1980年万代南梦宫(Namco)开发的《吃豆人》(PAC-MAN)"

  availableToolKeys: ->
    Helpers = PAA.Tutorials.Drawing.PixelArtTools.Helpers

    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      PAA.Practice.Software.Tools.ToolKeys.Zoom if Helpers.isAssetCompleted Helpers.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas if Helpers.isAssetCompleted Helpers.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo if Helpers.isAssetCompleted Helpers.UndoRedo
      PAA.Practice.Software.Tools.ToolKeys.Redo if Helpers.isAssetCompleted Helpers.UndoRedo
    ]

  editorStyleClasses: -> 'hidden-color-picker'

  @initialize()
  
  Asset = @
  
  class @Tool extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tool"
    @assetClass: -> Asset
    
    @message: -> """
        选择铅笔工具去画画，
        就像你之前做的那样。
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      not asset.completed()
    
    @completedConditions: ->
      editor = @getEditor()
      editor.interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.Pencil.id()
      
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @priority: -> 1
    
    @initialize()
    
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
        按住 alt/option 键可以
        暂时切换到拾色器，
        直到你松手为止。
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
      
      # Show when the pencil or the color picker are the active tool.
      editor = @getEditor()
      editor.interface.activeToolId() in [LOI.Assets.SpriteEditor.Tools.Pencil.id(), LOI.Assets.SpriteEditor.Tools.ColorPicker.id()]
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @initialize()
  
    onActivate: ->
      super arguments...
      
      editor = @getEditor()
      paintHelper = editor.interface.getHelperForActiveFile LOI.Assets.SpriteEditor.Helpers.Paint
      
      @_initialColorRamp = paintHelper.paletteColor().ramp
  
    completedConditions: ->
      editor = @getEditor()
      paintHelper = editor.interface.getHelperForActiveFile LOI.Assets.SpriteEditor.Helpers.Paint
  
      @_initialColorRamp isnt paintHelper.paletteColor().ramp
