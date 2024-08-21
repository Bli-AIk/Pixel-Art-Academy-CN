LOI = LandsOfIllusions
PAA = PixelArtAcademy

TextOriginPosition = PAA.Practice.Helpers.Drawing.Markup.TextOriginPosition
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtTools.Helpers.Lines extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Helpers.Lines'

  @displayName: -> "直线绘制"

  @description: -> """
      学习如何用铅笔工具快速绘制直线。
    """

  @fixedDimensions: -> width: 57, height: 32
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black
  
  @steps: -> for step in [1..5]
    goalImageUrl: "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/720-#{step}.png"
    imageUrl: "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/720.png" if step is 1
  
  @bitmapInfo: -> "出自1987年雅达利(Atari)开发的《720°》(ZX Spectrum版)"

  @markup: -> true

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
  ]
  
  initializeSteps: ->
    super arguments...
    
    # Allow steps to complete with extra pixels so that we can show only line ends, but continue with a line drawn.
    stepArea = @stepAreas()[0]
    
    for step, stepIndex in stepArea.steps() when stepIndex in [1, 2]
      step.options.canCompleteWithExtraPixels = true
      
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> Asset
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show with the correct step.
      asset.stepAreas()[0].activeStepIndex() is @stepNumber() - 1

  class @Tool extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tool"
    @assetClass: -> Asset
    
    @message: -> """
        选择铅笔工具去画画，
        就像你之前做的那样。
    """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
      not asset.completed()
      
    @completedConditions: ->
      editor = @getEditor()
      editor.interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.Pencil.id()
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @initialize()
  
  class @LineStart extends @StepInstruction
    @id: -> "#{Asset.id()}.LineStart"
    @stepNumber: -> 1
    
    @message: -> """
      点击指定的像素，做好画直线的准备。
    """
    
    @initialize()
    
    markup: ->
      markupStyle = Markup.defaultStyle()
      
      arrowBase =
        arrow:
          end: true
        style: markupStyle
      
      textBase = Markup.textBase()
      
      [
        line: _.extend {}, arrowBase,
          points: [
            x: 4, y: 20.5
          ,
            x: 5.5, y: 23.5, bezierControlPoints: [
              x: 4, y: 22
            ,
              x: 5.25, y: 23.25
            ]
          ]
        text: _.extend {}, textBase,
          position:
            x: 4, y: 20, origin: TextOriginPosition.BottomCenter
          value: "start\nhere"
      ]
  
  class @LineEnd extends @StepInstruction
    @id: -> "#{Asset.id()}.LineEnd"
    @stepNumber: -> 2
    
    @message: -> """
      按住 Shift 键，
      并点击直线末尾处的像素块，
      以绘制线条
    """
    
    @initialize()
  
  class @LineSequence extends @StepInstruction
    @id: -> "#{Asset.id()}.LineSequence"
    @stepNumber: -> 3
    
    @message: -> """
      您可以持续按住 Shift 键以连接多行。
    """

    @initialize()
    
  class @SeparateLines extends @StepInstruction
    @id: -> "#{Asset.id()}.SeparateLines"
    @stepNumber: -> 4
    
    @message: -> """
      当您想要画新的直线时，
      只需松开 Shift 键。
    """

    @initialize()
