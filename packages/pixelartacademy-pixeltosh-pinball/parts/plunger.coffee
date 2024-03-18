LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Plunger extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Plunger'
  @fullName: -> "plunger"
  @description: ->
    "
      A player-controlled, spring-loaded rod that allows the player to send the ball into the game.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/plunger.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Box
  ]
  
  @initialize()
  
  @pullingSpeed = 0.05 # m / s
  @releaseSpeed = 1.5 # m / s
  
  @maxDisplacementRatio = 0.8
  
  constructor: ->
    super arguments...
    
    @active = false
    @moving = false
    @displacement = 0

  createAvatar: ->
    new Pinball.Part.Avatar @,
      mass: 0
      height: 0.03
      restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
      friction: Pinball.PhysicsManager.FrictionConstants.Plastic
      rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
      collisionGroup: Pinball.PhysicsManager.CollisionGroups.Actuators
      collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
  
  onAddedToDynamicsWorld: (@dynamicsWorld) ->
    # Create a constraint at the plunger origin.
    physicsObject = @avatar.getPhysicsObject()
    @origin = physicsObject.getPosition()
    
    physicsObject.body.setCollisionFlags physicsObject.body.getCollisionFlags() | Ammo.btCollisionObject.CollisionFlags.KinematicObject
    physicsObject.body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
  
  onRemovedFromDynamicsWorld: (dynamicsWorld) ->
    @dynamicsWorld.removeConstraint @constraint
    
  activate: ->
    @active = true
    @moving = true
    
    physicsObject = @avatar.getPhysicsObject()
    @displacement = physicsObject.getPosition().z - @origin.z
  
  deactivate: ->
    @active = false
    
    physicsObject = @avatar.getPhysicsObject()
    @_releaseSpeed = -@constructor.releaseSpeed * @displacement / physicsObject.shape.depth
    
  fixedUpdate: (elapsed) ->
    return unless @moving
    
    physicsObject = @avatar.getPhysicsObject()
    maxDisplacement = physicsObject.shape.depth * @constructor.maxDisplacementRatio
    
    if @active
      if @displacement >= maxDisplacement
        # We reached maximum displacement, stop.
        @displacement = maxDisplacement
        speed = 0
        
      else
        # Keep pulling the plunger.
        speed = @constructor.pullingSpeed
    
    else
      if @displacement < 0
        # We reached the origin.
        @moving = false
        @displacement = 0
        speed = 0
        
      else
        # Keep releasing the plunger.
        speed = @_releaseSpeed
    
    distance = speed * elapsed
    @displacement += distance
    physicsObject.setPosition x: @origin.x, y: @origin.y, z: @origin.z + @displacement
