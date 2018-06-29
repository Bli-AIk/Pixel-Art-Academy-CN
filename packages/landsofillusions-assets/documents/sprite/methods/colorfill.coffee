AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.colorFill.method (spriteId, layerIndex, newTargetPixel) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check newTargetPixel, Match.ObjectIncluding
    x: Match.Integer
    y: Match.Integer
    paletteColor: Match.Optional Match.ObjectIncluding
      ramp: Match.Integer
      shade: Match.Integer
    directColor: Match.Optional Match.ObjectIncluding
      r: Number
      g: Number
      b: Number
    materialIndex: Match.Optional Match.Integer

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.VisualAsset._authorizeAssetAction sprite

  # Make sure the location is within the bounds.
  unless sprite.bounds.left <= newTargetPixel.x <= sprite.bounds.right and sprite.bounds.top <= newTargetPixel.y <= sprite.bounds.bottom
    throw new AE.ArgumentOutOfRangeException "Pixel to be filled must be inside of bounds."

  forward = {}
  backward = {}

  # Create a map for fast pixel retrieval. Start will all empty objects.
  pixelMap = []

  layerPixels = sprite.layers[layerIndex].pixels

  # Fill occupied spots with pixels.
  for pixel in layerPixels
    pixelMap[pixel.x] ?= []
    pixelMap[pixel.x][pixel.y] = pixel

  # Find current target pixel.
  currentTargetPixel = pixelMap[newTargetPixel.x]?[newTargetPixel.y]
  
  if currentTargetPixel
    # We are filling an area with existing color. Add the pixel to the fringe list.
    fringe = [currentTargetPixel]
    visited = []
  
    while fringe.length
      testPixel = fringe.pop()
  
      # Find 4 neighbours and add them if not already visited.
      tryAdd = (x, y) ->
        pixel = pixelMap[x]?[y]
        return unless pixel
  
        # Found it. Has it been added already?
        return if pixel in visited
  
        # Is it the right color?
        return unless EJSON.equals(pixel.paletteColor, currentTargetPixel.paletteColor) and pixel.materialIndex is currentTargetPixel.materialIndex
  
        # It seems legit, add it.
        fringe.push pixel
  
      tryAdd testPixel.x + 1, testPixel.y
      tryAdd testPixel.x - 1, testPixel.y
      tryAdd testPixel.x, testPixel.y + 1
      tryAdd testPixel.x, testPixel.y - 1
  
      visited.push testPixel
  
    # All the visited pixels are of correct color and should be filled!
    for pixel in visited
      pixelIndex = layerPixels.indexOf pixel
      for key in ['paletteColor', 'directColor', 'materialIndex']
        if newTargetPixel[key]
          # Set new or existing property.
          forward.$set ?= {}
          forward.$set["layers.#{layerIndex}.pixels.#{pixelIndex}.#{key}"] = newTargetPixel[key]

        else if pixel[key]
          # Unset existing property.
          forward.$unset ?= {}
          forward.$unset["layers.#{layerIndex}.pixels.#{pixelIndex}.#{key}"] = true

        if pixel[key]
          # Reset the old property.
          backward.$set ?= {}
          backward.$set["layers.#{layerIndex}.pixels.#{pixelIndex}.#{key}"] = pixel[key]

        else if newTargetPixel[key]
          # The property was not set previously, so we remove it.
          backward.$unset ?= {}
          backward.$unset["layers.#{layerIndex}.pixels.#{pixelIndex}.#{key}"] = true

  else
    # We are filling a transparent area.
    createPixel = (x, y) -> _.extend _.cloneDeep(newTargetPixel), {x, y}
    
    fringe = [newTargetPixel]
    created = []

    while fringe.length
      testPixel = fringe.pop()

      # Find 4 neighbours and add them if not already visited.
      tryAdd = (x, y) ->
        pixel = pixelMap[x]?[y]
        return if pixel

        # Found an empty spot. Has it been added already?
        return if _.find fringe, (pixel) -> pixel.x is x and pixel.y is y
        return if _.find created, (pixel) -> pixel.x is x and pixel.y is y
          
        # Is it out of bounds?
        return unless sprite.bounds.left <= x <= sprite.bounds.right and sprite.bounds.top <= y <= sprite.bounds.bottom

        # It seems legit, add it.
        fringe.push createPixel x, y

      tryAdd testPixel.x + 1, testPixel.y
      tryAdd testPixel.x - 1, testPixel.y
      tryAdd testPixel.x, testPixel.y + 1
      tryAdd testPixel.x, testPixel.y - 1

      created.push testPixel

    # Allow up to 2,000 pixels per layer.
    throw new AE.ArgumentOutOfRangeException "Up to 2,000 pixels per layer are allowed." if layerPixels.length + created.length > 2000

    # All the created pixels should be added.
    forward.$push ?= {}
    forward.$push["layers.#{layerIndex}.pixels"] = $each: created

    # Going back, restore previous amount of pixels.
    backward.$push ?= {}
    backward.$push["layers.#{layerIndex}.pixels"] =
      $each: []
      $slice: layerPixels.length

  sprite._applyOperation forward, backward
