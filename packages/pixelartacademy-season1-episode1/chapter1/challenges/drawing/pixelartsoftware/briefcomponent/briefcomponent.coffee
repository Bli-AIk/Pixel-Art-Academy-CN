AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent extends PAA.Practice.Project.Asset.Sprite.BriefComponent
  noActions: ->
    false

  canEdit: ->
    PAA.PixelBoy.Apps.Drawing.state('editorId')?

  canUpload: ->
    PAA.PixelBoy.Apps.Drawing.state('externalSoftware')?

  processUploadData: (imageData) ->
    # Put the sprite into upload mode.
    @sprite.uploadMode true

    # Clone current sprite data so we can manipulate it drectly.
    editor = @parent.drawing.editor()
    spriteData = _.cloneDeep editor.spriteData()
    editor.manualSpriteData spriteData
    @sprite.manualUserSpriteData spriteData
    @sprite.engineComponent.drawMissingPixelsUpTo x: -1, y: -1

    # Open the editor and zoom in the sprite as much as possible.
    editor.manuallyActivated true

    scaleSprite = =>
      scale = LOI.adventure.interface.display.scale()

      viewport = LOI.adventure.interface.display.viewport()

      clipboardSpriteSize = @parent.spriteSize()
      borderWidth = clipboardSpriteSize.borderWidth / clipboardSpriteSize.scale

      maxWidth = viewport.viewportBounds.width() * 0.9
      maxHeight = viewport.viewportBounds.height() * 0.9

      imageWidth = imageData.width + 2 * borderWidth
      imageHeight = imageData.height + 2 * borderWidth

      widthScale = maxWidth / imageWidth / scale
      heightScale = maxHeight / imageHeight / scale

      maxScale = Math.min widthScale, heightScale
      scale = Math.floor maxScale

      editor.pixelCanvas().camera().setScale scale

    # Draw all pixels in 3 seconds.
    pixelDrawDelay = 3000 / (imageData.width * imageData.height)

    # Prepare for palette mapping.
    palette = spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette._id
    colorDistance = (color, r, g, b) => Math.abs(color.r - r) + Math.abs(color.g - g) + Math.abs(color.b - b)
    backgroundColor = @sprite.constructor.backgroundColor()

    if backgroundColor?.paletteColor
      # Map palette color to a direct color so we can calculate distance to it.
      backgroundColor = palette.ramps[backgroundColor.paletteColor.ramp].shades[backgroundColor.paletteColor.shade]

    replacePixel = (x, y) =>
      existingPixel = _.find spriteData.layers[0].pixels, (pixel) => pixel.x is x and pixel.y is y

      pixelIndex = (x + y * imageData.width) * 4

      r = imageData.data[pixelIndex] / 255
      g = imageData.data[pixelIndex + 1] / 255
      b = imageData.data[pixelIndex + 2] / 255
      a = imageData.data[pixelIndex + 3]

      if a
        # This is a full pixel so find the closest palette color.
        closestRamp = null
        closestShade = null
        smallestColorDistance = if backgroundColor then colorDistance backgroundColor, r, g, b else 3

        for ramp, rampIndex in palette.ramps
          for shade, shadeIndex in ramp.shades
            distance = colorDistance shade, r, g, b

            if distance < smallestColorDistance
              smallestColorDistance = distance
              closestRamp = rampIndex
              closestShade = shadeIndex

      # If we didn't find a palette color, delete the pixel.
      if closestRamp? and closestShade?
        paletteColor =
          ramp: closestRamp
          shade: closestShade

        # This is a full pixel so color it.
        if existingPixel
          # Replace data in existing pixel.
          existingPixel.paletteColor = paletteColor
          delete existingPixel.directColor if existingPixel.directColor

        else
          # Add new pixel.
          newPixel = {x, y, paletteColor}
          spriteData.layers[0].pixels.push newPixel

      else if not a and existingPixel
        # This is an empty pixel so remove it.
        _.pull spriteData.layers[0].pixels, existingPixel

      # Re-set sprite data to force image refresh.
      editor.manualSpriteData spriteData
      @sprite.manualUserSpriteData spriteData

      @sprite.engineComponent.drawMissingPixelsUpTo {x, y}

      # Move to next pixel.
      x++

      if x is imageData.width
        x = 0
        y++

        if y is imageData.height
          # We have reached the end.
          updateSprite()
          return

      Meteor.setTimeout =>
        replacePixel x, y
      ,
        pixelDrawDelay

    updateSprite = =>
      LOI.Assets.Sprite.replacePixels @sprite.spriteId(), 0, spriteData.layers[0].pixels, (error) =>
        if error
          console.error error
          return

        editor.manualSpriteData null
        @sprite.manualUserSpriteData null
        @sprite.engineComponent.drawMissingPixelsUpTo x: -1, y: -1

        # Mark this asset as uploaded.
        assets = @sprite.tutorial.state 'assets'
        spriteId = @sprite.id()

        assets = [] unless assets
        asset = _.find assets, (asset) => asset.id is spriteId

        unless asset
          asset = id: @id()
          assets.push asset

        asset.uploaded = true

        @sprite.tutorial.state 'assets', assets

    Meteor.setTimeout =>
      scaleSprite()

      Meteor.setTimeout =>
        replacePixel 0, 0
      ,
        500
    ,
      1000

  onClickEditButton: (event) ->
    # Make sure sprite is not in upload mode.
    @sprite.uploadMode false

    super
