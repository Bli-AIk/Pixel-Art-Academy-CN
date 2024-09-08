AE = Artificial.Everywhere
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class CameraDisplayType extends Pinball.Interface.Actions.Action
  @cameraDisplayType: -> throw new AE.NotImplementedException "Camera display type action must provide the display type it activates."
  
  enabled: -> true
  
  active: -> @pinball.cameraManager()?.displayType() is @constructor.cameraDisplayType()
  
  execute: ->
    @pinball.cameraManager().displayType @constructor.cameraDisplayType()

class Pinball.Interface.Actions.OrthographicCamera extends CameraDisplayType
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.OrthographicCamera'
  @displayName: -> "二维视图"
  
  @cameraDisplayType: -> Pinball.CameraManager.DisplayTypes.Orthographic
  
  @initialize()

class Pinball.Interface.Actions.PerspectiveCamera extends CameraDisplayType
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Actions.PerspectiveCamera'
  @displayName: -> "三维视图"

  @cameraDisplayType: -> Pinball.CameraManager.DisplayTypes.Perspective

  @initialize()
