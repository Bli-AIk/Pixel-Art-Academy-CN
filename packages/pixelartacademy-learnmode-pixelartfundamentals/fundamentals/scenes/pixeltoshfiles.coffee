LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.PixeltoshFiles extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.PixeltoshFiles'

  @location: -> PAA.Pixeltosh.OS.FileSystem

  @initialize()
  
  things: ->
    unless @_pinballDisk
      @_pinballDisk = new PAA.Pixeltosh.OS.FileSystem.File
        id: "#{PAA.Pixeltosh.Programs.Pinball.id()}.Disk"
        path: '弹球机创作工具包'
        type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk
      
      @_pinballDisk.options.disk = @_pinballDisk
      
    @_pinballProgram ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: PAA.Pixeltosh.Programs.Pinball.id()
      path: '弹球机创作工具包/弹球机创作工具包'
      type: PAA.Pixeltosh.Programs.Pinball
      disk: @_pinballDisk
    
    @_pinballMachine ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: "#{PAA.Pixeltosh.Programs.Pinball.id()}.PinballMachine"
      path: '弹球机创作工具包/我的弹球机'
      type: PAA.Pixeltosh.Programs.Pinball.Project
      disk: @_pinballDisk
      data: => PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    
    @_moonShot ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: "#{PAA.Pixeltosh.Programs.Pinball.id()}.DemoMachines.MoonShot"
      path: '弹球机创作工具包/弹球机示例/月球冒险'
      type: PAA.Pixeltosh.Programs.Pinball.Project
      disk: @_pinballDisk
      data: => 'ewzE9QPCPPLnxHvpi'
    
    pinballEnabled = LM.PixelArtFundamentals.pinballEnabled()
    
    [
      @_pinballDisk if pinballEnabled
      @_pinballProgram if pinballEnabled
      @_pinballMachine if pinballEnabled
      @_moonShot if pinballEnabled
    ]
