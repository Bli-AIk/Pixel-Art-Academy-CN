AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtSoftware.ReferenceSelection extends PAA.Challenges.Drawing.ReferenceSelection
  @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtSoftware.ReferenceSelection"

  @displayName: -> "选择一张像素画来临摹"

  @description: -> """
    为了确保你已经准备好了去完成绘制像素画的任务，这个挑战要求你临摹一张出自其他游戏的像素画。
  """
  
  @portfolioComponentClass: -> @PortfolioComponent
  @customComponentClass: -> @CustomComponent
  
  @initialize()
  
  urlParameter: -> 'select-pixel-art-software-reference'
  
  width: -> 31
  height: -> 48
