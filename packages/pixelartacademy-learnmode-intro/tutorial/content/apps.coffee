PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Apps extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Apps'

  @displayName: -> "Apps"
  
  @unlockInstructions: -> "学习如何使用待办任务清单来解锁其他软件。"

  @contents: -> [
    @Drawing
    @Pico8
  ]

  @initialize()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      units: "apps"
  
  status: ->
    toDoTasksGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.ToDoTasks.id()
    if toDoTasksGoal.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked

  class @Drawing extends LM.Content.AppContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Apps.Drawing'
    @appClass = PAA.PixelPad.Apps.Drawing

    @initialize()

    status: -> LM.Content.Status.Unlocked

  class @Pico8 extends LM.Content.AppContent
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Apps.Pico8'
    @appClass = PAA.PixelPad.Apps.Pico8

    @unlockInstructions: -> "完成像素画软件挑战以解锁 PICO-8 软件。"

    @initialize()

    status: ->
      pixelArtSoftwareGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.PixelArtSoftware.id()
      if pixelArtSoftwareGoal.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked
