LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LongCurves extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LongCurves"

  @displayName: -> "更长的曲线"
  
  @description: -> """
    大型的圆和其他会逐渐改变方向的长曲线，会遇到类似不均匀斜线的问题。
  """
  
  @fixedDimensions: -> width: 67, height: 35
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/curves/longcurves-#{step}.png" for step in [1..2]
  
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
        # Write segment lengths next to lines.
        markup.push Markup.PixelArt.pointSegmentLengthTexts(line)...

      markup
  
  class @Uneven extends @StepInstruction
    @id: -> "#{Asset.id()}.Uneven"
    @stepNumber: -> 1
    
    @message: -> """
      当圆形变得足够大时，它的弧线有一部分将会位于1:2和1:1的角度之间。
      如果我们尝试严格地按照曲线绘制的原则来画，就无法让线段长度保持均匀变化。
    """

    @initialize()
    
    markup: ->
      markup = super arguments...
      
      markup.push
        line:
          style: "rgb(0 0 0 / 0.25)"
          width: 0
          arc:
            x: 32
            y: 32
            radius: 28.5
            startAngle: Math.PI
            endAngle: Math.PI * 1.5
            
      markup
  
  class @Even extends @StepInstruction
    @id: -> "#{Asset.id()}.Even"
    @stepNumber: -> 2
    
    @message: -> """
      一部分画师选择接受这种不完美（像接受不规则斜线那样），而另一部分，则坚持使用均匀变化的斜线来绘制曲线，即便这会让曲线的棱角更加分明。
    """
    
    @initialize()
  
  class @Complete extends PAA.Tutorials.Drawing.Instructions.CompleteInstruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
      在实际的绘画创作中，这些选择成为了创作过程的一部分，进而创造出了不同的风格。
    """
    
    @initialize()
    
    @MarkupType:
      None: 'None'
      IntendedLine: 'IntendedLine'
      PerceivedLine: 'PerceivedLine'
      Curvature: 'Curvature'
      
    constructor: ->
      super arguments...
      
      @markupType = new ReactiveField @constructor.MarkupType.None
      
    onActivate: ->
      super arguments...
      
      @markupType @constructor.MarkupType.None
      
      @_changeMarkupTypeInterval = Meteor.setInterval =>
        markupTypes = _.keys @constructor.MarkupType
        currentMarkupTypeIndex = markupTypes.indexOf @markupType()
        
        @markupType markupTypes[(currentMarkupTypeIndex + 1) % 4]
      ,
        2000
      
    onDeactivate: ->
      super arguments...
      
      Meteor.clearInterval @_changeMarkupTypeInterval
    
    markup: ->
      markupType = @markupType()
      return if markupType is @constructor.MarkupType.None
      
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      switch markupType
        when @constructor.MarkupType.IntendedLine
          lineBase = Markup.PixelArt.perceivedLineBase()
          
          for x in [32, 64]
            markup.push
              line: _.extend {}, lineBase,
                arc:
                  x: x
                  y: 32
                  radius: 28.5
                  startAngle: Math.PI
                  endAngle: Math.PI * 1.5
            
        when @constructor.MarkupType.PerceivedLine
          for line in pixelArtEvaluation.layers[0].lines
            markup.push Markup.PixelArt.segmentedPerceivedLine line
            
        when @constructor.MarkupType.Curvature
          for line in pixelArtEvaluation.layers[0].lines
            for curve in line.curvatureCurveParts
              perceivedLineMarkup = Markup.PixelArt.perceivedCurve curve
              perceivedLineMarkup.line.arrow = start: true
              perceivedLineMarkup.line.points = Markup.offsetPoints perceivedLineMarkup.line.points, if curve.clockwise then -2 else 2
    
              markup.push perceivedLineMarkup
        
      markup
