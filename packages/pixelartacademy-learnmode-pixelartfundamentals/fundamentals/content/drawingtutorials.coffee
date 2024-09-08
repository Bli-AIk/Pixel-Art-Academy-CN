PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials'
  @displayName: -> "绘画教程"
  @tags: -> [LM.Content.Tags.WIP]
  @contents: -> [
    @ElementsOfArt
    @PixelArtLines
    @PixelArtDiagonals
    @PixelArtCurves
    @PixelArtLineWidth
    @AntiAliasing
    @Dithering
    @Rotation
    @Scale
  ]
  @initialize()
  
  constructor: ->
    super arguments...
    
    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 3
      requiredUnits: "tutorials"
      totalUnits: "tutorial steps"
      totalRecursive: true
  
  status: ->
    toDoTasksGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.ToDoTasks.id()
    if toDoTasksGoal.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked
    
  class @ElementsOfArt extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt'
    @displayName: -> "绘画中的元素"
    @tags: -> [LM.Content.Tags.WIP]
    
    @contents: -> [
      @Line
      @Shape
      @Form
      @Space
      @Value
      @Color
      @Texture
    ]
    
    @initialize()
    
    constructor: ->
      super arguments...
    
      @progress = new LM.Content.Progress.ContentProgress
        content: @
        requiredUnits: "tutorials"
        totalUnits: "tutorial steps"
        totalRecursive: true
    
    status: -> @constructor.Status.Unlocked
    
    class @Line extends LM.Content.DrawingTutorialContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Line'
      @tutorialClass = PAA.Tutorials.Drawing.ElementsOfArt.Line
      @tags: -> [LM.Content.Tags.WIP]
      @initialize()
      
    class @Shape extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Shape'
      @displayName: -> "绘画中的元素：形状"
      @initialize()
    
    class @Form extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Form'
      @displayName: -> "绘画中的元素：结构"
      @initialize()
    
    class @Space extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Space'
      @displayName: -> "绘画中的元素：空间"
      @initialize()
    
    class @Value extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Value'
      @displayName: -> "绘画中的元素：权重"
      @initialize()
    
    class @Color extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Color'
      @displayName: -> "绘画中的元素：颜色"
      @initialize()
    
    class @Texture extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Texture'
      @displayName: -> "绘画中的元素：材质"
      @initialize()
  
  class @PixelArtLines extends LM.Content.DrawingTutorialContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArtLines'
    @tutorialClass = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines
    @initialize()
    
  class @PixelArtDiagonals extends LM.Content.DrawingTutorialContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArtDiagonals'
    @tutorialClass = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals
    @initialize()
  
  class @PixelArtCurves extends LM.Content.DrawingTutorialContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArtCurves'
    @tutorialClass = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves
    @initialize()
  
  class @PixelArtLineWidth extends LM.Content.DrawingTutorialContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArtLineWidth'
    @tutorialClass = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth
    @initialize()
    
  class @AntiAliasing extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.AntiAliasing'
    @displayName: -> "抗锯齿"
    @initialize()
  
  class @Dithering extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Dithering'
    @displayName: -> "抖动"
    @initialize()
  
  class @Rotation extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Rotation'
    @displayName: -> "像素画的旋转"
    @initialize()
    
  class @Scale extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Scale'
    @displayName: -> "像素画的缩放"
    @initialize()
