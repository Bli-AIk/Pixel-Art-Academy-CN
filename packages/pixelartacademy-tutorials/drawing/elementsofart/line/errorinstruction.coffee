AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.ErrorInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @id: -> "PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Line.ErrorInstruction"

  @message: -> """
      你画的不太对，不过别担心，
      你可以用橡皮擦工具轻松修复。
    """
  
  @getActiveAsset: ->
    # We must be in the editor on the provided asset.
    return unless editor = @getEditor()
    return unless editor.drawingActive()
    
    return unless asset = editor.activeAsset()
    return unless asset instanceof PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
    return unless asset.initialized()
    
    asset
    
  @activeConditions: ->
    return unless asset = @getActiveAsset()
    
    # Show when there are any extra pixels present.
    return unless asset.hasExtraPixels()
    
    # Wait for the stroke to have finished.
    editor = @getEditor()
    activeTool = editor.interface.activeTool()
    
    return true unless activeTool instanceof LOI.Assets.SpriteEditor.Tools.Pencil
    
    pencil = activeTool
    not pencil.strokeActive()
  
  @priority: -> 1
  
  @initialize()
