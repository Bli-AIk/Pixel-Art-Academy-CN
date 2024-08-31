AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtLineArt.ReferenceSelection extends PAA.Challenges.Drawing.ReferenceSelection
  @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtLineArt.ReferenceSelection"

  @displayName: -> "选择一张参考图来临摹"

  @description: -> """
    找一个你最喜欢的角色，然后绘制ta的同人像素画吧。
  """

  @portfolioComponentClass: -> @PortfolioComponent
  @customComponentClass: -> @CustomComponent
  
  @initialize()
  
  urlParameter: -> 'select-pixel-art-line-art-reference'
  
  width: -> 63
  height: -> 81
