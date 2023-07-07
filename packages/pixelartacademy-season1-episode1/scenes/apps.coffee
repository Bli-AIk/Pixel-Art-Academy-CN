LOI = LandsOfIllusions
PAA = PixelArtAcademy
E1 = PixelArtAcademy.Season1.Episode1

class E1.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Apps'
  
  @location: -> PAA.PixelPad.Apps
  
  @initialize()

  things: ->
    apps = [
      @constructor.AdmissionWeek
    ]

    if unlockedApps = PAA.PixelPad.Apps.AdmissionWeek.state 'unlockedApps'
      apps.push _.thingClass appId for appId in unlockedApps

    apps
