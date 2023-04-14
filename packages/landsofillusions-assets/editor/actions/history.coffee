AC = Artificial.Control
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Undo extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Undo'
  @displayName: -> "Undo"

  @initialize()

  enabled: ->
    return unless asset = @asset()
    asset.historyPosition

  execute: ->
    asset = @asset()
    asset.undo()

class LOI.Assets.Editor.Actions.Redo extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Redo'
  @displayName: -> "Redo"
  
  @initialize()

  enabled: ->
    return unless asset = @asset()
    asset.historyPosition < asset.history?.length

  execute: ->
    asset = @asset()
    asset.redo()
