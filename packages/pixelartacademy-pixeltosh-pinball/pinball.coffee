FM = FataMorgana
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Pinball extends PAA.Pixeltosh.Program
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball'
  @register @id()
  
  @version: -> '0.1.0'
  
  @fullName: -> "Pinball Creation Kit"
  @description: ->
    "
      A do-it-yourself Pinball game.
    "
  
  @programSlug: -> 'pinball'
  
  @initialize()
  
  load: ->
    @os.addWindow
      type: PAA.Pixeltosh.Program.View.id()
      programId: PAA.Pixeltosh.Programs.Pinball.id()
      top: 14
      left: 0
      right: 0
      bottom: 0
      contentArea:
        type: FM.SplitView.id()
        fixed: true
        dockSide: FM.SplitView.DockSide.Left
        mainArea:
          contentComponentId: @constructor.Interface.Playfield.id()
          width: 180
        remainingArea:
          type: FM.SplitView.id()
          fixed: true
          dockSide: FM.SplitView.DockSide.Top
          mainArea:
            contentComponentId: @constructor.Interface.Backbox.id()
            height: 140
          remainingArea:
            contentComponentId: @constructor.Interface.Instructions.id()
  
  menuItems: -> [
    caption: ''
    items: []
  ,
    caption: 'File'
    items: [
      PAA.Pixeltosh.OS.Interface.Actions.Quit.id()
    ]
  ]
