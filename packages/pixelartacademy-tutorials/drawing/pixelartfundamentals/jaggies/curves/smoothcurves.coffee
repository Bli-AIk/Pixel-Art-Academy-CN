LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.SmoothCurves extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.SmoothCurves"

  @displayName: -> "平滑曲线"
  
  @description: -> """
    学习如何通过计算线段长度，来让你的曲线尽可能地平滑。
  """
  
  @fixedDimensions: -> width: 52, height: 40
  
  @steps: ->
    path = '/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/curves/smoothcurves'
    
    [
      goalImageUrl: "#{path}-1-goal.png"
    ,
      goalImageUrl: "#{path}-2.png"
    ,
      goalImageUrl: "#{path}-2-goal.png"
    ,
      goalImageUrl: "#{path}-3-goal.png"
    ,
      imageUrl: "#{path}-4.png"
      goalImageUrl: "#{path}-4-goal.png"
    ]
    
  @markup: -> true
  @pixelArtEvaluation: -> true
  
  @initialize()
  
  initializeSteps: ->
    super arguments...

    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    # Step 2 and 5 introduce extra pixels, so we must allow other steps before them to complete with them present.
    steps[0].options.canCompleteWithExtraPixels = true
    steps[3].options.canCompleteWithExtraPixels = true
    
    # Step 2 needs to behave like a temporary step.
    steps[1].options.preserveCompleted = true
    steps[1].options.hasPixelsWhenInactive = false
    
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
    # The length of the arrow to indicate a pixel move.
    @movePixelArrowLength = 1.2
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      for line in pixelArtEvaluation.layers[0].lines
        # Write segment lengths next to lines.
        markup.push Markup.PixelArt.pointSegmentLengthTexts(line)...
      
      markup
    
  class @Curve1 extends @StepInstruction
    @id: -> "#{Asset.id()}.Curve1"
    @stepNumber: -> 1
    
    @message: -> """
      在像素画中，如果曲线的每个线段长度都在均匀变化，那么它看上去会更平滑。
    """
    
    @initialize()
    
  class @Curve2Draw extends @StepInstruction
    @id: -> "#{Asset.id()}.Curve2Draw"
    @stepNumber: -> 2
    
    @message: -> """
      倘若线段的长度交替着增加或减少，这个线条就会显得更锯齿化。
    """
    
    @initialize()
  
  class @Curve2Fix extends @StepInstruction
    @id: -> "#{Asset.id()}.Curve2Fix"
    @stepNumber: -> 3
    
    @message: -> """
      调整像素，确保线段长度不再减少（有长度重复的、或比上一节稍长一格的线段，也没关系）。
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      return unless asset = @getActiveAsset()
      bitmap = asset.bitmap()
      
      arrows = [
        {direction: {x: 0, y: -1}, targetPixel: {x: 11, y: 14}}
        {direction: {x: 0, y: -1}, targetPixel: {x: 15, y: 12}}
        {direction: {x: 0, y: 1}, targetPixel: {x: 20, y: 11}}
        {direction: {x: 0, y: 1}, targetPixel: {x: 24, y: 10}}
      ]
      
      markupStyle = Markup.errorStyle()
      
      arrowBase =
        arrow:
          end: true
          width: 0.5
          length: 0.25
        style: markupStyle
      
      for arrow in arrows when not bitmap.findPixelAtAbsoluteCoordinates arrow.targetPixel.x, arrow.targetPixel.y
        fromPosition =
          x: arrow.targetPixel.x - arrow.direction.x + 0.5
          y: arrow.targetPixel.y - arrow.direction.y + 0.5
        
        toPosition =
          x: fromPosition.x + arrow.direction.x * @constructor.movePixelArrowLength
          y: fromPosition.y + arrow.direction.y * @constructor.movePixelArrowLength
        
        markup.push
          line: _.extend {}, arrowBase,
            points: [fromPosition, toPosition]
      
      markup
  
  class @Curve3 extends @StepInstruction
    @id: -> "#{Asset.id()}.Curve3"
    @stepNumber: -> 4
    
    @message: -> """
      当曲线的长度比较长时，它的线段长度会在递增和递减之间发生转换，让它转换的次数越少越好。
    """
    
    @initialize()
  
  class @Curve4 extends @StepInstruction
    @id: -> "#{Asset.id()}.Curve4"
    @stepNumber: -> 5
    
    @message: -> """
      徒手绘制的曲线通常整体位置大致正确，但它仍然需要调整每个线段的长度，从而获得更平滑的视觉效果。
    """
    
    @initialize()

  class @Complete extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @activeDisplayState: ->
      # We only have markup without a message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      for line in pixelArtEvaluation.layers[0].lines
        # Write segment lengths next to lines.
        markup.push Markup.PixelArt.pointSegmentLengthTexts(line)...
        
        # Draw perceived curves.
        markup.push Markup.PixelArt.perceivedCurve linePart for linePart in line.parts when linePart instanceof PAE.Line.Part.Curve
      
      markup
