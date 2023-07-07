LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.AdmissionProjects.Snake.Intro.Coworking extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionProjects.Snake.Intro.Coworking'

  @location: -> HQ.Coworking

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/admissionprojects/snake/intro/scenes/coworking.script'

  @initialize()

  # Script

  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      reuben: HQ.Actors.Reuben

    @setCallbacks
      ReceiveProject: (complete) =>
        @ephemeralState 'startError', null
  
        PAA.Pico8.Cartridges.Snake.Project.start LOI.characterId(), (error) =>
          if error
            console.error error
            @ephemeralState 'startError', error

          else
            # Store if the player has the drawing app.
            pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
            drawingApp = _.find pixelPad.os.currentApps(), (app) => app instanceof PAA.PixelPad.Apps.Drawing
            @ephemeralState 'hasDrawingApp', drawingApp?

            # Reset high score to force replay.
            PAA.Pico8.Cartridges.Snake.state 'highScore', 0

          complete()

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    return unless choicePlaceholderResponse.scriptId is HQ.Coworking.Reuben.defaultScriptId()
    return unless choicePlaceholderResponse.placeholderId is 'MainQuestions'

    # Prerequisite is to ask what Reuben's working on.
    return unless Retronator.HQ.Coworking.Reuben.Listener.Script.state 'UpTo'

    # If the player got the cartridge, wait on the player to score 5 points
    if @script.state 'ReceiveCartridge'
      highScore = PAA.Pico8.Cartridges.Snake.state 'highScore'

      if highScore >= 5
        # Store high score to script.
        Tracker.nonreactive => @script.ephemeralState 'highScore', highScore

        choicePlaceholderResponse.addChoice @script.startNode.labels.Scored5OrMore.next

      else
        choicePlaceholderResponse.addChoice @script.startNode.labels.HaventScored5PointsYet.next

      return

    # Store in state if the character has the PICO-8 app.
    pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
    hasPico8 = PAA.PixelPad.Apps.Pico8 in pixelPad.os.currentAppsSituation().things()
    Tracker.nonreactive => @script.ephemeralState 'hasPico8', hasPico8

    # If the player has seen PICO-8 questions and has acquired the app, allow to report this.
    if @script.state('Pico8Questions') and hasPico8
      choicePlaceholderResponse.addChoice @script.startNode.labels.GotPico8.next
      return

    # If the player has seen PICO-8 questions, allow to ask them again until PICO-8 is acquired.
    if @script.state('Pico8Questions') and not hasPico8
      choicePlaceholderResponse.addChoice @script.startNode.labels.Pico8Choice.next
      return

    # Store in state if the character has the Snake project added to the Study Plan.
    hasSnakeGoal = PAA.PixelPad.Apps.StudyPlan.hasGoal C1.Goals.Snake
    Tracker.nonreactive => @script.ephemeralState 'hasSnakeGoal', hasSnakeGoal

    # If player has the snake goal and didn't before, let them report it.
    if @script.state('AddToStudyPlan') and hasSnakeGoal
      choicePlaceholderResponse.addChoice @script.startNode.labels.AddedSnakeGoal.next
      return

    # Looks like we haven't done any interactions yet. Show the offer to help.
    choicePlaceholderResponse.addChoice @script.startNode.labels.OfferHelp.next
