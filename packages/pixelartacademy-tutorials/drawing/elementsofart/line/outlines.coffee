LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.Outlines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences
  @displayName: -> "轮廓线"
  
  @description: -> """
    把线条连接在一起，就可以勾勒出物体的轮廓。
  """
  
  @fixedDimensions: -> width: 25, height: 25

  @referenceNames: -> [
    'outlines-banana'
    'outlines-orange'
    'outlines-apple'
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
