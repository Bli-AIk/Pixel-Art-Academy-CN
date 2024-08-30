AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines extends PAA.Practice.Tutorials.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines'

  @fullName: -> "像素画中的线条"

  @initialize()
  
  @assets: -> [
    @IntendedAndPerceivedLines
    @Jaggies
    @Jaggies2
    @LineArtCleanup
    @Corners
  ]

  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArtLines
