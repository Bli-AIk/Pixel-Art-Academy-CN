LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.Outlines2 extends PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences
  @displayName: -> "轮廓线：第二课"
  
  @description: -> """
    一些物体可以用更具风格化的方式绘制。
  """
  
  @fixedDimensions: -> width: 29, height: 39

  @referenceNames: -> [
    'outlines-palmtree'
    'outlines-sprucetree'
  ]
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      通过结合直线、曲线和断续线来绘制物体的轮廓。 
    """
    
    @initialize()
