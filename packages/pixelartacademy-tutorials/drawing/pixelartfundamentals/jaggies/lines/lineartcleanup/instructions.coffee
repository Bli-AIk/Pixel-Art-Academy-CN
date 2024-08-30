LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions
LineArtCleanup = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.LineArtCleanup

class LineArtCleanup.Instructions
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> LineArtCleanup
    
    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 3
    
  class @DrawCurve extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.DrawCurve"
    @stepNumber: -> 1
    
    @message: -> """
      徒手绘制线条时，出现不需要的重复像素总会造成困扰。 
      
      徒手绘制这条曲线，一口气连着画完所有像素块。
    """
    
    @initialize()
  
  class @OpenEvaluationPaper extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.OpenEvaluationPaper"
    @stepNumber: -> 2
    
    @message: -> """
      现在，你可以打开右下角的像素画评估页面，获取对这个线条的分析结果。
    """
    
    @initialize()
    
  class @OpenPixelPerfectLines extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.OpenPixelPerfectLines"
    @stepNumber: -> 3
    
    @message: -> """
      当线条没有任何“重复像素”或不应出现的拐角时，它就是一个“像素完美”线条。
      
      点击下面的像素完美线条标准，查看各个问题。
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
  class @HoverOverCriterion extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.HoverOverCriterion"
    @stepNumber: -> 4
    
    @message: -> """
      在这个详细的界面内，你可以把鼠标悬停在任一总数上，从而单独显示那一部分像素。
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
  class @CloseEvaluationPaper extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.CloseEvaluationPaper"
    @stepNumber: -> 5
    
    @message: -> """
      关闭评估界面，并修复所有不恰当的重复像素和拐角像素。
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration

    @initialize()
  
  class @CloseEvaluationPaperWithoutCorners extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.CloseEvaluationPaperWithoutCorners"
    @stepNumber: -> 5
    
    @message: -> """
      在这个详细的界面内，你可以把鼠标悬停在任一总数上，从而单独显示那一部分像素。

      目前这里没有拐角像素，所以这个功能暂时用不上，但将来你大概会用到它的。

      关闭评估界面，并修复所有不恰当的重复像素。
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @activeConditions: ->
      return unless super arguments...
      
      return unless asset = @getActiveAsset()
      return unless bitmap = asset.bitmap()
      return if bitmap.properties.pixelArtEvaluation.pixelPerfectLines.corners.count
      
      true
      
    @priority: -> 1
    
    @initialize()
  
  class @CloseEvaluationPaperWithPixelPerfectLine extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.CloseEvaluationPaperWithPixelPerfectLine"
    @stepNumber: -> 5
    
    @message: -> """
      在这个详细的界面内，你可以把鼠标悬停在任一总数上，从而单独显示那一部分像素。
      
      你绘制的线条就是像素完美线条，所以这个功能暂时用不上，但将来你大概会用到它的。

      关闭评估界面以完成课程。
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @activeConditions: ->
      return unless super arguments...
      
      return unless asset = @getActiveAsset()
      return unless bitmap = asset.bitmap()
      return if bitmap.properties.pixelArtEvaluation.pixelPerfectLines.doubles.count
      return if bitmap.properties.pixelArtEvaluation.pixelPerfectLines.corners.count
      
      true
    
    @priority: -> 2
    
    @initialize()

  class @CleanDoubles extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.CleanDoubles"
    @stepNumber: -> 6
    
    @message: -> """
      在每个重复像素中移除任一像素，并使拐角像素更平滑，从而绘制一个像素完美线条。
    """
    
    @delayDuration: -> @defaultDelayDuration
  
    @resetDelayOnOperationExecuted: -> true
  
    @initialize()
    
    displaySide: ->
      return unless drawingEditor = @getEditor()
      
      # Note: In case the user undoes the steps to where the pixel art evaluation property is not present anymore, the
      # view will not display anymore, so we just show this instruction at the bottom even without the view being
      # present.
      return InstructionsSystem.DisplaySide.Bottom unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
    
  class @Complete extends PAA.Tutorials.Drawing.Instructions.CompleteInstruction
    @id: -> "#{LineArtCleanup.id()}.Complete"
    @assetClass: -> LineArtCleanup
    
    @message: -> """
      干得好！像素画软件通常会有“像素完美”选项，它可以预防你画出重复像素和拐角像素，但学习手动清理线条也很重要。
    """
    
    @initialize()
    
    displaySide: ->
      return unless drawingEditor = @getEditor()
      return InstructionsSystem.DisplaySide.Bottom unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
