LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Intro extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.LearnMode.Intro'

  @fullName: -> "Learn Mode introduction"

  @chapters: -> [
    @Tutorial
  ]

  @scenes: -> [
    @PixelPad
    @Apps
    @Editors
    @ChallengesDrawing
    @TutorialsDrawing
    @Pico8Cartridges
    @Workbench
  ]
  
  @startSection: -> @Start
  
  @initialize()

  pico8Enabled: ->
    tutorial = @getChapter LM.Intro.Tutorial
    pixelArtSoftwareGoal = tutorial.getGoal LM.Intro.Tutorial.Goals.PixelArtSoftware
    pixelArtSoftwareGoal.completed()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-learnmode-intro'
    assets: Assets
