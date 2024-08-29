LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.BrokenLines2 extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "断续线：第二课"
  @displayNameBack: -> "Broken lines 2"
  @description: -> """
    你可能没有意识到，但你在写字时其实一直在练习画断续线。
  """

  @fixedDimensions: -> width: 54, height: 21
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      将你画直线和曲线的方法结合起来，画出所有的数字。
    """
    
    @initialize()
