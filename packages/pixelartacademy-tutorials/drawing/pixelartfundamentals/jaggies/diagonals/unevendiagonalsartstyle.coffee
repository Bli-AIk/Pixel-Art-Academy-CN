AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.UnevenDiagonalsArtStyle extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.UnevenDiagonalsArtStyle"

  @displayName: -> "将不均匀斜线作为一种艺术风格"
  
  @description: -> """
    规则是死的，但人是活的。遵守规则与否，取决于你的选择。
  """
  
  @bitmapInfo: -> """
    出自[《Into The Breach》](https://subsetgames.com/itb.html)，2018年

    画师：Jay Ma
  """
  
  @fixedDimensions: -> width: 56, height: 86
  @minClipboardScale: -> 1
  
  @resources: ->
    resources = layers: []
    
    for layer in [1..4]
      resources.layers.push new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/unevendiagonalsartstyle-#{layer}.png"
      
    resources

  @pixelArtEvaluation: -> true
  @markup: -> true
  
  @properties: ->
    pixelArtScaling: true
    pixelArtEvaluation:
      editable: true
      allowedCriteria: [PAE.Criteria.EvenDiagonals]
      evenDiagonals:
        segmentLengths: {}
  
  @initialize()
  
  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
  ]
  
  initializeSteps: ->
    fixedDimensions = @constructor.fixedDimensions()
    
    stepAreaBounds =
      x: 0
      y: 0
      width: fixedDimensions.width
      height: fixedDimensions.height
    
    stepArea = new @constructor.StepArea @, stepAreaBounds
    
    new @constructor.DisableEvenDiagonalsEvaluation @, stepArea,
      startPixels: @resources.layers
  
  Asset = @
  
  class @DisableEvenDiagonalsEvaluation extends TutorialBitmap.Step
    completed: ->
      not @tutorialBitmap.bitmap().properties.pixelArtEvaluation.evenDiagonals
      
    solve: ->
      # Disable pixel art evaluation.
      bitmap = @tutorialBitmap.bitmap()
      pixelArtEvaluation = bitmap.properties.pixelArtEvaluation
      delete pixelArtEvaluation.evenDiagonals
      
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.id(), bitmap, 'pixelArtEvaluation', pixelArtEvaluation
      AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, updatePropertyAction, new Date
    
    hasPixel: (x, y) ->
      # We simply require pixels everywhere we have them.
      @tutorialBitmap.bitmap().findPixelAtAbsoluteCoordinates x, y
  
  class @Convention extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Convention"
    @assetClass: -> Asset
    
    @message: -> """
      均匀斜线只是一种约定俗成的做法，使用或不使用它，都可以创作出杰出的作品。\n
      正如这幅出自《Into the Breach》的作品展示的那样，俯视角不仅提升了游戏场景的清晰度，还营造出了独特的风格。

      打开评估页面以继续。
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      not asset.completed()
    
    @completedConditions: ->
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.active()
    
    @resetCompletedConditions: ->
      return true unless @getActiveAsset()
      
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      not pixelArtEvaluation.active()
      
    @priority: -> 1
    
    @initialize()
    
  class @TurnOff extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.TurnOff"
    @assetClass: -> Asset
    
    @message: -> """
      在这里，不均匀、断开的斜线是刻意而为的。别忘了，在日后，你也可以做出同样的选择。
      
      为了完成本课，请取消“均匀斜线评估”。
    """
    
    @displaySide: -> PAA.PixelPad.Systems.Instructions.DisplaySide.Top
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
      
      # Note: We have to activate only when the evaluation paper is open, so that the onActivate animation
      # happens immediately, even before the previous instruction hides and displays this one.
      return unless editor = @getEditor()
      return unless pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.active()
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      
      camera.translateTo {x: 28, y: 16}, 1
      camera.scaleTo 5, 1

    markup: ->
      return [] unless asset = @getActiveAsset()
      return [] unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      linePart = pixelArtEvaluation.getLinePartsAt(40, 21)[0]
      Markup.PixelArt.straightLineBreakdown linePart
