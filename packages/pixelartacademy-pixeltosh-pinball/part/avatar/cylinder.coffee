AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Cylinder extends Pinball.Part.Avatar.Shape
  @detectShape: (pixelArtEvaluation, properties) ->
    # We can have a cylinder shape if we detect a circle.
    return unless circle = @_detectCircle pixelArtEvaluation
    
    new @ pixelArtEvaluation, properties, circle
  
  constructor: (@pixelArtEvaluation, @properties, circle) ->
    super arguments...
    
    @bitmapOrigin = circle.position
    @radius = circle.radius * Pinball.CameraManager.orthographicPixelSize * (@properties.radiusRatio ? 1)
    
    @continuousCollisionDetectionRadius = @radius
  
  fixedBitmapRotation: -> true
  
  collisionShapeMargin: -> null
  
  createPhysicsDebugGeometry: ->
    new THREE.CylinderBufferGeometry @radius, @radius, @height

  createCollisionShape: ->
    new Ammo.btCylinderShape new Ammo.btVector3 @radius, @height / 2, @radius
    
  yPosition: -> @height / 2
