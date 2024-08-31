LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation
Jaggies2 = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Jaggies2

class Jaggies2.Instructions
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Jaggies2
    
    # The length of the arrow to indicate a pixel move.
    @movePixelArrowLength = 1.2
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @getPixelArtEvaluation: ->
      drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    perceivedLineMarkupForStep: (asset, pixelArtEvaluation, stepNumber) ->
      markup = []
      lines = []
      
      step = asset.stepAreas()[0].steps()[stepNumber - 1]
      
      for point in step.goalPixels
        lines.push line for line in pixelArtEvaluation.getLinesAt(point.x, point.y) when line not in lines
      
      for line in lines
        markup.push Markup.PixelArt.segmentedPerceivedLine line
      
      markup
      
    doublesMarkup: (pixelArtEvaluation, point) ->
      markup = []
      lines = pixelArtEvaluation.getLinesAt point.x, point.y
      
      return unless asset = @getActiveAsset()
      pixelArtEvaluationProperty = asset.bitmap().properties.pixelArtEvaluation
      
      for line in lines
        markup.push Markup.PixelArt.pixelPerfectLineErrors(line, true, true, pixelArtEvaluationProperty)...
      
      markup
    
  class @Line1 extends @StepInstruction
    @id: -> "#{Jaggies2.id()}.Line1"
    @stepNumber: -> 1
    
    @message: -> """
      像素画中的线条是由多行（或多列）像素块构成的，这些像素块通常只在拐角处相连。
    """
    
    @initialize()
  
  class @Line2Draw extends @StepInstruction
    @id: -> "#{Jaggies2.id()}.Line2Draw"
    @stepNumber: -> 2
    
    @message: -> """
      然而，直接上手画线时，我们常常会不小心连上多个相邻行的像素块，进而导致行与行连接在一起。
    """
    
    @initialize()

  class @Line2Fix extends @StepInstruction
    @id: -> "#{Jaggies2.id()}.Line2Fix"
    @stepNumber: -> 3
    
    @message: -> """
      这些意外多出的像素块被称为“重复像素”，想画出最简洁的一条像素线条，保留其中一个像素块即可。

      擦掉每组“重复像素”中的任意一个像素块吧。
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      @doublesMarkup pixelArtEvaluation, {x: 3, y:9}
  
  class @Line3Draw extends @StepInstruction
    @id: -> "#{Jaggies2.id()}.Line3Draw"
    @stepNumber: -> 4
    
    @message: -> """
      重复像素会在感知线条中产生锯齿，它会破坏线条的平滑流畅感。
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      @perceivedLineMarkupForStep asset, pixelArtEvaluation, 4
  
  class @Line3Fix extends @StepInstruction
    @id: -> "#{Jaggies2.id()}.Line3Fix"
    @stepNumber: -> 5
    
    @message: -> """
      在这里也擦掉一个“重复像素”中的像素块吧。
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      [
        @doublesMarkup(pixelArtEvaluation, {x: 3, y:14})...
        @perceivedLineMarkupForStep(asset, pixelArtEvaluation, 4)...
      ]
  
  class @Line4Draw extends @StepInstruction
    @id: -> "#{Jaggies2.id()}.Line4Draw"
    @stepNumber: -> 6
    
    @message: -> """
      即使没有重复像素，某些线条的排列方式仍然会使感知线条产生锯齿。 
      
      如今，像素画师们也常用“锯齿”来指代这些不需要的像素。
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = for stepNumber in [4, 6]
        @perceivedLineMarkupForStep asset, pixelArtEvaluation, stepNumber
      
      _.flatten markup
  
  class @Line4Fix extends @StepInstruction
    @id: -> "#{Jaggies2.id()}.Line4Fix"
    @stepNumber: -> 7
    
    @message: -> """
      把这块像素挪个位置，问题就解决了。
      
      我们将在后续的像素画曲线教程中对此进行深入讲解。
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = for stepNumber in [4, 6]
        @perceivedLineMarkupForStep asset, pixelArtEvaluation, stepNumber
        
      markup = _.flatten markup
      
      bitmap = asset.bitmap()
      
      unless bitmap.findPixelAtAbsoluteCoordinates 25, 6
        markupStyle = Markup.errorStyle()
        
        arrowBase =
          arrow:
            end: true
            width: 0.5
            length: 0.25
          style: markupStyle
        
        markup.push
          line: _.extend {}, arrowBase,
            points: [
              x: 25.5, y: 7.5
            ,
              x: 25.5, y: 7.5 - @constructor.movePixelArrowLength
            ]
        
      markup
  
  class @Line5Draw extends @StepInstruction
    @id: -> "#{Jaggies2.id()}.Line5Draw"
    @stepNumber: -> 8
    
    @message: -> """
      同样，多余的锯齿会干扰斜线的流动感。
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = for stepNumber in [4, 6, 8]
        @perceivedLineMarkupForStep asset, pixelArtEvaluation, stepNumber
        
      _.flatten markup
      
  class @Line5Fix extends @StepInstruction
    @id: -> "#{Jaggies2.id()}.Line5Fix"
    @stepNumber: -> 9
    
    @message: -> """
      那么，移动这些像素吧。
      
      虽然画出的线条与之前有所不同，但画师们通常会调整线条的角度，从而创造出理想的锯齿效果。

      我们将在斜线教程中进一步探讨这一点。
    """
    
    @initialize()
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = for stepNumber in [4, 6, 8]
        @perceivedLineMarkupForStep asset, pixelArtEvaluation, stepNumber
        
      markup = _.flatten markup
      
      markupStyle = Markup.errorStyle()
      
      arrowBase =
        arrow:
          end: true
          width: 0.5
          length: 0.25
        style: markupStyle
      
      bitmap = asset.bitmap()
      
      for arrowData in [{x: 23.5, y: 17.5, sign: 1}, {x: 24.5, y: 16.5, sign: 1}, {x: 32.5, y: 10.5, sign: -1}, {x: 33.5, y: 9.5, sign: -1}]
        unless bitmap.findPixelAtAbsoluteCoordinates Math.floor(arrowData.x + arrowData.sign), Math.floor(arrowData.y)
          markup.push
            line: _.extend {}, arrowBase,
              points: [
                x: arrowData.x
                y: arrowData.y
              ,
                x: arrowData.x + arrowData.sign * @constructor.movePixelArrowLength
                y: arrowData.y
              ]
            
      markup
      
  class @Complete extends @StepInstruction
    @id: -> "#{Jaggies2.id()}.Complete"
    
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
      
      markup = for stepNumber in [4, 6, 8]
        @perceivedLineMarkupForStep asset, pixelArtEvaluation, stepNumber
      
      _.flatten markup
