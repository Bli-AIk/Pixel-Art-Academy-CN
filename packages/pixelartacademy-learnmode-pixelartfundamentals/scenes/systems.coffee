LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Systems extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Systems'

  @location: -> PAA.PixelPad.Systems

  @initialize()
  
  things: -> [
    PAA.PixelPad.Systems.Music
  ]
