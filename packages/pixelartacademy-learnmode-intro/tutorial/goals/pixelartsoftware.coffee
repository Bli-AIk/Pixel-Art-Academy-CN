LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.PixelArtSoftware extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware'

  @displayName: -> "像素画绘图软件"
  
  @chapter: -> LM.Intro.Tutorial

  Goal = @

  # Main path
  class @Basics extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.Basics'
    @goal: -> Goal

    @directive: -> "学习画像素画所需的基本工具"

    @instructions: -> """
      在绘图软件内，完成基础教程，
      进而学习如何使用基本绘图工具。
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing
  
    @requiredInterests: -> ['to-do tasks']

    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtTools.Basics.completed()

  class @Helpers extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.Helpers'
    @goal: -> Goal

    @directive: -> "学习一些辅助功能"

    @instructions: -> """
      在绘图软件内，完成辅助教程，
      进而学习缩放和绘制线条等额外工具。
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> -1

    @initialize()

    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtTools.Helpers.completed()

  class @ColorTools extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.ColorTools'
    @goal: -> Goal

    @directive: -> "学习如何切换颜色"

    @instructions: -> """
      在绘图软件内，完成颜色教程，
      进而学习如何切换不同的颜色。
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> 1

    @initialize()

    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtTools.Colors.completed()

  class @CopyReference extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.CopyReference'
    @goal: -> Goal

    @directive: -> "Complete the pixel art software challenge"

    @instructions: -> """
      In the Drawing app under the Challenges section, select a pixel art
      sprite and copy it to show you got the hang of using pixel art software.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @interests: -> ['pixel art software', 'pixel art', 'drawing software']

    @predecessors: -> [Goal.Basics, Goal.Helpers, Goal.ColorTools]
    @predecessorsCompleteType: -> @PredecessorsCompleteType.Any

    @initialize()

    @completedConditions: ->
      PAA.Challenges.Drawing.PixelArtSoftware.completed()
    
    activeNotificationId: -> @constructor.ActiveNotification.id()
    
    Task = @
    
    class @ActiveNotification extends PAA.PixelPad.Systems.Notifications.Notification
      @id: -> "#{Task.id()}.ActiveNotification"
      
      @message: -> """
        注意哦，你可以根据自己的喜好完成待办任务的顺序！
      """
      
      @displayStyle: -> @DisplayStyles.Always
      
      @initialize()

  @tasks: -> [
    @Basics
    @CopyReference
    @ColorTools
    @Helpers
  ]

  @finalTasks: -> [
    @CopyReference
  ]

  @initialize()
