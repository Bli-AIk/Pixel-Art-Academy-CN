AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Camera extends AM.Component
  @register 'LandsOfIllusions.Assets.MeshEditor.Camera'

  constructor: (@options) ->
    super arguments...

  onCreated: ->
    super arguments...

  vectors: ->
    vectors = []
    camera = @options.load()

    for name in ['position', 'target', 'up']
      vector = camera[name]
      vectors.push _.extend {name: _.upperFirst(name), x: 0, y: 0, z: 0}, vector

    vectors

  # Events

  events: ->
    super(arguments...).concat
      'change .coordinate-input': @onChangeCoordinate

  onChangeCoordinate: (event) ->
    vector = @currentData()
    $vector = $(event.target).closest('.vector')

    newVector = {}

    for property in ['x', 'y', 'z']
      newVector[property] = _.parseFloatOrZero $vector.find(".coordinate-#{property} .coordinate-input").val()

    @options.save "#{_.toLower vector.name}": newVector
