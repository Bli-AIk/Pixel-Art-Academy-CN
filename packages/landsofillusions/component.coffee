AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Component extends AM.Component
  constructor: ->
    super arguments...
    
    @audioMixin = new LOI.Components.Mixins.Audio @
  
  mixins: -> super(arguments...).concat @audioMixin
