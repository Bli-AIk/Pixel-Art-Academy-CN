AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.Components.Tools.HardEraser extends LandsOfIllusions.Assets.Components.Tools.Tool
  constructor: ->
    super arguments...

    @name = "橡皮擦工具"
    @shortcut = AC.Keys.e

  onMouseDown: (event) ->
    super arguments...

    @applyEraser()

  onMouseMove: (event) ->
    super arguments...

    @applyEraser()

  applyEraser: ->
    return unless @constructor.mouseState.leftButton

    # Do we even need to remove this pixel? See if it is even there.
    spriteData = @options.editor().spriteData()

    xCoordinates = [@constructor.mouseState.x]

    symmetryXOrigin = @options.editor().symmetryXOrigin?()

    if symmetryXOrigin?
      mirroredX = -@constructor.mouseState.x + 2 * symmetryXOrigin
      xCoordinates.push mirroredX

    for xCoordinate in xCoordinates
      pixel =
        x: xCoordinate
        y: @constructor.mouseState.y

      existing = LOI.Assets.Sprite.documents.findOne
        _id: spriteData._id
        "layers.#{0}.pixels":
          $elemMatch: pixel

      return unless existing

      LOI.Assets.Sprite.removePixel spriteData._id, 0, pixel
