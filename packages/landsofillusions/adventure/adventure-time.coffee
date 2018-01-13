AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeTime: ->
    # The amount of seconds of playtime that happened.
    @_time = new ReactiveField null

    # The current game time from the character's perspective. Only the time number is stored here.
    @_gameDate = new ReactiveField null

    @_gameTimeInterval = Meteor.setInterval =>
      # Only increase time when the page is active and we're not paused.
      return if document.hidden or @paused()

      # Read last playtime from game state.
      return unless gameState = @gameState()
      lastTime = gameState.time or 0
      lastGameDateTime = gameState.gameDateTime or 0

      # Add one second.
      newTime = lastTime + 1

      speedFactor = gameState.gameTimeSpeedFactor or 1
      newGameDateTime = lastGameDateTime + speedFactor / (60 * 60 * 24)

      # Update time in game state, but don't trigger reactivity (no need to update the database just for time increase)/.
      gameState.time = newTime
      gameState.gameDateTime = newGameDateTime

      # Instead, if things need to be reactive to time, they will depend on the time reactive field.
      @_time newTime

      newGameDate = new LOI.GameDate newGameDateTime
      @_gameDate newGameDate

      console.log "Playtime:", newTime, "seconds, Game time:", newGameDate.toString() if LOI.debug
    ,
      1000

  # Query this to see if adventure time is running or not.
  paused: ->
    # Game is paused when there are any modal dialogs.
    return true if LOI.adventure.modalDialogs().length

    # It's also paused when we're in any of the accounts-ui flows/dialogs.
    accountsUiSessionVariables = ['inChangePasswordFlow', 'inMessageOnlyFlow', 'resetPasswordToken', 'enrollAccountToken', 'justVerifiedEmail', 'justResetPassword', 'configureLoginServiceDialogVisible', 'configureOnDesktopVisible']
    for variable in accountsUiSessionVariables
      return true if Accounts._loginButtonsSession.get variable

    false

  time: ->
    console.log "Returned time", @_time() if LOI.debug
    @_time()

  resetTime: ->
    @_time null

  gameDate: ->
    @_gameDate()
