LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt'

  @displayName: -> "- 绘画中的元素 -"
  
  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @

  class @Line extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Line'
    @goal: -> Goal

    @directive: -> "学习线条"

    @instructions: -> """
      在绘图软件中，完成线条教程，
      以了解绘画中最基本的元素。
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['line']
  
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.ElementsOfArt.Line.completed()
    
    Task = @
    
  @tasks: -> [
    @Line
  ]

  @finalTasks: -> [
    @Line
  ]

  @initialize()
