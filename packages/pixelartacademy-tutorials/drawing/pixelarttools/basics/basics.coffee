AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics extends PAA.Tutorials.Drawing.PixelArtTools
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics'

  @fullName: -> "像素画工具: 基础部分"

  @initialize()

  @assets: -> [
    @Pencil
    @Eraser
    @ColorFill
    @ColorFill2
    @ColorFill3
    @BasicTools
    @Shortcuts
    @References
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.Intro.Tutorial
    chapter.getContent PAA.LearnMode.Intro.Tutorial.Content.DrawingTutorials.Basics
