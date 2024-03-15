AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.CameraManager
  @DisplayTypes:
    Orthographic: 'Orthographic'
    Perspective: 'Perspective'
  
  @orthographicPixelSize = 0.5 / 180 # m/px
  
  constructor: (@pinball) ->
    @displayType = new ReactiveField @constructor.DisplayTypes.Orthographic
    
    halfWidth = Pinball.SceneManager.playfieldWidth / 2
    halfHeight = halfWidth / Pinball.RendererManager.orthographicAspectRatio
    
    @_orthographicCamera = new THREE.OrthographicCamera -halfWidth, halfWidth, halfHeight, -halfHeight, 0, 2
    @_orthographicCamera.position.set halfWidth, 1, halfHeight
    @_orthographicCamera.rotation.set -Math.PI / 2, 0, 0
    
    @_perspectiveCamera = new THREE.PerspectiveCamera 60, Pinball.RendererManager.perspectiveAspectRatio, 0.1, 10
    
    @camera = new AE.ReactiveWrapper null
    
    @pinball.autorun =>
      switch @displayType()
        when @constructor.DisplayTypes.Orthographic
          @camera @_orthographicCamera
          
        when @constructor.DisplayTypes.Perspective
          @camera @_perspectiveCamera
    
    # Update camera position when properties change.
    @_properties = new ReactiveField
      azimuthalAngle: AR.Degrees 180
      polarAngle: AR.Degrees 80
      radialDistance: Pinball.SceneManager.shortPlayfieldHeight
    
    @pinball.autorun =>
      properties = @_properties()
      r = properties.radialDistance
      ɸ = properties.azimuthalAngle
      θ = properties.polarAngle
      
      @_perspectiveCamera.position.copy
        x: r * Math.sin(θ) * Math.cos(ɸ) + Pinball.SceneManager.playfieldWidth / 2
        y: r * Math.cos(θ)
        z: r * Math.sin(θ) * Math.sin(ɸ) + Pinball.SceneManager.shortPlayfieldHeight / 2
      
      # Update rotation to look at the center.
      @_perspectiveCamera.rotation.set -Math.PI / 2 + θ, Math.PI / 2 - ɸ, 0, 'YXZ'
      
      @camera.updated()
      
    @rotatingCamera = new ReactiveField false
    
    @pinball.autorun =>
      return unless @rotatingCamera()
      return unless newViewportCoordinates = @pinball.mouse().viewportCoordinates()

      dragDelta =
        x: @_rotateCameraStartViewportCoordinates.x - newViewportCoordinates.x
        y: @_rotateCameraStartViewportCoordinates.y - newViewportCoordinates.y

      # Only react to mouse coordinate changes.
      Tracker.nonreactive =>
        oldProperties = @_properties()

        newProperties =
          azimuthalAngle: @_rotateCameraStartProperties.azimuthalAngle - dragDelta.x * Math.PI
          polarAngle: _.clamp @_rotateCameraStartProperties.polarAngle - dragDelta.y * Math.PI * 0.5, 0, Math.PI
          radialDistance: oldProperties.radialDistance

        @_properties newProperties

  startRotateCamera: ->
    # Dragging of blueprint needs to be handled in display coordinates since the canvas ones should technically stay
    # the same (the whole point is for the same canvas coordinate to stay under the mouse as we move it around).
    @_rotateCameraStartViewportCoordinates = @pinball.mouse().viewportCoordinates()
    @_rotateCameraStartProperties = @_properties()
    @rotatingCamera true

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on 'mouseup.pixelartacademy-pixeltosh-programs-pinball-cameramanager', =>
      $(document).off '.pixelartacademy-pixeltosh-programs-pinball-cameramanager'

      @rotatingCamera false
      
  changeDistanceByFactor: (factor) ->
    properties = @_properties()
    properties.radialDistance = _.clamp properties.radialDistance * factor, 0.1, 10
    @_properties properties
