LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Intro extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.LearnMode.Intro'

  @fullName: -> "Pixel art tools"

  @chapters: -> [
    @Tutorial
  ]

  @scenes: -> [
    @PixelPad
    @Apps
    @Systems
    @Editors
    @ChallengesDrawing
    @TutorialsDrawing
    @Pico8Cartridges
    @Workbench
  ]
  
  @startSection: -> @Start
  
  @initialize()

  @pico8Enabled: ->
    PAA.Learning.Goal.getAdventureInstanceForId(LM.Intro.Tutorial.Goals.PixelArtSoftware.id())?.completed()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-learnmode-intro'
    assets: Assets
