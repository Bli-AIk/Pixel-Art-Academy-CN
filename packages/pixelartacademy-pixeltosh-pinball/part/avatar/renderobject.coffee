AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

_rotation = new THREE.Quaternion
_rotationAngles = new THREE.Euler

if Meteor.isClient
  _transform = new Ammo.btTransform

class Pinball.Part.Avatar.RenderObject extends AS.RenderObject
  @rotationAxis = new THREE.Vector3 0, -1, 0
  
  @physicsDebugMaterial = new THREE.MeshLambertMaterial
    color: 0xff0000
    wireframe: true

  constructor: (@entity, @properties, @shape, @bitmap, @existingResources) ->
    super arguments...
    
    # Create the physics debug mesh.
    @physicsDebugGeometry?.dispose()
    @physicsDebugGeometry = @existingResources?.physicsDebugGeometry or @shape.createPhysicsDebugGeometry()

    @physicsDebugMesh = new THREE.Mesh @physicsDebugGeometry, @constructor.physicsDebugMaterial
    @physicsDebugMesh.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
    
    @add @physicsDebugMesh
    
    # Create the main mesh and render its texture.
    if @existingResources?.material
      @material = @existingResources.material
      
    else
      @material = new THREE.MeshLambertMaterial
        color: 0xffffff
        alphaTest: 0.5
        side: THREE.DoubleSide
      
      pixelImage = new LOI.Assets.Engine.PixelImage.Bitmap asset: => @bitmap
      
      originalCanvas = pixelImage.getCanvas()
      expandedCanvas = new AM.Canvas originalCanvas.width + 2, originalCanvas.height + 2
      expandedCanvas.context.drawImage originalCanvas, 1, 1
      scaledCanvas = AS.Hqx.scale expandedCanvas, 4, AS.Hqx.Modes.NoBlending, false, true
      
      @material.map = new THREE.CanvasTexture scaledCanvas
      @material.map.minFilter = THREE.NearestFilter
      @material.map.magFilter = THREE.NearestFilter
      
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    @geometry = @existingResources?.geometry or new THREE.PlaneGeometry pixelSize * (@bitmap.bounds.width + 2), pixelSize * (@bitmap.bounds.height + 2)
    
    @bitmapPlane = new THREE.Mesh @geometry, @material
    @bitmapPlane.rotation.x = -Math.PI / 2
    @bitmapPlane.scale.x = -1 if @properties.flipped
    @bitmapPlane.receiveShadow = true
    @bitmapPlane.castShadow = true
    @bitmapPlane.layers.set Pinball.RendererManager.RenderLayers.Main
    
    # Offset the mesh so that the shape origin on the bitmap will appear at the render object's position.
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    @bitmapPlane.position.x = (@bitmap.bounds.width / 2 - @shape.bitmapOrigin.x) * pixelSize
    @bitmapPlane.position.x *= -1 if @properties.flipped
    @bitmapPlane.position.z = (@bitmap.bounds.height / 2 - @shape.bitmapOrigin.y) * pixelSize
    
    @mesh = new THREE.Object3D
    @mesh.add @bitmapPlane
    @add @mesh
  
  destroy: ->
    super arguments...
    
    return if @existingResources

    @physicsDebugGeometry.dispose()
    @material.dispose()
    @geometry.dispose()
    
  clone: ->
    new @constructor @part, @properties, @shape, @bitmap, @
    
  updateFromPhysicsObject: (physicsObject) ->
    physicsObject.motionState.getWorldTransform _transform
    @position.setFromBulletVector3 _transform.getOrigin()
    
    rotation = _transform.getRotation()
    @physicsDebugMesh.quaternion.setFromBulletQuaternion rotation

    unless @shape.fixedBitmapRotation()
      # Rotate the bitmap only around the Y axis.
      _rotation.setFromBulletQuaternion rotation
      _rotationAngles.setFromQuaternion _rotation
      
      # Note: We divide by 1.9 so that when an object is resting at
      # 90 degrees, we don't flip between sides due to instabilities.
      if Math.abs(_rotationAngles.z) > Math.PI / 1.9
        _rotationAngles.z = Math.sign(_rotationAngles.z) * Math.PI
        
      else
        _rotationAngles.z = 0
        
      if Math.abs(_rotationAngles.x) > Math.PI / 1.9
        _rotationAngles.x = Math.sign(_rotationAngles.x) * Math.PI
      
      else
        _rotationAngles.x = 0
      
      @mesh.quaternion.setFromEuler _rotationAngles
  
  renderReflections: (renderer, scene) ->
    unless @cubeCamera
      @cubeCameraRenderTarget = new THREE.WebGLCubeRenderTarget 256,
        format: THREE.RGBAFormat
        type: THREE.FloatType
        stencilBuffer: false

      @cubeCamera = new THREE.CubeCamera 0.001, 10, @cubeCameraRenderTarget

    @visible = false
    @cubeCamera.position.copy @position

    renderer.outputEncoding = THREE.LinearEncoding
    renderer.toneMapping = THREE.NoToneMapping
    renderer.shadowMap.needsUpdate = true
    @cubeCameraRenderTarget.clear renderer
    @cubeCamera.update renderer, scene

    @visible = true

    @material.envMap = @cubeCamera.renderTarget.texture
