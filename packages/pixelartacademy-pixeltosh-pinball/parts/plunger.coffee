LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

_displacedPosition = new THREE.Vector3

class Pinball.Parts.Plunger extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Plunger'
  @fullName: -> "弹射装置"
  @description: ->
    "
      一个由玩家控制的弹射装置，玩家可以用它将弹球发射到弹球台内。
    "
  
  @assetId: -> Pinball.Assets.Plunger.id()
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Extrusion
  ]
  
  @initialize()
  
  @placeableRequiredTask: -> LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.DrawBall
  
  @maxDisplacementRatio = 0.8
  
  settings: ->
    pullingSpeed:
      name: '拉伸速度'
      unit: "m/s"
      type: Pinball.Interface.Settings.Number.id()
      min: 0.01
      max: 0.5
      step: 0.01
      default: 0.05
    releaseSpeed:
      name: '释放速度'
      unit: "m/s"
      type: Pinball.Interface.Settings.Number.id()
      min: 0.1
      max: 5
      step: 0.1
      default: 1.5
      
  constants: ->
    height: 0.02
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Plastic
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.Actuators
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
  
  onAddedToDynamicsWorld: (dynamicsWorld) ->
    # Plunger is a player-controlled kinematic object.
    physicsObject = @avatar.getPhysicsObject()
    @origin = physicsObject.getPosition()
    
    physicsObject.body.setCollisionFlags physicsObject.body.getCollisionFlags() | Ammo.btCollisionObject.CollisionFlags.KinematicObject
    physicsObject.body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
  
  reset: ->
    super arguments...
    
    if physicsObject = @avatar.getPhysicsObject()
      @origin = physicsObject.getPosition()
    
    @active = false
    @moving = false
    @displacement = 0
  
  activate: ->
    @active = true
    @moving = true
    
    physicsObject = @avatar.getPhysicsObject()
    @displacement = physicsObject.getPosition().z - @origin.z
  
  deactivate: ->
    @active = false
    
    @_releaseSpeed = -@data().releaseSpeed * @displacement / @shape().depth
    
  fixedUpdate: (elapsed) ->
    return unless @moving
    
    physicsObject = @avatar.getPhysicsObject()
    maxDisplacement = @shape().depth * @constructor.maxDisplacementRatio
    
    if @active
      if @displacement >= maxDisplacement
        # We reached maximum displacement, stop.
        @displacement = maxDisplacement
        speed = 0
        
      else
        # Keep pulling the plunger.
        speed = @data().pullingSpeed
    
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
    
    _displacedPosition.copy @origin
    _displacedPosition.z += @displacement
    physicsObject.setPosition _displacedPosition
