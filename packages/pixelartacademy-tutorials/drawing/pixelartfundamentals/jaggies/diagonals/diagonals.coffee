AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals extends PAA.Practice.Tutorials.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals'

  @fullName: -> "像素画中的斜线"

  @initialize()
  
  @assets: -> [
    @EvenDiagonals
    @ConstrainingAngles
    @UnevenDiagonals
    @DiagonalsEvaluation
    @UnevenDiagonalsArtStyle
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArtDiagonals
