LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.Edges extends PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences
  @displayName: -> "边缘线"
  
  @description: -> """
    线条也用于绘制物体的内部边缘。
  """
  
  @fixedDimensions: -> width: 33, height: 33

  @referenceNames: -> [
    'edges-cube'
    'edges-pottedplant'
  ]
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      通过结合直线、曲线和断续线来绘制物体。
    """
    
    @initialize()
