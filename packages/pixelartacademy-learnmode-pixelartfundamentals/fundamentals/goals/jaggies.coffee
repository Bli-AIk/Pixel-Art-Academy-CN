LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies'

  @displayName: -> "- 像素画基本原则：锯齿 -"
  
  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @

  class @Lines extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.Lines'
    @goal: -> Goal

    @directive: -> "学习像素画中的线条"

    @instructions: -> """
      在绘图软件内，完成像素画线条教程，学习什么是锯齿。
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @requiredInterests: -> ['line']
    
    @interests: -> ['jaggy']
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.completed()
  
  class @Diagonals extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.Diagonals'
    @goal: -> Goal
    
    @directive: -> "学习像素画中的斜线"
    
    @instructions: -> """
      在绘图软件内，完成像素画斜线教程，学习不同的斜线角度如何影响锯齿的外观。
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Lines]
    
    @groupNumber: -> 1
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.completed()
  
  class @Curves extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.Curves'
    @goal: -> Goal
    
    @directive: -> "学习像素画中的曲线"
    
    @instructions: -> """
      在绘图软件内，完成像素画曲线教程，学习让线条看上去更平滑的秘诀。
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Lines]
    
    @groupNumber: -> 2
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.completed()
      
  class @LineWidth extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.LineWidth'
    @goal: -> Goal
    
    @directive: -> "学习像素画中的线宽"
    
    @instructions: -> """
      在绘图软件内，完成像素画线宽教程，学习如何呈现粗细不同的线条。
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Lines]
    
    @groupNumber: -> 3
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.completed()
  
  class @PixelPerfectLines extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.PixelPerfectLines'
    @goal: -> Goal
    
    @directive: -> "用像素完美线条画出同人像素画"
    
    @instructions: -> """
      在绘图软件内，选择一张像素线条挑战中的参考图，

      绘制它，同时遵循像素画评估页面中的“像素完美线条”规则。
      
      你需要获得80%以上的评分（可以保留必要的重复像素或拐角像素）。
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['pixel-perfect line']
    
    @predecessors: -> [Goal.Lines]
    
    @initialize()
    
    @completedConditions: ->
      PAA.Challenges.Drawing.PixelArtLineArt.completedPixelPerfectLines()
  
    activeNotificationId: -> Goal.WIPNotification.id()
  
  class @EvenDiagonals extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.EvenDiagonals'
    @goal: -> Goal
    
    @directive: -> "使用均匀斜线画出同人像素画"
    
    @instructions: -> """
      在绘图软件内，选择一张像素线条挑战中的参考图。
      
      绘制它，同时遵循像素画评估页面中的“均匀斜线”规则。
      
      确保有至少10条线段长度均匀的线条，同时获得80%以上的分数。
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['even diagonal (pixel art)']
    
    @predecessors: -> [Goal.Diagonals]
    
    @groupNumber: -> 1
    
    @initialize()
    
    @completedConditions: ->
      PAA.Challenges.Drawing.PixelArtLineArt.completedEvenDiagonals()
  
    activeNotificationId: -> Goal.WIPNotification.id()

  class @SmoothCurves extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.SmoothCurves'
    @goal: -> Goal
    
    @directive: -> "使用平滑曲线画出同人像素画"
    
    @instructions: -> """
      在绘图软件内，选择一张像素线条挑战中的参考图。

      绘制它，同时遵循像素画评估页面中的“平滑曲线”规则。

      在像素画评估页面中达到80%以上的评分（包括总体评分以及对生硬的线段长度变化、接近直线的部分和拐点的单独评分）。
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['smooth curve (pixel art)']
    
    @predecessors: -> [Goal.Curves]
    
    @groupNumber: -> 2
    
    @initialize()
    
    @completedConditions: ->
      PAA.Challenges.Drawing.PixelArtLineArt.completedSmoothCurves()
  
    activeNotificationId: -> Goal.WIPNotification.id()
  
  class @ConsistentLineWidth extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.ConsistentLineWidth'
    @goal: -> Goal
    
    @directive: -> "使用一致的线宽画出同人像素画"
    
    @instructions: -> """
      在绘图软件内，选择一张像素线条挑战中的参考图。
      
      绘制它，同时遵循像素画评估页面中的“统一线宽”规则。

      在像素画评估页面中使单独线宽或统一线型这两项的任一项达到80%以上的评分。
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['line width (pixel art)']
    
    @predecessors: -> [Goal.LineWidth]
    
    @groupNumber: -> 3
    
    @initialize()
    
    @completedConditions: ->
      PAA.Challenges.Drawing.PixelArtLineArt.completedConsistentLineWidth()
    
    activeNotificationId: -> Goal.WIPNotification.id()
  
  @tasks: -> [
    @Lines
    @PixelPerfectLines
    @Diagonals
    @EvenDiagonals
    @Curves
    @SmoothCurves
    @LineWidth
    @ConsistentLineWidth
  ]

  @finalTasks: -> [
    @PixelPerfectLines
    @EvenDiagonals
    @SmoothCurves
    @ConsistentLineWidth
  ]

  @initialize()
  
  class @WIPNotification extends PAA.PixelPad.Systems.Notifications.Notification
    @id: -> "#{Goal.id()}.WIPNotification"
    
    @message: -> """
      像素画评估目前还是一个实验性功能，它还在不断完善。

      不要过于看重它的评分。相信自己的艺术直觉吧，你不必完全依赖它。 
    """
    
    @displayStyle: -> @DisplayStyles.Always
    
    @retroClasses: ->
      head: PAA.PixelPad.Systems.Notifications.Retro.HeadClasses.HardHat
      body: PAA.PixelPad.Systems.Notifications.Retro.BodyClasses.Wrench
    
    @retroClassesDisplayed: ->
      head: PAA.PixelPad.Systems.Notifications.Retro.HeadClasses.HardHatPuffed
      face: PAA.PixelPad.Systems.Notifications.Retro.FaceClasses.Yikes
    
    @initialize()
