PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.DrawingEditors extends LM.Content.FutureContent
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingEditors'
  @displayName: -> "绘图编辑器"
  @contents: -> [
    @PixelPaint
  ]
  @initialize()

  class @PixelPaint extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingEditors.PixelPaint'
    @displayName: -> "PixelPaint"
    @initialize()
