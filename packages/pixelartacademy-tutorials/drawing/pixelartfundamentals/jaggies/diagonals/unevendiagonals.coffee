LOI = LandsOfIllusions
PAA = PixelArtAcademy

StraightLine = PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.UnevenDiagonals extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.UnevenDiagonals"

  @displayName: -> "不均匀斜线"
  
  @description: -> """
    为了绘制所有可能的角度，我们需要使用线段长度不均匀的斜线。
  """
  
  @fixedDimensions: -> width: 39, height: 36
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/unevendiagonals-#{step}.png" for step in [1..4]
  
  @markup: -> true
  @pixelArtEvaluation: -> true
  
  @initialize()
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      for line in pixelArtEvaluation.layers[0].lines
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
        
        # Add the perceived line.
        markup.push Markup.PixelArt.perceivedStraightLine linePart
        
      markup
  
  class @StepInstructionWithDiagonalRatios extends @StepInstruction
    markup: ->
      markup = super arguments...
      
      # Write diagonal ratios next to lines.
      return markup unless asset = @getActiveAsset()
      return markup unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      for line in pixelArtEvaluation.layers[0].lines
        # Draw this only for lines that are recognized as straight lines.
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
        
        lineEvaluation = linePart.evaluate()
        
        unless lineEvaluation.type is StraightLine.Type.AxisAligned
          diagonalRatioText = Markup.PixelArt.diagonalRatioText linePart
          diagonalRatioText.text.style = @_getLineStyle lineEvaluation
          markup.push diagonalRatioText
        
      markup
      
    _getLineStyle: (lineEvaluation) ->
      if lineEvaluation.type in [StraightLine.Type.AxisAligned, StraightLine.Type.EvenDiagonal]
        Markup.betterStyle()
      
      else if lineEvaluation.pointSegmentLengths is StraightLine.SegmentLengths.Alternating
        Markup.mediocreStyle()
        
      else
        Markup.worseStyle()
  
  class @StepInstructionWithSegmentLines extends @StepInstructionWithDiagonalRatios
    markup: ->
      markup = super arguments...
      
      return markup unless asset = @getActiveAsset()
      return markup unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      for line in pixelArtEvaluation.layers[0].lines
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
        
        # Add segment corner lines.
        lineEvaluation = linePart.evaluate()
        
        segmentCornersLineBase = Markup.PixelArt.perceivedLineBase()
        segmentCornersLineBase.style = @_getLineStyle lineEvaluation
        
        segmentCorners = linePart.getSegmentCorners()
        
        for side in ['left', 'right']
          for point in segmentCorners[side]
            point.x += 0.5
            point.y += 0.5
          
          markup.push
            line: _.extend {}, segmentCornersLineBase,
              points: segmentCorners[side]
            
      markup
      
  class @ShallowAngles extends @StepInstruction
    @id: -> "#{Asset.id()}.ShallowAngles"
    @stepNumber: -> 1
    
    @message: -> """
      在接近平行或垂直的角度时，我们可以轻松找到均匀斜线。
    """
    
    @initialize()
  
  class @OneToTwo extends @StepInstruction
    @id: -> "#{Asset.id()}.OneToTwo"
    @stepNumber: -> 2
    
    @message: -> """
      从1:3斜线到1:2斜线的过渡中，角度之间的间距变大了。
    """
    
    @initialize()
  
  class @OneToOne extends @StepInstruction
    @id: -> "#{Asset.id()}.OneToOne"
    @stepNumber: -> 3
    
    @message: -> """
      在1:2和1:1斜线之间的间距最大。并且这个范围内没有均匀的斜线。
    """
    
    @initialize()
  
  class @Intermediary extends @StepInstructionWithDiagonalRatios
    @id: -> "#{Asset.id()}.Intermediary"
    @stepNumber: -> 4
    
    @message: -> """
      为了弥合间距内的空隙，我们需要在中间插入一些线段长度交替变化的斜线。
    """
    
    @initialize()
  
  class @Complete extends @StepInstructionWithSegmentLines
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
      因为不均匀斜线的线段长度会变化，这会导致锯齿无法与预期方向完美对齐。
      
      这些角度往往被认为缺乏美感，因此在创作中通常会被有意回避，但最终还是要依据作品的特定需求和艺术风格来权衡取舍。
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
