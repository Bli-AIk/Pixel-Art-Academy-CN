AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.OS extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.OS'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      complete: AEc.ValueTypes.Trigger

  constructor: (@pixelPad) ->
    super arguments...

    @justOS = not @pixelPad

    @appsLocation = new PAA.PixelPad.Apps
    @systemsLocation = new PAA.PixelPad.Systems

    @currentAppsSituation = new ComputedField =>
      options =
        timelineId: LOI.adventure.currentTimelineId()
        location: @appsLocation

      return unless options.timelineId and options.location

      new LOI.Adventure.Situation options
  
    @currentSystemsSituation = new ComputedField =>
      options =
        timelineId: LOI.adventure.currentTimelineId()
        location: @systemsLocation
    
      return unless options.timelineId and options.location
    
      new LOI.Adventure.Situation options
  
    # We use caches to avoid reconstruction.
    @_apps = {}
    @_systems = {}

    # Instantiates and returns all apps that are available to listen to commands.
    @currentApps = new ComputedField =>
      return unless currentAppsSituation = @currentAppsSituation()

      appClasses = currentAppsSituation.things()

      for appClass in appClasses
        # We create the instance in a non-reactive context so that
        # reruns of this autorun don't invalidate instance's autoruns.
        Tracker.nonreactive =>
          @_apps[appClass.id()] ?= new appClass @

        @_apps[appClass.id()]
        
    @currentAppUrl = new ComputedField =>
      appUrl = AB.Router.getParameter('parameter2')
      appClass = PAA.PixelPad.App.getClassForUrl appUrl

      # Make sure this app exists.
      if appClass then appUrl else null

    @currentAppPath = new ComputedField =>
      AB.Router.getParameter('parameter3')

    @currentAppParameter = new ComputedField =>
      AB.Router.getParameter('parameter4')

    @currentApp = new ReactiveField null

    # Instantiates and returns all systems that are active.
    @currentSystems = new ComputedField =>
      return unless currentSystemsSituation = @currentSystemsSituation()

      systemClasses = currentSystemsSituation.things()

      for systemClass in systemClasses
        # We create the instance in a non-reactive context so that
        # reruns of this autorun don't invalidate instance's autoruns.
        Tracker.nonreactive =>
          @_systems[systemClass.id()] ?= new systemClass @
    
        @_systems[systemClass.id()]
        
    # Set currentApp based on url.
    @appTransitioning = new ReactiveField false
    
    Tracker.autorun (computation) =>
      return unless @isRendered()
      
      # Don't route until apps are created.
      return unless currentApps = @currentApps()
      
      # Don't route during transitions.
      return if @appTransitioning()

      appUrl = @currentAppUrl()
      appClass = PAA.PixelPad.App.getClassForUrl(appUrl) or PAA.PixelPad.Apps.HomeScreen

      Tracker.nonreactive =>
        newApp = _.find currentApps, (app) => app instanceof appClass
        currentApp = @currentApp()

        return if newApp is currentApp

        startNewApp = =>
          return unless newApp

          # Hide app area to prevent flickering before the transition starts.
          @$appArea.css opacity: 0

          @currentApp newApp
          newApp.activate()

          # Transition the new app in after it has rendered (and we have a new app wrapper).
          Tracker.autorun (computation) =>
            return unless newApp.isRendered()
            computation.stop()
            
            @$appArea.velocity 'transition.slideUpIn', complete: => @$appArea.css transform: ''
          
        if currentApp
          @appTransitioning true
          currentApp.deactivate =>
            startNewApp()
            @appTransitioning false

        else
          startNewApp()

    if @justOS
      # Create pixel scaling display.
      @display = new Artificial.Mirage.Display
        safeAreaWidth: 320
        safeAreaHeight: 240
        minScale: 2

    else
      # Just take adventure's display.
      @display = LOI.adventure.interface.display

  onRendered: ->
    super arguments...

    @$root = if @justOS then $('html') else @$('.pixelartacademy-pixelpad-os').closest('.os')
    @$root.addClass('pixelartacademy-pixelpad-os-root')
    
    @$appArea = @$('.app-area')

  onDestroyed: ->
    super arguments...

    @$root.removeClass('pixelartacademy-pixelpad-os-root')
    
  getSystem: (systemClass) ->
    _.find @currentSystems(), (system) => system instanceof systemClass

  url: ->
    url = PAA.PixelPad.url()

    if appUrl = @currentAppUrl()
      url = "#{url}/#{appUrl}/*"

    url

  appPath: (appUrl, appPath, appParameter) ->
    appPath = null if appPath instanceof Spacebars.kw

    if @justOS
      AB.Router.createUrl 'pixelPad',
        app: appUrl
        path: appPath
        parameter: appParameter

    else
      AB.Router.createUrl LOI.adventure,
        parameter1: PAA.PixelPad.url()
        parameter2: appUrl
        parameter3: appPath
        parameter4: appParameter

  go: (appUrl, appPath, appParameter) ->
    AB.Router.goToUrl @appPath appUrl, appPath, appParameter

  shortcutsTableVisibleClass: ->
    'visible' if _.every [@currentSystems()..., @currentApp()], (program) => program.allowsShortcutsTable()

  backButtonCallback: ->
    # See if the app can handle it.
    return cancel: true if @currentApp().onBackButton?()
    
    # See if any of the systems want to handle it.
    for system in @currentSystems()
      return cancel: true if system.onBackButton?()

    # Clear one of the parameters.
    if @currentAppParameter()
      # We clear the parameter.
      AB.Router.changeParameter 'parameter4', null

    else if @currentAppPath()
      # We return to main app screen.
      AB.Router.changeParameter 'parameter3', null

    else if @currentAppUrl()
      # We return to home screen.
      AB.Router.changeParameter 'parameter2', null

    else
      # No app is open, we should actually close PixelPad.
      LOI.adventure.deactivateActiveItem()
      return

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true
