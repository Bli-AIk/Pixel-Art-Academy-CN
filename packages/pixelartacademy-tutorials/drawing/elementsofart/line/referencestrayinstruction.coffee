AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.ReferencesTrayInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @id: -> "PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Line.ReferencesTrayInstruction"
  
  @message: -> """
    打开参考资料托盘，选择一个您想要绘制的对象。
  """
  
  @getActiveAsset: ->
    # We must be in the editor on the provided asset.
    return unless editor = @getEditor()
    return unless editor.drawingActive()
    
    return unless asset = editor.activeAsset()
    return unless asset instanceof PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences
    
    asset
  
  @activeConditions: ->
    return unless asset = @getActiveAsset()
    
    # Show until the image has a displayed reference.
    bitmap = asset.bitmap()
    displayedReferences = _.filter bitmap.references, (reference) => reference.displayed
    not displayedReferences.length
    
  @delayDuration: ->
    return @defaultDelayDuration unless asset = @getActiveAsset()
  
    # Only the first asset with references needs immediate instructions.
    if asset instanceof PAA.Tutorials.Drawing.ElementsOfArt.Line.Outlines then 0 else @defaultDelayDuration
  
  @priority: -> 1
  
  @initialize()
  
  
