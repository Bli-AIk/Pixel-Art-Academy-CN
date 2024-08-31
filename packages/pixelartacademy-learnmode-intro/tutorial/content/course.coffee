LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Content.Course extends LM.Content.Course
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Course'

  @displayName: -> "像素画工具"

  @description: -> """
    学习基础的像素画工具，并为你的第一个游戏绘制像素画。
  """
  
  @tags: -> [
    LM.Content.Tags.Free
  ]

  @contents: -> [
    LM.Intro.Tutorial.Content.Goals
    LM.Intro.Tutorial.Content.DrawingTutorials
    LM.Intro.Tutorial.Content.DrawingChallenges
    LM.Intro.Tutorial.Content.Projects
    LM.Intro.Tutorial.Content.Apps
  ]

  @initialize()
