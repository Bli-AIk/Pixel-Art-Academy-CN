AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Actions.ToggleDisplayWalls extends Pinball.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.ToggleDisplayWalls'
  @displayName: -> "显示障碍物"

  @initialize()
  
  enabled: -> true
  
  active: -> @pinball.displayWalls()
  
  execute: ->
    @pinball.displayWalls not @pinball.displayWalls()
