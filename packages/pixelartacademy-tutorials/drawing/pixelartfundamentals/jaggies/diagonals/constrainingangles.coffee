LOI = LandsOfIllusions
PAA = PixelArtAcademy

StraightLine = PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.ConstrainingAngles extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.ConstrainingAngles"

  @displayName: -> "约束线条角度"
  
  @description: -> """
    提升均匀斜线绘制的效率。
  """
  
  @fixedDimensions: -> width: 23, height: 15
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/constrainingangles-#{step}.png" for step in [1..5]
  
  @markup: -> true
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    # Allow steps to complete with extra pixels so that we can show only line ends, but continue with a line drawn.
    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    steps[0].options.canCompleteWithExtraPixels = true
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless bitmap = asset.bitmap()
      
      markup = []
      
      # Highlight uneven pixels.
      unevenPixelBase = style: Markup.errorStyle()
      
      for x in [bitmap.bounds.left..bitmap.bounds.right]
        for y in [bitmap.bounds.top..bitmap.bounds.bottom]
          # Uneven pixels can only exist where pixels are placed.
          continue unless bitmap.findPixelAtAbsoluteCoordinates x, y
          
          # If we don't need a pixel here, it's uneven.
          continue if asset.hasGoalPixel x, y
          
          markup.push pixel: _.extend {x, y}, unevenPixelBase
          
      markup
   
  class @DrawLine extends @StepInstruction
    @id: -> "#{Asset.id()}.DrawLine"
    @stepNumber: -> 1
    
    @message: -> """
      利用铅笔工具的线条绘制功能（Shift键 + 点击）连接这两个点。
    """
    
    @initialize()
  
  class @Cleanup extends @StepInstruction
    @id: -> "#{Asset.id()}.Cleanup"
    @stepNumber: -> 2
    
    @message: -> """
      在点阵图像中，最常用的一种直线绘制算法（布雷森汉姆直线算法）不会绘制完全平均的斜线，因为它会缩短起始处和末尾处的线段，以方便连接多条线条。所以你需要手动清理这些线条。
    """
    
    @initialize()
  
  class @ConstrainAngle extends @StepInstruction
    @id: -> "#{Asset.id()}.ConstrainAngle"
    @stepNumbers: -> [3, 4]
    
    @message: -> """
      为提高效率，在按住Shift键绘制直线时，同时按住Cmd键/Ctrl键即可绘制角度规整的均匀斜线。
    """
    
    @initialize()
