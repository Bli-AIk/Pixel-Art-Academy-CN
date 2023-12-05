LOI = LandsOfIllusions
PAA = PixelArtAcademy

TextOriginPosition = PAA.Practice.Tutorials.Drawing.MarkupEngineComponent.TextOriginPosition
TextAlign = PAA.Practice.Tutorials.Drawing.MarkupEngineComponent.TextAlign
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.PerfectDiagonals extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Diagonals.PerfectDiagonals"

  @displayName: -> "Perfect diagonals"
  
  @description: -> """
    Not all jaggies are created equal and not all diagonals are equally aesthetic.
  """
  
  @fixedDimensions: -> width: 41, height: 21
  
  @resources: -> [
    step1Markup: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/perfectdiagonals-1.svg"
    step2Markup: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/perfectdiagonals-2.svg"
  ]
  
  @steps: -> [
    imageUrl: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/perfectdiagonals.png"
    goalImageUrl: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/perfectdiagonals-1.png"
  ,
    "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/perfectdiagonals-2.png"
  ]
  
  @markup: -> true
  @pixelArtGrading: -> true
  
  @initialize()
  
  Asset = @
  
  class @InstructionStep extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> Asset
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show with the correct step.
      return unless asset.currentActivePathIndex() is @stepNumber() - 1
      
      # Show until the asset is completed.
      not asset.completed()
    
    @resetDelayOnOperationExecuted: -> true
    
  class @Aligned extends @InstructionStep
    @id: -> "#{Asset.id()}.Aligned"
    @stepNumber: -> 1
    
    @message: -> """
      Pixel art is drawn on a raster grid. When we draw lines that align with the grid, the result perfectly matches the intended shapes.
    """
    
    @initialize()
  
  class @NonAligned extends @InstructionStep
    @id: -> "#{Asset.id()}.NonAligned"
    @stepNumber: -> 2
    
    @message: -> """
      When lines don't align with the grid, such as with diagonals and curves, they become jagged—spiky and sharp.
      These stair-like deformations are called 'jaggies' and contribute to the blocky appearance of pixel art.
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
      palette = LOI.palette()
      
      return unless asset = @getActiveAsset()
      return unless pixelArtGrading = asset.pixelArtGrading()
      
      markup = []
      
      # Add jaggies.
      jaggyColor = palette.color Atari2600.hues.red, 3
      jaggyStyle =
        style: "##{jaggyColor.getHexString()}"
        
      return unless trashCanLine = pixelArtGrading.getLinesAt(6, 12)?[0]
      return unless lampLine = pixelArtGrading.getLinesAt(13, 6)?[0]
      return unless handrailLine = pixelArtGrading.getLinesAt(17, 12)?[0]
      
      for line in [trashCanLine, lampLine, handrailLine]
        for jaggy in line.getJaggies()
          markup.push
            pixel: _.extend {}, jaggyStyle,
              x: jaggy.x
              y: jaggy.y
      
      # Add jaggy arrows.
      markupColor = palette.color Atari2600.hues.azure, 4
      markupStyle = "##{markupColor.getHexString()}"
      
      arrowStyle =
        arrow:
          end: true
        style: markupStyle
        
      textStyle =
        size: 6
        lineHeight: 7
        font: 'Small Print Retronator'
        style: markupStyle
        align: TextAlign.Center
      
      markup.push
        line: _.extend {}, arrowStyle,
          points: [
            x: 28.5, y: 16.5
          ,
            x: 25.5, y: 14.5, bezierControlPoints: [
              x: 26.5, y: 16.5
            ,
              x: 26, y: 15
            ]
          ]
        text: _.extend {}, textStyle,
          position:
            x: 28.5, y: 16.5, origin: TextOriginPosition.TopLeft
          value: "not jaggies\n(actual stairs)"

      markup.push
        line: _.extend {}, arrowStyle,
          points: [
            x: 20.5, y: 6.5
          ,
            x: 20.5, y: 9.5, bezierControlPoints: [
              x: 19, y: 8
            ,
              x: 20, y: 9
            ]
          ]
        text: _.extend {}, textStyle,
          position:
            x: 21, y: 6.5, origin: TextOriginPosition.BottomLeft
          value: "jaggies\n(diagonal)"
      
      markup.push
        line: _.extend {}, arrowStyle,
          points: [
            x: 11, y: 4
          ,
            x: 12.5, y: 5, bezierControlPoints: [
              x: 11, y: 5
            ,
              x: 12, y: 5
            ]
          ]
        text: _.extend {}, textStyle,
          position:
            x: 11, y: 3.5, origin: TextOriginPosition.BottomCenter
          value: "jaggies\n(curve)"
      
      markup.push
        line: _.extend {}, arrowStyle,
          points: [
            x: 4.5, y: 10
          ,
            x: 5.5, y: 11.5, bezierControlPoints: [
              x: 4.5, y: 11
            ,
              x: 5.25, y: 11.25
            ]
          ]
        text: _.extend {}, textStyle,
          position:
            x: 4.5, y: 9.5, origin: TextOriginPosition.BottomCenter
          value: "not a jaggy\n(sharp corner)"
      
      # Add intended lines.
      intendedLineColor = palette.color Atari2600.hues.azure, 5
      intendedLineStyle =
        style: "##{intendedLineColor.getHexString()}"
      
      markup.push
        line: _.extend {}, intendedLineStyle,
          points: [
            x: 18.5, y: 16.5
          ,
            x: 18.5, y: 15.5
          ,
            x: 20.5, y: 15.5
          ,
            x: 20.5, y: 14.5
          ,
            x: 22.5, y: 14.5
          ,
            x: 22.5, y: 13.5
          ,
            x: 24.5, y: 13.5
          ,
            x: 24.5, y: 12.5
          ,
            x: 26.5, y: 12.5
          ]
      
      markup.push
        line: _.extend {}, intendedLineStyle,
          points: [
            x: 16.5, y: 14.5
          ,
            x: 17.5, y: 12.75, bezierControlPoints: [
              x: 16.5, y: 13.5
            ,
              x: 17, y: 13
            ]
          ,
            x: 23.25, y: 9.875
          ,
            x: 25.125, y: 10.125, bezierControlPoints: [
              x: 23.75, y: 9.625
            ,
              x: 24.625, y: 9.625
            ]
          ,
            x: 25.5, y: 11.125, bezierControlPoints: [
              x: 25.325, y: 10.325
            ,
              x: 25.5, y: 10.625
            ]
          ]
      
      markup.push
        line: _.extend {}, intendedLineStyle,
          points: [
            x: 13.5, y: 6.25
          ,
            x: 15.25, y: 4.5, bezierControlPoints: [
              x: 13.5, y: 5.25
            ,
              x: 14.26, y: 4.5
            ]
          ]
      
      markup.push
        line: _.extend {}, intendedLineStyle,
          points: [
            x: 7.5, y: 16
          ,
            x: 6.625, y: 12.5
          ,
            x: 10.375, y: 12.5
          ,
            x: 9.5, y: 16
          ]
      
      markup
