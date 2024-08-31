LOI = LandsOfIllusions
PAA = PixelArtAcademy

StraightLine = PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.EvenDiagonals extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.EvenDiagonals"

  @displayName: -> "均匀斜线"
  
  @description: -> """
    锯齿的形成各不相同，斜线的美感也因角度而异。
  """
  
  @fixedDimensions: -> width: 26, height: 26
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/evendiagonals-#{step}.png" for step in [1..4]
  
  @markup: -> true
  @pixelArtEvaluation: -> true
  
  @initialize()
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
    markup: ->
      # Write diagonal ratios next to lines.
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      for line in pixelArtEvaluation.layers[0].lines
        # Draw this only for lines that are recognized as straight lines.
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
        
        lineEvaluation = linePart.evaluate()
        markup.push Markup.PixelArt.diagonalRatioText linePart unless lineEvaluation.type is StraightLine.Type.AxisAligned
        
      markup
  
  class @StepInstructionWithSegmentLines extends @StepInstruction
    markup: ->
      markup = super arguments...
      
      return markup unless asset = @getActiveAsset()
      return markup unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      # Add perceived lines for straight lines.
      for line in pixelArtEvaluation.layers[0].lines
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
        
        markup.push Markup.PixelArt.perceivedStraightLine linePart

      markup
      
  class @Horizontal extends @StepInstruction
    @id: -> "#{Asset.id()}.Aligned"
    @stepNumber: -> 1
    
    @message: -> """
      在像素画中，横线和竖线不会产生锯齿。因此，某些角度（例如 0°和 90°）比其他角度更常用。
    """
    
    @initialize()
  
  class @OneToOne extends @StepInstruction
    @id: -> "#{Asset.id()}.OneToOne"
    @stepNumber: -> 2
    
    @message: -> """
      虽然45°的斜线会产生锯齿，但它遵循一种规律，即每前进一个像素就上升一个像素。这种斜线被称为1:1斜线。
    """
    
    @initialize()
  
  class @OneToTwo extends @StepInstruction
    @id: -> "#{Asset.id()}.OneToTwo"
    @stepNumber: -> 3
    
    @message: -> """
      如果每段线是2个像素长，那么就会形成1:2或2:1斜线。
    """
    
    @initialize()
  
  class @Even extends @StepInstructionWithSegmentLines
    @id: -> "#{Asset.id()}.Even"
    @stepNumber: -> 4
    
    @message: -> """
      每当我们在线条中使用相同数量的像素时，就会绘制出均匀或“完美”的斜线。

      在像素画中，这些角度被认为是完美的，因为线条的拐角像素与感知线条完全吻合。
    """

    # Note: We want this instruction to appear also when the asset
    # is completed, which is why we're overriding this method.
    @activeConditions: ->
      # Show with the correct step.
      return unless @activeStepNumber() in @stepNumbers()
      
      true
      
    @initialize()
