LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.LineWidth extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.LineWidth"

  @displayName: -> "线条宽度"
  
  @description: -> """
    你可以使用重复像素来改变线条的宽度（粗细程度）。
  """
  
  @fixedDimensions: -> width: 45, height: 45
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/linewidth-#{step}.png" for step in [1..5]
  
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
      
      # Add perceived lines for straight lines during the lesson.
      unless asset.completed()
        for line in pixelArtEvaluation.layers[0].lines
          continue unless line.parts.length is 1
          linePart = line.parts[0]
          continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
          
          markup.push Markup.PixelArt.perceivedStraightLine linePart
      
      # Add titles.
      textBase = Markup.textBase()
      
      if @constructor.stepNumber() >= 1
        markup.push
          text: _.extend {}, textBase,
            position:
              x: 0.5, y: 0.5, origin: Markup.TextOriginPosition.TopLeft
            value: "细线（1格宽）"
      
      if @constructor.stepNumber() >= 3
        markup.push
          text: _.extend {}, textBase,
            position:
              x: 44.5, y: 0.5, origin: Markup.TextOriginPosition.TopRight
            value: "粗线（1格宽）"
            
      if @constructor.stepNumber() >= 4
        markup.push
          text: _.extend {}, textBase,
            position:
              x: 44.5, y: 44.5, origin: Markup.TextOriginPosition.BottomRight
            value: "宽线（2格宽）"
            
      # Add widths.
      markupStyle = Markup.defaultStyle()
      
      arrowBase =
        arrow:
          end: true
        style: markupStyle
      
      textBase = Markup.textBase()
      
      width1X = 3.5
      width0XY = 11
      
      endOffset = 0.1
      endOffsetZeroWidth = 0.2
      startOffset = 1.2
      startOffsetVertical = 1.6
      
      if 1 <= @constructor.stepNumber() <= 2 and pixelArtEvaluation.getLinesBetween({x: 3, y: 22}, {x: 14, y: 22}).length
        markup.push
          line: _.extend {}, arrowBase,
            points: [
              x: width1X, y: 23 + startOffsetVertical
            ,
              x: width1X, y: 23 + endOffset
            ]
        ,
          line: _.extend {}, arrowBase,
            points: [
              x: width1X, y: 22 - startOffsetVertical
            ,
              x: width1X, y: 22 - endOffset
            ]
          text: _.extend {}, textBase,
            position:
              x: width1X, y: 22 - startOffsetVertical, origin: Markup.TextOriginPosition.BottomCenter
            value: "1"
      
      if @constructor.stepNumber() is 2 and pixelArtEvaluation.getLinesBetween({x: 8, y: 8}, {x: 17, y: 17}).length
        markup.push
          line: _.extend {}, arrowBase,
            points: [
              x: 8 - startOffset, y: 9 + startOffset
            ,
              x: 8 - endOffset, y: 9 + endOffset
            ]
        ,
          line: _.extend {}, arrowBase,
            points: [
              x: 9 + startOffset, y: 8 - startOffset
            ,
              x: 9 + endOffset, y: 8 - endOffset
            ]
          text: _.extend {}, textBase,
            position:
              x: 9 + startOffset, y: 8 - startOffset, origin: Markup.TextOriginPosition.BottomLeft
            value: "1.4"
        ,
          line: _.extend {}, arrowBase,
            points: [
              x: width0XY - startOffset, y: width0XY + startOffset
            ,
              x: width0XY - endOffsetZeroWidth, y: width0XY + endOffsetZeroWidth
            ]
        ,
          line: _.extend {}, arrowBase,
            points: [
              x: width0XY + startOffset, y: width0XY - startOffset
            ,
              x: width0XY + endOffsetZeroWidth, y: width0XY - endOffsetZeroWidth
            ]
          text: _.extend {}, textBase,
            position:
              x: width0XY + startOffset, y: width0XY - startOffset, origin: Markup.TextOriginPosition.BottomLeft
            value: "0"
            
      markup
      
  class @Width1 extends @StepInstruction
    @id: -> "#{Asset.id()}.Width1"
    @stepNumber: -> 1
    
    @message: -> """
      在像素画中，线条的宽度通常是1格，但这种线条只能在水平或垂直方向上完美绘制。
    """

    @initialize()

  class @Width1Thin extends @StepInstruction
    @id: -> "#{Asset.id()}.Width1Thin"
    @stepNumber: -> 2
    
    @message: -> """
      对于斜线而言，出于锯齿的影响，线条的宽度会有所变化。\n
      一条1格宽的细线，在最宽的地方能达到1.4像素，而在锯齿衔接处则会降至0像素。
    """
    
    @initialize()
    
  class @Width1Thick extends @StepInstruction
    @id: -> "#{Asset.id()}.Width1Thick"
    @stepNumber: -> 3
    
    @message: -> """
      如果我们希望这根线条能够保持清晰，并确保至少有1像素格的宽度，我们就需要添加重复像素，从而实现1格宽的粗线。
    """
    
    @initialize()
    
  class @Width2 extends @StepInstruction
    @id: -> "#{Asset.id()}.Width2"
    @stepNumber: -> 4
    
    @message: -> """
      2像素宽的线条虽然不常见，但如果空间足够，你也可以进行绘制。\n
      使用+/-键，或按住Ctrl键并滑动鼠标滚轮，以调整画笔的大小。
    """
    
    @initialize()
    
  class @Width2ThinThick extends @StepInstruction
    @id: -> "#{Asset.id()}.Width2ThinThick"
    @stepNumber: -> 5
    
    @message: -> """
      在这里，我们同样可以选择绘制2格宽的细斜线或粗斜线。
    """
    
    @initialize()
  
  class @Complete extends @StepInstruction
    @id: -> "#{Asset.id()}.Complete"
    @stepNumber: -> 6
    
    @activeDisplayState: ->
      # We only have markup without a message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
