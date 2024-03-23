LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball
CollisionGroups = Pinball.PhysicsManager.CollisionGroups

class Pinball.Parts.BallSpawner extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.BallSpawner'
  @fullName: -> "ball"
  @description: ->
    "
      Marks the place where the ball will spawn.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/ball.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Sphere
    Pinball.Part.Avatar.ConvexExtrusion
  ]
  
  @initialize()
  
  constants: ->
    restitution: Pinball.PhysicsManager.BallConstants.Restitution
    friction: Pinball.PhysicsManager.BallConstants.Friction
    rollingFriction: Pinball.PhysicsManager.BallConstants.RollingFriction
    collisionGroup: CollisionGroups.Balls
    collisionMask: CollisionGroups.Balls | CollisionGroups.BallGuides | CollisionGroups.Actuators
    continuousCollisionDetection: true

  spawnBall: ->
    new Pinball.Ball @pinball, @
