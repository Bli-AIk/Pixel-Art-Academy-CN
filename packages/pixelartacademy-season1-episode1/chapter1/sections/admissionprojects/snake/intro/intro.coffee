LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.AdmissionProjects.Snake.Intro extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionProjects.Snake.Intro'

  @scenes: -> [
    @Coworking
  ]

  @initialize()
  
  @started: ->
    # Snake storyline starts when the admission projects get activated
    # and the user has added the snake project to their study plan.
    C1.AdmissionProjects.started() and PAA.PixelBoy.Apps.StudyPlan.hasGoal C1.Goals.Snake

  @finished: ->
    # TODO: Intro section ends when the player has played Snake and got a score of at least 5.
    false
