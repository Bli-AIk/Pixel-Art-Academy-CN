AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Interface.Actions.Quit extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Interface.Actions.Quit'
  @displayName: -> "退出"

  @initialize()
  
  enabled: ->
    # We can perform a quit action when we have an active program.
    @os.activeProgram()
  
  execute: ->
    @os.unloadProgram @os.activeProgram()
