AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.Landmarks extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.Landmarks'

  constructor: (@options) ->
    super arguments...

  onCreated: ->
    super arguments...

    @assetData = new ComputedField =>
      assetId = @options.assetId()
      @options.documentClass.documents.findOne assetId,
        fields:
          landmarks: 1

    @landmarks = new ComputedField =>
      data = @assetData()
      return unless data?.landmarks

      for landmark, index in data.landmarks
        # Add index to named color data.
        _.extend {}, landmark,
          index: index
          number: index + 1

    @_landmarkImage ?= $('<canvas>')[0]
    @_landmarkImage.width = 7
    @_landmarkImage.height = 7

    context = @_landmarkImage.getContext '2d'
    imageData = context.getImageData 0, 0, @_landmarkImage.width, @_landmarkImage.height

    bitmap = """
      0011100
      0100010
      1000001
      1000001
      1000001
      0100010
      0011100
    """

    for line, y in bitmap.split '\n'
      for char, x in line
        continue unless char is '1'

        for i in [0..3]
          imageData.data[(x + y * @_landmarkImage.width) * 4 + i] = 255

    context.putImageData imageData, 0, 0

  # Renderer

  drawToContext: (context) ->
    return unless landmarks = @landmarks()

    scale = @options.pixelCanvas().camera().scale()
    context.imageSmoothingEnabled = false

    # Divide landmark size by scale so it always renders at the same size.
    landmarkSize = @_landmarkImage.width / scale

    # We need to draw the sphere centered on the middle of the pixel.
    offset = -landmarkSize / 2 + 0.5

    for landmark, index in landmarks
      context.drawImage @_landmarkImage, landmark.x + offset, landmark.y + offset, landmarkSize, landmarkSize

      context.font = "#{7 / scale}px 'Adventure Pixel Art Academy'"
      context.fillStyle = "white"
      context.fillText landmark.number, landmark.x + offset + 8 / scale, landmark.y + offset + 6 / scale

  # Events

  events: ->
    super(arguments...).concat
      'change .number-input': @onChangeNumber
      'change .name-input, change .coordinate-input': @onChangeLandmark
      'click .add-landmark-button': @onClickAddLandmarkButton

  onChangeNumber: (event) ->
    data = @currentData()

    number = parseInt $(event.target).val()

    # HACK: Replace the number back since it won't update by itself (probably since it's the edited input).
    $(event.target).val data.number

    if _.isNaN number
      LOI.Assets.VisualAsset.removeLandmark @options.documentClass.className, @assetData()._id, data.index

    else
      newIndex = number - 1
      LOI.Assets.VisualAsset.reorderLandmark @options.documentClass.className, @assetData()._id, data.index, newIndex

  onChangeLandmark: (event) ->
    $landmark = $(event.target).closest('.landmark')

    index = @currentData().index

    landmark =
      # We null the name if it's an empty string
      name: $landmark.find('.name-input').val() or null
      
    for property in ['x', 'y', 'z']
      landmark[property] = @_parseFloatOrNull $landmark.find(".coordinate-#{property} .coordinate-input").val()

    LOI.Assets.VisualAsset.updateLandmark @options.documentClass.className, @assetData()._id, index, landmark

  onClickAddLandmarkButton: (event) ->
    assetData = @assetData()
    index = assetData.landmarks?.length or 0
    LOI.Assets.VisualAsset.updateLandmark @options.documentClass.className, assetData._id, index, {}

  _parseFloatOrNull: (string) ->
    float = parseFloat string

    if _.isNaN float then null else float
