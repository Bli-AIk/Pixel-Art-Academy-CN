LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.BrokenLines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "Broken lines"

  @description: -> """
    Lines often change direction in corners to create more complex designs.
  """

  @fixedDimensions: -> width: 65, height: 27
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Chain together straight and curved lines from corner to corner.
    """
    
    @initialize()
  
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      You went too far from the line, but don't worry. You can easily fix it with the eraser.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any extra pixels present.
      asset.hasExtraPixels()
    
    @priority: -> 1
    
    @initialize()
