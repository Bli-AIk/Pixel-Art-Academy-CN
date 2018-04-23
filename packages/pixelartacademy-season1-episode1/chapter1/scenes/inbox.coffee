LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Inbox extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Inbox'

  @location: -> LOI.Emails.Inbox

  @initialize()

  constructor: ->
    super

    @emails = [
      new C1.Items.ApplicationEmail
      new C1.Items.AdmissionEmail
    ]

  things: ->
    things = []

    things.push email for email in @emails when email.arrived()

    things

  ready: ->
    conditions = [
      super
      email.ready() for email in @emails
    ]

    _.every _.flatten conditions
