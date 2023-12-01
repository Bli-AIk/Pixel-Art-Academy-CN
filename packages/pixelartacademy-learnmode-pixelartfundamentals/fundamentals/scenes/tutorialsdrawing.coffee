LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.TutorialsDrawing extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.TutorialsDrawing'

  @location: -> PAA.Practice.Tutorials.Drawing

  @initialize()
  
  destroy: ->
    super arguments...
  
    @_tutorialLine?.destroy()
    @_tutorialJaggies?.destroy()

  things: ->
    things = []

    @_tutorialLine ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.ElementsOfArt.Line
    things.push @_tutorialLine
    
    if @_tutorialLine.completed()
      @_tutorialPixelArtLines ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines
      things.push @_tutorialPixelArtLines

    things
