
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation
InstructionsSystem = PAA.PixelPad.Systems.Instructions

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Corners extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Corners"

  @displayName: -> "拐角像素"
  
  @description: -> """
    你可以刻意绘制一些尖锐的边缘。
  """

  @fixedDimensions: -> width: 55, height: 28
  
  @customPalette: ->
    new LOI.Assets.Palette
      ramps: [
        shades: [r: 0, g: 0, b: 0]
      ,
        shades: [r: 1, g: 0.8, b: 0.2]
      ]
  
  @resources: ->
    imagePixelsOptions = palette: => @customPalette()
    
    steps: for step in [1..2]
      startPixels: new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/lines/corners-#{step}.png", imagePixelsOptions
      goalPixels: new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/lines/corners-#{step}-goal.png", imagePixelsOptions

  @pixelArtEvaluation: -> true
  
  @properties: ->
    pixelArtScaling: true
    pixelArtEvaluation:
      editable: true
      allowedCriteria: [PAE.Criteria.PixelPerfectLines]
      pixelPerfectLines:
        doubles: {}
        corners:
          ignoreStraightLineCorners: false
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    # The first step should not show goal pixels.
    steps[0].options.drawHintsForGoalPixels = false

    # Add step for disabling the corners criterion.
    new @constructor.DisableCornersEvaluation @, stepArea
  
  Asset = @
  
  class @DisableCornersEvaluation extends TutorialBitmap.Step
    completed: ->
      not @tutorialBitmap.bitmap().properties.pixelArtEvaluation.pixelPerfectLines?.corners
      
    solve: ->
      # Disable pixel art evaluation.
      bitmap = @tutorialBitmap.bitmap()
      pixelArtEvaluation = bitmap.properties.pixelArtEvaluation
      delete pixelArtEvaluation.pixelPerfectLines.corners
      
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.id(), bitmap, 'pixelArtEvaluation', pixelArtEvaluation
      AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, updatePropertyAction, new Date
    
  class @Outline1 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Outline1"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      按照之前的指导，在星星的外部围上一条黑色轮廓线（请仅在对角处连接像素线条）。
    """

    @initialize()
  
  class @Outline2 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Outline2"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      遵循这些规则会产生圆角，这很适合柔和的外观。但如果需要尖角，使用更尖锐的线条也是可以的。
    """
    
    @initialize()
  
  class @OpenEvaluation extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.OpenEvaluation"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      打开像素画评估页面，查看关于拐角处的分析。
    """
    
    @completedConditions: ->
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.active()
    
    @resetCompletedConditions: ->
      return true unless @getActiveAsset()
      
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      not pixelArtEvaluation.active()
    
    @priority: -> 2
    
    @initialize()
    
  class @SelectCriterion extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.SelectCriterion"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      像素完美线条不允许拐角像素出现，所以拐角处被标记为错误像素。
      
      但是评估工具不理解你的实际情况。请打开“像素完美线条细节”以继续。
    """
    
    @completedConditions: ->
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.active() and pixelArtEvaluation.activeCriterion() is PAE.Criteria.PixelPerfectLines
    
    @resetCompletedConditions: ->
      return true unless @getActiveAsset()
      
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      not pixelArtEvaluation.active() or pixelArtEvaluation.activeCriterion() isnt PAE.Criteria.PixelPerfectLines
    
    @priority: -> 1
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top

    @initialize()
    
  class @TurnOff extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.TurnOff"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      评估页面只会显示可能存在的问题。所以你无需担心那些故意保留的拐角处。
      
      你可以选择完全禁用某些规则。请取消“拐角像素”规则的勾选。
    """
    
    @displaySide: -> PAA.PixelPad.Systems.Instructions.DisplaySide.Top
    
    @initialize()
    
  class @Complete extends PAA.Tutorials.Drawing.Instructions.CompleteInstruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
      干得不错！评估只是一个检查像素画的辅助工具，不必完全遵循它的建议。
      
      评估可能会出错，也不了解你的想法，因此对它的评估结果应当谨慎看待。
    """

    @initialize()
    
    displaySide: ->
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
