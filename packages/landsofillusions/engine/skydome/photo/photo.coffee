AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

class LOI.Engine.Skydome.Photo extends LOI.Engine.Skydome
  constructor: (options = {}) ->
    super arguments...

    @loader = new THREE.RGBELoader()
    @loader.setDataType THREE.FloatType

    # Don't draw the sphere until a map is loaded.
    @sphere.visible = false

    # A photo skydome is used both in the final render and to render indirect lights (even though it can include direct
    # lights, but we assume these will not be replicated with geometric lights, so it's OK that they are there).
    @sphere.layers.enable LOI.Engine.RenderLayers.Indirect

  createMaterial: -> new @constructor.Material

  loadFromUrl: (url) ->
    # Temporarily hide the sphere until the map is loaded.
    @sphere.visible = false

    @loader.load url, (texture) =>
      @material.map?.dispose()

      @material.map = texture
      @material.uniforms.map.value = texture
      @material.needsUpdate = true

      if @options.generateCubeTexture
        @cubeSceneSphereMaterial.map = texture
        @cubeSceneSphereMaterial.uniforms.map.value = texture
        @cubeSceneSphereMaterial.needsUpdate = true

      @sphere.visible = true

      @options.onLoaded?()
