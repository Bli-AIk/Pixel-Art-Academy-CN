AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Menu.Items extends LOI.Components.Menu.Items
  @register 'PixelArtAcademy.LearnMode.Menu.Items'

  template: -> 'PixelArtAcademy.LearnMode.Menu.Items'

  onCreated: ->
    super arguments...
    
    # On desktop we have to ask the window for its full-screen status.
    if Meteor.isDesktop
      @_isFullscreen = new ReactiveField false

      # Listen to fullscreen changes.
      Desktop.on 'window', 'isFullscreen', (event, isFullscreen) =>
        @_isFullscreen isFullscreen
      
      # Request initial value.
      Desktop.send 'window', 'isFullscreen'
    
  isFullscreen: ->
    if Meteor.isDesktop
      @_isFullscreen()
    
    else
      super arguments...
      
  showQuitToMenu: ->
    # We quit to menu when we're not on the landing page
    not @options.landingPage
    
  events: ->
    super(arguments...).concat
      # Main menu
      'click .quit-to-menu': @onClickQuitToMenu

  onClickContinue: (event) ->
    LOI.adventure.menu.hideMenu()
  
  onClickNew: (event) ->
    LOI.adventure.startNewGame().then =>
      LOI.adventure.interface.goToPlay()
  
  onClickQuitToMenu: (event) ->
    # Check if the profile is being synced.
    profile = LOI.adventure.profile()
    
    if _.keys(profile.syncedStorages).length > 0
      @_quitGame()
  
    else
      # Notify the player that they will lose the current game state.
      dialog = new LOI.Components.Dialog
        message: "You will lose your current game progress if you quit without saving."
        buttons: [
          text: "Quit"
          value: true
        ,
          text: "Cancel"
        ]
    
      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: =>
          @_quitGame() if dialog.result
          
  _quitGame: ->
    LOI.adventure.menu.hideMenu()
    LOI.adventure.quitGame callback: =>
      LOI.adventure.interface.goToMainMenu()
      
      # Notify that we've handled the quitting sequence.
      true

  onClickQuit: (event) ->
    if Meteor.isDesktop
      Desktop.send 'desktop', 'closeApp'
  
  onClickSettings: (event) ->
    @currentScreen @constructor.Screens.Settings
  
    # Store current state of settings.
    @_oldSettings = LOI.settings.toObject()

  onClickFullscreen: (event) ->
    if Meteor.isDesktop
      if @_isFullscreen()
        Desktop.send 'window', 'setFullscreen', false
    
      else
        Desktop.send 'window', 'setFullscreen', true
        
    else
      if AM.Window.isFullscreen()
        AM.Window.exitFullscreen()
    
      else
        AM.Window.enterFullscreen()
      
    # Do a late UI resize to accommodate any fullscreen transitions.
    Meteor.setTimeout =>
      LOI.adventure.interface.resize()
    ,
      1000
