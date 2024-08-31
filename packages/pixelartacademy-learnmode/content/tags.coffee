AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Tags
  @Free = 'Free'
  @BaseGame = 'BaseGame'
  @DLC = 'DLC'
  @WIP = 'WIP'
  @Future = 'Future'
  
  @id: -> 'PixelArtAcademy.LearnMode.Content.Tags'
  
  @getDisplayNameForKey: (key) -> @_getTranslationForKey key, 'displayName'
  @getDescriptionForKey: (key) -> @_getTranslationForKey key, 'description'
  
  @_getTranslationForKey: (key, property) -> AB.translate(@_translationSubscription, "#{key}.#{property}").text

  @initialize: (translations) ->
    translationNamespace = @id()

    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create translations.
        for tag, tagTranslations of translations
          for property, value of tagTranslations
            AB.createTranslation translationNamespace, "#{tag}.#{property}", value

    # On the client, subscribe to the translations.
    if Meteor.isClient
      @_translationSubscription = AB.subscribeNamespace translationNamespace

LM.Content.Tags.initialize
  Free:
    displayName: "免费"
    description: "此课程作为游戏试玩版免费提供。"
  BaseGame:
    displayName: "游戏本体"
    description: "此课程包含在游戏本体内。"
  DLC:
    displayName: "DLC"
    description: "This course can be purchased as downloadable content."
  DLCAppStore:
    displayName: "DLC"
    description: "This course can be purchased as an in-app purchase."
  WIP:
    displayName: "尚未完成"
    description: "该课程仍在开发中，获得alpha访问权限的玩家可以在未完成的状态下进行游玩。"
  Future:
    displayName: "即将开发"
    description: "此课程计划在将来进行开发，开发计划会随着开发工作的推进而发生变化。"
