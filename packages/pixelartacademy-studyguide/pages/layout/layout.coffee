AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Layout extends LOI.Components.EmbeddedWebpage
  @register 'PixelArtAcademy.StudyGuide.Pages.Layout'

  @image: (parameters) ->
    Meteor.absoluteUrl "retropolis/city/academyofart/link-image.png"

  constructor: ->
    super arguments...

    @_modalDialogs = []
    @_modalDialogsDependency = new Tracker.Dependency

  rootClass: -> 'pixelartacademy-studyguide'

  addModalDialog: (dialogOptions) ->
    # Delegate dialog display to adventure if embedded.
    return LOI.adventure.addModalDialog dialogOptions if @embedded

    # We add _id so that #each won't re-render the dialogs.
    dialogOptions._id = Random.id()

    # We add new dialogs at the beginning so the first is the (assumed) top-most.
    @_modalDialogs.unshift dialogOptions
    @_modalDialogsDependency.changed()

  removeModalDialog: (dialog) ->
    # Delegate dialog display to adventure if embedded.
    return LOI.adventure.removeModalDialog dialogOptions if @embedded

    dialogIndex = _.findIndex @_modalDialogs, (dialogOptions) -> dialogOptions.dialog is dialog

    @_modalDialogs.splice dialogIndex, 1
    @_modalDialogsDependency.changed()

  modalDialogs: ->
    @_modalDialogsDependency.depend()
    @_modalDialogs

  # Activates a dialog and waits for the player to complete interacting with it.
  showActivatableModalDialog: (dialogOptions) ->
    # Wait until dialog has been active and deactivated again.
    dialogWasActivated = false

    @addModalDialog dialogOptions

    # Wait for the dialog to be rendered.
    Tracker.afterFlush =>
      dialogOptions.dialog.activatable.activate()

      Tracker.autorun (computation) =>
        if dialogOptions.dialog.activatable.activated()
          dialogWasActivated = true

        else if dialogOptions.dialog.activatable.deactivated() and dialogWasActivated
          computation.stop()
          @removeModalDialog dialogOptions.dialog

          # Call callback in nonreactive context in case the callback runs any of its own
          # autoruns (we don't want them to get invalidated when this autorun completes).
          Tracker.nonreactive =>
            dialogOptions.callback?()

  showDialogMessage: (message) ->
    @showActivatableModalDialog
      dialog: new LOI.Components.Dialog
        message: message
        buttons: [
          text: "好的"
        ]
