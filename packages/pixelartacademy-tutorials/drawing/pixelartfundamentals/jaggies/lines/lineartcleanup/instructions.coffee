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
      Undesirable doubles are an issue when drawing lines freehand.
      For this lesson, draw the curve with a single, freehand stroke.
    """
    
    @initialize()
  
  class @DrawCurveFreehand extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.DrawCurveFreehand"
    @stepNumber: -> 1
    
    @message: -> """
      Hold up!

      Please use a freehand stroke for this step.
      Click on the start of the line and drag along the path in a fluid motion.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show if you've already done a stroke and you're still in the first step.
      return unless asset = @getActiveAsset()
      return unless bitmap = asset.bitmap()
      bitmap.historyPosition
    
    @priority: -> 1
    
    @initialize()
  
  class @OpenEvaluationPaper extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.OpenEvaluationPaper"
    @stepNumber: -> 2
    
    @message: -> """
      You can now open the pixel art evaluation paper in the bottom-right corner to get an analysis of your line.
    """
    
    @initialize()
    
  class @OpenPixelPerfectLines extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.OpenPixelPerfectLines"
    @stepNumber: -> 3
    
    @message: -> """
      Lines are considered 'pixel-perfect' when they don't have any doubles or other corners.
      
      Click on the Pixel-perfect lines criterion below to see individual problems.
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
  class @HoverOverCriterion extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.HoverOverCriterion"
    @stepNumber: -> 4
    
    @message: -> """
      In this detailed view, you can hover over the numbers in the count column to show just those pixels in the analysis.
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
  class @CloseEvaluationPaper extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.CloseEvaluationPaper"
    @stepNumber: -> 5
    
    @message: -> """
      Close the evaluation paper and eliminate all doubles and corners.
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration

    @initialize()
  
  class @CloseEvaluationPaperWithoutCorners extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.CloseEvaluationPaperWithoutCorners"
    @stepNumber: -> 5
    
    @message: -> """
      In this detailed view, you can hover over the numbers in the count column to show just those pixels in the analysis.
      Right now you have no corners so this is not useful, but it will be later.

      Close the evaluation paper and eliminate all doubles.
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
      In this detailed view, you can hover over the numbers in the count column to show just those pixels in the analysis.
      You've already made your line pixel-perfect so this is not useful, but it will be later.

      Close the evaluation paper to complete the lesson.
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
      Remove one pixel in each of the doubles and smooth out the corners to create a pixel-perfect line.
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
      Great job! Pixel art software often includes a pixel-perfect option for the pencil, which avoids the creation of doubles and sharp corners, but it is important to know how to clean a line by hand too.
    """
    
    @initialize()
    
    displaySide: ->
      return unless drawingEditor = @getEditor()
      return InstructionsSystem.DisplaySide.Bottom unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
