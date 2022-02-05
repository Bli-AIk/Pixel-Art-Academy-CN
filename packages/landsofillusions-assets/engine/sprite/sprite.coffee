AM = Artificial.Mirage
LOI = LandsOfIllusions

# Create temporary objects and constants.
_normal = new THREE.Vector3
_backward = new THREE.Vector3 0, 0, 1
_color = new THREE.Color
_lightColor = new THREE.Color
_averageNormal = new THREE.Vector3

class LOI.Assets.Engine.Sprite
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless spriteData = @options.spriteData()
      return unless spriteData.layers?.length and spriteData.bounds
      return unless spriteData.customPalette or LOI.Assets.Palette.documents.findOne(spriteData.palette?._id) or @options.visualizeNormals?()

      true

  drawToContext: (context, renderOptions = {}) ->
    # HACK: Request sprite data already at the top since otherwise ready sometimes doesn't get recomputed in time.
    spriteData = @options.spriteData()

    return unless @ready()

    @_render renderOptions

    # Right now we're using canvas' drawing capabilities, without using our depth data. This is done for simplicity
    # since we can let canvas' context deal with transformations and stuff. Eventually we'll want to move to either
    # a custom drawing routine or upgrade to WebGL.
    bounds = spriteData.bounds

    context.imageSmoothingEnabled = false
    context.drawImage @_canvas, bounds.x, bounds.y

  getImageData: (renderOptions = {}) ->
    # HACK: Request sprite data already at the top since otherwise ready sometimes doesn't get recomputed in time.
    @options.spriteData()
    return unless @ready()

    @_render renderOptions
    @_imageData

  getCanvas: (renderOptions = {}) ->
    # HACK: Request sprite data already at the top since otherwise ready sometimes doesn't get recomputed in time.
    @options.spriteData()
    return unless @ready()

    @_render renderOptions
    @_canvas

  _render: (renderOptions) ->
    spriteData = @options.spriteData()

    # On the server we need to manually request pixel maps.
    spriteData.requirePixelMaps() if Meteor.isServer

    palette = spriteData.customPalette or LOI.Assets.Palette.documents.findOne(spriteData.palette?._id)

    # Build a new canvas if needed.
    unless @_canvas?.width is spriteData.bounds.width and @_canvas?.height is spriteData.bounds.height
      @_canvas = new AM.Canvas spriteData.bounds.width, spriteData.bounds.height

    # Resize the canvas if needed.
    @_context = @_canvas.context
    @_imageData = @_canvas.getFullImageData()
    @_canvasPixelsCount = @_canvas.width * @_canvas.height

    # Clear the image buffer to transparent.
    @_imageData.data.fill 0

    # Build the depth buffer if needed.
    unless @_depthBuffer?.length is @_canvasPixelsCount
      @_depthBuffer = new Float32Array @_canvasPixelsCount

    # Clear the depth buffer to smallest value.
    @_depthBuffer.fill Number.NEGATIVE_INFINITY

    # Prepare constants.
    inverseLightDirection = renderOptions.lightDirection?.clone().multiplyScalar(-1)
    materialsData = @options.materialsData?()
    visualizeNormals = @options.visualizeNormals?()
    flippedHorizontal = @options.flippedHorizontal
    flippedHorizontal = flippedHorizontal() if _.isFunction flippedHorizontal
    smoothShading = renderOptions.smoothShading ? LOI.settings?.graphics.smoothShading.value()

    if smoothShading
      colorQuantizationLevels = renderOptions.colorQuantizationLevels ? LOI.settings.graphics.colorQuantizationLevels.value()
      colorQuantizationFactor = (colorQuantizationLevels or 1) - 1

    for layer in spriteData.layers when layer?.pixels and layer.visible isnt false
      layerOrigin =
        x: layer.origin?.x or 0
        y: layer.origin?.y or 0
        z: layer.origin?.z or 0

      for pixel in layer.pixels
        # Find pixel index in the image buffer.
        x = pixel.x + layerOrigin.x - spriteData.bounds.x
        y = pixel.y + layerOrigin.y - spriteData.bounds.y
        depthPixelIndex = x + y * @_canvas.width
        pixelIndex = depthPixelIndex * 4

        # Allow a special material called 'erase' to delete pixels.
        erase = spriteData.materials?[pixel.materialIndex]?.name is 'erase'

        if erase
          z = Number.NEGATIVE_INFINITY

        else
          # Cull by depth.
          z = layerOrigin.z + (pixel.z or 0)
          continue if z < @_depthBuffer[depthPixelIndex]

        # Update depth buffer.
        @_depthBuffer[depthPixelIndex] = z

        # Determine the color.
        if visualizeNormals
          # Visualized normals mode.
          if pixel.normal
            _normal.copy pixel.normal
            _normal.x *= -1 if flippedHorizontal

            horizontalAngle = Math.atan2(_normal.y, _normal.x) + Math.PI
            verticalAngle = _normal.angleTo _backward

            hue = horizontalAngle / (2 * Math.PI)
            saturation = verticalAngle / (Math.PI / 2)

            if Math.abs(verticalAngle) > Math.PI / 2
              lightness = 1 - Math.abs(verticalAngle) / Math.PI

            else
              lightness = 0.5

            _color.setHSL hue, saturation, lightness
            destinationColor = _color

          else
            destinationColor = r: 0, g: 0, b: 0

        else if renderOptions.renderNormalData
          # Rendering of raw normal data for use in shaders.
          if pixel.normal
            destinationColor =
              r: pixel.normal.x * 0.5 + 0.5
              g: pixel.normal.y * 0.5 + 0.5
              b: pixel.normal.z * 0.5 + 0.5

            destinationColor.r = -pixel.normal.x * 0.5 + 0.5 if flippedHorizontal

          else
            destinationColor = r: 0, g: 0, b: 0

        else if renderOptions.renderPaletteData
          # Rendering of ramp + shade + dither + shininess data for use in shaders.
          paletteColor = null

          # Normal color mode.
          if pixel.materialIndex?
            material = spriteData.materials[pixel.materialIndex]

            paletteColor = _.clone material

            # Override material data if we have it present.
            if materialData = materialsData?[material.name]
              for key, value of materialData
                paletteColor[key] = value if value?

          else if pixel.paletteColor
            paletteColor = pixel.paletteColor

          paletteColor ?=
            ramp: 0
            shade: 9

          # Pack palette color data into the RGB channels.
          # R: ramp (4 bits), shade (4 bits)
          # G: intensity (4 bits), shininess (3 bits), smoothing factor (1 bit)
          # B: dither (3 bits)
          destinationColor =
            r: ((paletteColor.ramp << 4) + paletteColor.shade) / 255
            g: 0
            b: (Math.round(paletteColor.dither * 7) << 5) / 255

          if paletteColor?.reflection
            intensity = paletteColor.reflection.intensity or 0
            intensity = Math.round _.clamp(intensity, 0, 0.3) / 0.3 * 15

            shininess = paletteColor.reflection.shininess or 1
            shininess = Math.round _.clamp shininess, 0, 7

            smoothFactor = paletteColor.reflection.smoothFactor or 0
            smoothFactor = Math.round _.clamp smoothFactor, 0, 1

            destinationColor.g = ((intensity << 4) + (shininess << 1) + smoothFactor) / 255

        else if renderOptions.silhouette
          paletteColor = renderOptions.silhouette

          continue unless shades = palette.ramps[paletteColor.ramp]?.shades
          shadeIndex = THREE.Math.clamp paletteColor.shade, 0, shades.length - 1
          destinationColor = shades[shadeIndex]

        else
          paletteColor = null

          # Normal color mode.
          if pixel.materialIndex?
            continue unless material = spriteData.materials?[pixel.materialIndex]

            paletteColor = _.clone material

            # Override material data if we have it present.
            if materialData = materialsData?[material.name]
              for key, value of materialData
                paletteColor[key] = value if value?

          else if pixel.paletteColor
            paletteColor = pixel.paletteColor

          else if pixel.directColor
            directColor = pixel.directColor

          if paletteColor
            continue unless shades = palette.ramps[paletteColor.ramp]?.shades
            shadeIndex = THREE.Math.clamp paletteColor.shade, 0, shades.length - 1
            directColor = shades[shadeIndex]

          unless directColor
            console.warn "Missing color information in pixel", pixel
            continue

          sourceColor = THREE.Color.fromObject directColor

          if inverseLightDirection
            # Shade color based on the normal.
            shadeFactor = 0

            # Calculate ambient lighting.
            sceneAmbientCoefficient = 0.4
            materialAmbientCoefficient = 1

            if sceneAmbientCoefficient and materialAmbientCoefficient
              shadeFactor += sceneAmbientCoefficient * materialAmbientCoefficient

            # Calculate diffuse lighting.
            if pixel.normal
              _normal.copy pixel.normal
              _normal.x *= -1 if flippedHorizontal

            else
              _normal.set 0, 0, 1

            normalLightProduct = THREE.Math.clamp _normal.dot(inverseLightDirection), 0, 1

            lightDiffuseCoefficient = 0.6
            materialDiffuseCoefficient = 1

            if lightDiffuseCoefficient and materialDiffuseCoefficient
              shadeFactor += normalLightProduct * lightDiffuseCoefficient * materialDiffuseCoefficient

            shadedColor = sourceColor.clone().multiplyScalar shadeFactor

            # Calculate specular lighting.
            lightSpecularCoefficient = 1
            materialSpecularCoefficient = 0

            if paletteColor?.reflection
              materialSpecularCoefficient = paletteColor.reflection.intensity or 0
              shininess = paletteColor.reflection.shininess or 1

            if lightSpecularCoefficient and materialSpecularCoefficient
              smoothFactor = paletteColor.reflection.smoothFactor or 0

              # Average the normal.
              _averageNormal.set 0, 0, 0

              for offsetX in [-smoothFactor..smoothFactor]
                for offsetY in [-smoothFactor..smoothFactor]
                  if sampleNormal = layer._pixelMap[pixel.x + offsetX]?[pixel.y + offsetY]?.normal
                    _averageNormal.add sampleNormal

              _averageNormal.normalize()
              _averageNormal.x *= -1 if flippedHorizontal

              averageNormalLightProduct = THREE.Math.clamp _averageNormal.dot(inverseLightDirection), 0, 1

              # Calculate the perfectly reflected ray.
              reflection = _averageNormal.clone().multiplyScalar(2 * averageNormalLightProduct).sub inverseLightDirection

              # We assume the inverse view direction to be (0, 0, 1).
              # Dot product is then the equivalent of the z coordinate.
              reflectionViewProduct = THREE.Math.clamp reflection.z, 0, 1

              lightFactor = Math.pow(reflectionViewProduct, shininess) * lightSpecularCoefficient * materialSpecularCoefficient
              _lightColor.set(0xffffff).multiplyScalar lightFactor

              shadedColor.add _lightColor

            if palette and paletteColor
              if colorQuantizationFactor
                shadedColor.r = Math.round(shadedColor.r * colorQuantizationFactor) / colorQuantizationFactor
                shadedColor.g = Math.round(shadedColor.g * colorQuantizationFactor) / colorQuantizationFactor
                shadedColor.b = Math.round(shadedColor.b * colorQuantizationFactor) / colorQuantizationFactor

              destinationColor = @_boundColorToPaletteRamp pixel, shadedColor, palette.ramps[paletteColor.ramp], paletteColor.dither, smoothShading

            else
              destinationColor = shadedColor

          else
            destinationColor = sourceColor

        if erase
          @_imageData.data[pixelIndex + 3] = 0

        else
          @_imageData.data[pixelIndex] = destinationColor.r * 255
          @_imageData.data[pixelIndex + 1] = destinationColor.g * 255
          @_imageData.data[pixelIndex + 2] = destinationColor.b * 255
          @_imageData.data[pixelIndex + 3] = (destinationColor.a or 1) * 255

    @_canvas.putFullImageData @_imageData

  _boundColorToPaletteRamp: (pixel, color, ramp, dither, smoothShading) ->
    # Find the nearest color from the palette to represent the shaded color.
    bestColor = null
    bestColorDistance = Number.POSITIVE_INFINITY

    passedZero = false
    earlierColor = null
    laterColor = null
    blendFactor = 0

    previousColor = null
    previousSignedDistance = 0

    for shade, shadeIndex in ramp.shades
      # Measure distance to color.
      difference =
        r: shade.r - color.r
        g: shade.g - color.g
        b: shade.b - color.b

      signedDistance = difference.r + difference.g + difference.b
      distance = Math.abs(difference.r) + Math.abs(difference.g) + Math.abs(difference.b)

      unless shadeIndex
        # Set initial values in first loop iteration.
        bestColor = shade
        bestColorDistance = distance

      else
        # See if we've crossed zero distance, which means our target
        # shaded color is between the previous and current shade.
        if previousSignedDistance < 0 and signedDistance >= 0 or previousSignedDistance >= 0 and signedDistance < 0
          passedZero = true
          earlierColor = previousColor
          laterColor = shade
          blendFactor = Math.abs(previousSignedDistance) / Math.abs(signedDistance - previousSignedDistance)

        if distance < bestColorDistance
          bestColor = shade
          bestColorDistance = distance

        # Note: We have to make sure the distance increased since there could be two of the same colors in the palette.
        else if distance > bestColorDistance
          # We have increased the distance, which means we're moving away from the best color and can safely quit.
          break

      previousSignedDistance = signedDistance
      previousColor = shade

    boundColor = bestColor

    # Apply dithering.
    if Math.abs(0.5 - blendFactor) < dither / 2.0
      if Math.abs(pixel.x % 2) + Math.abs(pixel.y % 2) is 1
        boundColor = laterColor

      else
        boundColor = earlierColor

    else if smoothShading and passedZero
      boundColor = _color.copy(earlierColor).lerp(laterColor, blendFactor)

    boundColor
