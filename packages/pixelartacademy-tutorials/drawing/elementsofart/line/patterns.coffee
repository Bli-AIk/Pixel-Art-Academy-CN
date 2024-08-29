LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.Patterns extends PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences
  @displayName: -> "图案"
  
  @description: -> """
    我们可以将线条排列成图案，以表现细节、质感或阴影。
  """
  
  @fixedDimensions: -> width: 29, height: 29

  @referenceNames: -> [
    'patterns-bamboo'
    'patterns-sunset'
  ]
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      通过结合直线、曲线和断续线来绘制物体的细节。
    """
    
    @initialize()
