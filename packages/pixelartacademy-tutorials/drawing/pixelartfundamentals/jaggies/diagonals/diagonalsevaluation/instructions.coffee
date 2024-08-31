LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation
StraightLine = PAE.Line.Part.StraightLine

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions

DiagonalsEvaluation = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.DiagonalsEvaluation

class DiagonalsEvaluation.Instructions
  class @PixelPerfectInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{DiagonalsEvaluation.id()}.PixelPerfectInstruction"
    @assetClass: -> DiagonalsEvaluation
    
    @message: -> """
      确保你的线条是像素完美的（不应包含重复像素）。
    """
    
    @getPixelArtEvaluation: ->
      return unless drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
    @activeConditions: ->
      # Only show this tip when the evaluation paper is open.
      return unless pixelArtEvaluation = @getPixelArtEvaluation()
      return unless pixelArtEvaluation.active()
      
      return unless asset = @getActiveAsset()
      
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()

      for line in pixelArtEvaluation.layers[0].lines
        # The line must not have any doubles.
        lineEvaluation = line.evaluate()
        return true if lineEvaluation.doubles.count

      false
    
    @priority: -> 1
    
    @initialize()
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> DiagonalsEvaluation

    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 3
    
    # The amount of time before we show instructions when a new line is introduced.
    @newLineDelayDuration = 5
    
    @closeOutsideEvaluationPaper: -> false
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @getPixelArtEvaluation: ->
      drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    @activeDisplayState: ->
      return PAA.PixelPad.Systems.Instructions.DisplayState.Open unless @closeOutsideEvaluationPaper()
      
      pixelArtEvaluation = @getPixelArtEvaluation()
      
      if pixelArtEvaluation.active() then PAA.PixelPad.Systems.Instructions.DisplayState.Open else PAA.PixelPad.Systems.Instructions.DisplayState.Closed
    
    displaySide: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()

      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
      
    openEvaluationPaper: (focusPoint, scale, criterion = PAE.Criteria.EvenDiagonals) ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      pixelArtEvaluation.activate criterion
      
      return unless focusPoint or scale
      
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()

      if focusPoint
        camera.translateTo focusPoint, 1
        
      if scale
        camera.scaleTo scale, 1
        
    centerFocus: ->
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      camera.translateTo {x: 15, y: 14.5}, 1
      
    getLinePartForStep: (stepNumber) ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      return unless step = @getTutorialStep stepNumber
      
      corners = _.flatten step.paths[0].cornersOfParts
      return unless linePart = pixelArtEvaluation.getLinePartsBetween(corners...)[0]
      return unless linePart instanceof StraightLine
      
      linePart
    
    getLineBreakdownMarkup: (stepNumber) ->
      return [] unless linePart  = @getLinePartForStep stepNumber
      
      Markup.PixelArt.straightLineBreakdown linePart
  
  class @EvaluationPaper extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.EvaluationPaper"
    @stepNumbers: -> [1, 2]
    
    @message: -> """
      绘制斜线，并在右下角打开像素画评估。
    """
    
    @initialize()
  
  class @Criterion extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.Criterion"
    @stepNumber: -> 3
    
    @message: -> """
      现在你可以分析斜线是否均匀了。点击“均匀斜线”标准继续。
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
  
  class @Broken extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.Broken"
    @stepNumber: -> 4
    
    @message: -> """
      这条斜线不均匀。此外，单像素段和双像素段没有很好地交替，而是被分割成了多个部分。
      
      将鼠标悬停在线条上以查看线段长度的数值。
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 18}, 4
  
  class @NotBrokenAlternative extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.NotBrokenAlternative"
    @stepNumber: -> 4
    
    @message: -> """
      将鼠标悬停在线条上以查看线段长度的数值。
    """
    
    @activeConditions: ->
      return false unless super arguments...
      
      # See if we have an alternative diagonal to begin with.
      return unless bitmap = @getActiveAsset().bitmap()
      
      bitmap.properties.pixelArtEvaluation.evenDiagonals.segmentLengths.counts.broken is 0
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @priority: -> 1
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 18}, 4
  
  class @Alternating extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.Alternating"
    @stepNumber: -> 5
    
    @message: -> """
      你可以让这条线在双段和单段之间交替排列（例如2-1-2-1-2-…）。关闭评估，然后修改你的像素线条，以符合该模式。
    """
    
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()
  
  class @Alternating23 extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.Alternating23"
    @stepNumber: -> 6
    
    @message: -> """
      很好！这条斜线每横向2个像素就下降3个像素，形成了理想的3:2斜线。
      
      关闭评估，去画下一条线吧。
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 18}, 4
    
    markup: -> @getLineBreakdownMarkup 1
  
  class @ContinueLine2 extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.ContinueLine2"
    @stepNumber: -> 7
    
    @message: -> """
      继续画下一条线。
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @centerFocus()
    
  class @Alternating25 extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.Alternating25"
    @stepNumber: -> 8
    
    @message: -> """
      这条斜线的线段长度为2和3像素。\n
      然而，它们又被一组一组地排列，而不是交替排列。\n
      试试用2-3-2-3-2-…的方式来修复它。
    """
    
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 10}, 4
    
    markup: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      return [] unless pixelArtEvaluation.active()
      
      @getLineBreakdownMarkup 7
  
  class @Alternating25Fixed extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.Alternating24Fixed"
    @stepNumber: -> 9
    
    @message: -> """
      这条线的得分为83%，高于前一条线的75%，因为线段长度更长，使得交替不太明显。
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 10}, 4
      
    markup: ->
      [@getLineBreakdownMarkup(1)..., @getLineBreakdownMarkup(7)...]
  
  class @ContinueLine3 extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.ContinueLine3"
    @stepNumber: -> 10
    
    @message: -> """
      继续使用交替的线段长度绘制下一条线。
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @centerFocus()
  
  class @Alternating29 extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.Alternating29"
    @stepNumber: -> 11
    
    @message: -> """
      将这条线的线段长度调整为4-5-4-5-4。
    """
    
    @delayDuration: -> @newLineDelayDuration
    
    @initialize()
  
  class @Ends extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.Ends"
    @stepNumber: -> 12
    
    @message: -> """
      当线段长度较长时，很难区分均匀斜线和交替斜线，这使得它们不再那么重要。\n
      更关键的是末端段的长度要与中间段相匹配。
    """
    
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()

    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 15}, 4
    
    markup: ->
      [@getLineBreakdownMarkup(1)..., @getLineBreakdownMarkup(7)..., @getLineBreakdownMarkup(11)...]
  
  class @ContinueLine4 extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.ContinueLine4"
    @stepNumber: -> 13
    
    @message: -> """
      使用默认的布雷森汉姆算法绘制最后的线条（按住 Shift 并点击，且不使用均匀斜线选项）。
    """
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @centerFocus()
      
  class @Highlight extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.Highlight"
    @stepNumbers: -> [14, 15]
    
    @message: -> """
      现在，“末端线段”可以帮助你找出线段末端处较短的线条。\n
      你可以在评估页面的数字上悬停，以高亮显示这种类型的线条。\n
      最后，调整线条，使末端段与中间段长度一致。
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 25}, 4
      
    markup: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      return [] unless pixelArtEvaluation.active()
      return [] unless linePart  = @getLinePartForStep 13
      
      Markup.PixelArt.evaluatedSegmentCornerLines linePart
    
  class @Complete extends @StepInstruction
    @id: -> "#{DiagonalsEvaluation.id()}.Complete"
    
    @message: -> """
      做得不错！因为评估页面只会评估均匀斜线，而这节课要求你学习不均匀斜线，所以课程得分无法再提升了。\n
      不过，通过使用交替的线段长度，并匹配线段末端长度，你仍然获得了最高分。
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
      
    @closeOutsideEvaluationPaper: -> true
    
    @initialize()
    
    onActivate: ->
      super arguments...
      @openEvaluationPaper {x: 15, y: 15}, 3, null
    
    markup: ->
      pixelArtEvaluation = @constructor.getPixelArtEvaluation()
      return [] unless pixelArtEvaluation.active()
      return [] unless linePart  = @getLinePartForStep 13
      
      Markup.PixelArt.evaluatedSegmentCornerLines linePart
