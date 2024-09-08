AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Pin extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Pin'
  @fullName: -> "挡针"
  @description: ->
    "
      弹球游戏中的小挡针，会改变弹球的运动路线。
    "
    
  @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/pin.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Cylinder
    Pinball.Part.Avatar.Extrusion
  ]
  
  @initialize()
  
  @placeableRequiredTask: -> LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.PlayGobbleHole
  
  @radiusRatio = 0.5
  
  constants: ->
    height: 0.03
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Metal
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
    radiusRatio: @constructor.radiusRatio
