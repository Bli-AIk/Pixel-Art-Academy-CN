AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.Undo extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.Undo'
  @displayName: -> "撤销"

  @initialize()

  enabled: ->
    return unless sprite = @editor().spriteData()
    sprite.historyPosition

  execute: ->
    sprite = @editor().spriteData()
    LOI.Assets.VisualAsset.undo LOI.Assets.Sprite.className, sprite._id

class LOI.Assets.MeshEditor.Actions.Redo extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.Redo'
  @displayName: -> "重做"
      
  @initialize()

  enabled: ->
    return unless sprite = @editor().spriteData()
    sprite.historyPosition < sprite.history?.length

  execute: ->
    sprite = @editor().spriteData()
    LOI.Assets.VisualAsset.redo LOI.Assets.Sprite.className, sprite._id
