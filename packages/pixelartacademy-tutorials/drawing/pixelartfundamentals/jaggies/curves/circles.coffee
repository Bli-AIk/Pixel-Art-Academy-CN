LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.Circles extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.Circles"

  @displayName: -> "圆形"
  
  @description: -> """
    毫无疑问，用像素画出最圆的形状，往往是一个不小的挑战。
  """
  
  @fixedDimensions: -> width: 205, height: 98
  @minClipboardScale: -> 1
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/curves/circles-#{step}.png" for step in [1..11]
  
  @markup: -> true
  
  @initialize()
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
    @sizeNumberXCoordinates = [4.5, 10, 16.5, 24, 32.5, 42, 52.5, 64, 76.5, 90, 104.5, 120, 136.5, 154, 172.5, 192]

    @maxSizeNumber: -> throw new AE.NotImplementedException "Step needs to specify up to which number to draw the sizes on top."

    markup: ->
      markup = []
      
      textBase = _.extend {}, Markup.textBase(),
        size: 8
        lineHeight: 10
      
      for number in [1..@constructor.maxSizeNumber()]
        markup.push
          text: _.extend {}, textBase,
            position:
              x: @constructor.sizeNumberXCoordinates[number - 1], y: -1, origin: Markup.TextOriginPosition.BottomCenter
            value: "#{number}"
  
      markup
      
    _addCircle: (markup, x, y, radius) ->
      markup.push
        line: _.extend {}, Markup.PixelArt.intendedLineBase(),
          arc: {x, y, radius}
  
  class @Size1 extends @StepInstruction
    @id: -> "#{Asset.id()}.Size1"
    @stepNumber: -> 1
    @maxSizeNumber: -> 1
    
    @message: -> """
      我们能绘制的最小的圆形，就是一个像素块。
    """

    @initialize()
  
    markup: ->
      markup = super arguments...
      
      markupStyle = Markup.defaultStyle()
      
      arrowBase =
        arrow:
          end: true
        style: markupStyle
      
      textBase = Markup.textBase()
      
      markup.push
        line: _.extend {}, arrowBase,
          points: [
            x: 8.5, y: 7
          ,
            x: 5.5, y: 5.5, bezierControlPoints: [
              x: 7, y: 7
            ,
              x: 5.75, y: 5.75
            ]
          ]
        text: _.extend {}, textBase,
          position:
            x: 9.5, y: 7, origin: Markup.TextOriginPosition.MiddleLeft
          value: "从这儿\n开始"
          
      markup
      
  class @Size2 extends @StepInstruction
    @id: -> "#{Asset.id()}.Size2"
    @stepNumber: -> 2
    @maxSizeNumber: -> 2
    
    @message: -> """
      和1像素大小的圆形一样，2像素大小的圆形也容易被看成方形。\n
      但在特定的情境下（例如让它作为汽车的车轮时），其他人就会认为它是圆形。
    """
    
    @initialize()
  
  class @Size3 extends @StepInstruction
    @id: -> "#{Asset.id()}.Size3"
    @assetClass: -> Asset
    @stepNumber: -> 3
    @maxSizeNumber: -> 3
    
    @message: -> """
      3像素大小的圆形，就显得更像方形了。
    """
    
    @initialize()
  
  class @Size3Alternative extends @StepInstruction
    @id: -> "#{Asset.id()}.Size3Alternative"
    @assetClass: -> Asset
    @stepNumber: -> 4
    @maxSizeNumber: -> 3
    
    @message: -> """
      我们现在有足够的空间来移除最外一圈的拐角像素。
    """
    
    @initialize()

    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 4.5, 4.5, 0.25
      @_addCircle markup, 10, 5, 0.5
      @_addCircle markup, 16.5, 5.5, 1
      
      markup
      
  class @Sizes4To6 extends @StepInstruction
    @id: -> "#{Asset.id()}.Sizes4To6"
    @assetClass: -> Asset
    @stepNumber: -> 5
    @maxSizeNumber: -> 6
    
    @message: -> """
      当我们用这种形状去画更大的圆时，它慢慢变得像一个带圆角的正方形。
    """
    
    @initialize()
  class @Size6Alternative extends @StepInstruction
    @id: -> "#{Asset.id()}.Size6Alternative"
    @assetClass: -> Asset
    @stepNumber: -> 6
    @maxSizeNumber: -> 6
    
    @message: -> """
      现在，这里的空间更充足了，我们可以在拐角处再插入一个像素，来分隔较长的线段。
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 16.5, 10.5, 1
      @_addCircle markup, 24, 11, 1.5
      @_addCircle markup, 32.5, 11.5, 2
      @_addCircle markup, 42, 12, 2.5
      
      markup
      
  class @Sizes7To10 extends @StepInstruction
    @id: -> "#{Asset.id()}.Sizes7To10"
    @assetClass: -> Asset
    @stepNumber: -> 7
    @maxSizeNumber: -> 10
    
    @message: -> """
      随着圆一步步地扩大，它又逐渐像一个带圆角的方形了。
    """
    
    @initialize()
    
  class @Sizes9To11 extends @StepInstruction
    @id: -> "#{Asset.id()}.Sizes9To11"
    @assetClass: -> Asset
    @stepNumber: -> 8
    @maxSizeNumber: -> 11
    
    @message: -> """
      我们可以在拐角再再插入一个像素，让它来连接最外部的线段。\n
      但由于插入的这两个像素形成了45°斜线，最终让圆看起来更像一个八边形。
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 42, 20, 2.5
      @_addCircle markup, 52.5, 20.5, 3
      @_addCircle markup, 64, 21, 3.5
      @_addCircle markup, 76.5, 21.5, 4
      @_addCircle markup, 90, 22, 4.5
      
      markup
  
  class @Sizes10To14 extends @StepInstruction
    @id: -> "#{Asset.id()}.Sizes10To14"
    @assetClass: -> Asset
    @stepNumber: -> 9
    @maxSizeNumber: -> 14
    
    @message: -> """
      为了避免形成斜线，我们可以将插入像素延长至两格。
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 76.5, 33.5, 4
      @_addCircle markup, 90, 34, 4.5
      @_addCircle markup, 104.5, 34.5, 5
      @_addCircle markup, 120, 35, 5.5
      
      markup
      
  class @Sizes13To16 extends @StepInstruction
    @id: -> "#{Asset.id()}.Sizes13To16"
    @assetClass: -> Asset
    @stepNumber: -> 10
    @maxSizeNumber: -> 16
    
    @message: -> """
      空间现在非常充足，我们可以再在拐角处插入一个像素。
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 90, 48, 4.5
      @_addCircle markup, 104.5, 48.5, 5
      @_addCircle markup, 120, 49, 5.5
      @_addCircle markup, 136.5, 49.5, 6
      @_addCircle markup, 154, 50, 6.5
      
      markup

  class @Size16Alternative extends @StepInstruction
    @id: -> "#{Asset.id()}.Size16Alternative"
    @assetClass: -> Asset
    @stepNumber: -> 11
    @maxSizeNumber: -> 16
    
    @message: -> """
      最后，对于16像素大小的圆，你可以在拐角处多插入一个像素。
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      @_addCircle markup, 120, 65, 5.5
      @_addCircle markup, 136.5, 65.5, 6
      @_addCircle markup, 154, 66, 6.5
      @_addCircle markup, 172.5, 66.5, 7
      @_addCircle markup, 192, 67, 7.5
      
      markup

  class @Complete extends @StepInstruction
    @id: -> "#{Asset.id()}.Complete"
    @maxSizeNumber: -> 16
    
    @message: -> """
      更大的圆可以通过椭圆工具轻松绘制，而画较小尺寸的圆形时，手动绘制的形状往往比工具绘制的更为美观。
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
      
    @initialize()
