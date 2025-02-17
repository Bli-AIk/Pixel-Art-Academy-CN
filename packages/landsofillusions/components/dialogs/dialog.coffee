AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Dialog extends AM.Component
  @register 'LandsOfIllusions.Components.Dialog'

  constructor: (@options) ->
    super arguments...

    @activatable = new LOI.Components.Mixins.Activatable()
    @result = null

  mixins: -> [@activatable]

  events: ->
    super(arguments...).concat
      'click .button': @onClickButton

  onClickButton: (event) ->
    button = @currentData()
    @result = button.value

    @activatable.deactivate()
