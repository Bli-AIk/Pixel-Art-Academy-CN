LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.BrokenLines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "断续线"
  @displayNameBack: -> "Broken lines"

  @description: -> """
    线条在拐角处经常会改变方向，以便形成更复杂的图案。
  """

  @fixedDimensions: -> width: 65, height: 27
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      把直线和曲线连接在一起，从一个拐角连到另一个拐角。
    """
    
    @initialize()
