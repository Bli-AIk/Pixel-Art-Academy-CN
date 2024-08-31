LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.ToDoTasks extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.ToDoTasks'

  @displayName: -> "To-do tasks"

  @chapter: -> LM.Intro.Tutorial

  Goal = @
  
  class @OpenInstructions extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.ToDoTasks.OpenInstructions'
    @goal: -> Goal

    @directive: -> "点击这里阅读任务说明"

    @instructions: -> """
      这个记事本将记录你当前的任务。
      你可以随时回到这里，
      以了解如何完成你的任务。

      点击箭头返回。
    """
    
    @interests: -> ['to-do tasks']
  
    @initialize()
    
    constructor: ->
      super arguments...
      
      @_instructionsWereOpened = false
      @_instructionsWereOpenedAndClosed = new ReactiveField false
      
      @_instructionsAutorun = Tracker.autorun (computation) =>
        return unless LOI.adventure.ready()
        return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
        return unless toDoSystem = _.find pixelPad.os.currentSystems(), (system) => system instanceof PAA.PixelPad.Systems.ToDo
        return unless toDoSystem.isCreated()
        
        selectedTask = toDoSystem.selectedTask()
        
        # Wait for instructions to be opened.
        @_instructionsWereOpened = true if selectedTask
        
        # Wait for instructions to close after they've been opened.
        if @_instructionsWereOpened and not selectedTask
          @_instructionsWereOpenedAndClosed true
          computation.stop()
        
    destroy: ->
      super arguments...
      
      @_instructionsAutorun.stop()

    completedConditions: ->
      @_instructionsWereOpenedAndClosed()
    
    activeNotificationId: -> @constructor.ActiveNotification.id()
    
    Task = @
    
    class @ActiveNotification extends PAA.PixelPad.Systems.Notifications.Notification
      @id: -> "#{Task.id()}.ActiveNotification"
      
      @message: -> """
        点击下面的笔记本，
        查看你的待办任务。
        你也可以随时点击我，
        来听听我的想法！
      """
      
      @priority: -> 1
      
      @initialize()
      
  @tasks: -> [
    @OpenInstructions
  ]

  @finalTasks: -> [
    @OpenInstructions
  ]

  @initialize()
