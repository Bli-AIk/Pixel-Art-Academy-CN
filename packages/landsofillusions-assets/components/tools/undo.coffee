AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.Components.Tools.Undo extends LandsOfIllusions.Assets.Components.Tools.Tool
  constructor: ->
    super arguments...

    @name = "撤销"
    @shortcut = AC.Keys.z
    @shortcutCommandOrCtrl = true

  extraToolClasses: ->
    return unless spriteData = @options.editor().spriteData()
    'enabled' if spriteData.historyPosition

  method: ->
    spriteData = @options.editor().spriteData()
    return unless spriteData.historyPosition

    LOI.Assets.VisualAsset.undo 'Sprite', spriteData._id
