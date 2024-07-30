AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Program extends LOI.Adventure.Thing
  @_programClassesBySlug = {}
  
  @getClassForSlug: (slug) ->
    @_programClassesBySlug[slug]
  
  @fullName: -> throw new AE.NotImplementedException "A program must provide its name."

  @slug: -> throw new AE.NotImplementedException "A program must provide the URL slug."
  @projectClass: -> null # Override to provide the project class if this program can be modified.
  
  @iconUrl: -> @versionedUrl "/pixelartacademy/pixeltosh/programs/#{@slug()}/icon.png"
  
  @initialize: ->
    super arguments...
    
    @_programClassesBySlug[@slug()] = @

  constructor: (@os) ->
    super arguments...
    
    @loaded = new ReactiveField()
  
  iconUrl: -> @constructor.iconUrl()
  
  load: ->
    # Extend to perform any logic on startup.
    @loaded true
  
  unload: ->
    # Extend to perform any cleanup.
    @loaded false
  
  menuItems: -> [] # Override to supply the data used to display the menu when this program is active.

  shortcuts: -> {} # Override to supply shortcuts to use when this program is active.
