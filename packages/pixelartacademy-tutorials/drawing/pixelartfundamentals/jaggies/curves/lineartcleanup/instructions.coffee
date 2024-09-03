LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions
LineArtCleanup = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LineArtCleanup

class LineArtCleanup.Instructions
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> LineArtCleanup
    
    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 3
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show with the correct step.
      return unless asset.stepAreas()[0]?.activeStepIndex() is @stepNumber() - 1
      
      # Show until the asset is completed.
      not asset.completed()
    
    @resetDelayOnOperationExecuted: -> true
    
    @getPixelArtEvaluation: ->
      drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    getTutorialStep: (stepNumber) ->
      return unless asset = @getActiveAsset()
      
      stepNumber ?= @constructor.stepNumber()
      
      asset.stepAreas()[0].steps()[stepNumber - 1]
    
  class @DrawLine extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.DrawLine"
    @stepNumber: -> 1
    
    @message: -> """
      一口气连接所有像素点，画出一条曲线，然后打开右下角的像素画评估页面。
    """
    
    @initialize()
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
  
  class @OpenSmoothCurves extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.OpenSmoothCurves"
    @stepNumber: -> 2
    
    @message: -> """
      现在你可以分析这条曲线了。点击“平滑曲线”继续。
    """
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
  class @AnalyzeTheCurve extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.AnalyzeTheCurve"
    @stepNumber: -> 3
    
    @message: -> """
      一条平滑的曲线，应该具备均匀变化的线段长度，尽量减少直线部分，并减少拐点。\n
      把光标悬停在评估页面上，分析你的曲线。
    """
    
    @delayDuration: -> @uiRevealDelayDuration

    @initialize()
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
  
  class @SmoothenTheCurve extends @StepInstruction
    @id: -> "#{LineArtCleanup.id()}.SmoothenTheCurve"
    @stepNumber: -> 4
    
    @message: -> """
      清理你的线条吧，直到所有的平滑曲线标准都达到90%以上。
    """
    
    @delayDuration: -> @defaultDelayDuration
  
    @resetDelayOnOperationExecuted: -> true
    
    @initialize()
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
