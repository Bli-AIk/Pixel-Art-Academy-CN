LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.Course extends LM.Content.Course
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Course'

  @displayName: -> "像素画基础"

  @description: -> """
    学习像素画的基础概念，如锯齿、抗锯齿和抖动。
  """
  
  @tags: -> [
    LM.Content.Tags.BaseGame
    LM.Content.Tags.WIP
  ]

  @contents: -> [
    LM.PixelArtFundamentals.Fundamentals.Content.Storylines
    LM.PixelArtFundamentals.Fundamentals.Content.Goals
    LM.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials
    LM.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges
    LM.PixelArtFundamentals.Fundamentals.Content.Projects
    LM.PixelArtFundamentals.Fundamentals.Content.Apps
    LM.PixelArtFundamentals.Fundamentals.Content.DrawingEditors
  ]

  @initialize()
