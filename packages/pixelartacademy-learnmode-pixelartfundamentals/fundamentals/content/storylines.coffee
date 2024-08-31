PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.Storylines extends LM.Content.FutureContent
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Storylines'
  @displayName: -> "剧情"
  @contents: -> [
    @Japan
    @US
    @UK
  ]
  @initialize()

  class @Japan extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Storylines.Japan'
    @displayName: -> "1970年代的日本"
    @description: -> "让我们开启日本之旅，在那里你将为街机游戏绘制像素画。"
    @initialize()

  class @US extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Storylines.US'
    @displayName: -> "1980年代的美国"
    @description: -> "让我们开启美国之旅，在那里你将成为1984年初代苹果电脑的平面设计师。"
    @initialize()

  class @UK extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Storylines.UK'
    @displayName: -> "1980年代的英国"
    @description: -> "让我们开启英国之旅，在那里你将为ZX Spectrum的游戏绘制像素画。"
    @initialize()
