AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.ContextWithArtworks extends LOI.Adventure.Context
  constructor: ->
    super arguments...

    @verticalParallaxFactor = 1
    @horizontalParallaxFactor = 1

    @displayedArtworksFields = new ReactiveField null
    @highlightedArtworksFields = new ReactiveField []

    @dialogueMode = new ReactiveField false

    @targetFocusPoint = new ReactiveField x: 0.5, y: 0.5
    @_focusPoint = @targetFocusPoint()
    @_scrollTop = 0

  onCreated: ->
    super arguments...

    # Subscribe to artists and artworks.
    for artistField, artistInfo of @artistsInfo
      if artistInfo.name
        PADB.Artist.forName.subscribe @, artistInfo.name
        PADB.Artwork.forArtistName.subscribe @, artistInfo.name
        
      else if artistInfo.pseudonym
        PADB.Artist.forPseudonym.subscribe @, artistInfo.pseudonym
        PADB.Artwork.forArtistPseudonym.subscribe @, artistInfo.pseudonym

    @artists = new ComputedField =>
      artists = {}

      for artistField, artistInfo of @artistsInfo
        if artistInfo.name
          artists[artistField] = PADB.Artist.forName.query(artistInfo.name).fetch()[0]

        else if artistInfo.pseudonym
          artists[artistField] = PADB.Artist.documents.findOne pseudonym: artistInfo.pseudonym

      artists

    @artworks = new ComputedField =>
      artworks = {}

      for artworkField, artworkInfo of @artworksInfo
        if artworkInfo.artistInfo.name
          artist = PADB.Artist.forName.query(artworkInfo.artistInfo.name).fetch()[0]

        else if artworkInfo.artistInfo.pseudonym
          artist = PADB.Artist.documents.findOne pseudonym: artworkInfo.artistInfo.pseudonym

        continue unless artist

        if artworkInfo.url
          # Search by URL.
          artwork = PADB.Artwork.forUrl.query(artworkInfo.url).fetch()[0]

        else
          # Search by title.
          artwork = PADB.Artwork.documents.findOne
            'authors._id': artist._id
            title: artworkInfo.title

        if artwork
          artworks[artworkField] = artwork

          # Forward the caption.
          artwork.caption = artworkInfo.caption
          
          # Set if it's non-pixel art (true for all physical artworks).
          artwork.nonPixelArt = artworkInfo.nonPixelArt or artwork.type is PADB.Artwork.Types.Physical

      artworks

    @displayedArtworks = new ComputedField =>
      return unless fields = @displayedArtworksFields()

      artworks = @artworks()
      artworks[field] for field in fields when artworks[field]

  onRendered: ->
    super arguments...

    @$scene = @$('.scene')

    @_parallaxItems = for element in @$('.scene *[data-depth]')
      $element = $(element)

      $element: $element
      depth: $element.data('depth')
      origin:
        x: $element.data('originX')
        y: $element.data('originY')

    # Dummy DOM element to run velocity on.
    @$animate = $('<div>')

    # Update scene style when viewport changes.
    @autorun (computation) =>
      @_updateSceneStyle()

  displayArtworks: (artworkFields) ->
    @displayedArtworksFields artworkFields

    # Create the stream component.
    stream = new @constructor.Stream @displayedArtworks

    LOI.adventure.showActivatableModalDialog
      dialog: stream

  highlight: (artworkFields) ->
    if @highlightedArtworksFields().length
      # We need to first cancel highlighting for a frame.
      Meteor.clearTimeout @_highlightEndTimeout
      @highlightedArtworksFields []

      Tracker.afterFlush => @highlight artworkFields

    else
      @highlightedArtworksFields artworkFields or []

      @_highlightEndTimeout = Meteor.setTimeout =>
        @highlightedArtworksFields []
      ,
        5000

  setFocus: (targetFocusPoint) ->
    @_focusPoint = targetFocusPoint
    @targetFocusPoint targetFocusPoint
    return unless @isRendered()

    @$animate.velocity('stop', 'moveFocus')
    @_updateSceneStyle()

  moveFocus: (targetFocusPointOrOptions) ->
    if targetFocusPointOrOptions.focusPoint
      targetFocusPoint = targetFocusPointOrOptions.focusPoint
      speedFactor = targetFocusPointOrOptions.speedFactor or 1
      completeCallback = targetFocusPointOrOptions.completeCallback
      
    else
      targetFocusPoint = targetFocusPointOrOptions
      speedFactor = 1
      
    # We clamp the focus point so that it won't get clamped later.
    @_startingFocusPoint = @_clampFocusPoint @_focusPoint
    @targetFocusPoint targetFocusPoint
    targetFocusPoint = @_clampFocusPoint targetFocusPoint

    @_moveFocusDelta =
      x: targetFocusPoint.x - @_startingFocusPoint.x
      y: targetFocusPoint.y - @_startingFocusPoint.y

    duration = 30 / speedFactor * Math.sqrt(Math.pow(@_moveFocusDelta.x * @sceneSize.width, 2) + Math.pow(@_moveFocusDelta.y * @sceneSize.height, 2))

    @$animate.velocity('stop', 'moveFocus').velocity
      tween: [1, 0]
    ,
      duration: duration
      easing: 'ease-in-out'
      queue: 'moveFocus'
      progress: (elements, complete, remaining, current, tweenValue) =>
        @_focusPoint =
          x: @_startingFocusPoint.x + @_moveFocusDelta.x * tweenValue
          y: @_startingFocusPoint.y + @_moveFocusDelta.y * tweenValue

        @_updateSceneStyle()
      complete: completeCallback

    @$animate.dequeue('moveFocus')

  _clampFocusPoint: (focusPoint) ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    halfWidth = viewport.viewportBounds.width() / scale / 2
    halfHeight = @illustration().height / 2

    x: _.clamp focusPoint.x, halfWidth / @sceneSize.width, (@sceneSize.width - halfWidth) / @sceneSize.width
    y: _.clamp focusPoint.y, halfHeight / @sceneSize.height, (@sceneSize.height - halfHeight) / @sceneSize.height

  illustration: ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    if @dialogueMode()
      # In dialogue mode we only fill half the screen minus one line (8rem).
      height = viewport.viewportBounds.height() / scale / 2 - 8

    else
      height = @sceneSize.height
    
    {height}
      
  onScroll: (scrollTop) ->
    return unless @isRendered()

    @_scrollTop = scrollTop
    @_updateSceneStyle()

  _updateSceneStyle: ->
    scrollParallaxOffset = @_scrollTop / 20 * @verticalParallaxFactor

    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()
    illustrationHeight = @illustration().height

    scrollableWidth = @sceneSize.width * scale - viewport.viewportBounds.width()
    scrollableHeight = @sceneSize.height * scale - illustrationHeight * scale

    # The scene top also needs to take into account that scrolling reduces the size of the illustration (the UI covers
    # it from the bottom). The smaller the illustration (or the bigger the scroll top), the more scrollable height
    # there is. Finally we need to account for the amount of parallax offset we can introduce from scrolling.
    reducedScrollableHeight = scrollableHeight + @_scrollTop - scrollParallaxOffset

    focusFactor =
      x: _.clamp (@_focusPoint.x * @sceneSize.width * scale - viewport.viewportBounds.width() / 2) / scrollableWidth, 0, 1
      y: _.clamp (@_focusPoint.y * @sceneSize.height * scale - illustrationHeight * scale / 2) / scrollableHeight, 0, 1

    focusFactor.x = @_focusPoint.x if _.isNaN focusFactor.x
    focusFactor.y = @_focusPoint.y if _.isNaN focusFactor.y

    # Outside of dialogue we always show the whole scene so we need to
    # focus on the bottom to show the whole scene as we scroll by.
    focusFactor.y = 1 unless @dialogueMode()

    left = -scrollableWidth * focusFactor.x
    top = -reducedScrollableHeight * focusFactor.y

    @$scene.css transform: "translate3d(#{left}px, #{top}px, 0)"

    for parallaxItem in @_parallaxItems
      left = (parallaxItem.origin.x - focusFactor.x) * parallaxItem.depth * scrollableWidth / 10 * @horizontalParallaxFactor
      top = (parallaxItem.origin.y - focusFactor.y) * parallaxItem.depth * scrollableHeight / 5 - parallaxItem.depth * scrollParallaxOffset

      parallaxItem.$element.css transform: "translate3d(#{left}px, #{top}px, 0)"

  highlightingActiveClass: ->
    'highlighting-active' if @highlightedArtworksFields().length

  artworkClasses: (artworkField) ->
    classes = [
      _.kebabCase artworkField
      'artwork'
    ]

    classes.push 'highlighted' if artworkField in @highlightedArtworksFields()

    classes.join ' '

  events: ->
    super(arguments...).concat
      'click .artwork': @onClickArtwork

  onClickArtwork: (event) ->
    styleClasses = $(event.target).attr('class').split(' ')
    artworkFields = (_.camelCase styleClass for styleClass in styleClasses)

    @displayArtworks artworkFields

  class @Stream extends AM.Component
    @register 'Retronator.HQ.ArtStudio.ContextWithArtworks.Stream'

    constructor: (@artworks) ->
      super arguments...

      @activatable = new LOI.Components.Mixins.Activatable()

    mixins: -> [@activatable]

    onRendered: ->
      super arguments...

      $(window).scrollTop 0

    onDestroyed: ->
      super arguments...

      $(window).scrollTop 0

    streamOptions: ->
      captionComponentClass: @constructor.ArtworkCaption
      scrollParentSelector: '.retronator-hq-artstudio-contextwithartworks-stream'
      display: LOI.adventure.interface.display

    events: ->
      super(arguments...).concat
        'click': @onClick

    onClick: (event) ->
      @activatable.deactivate()

    class @ArtworkCaption extends AM.Component
      @register 'Retronator.HQ.ArtStudio.ContextWithArtworks.Stream.ArtworkCaption'

      authors: ->
        artwork = @data()
        authors = (artist.displayName for artist in artwork.authors)
        authors.join ' & '

      year: ->
        artwork = @data()
        artwork.completionDate.year or artwork.completionDate.getFullYear()
