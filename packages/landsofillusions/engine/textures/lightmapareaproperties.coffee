LOI = LandsOfIllusions

class LOI.Engine.Textures.LightmapAreaProperties extends LOI.Engine.Textures.Properties
  @propertyIndices:
    position: 0
    size: 1
    mipmapLevel: 2 # active, highest

  @maxItems: 256
  @maxProperties: 4

  constructor: ->
    super LOI.Engine.Textures.LightmapAreaProperties

  update: (lightmapAreaProperties, lightmap) ->
    activeMipmapLevels = lightmap.activeMipmapLevels()

    for area, areaIndex in lightmapAreaProperties
      @_writeToData areaIndex, @constructor.propertyIndices.position, area.positionX, area.positionY
      @_writeToData areaIndex, @constructor.propertyIndices.size, area.size
      @_writeToData areaIndex, @constructor.propertyIndices.mipmapLevel, activeMipmapLevels[areaIndex], area.level

    @needsUpdate = true
