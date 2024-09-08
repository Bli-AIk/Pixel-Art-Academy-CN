AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions

Persistence = Artificial.Mummification.Document.Persistence

profileWidth = 80

class LOI.Components.LoadGame extends LOI.Component
  @id: -> 'LandsOfIllusions.Components.LoadGame'
  @register @id()

  @url: -> 'loadgame'
  
  @version: -> '0.0.1'
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      load: AEc.ValueTypes.Boolean
      loadPan: AEc.ValueTypes.Number
  
  constructor: (@options) ->
    super arguments...
    
    @activatable = new LOI.Components.Mixins.Activatable
    @loadingVisible = new ReactiveField false
    @loadingTextVisible = new ReactiveField false
    @loadingProfileId = new ReactiveField null
    @autoLoadedProfileId = new ReactiveField null
    @showProfileLoadingPercentage = new ReactiveField false
    
    # Which profile is shown left-most. Allows to scroll through options.
    @firstProfileOffset = new ReactiveField 0
  
  mixins: -> super(arguments...).concat @activatable
  
  onCreated: ->
    super arguments...

    @profiles = new ComputedField => Persistence.Profile.documents.fetch syncedStorages: $ne: {}
    @maxFirstProfileOffset = new ComputedField => @profiles().length - 4

  show: (autoLoadProfileId) ->
    @autoLoadedProfileId autoLoadProfileId
    @firstProfileOffset 0

    LOI.adventure.showActivatableModalDialog
      dialog: @
      dontRender: true

    if autoLoadProfileId
      new Promise (resolve, reject) =>
        Tracker.autorun (computation) =>
          # Wait until persistence is ready so we have the profiles loaded.
          return unless Persistence.ready()
          computation.stop()
  
          if Persistence.Profile.documents.findOne autoLoadProfileId
            @loadProfile(autoLoadProfileId, false).then =>
              resolve()
              
          else
            console.log "Desired profile was not provided by any of the synced storages." if LOI.debug or LOI.Adventure.debugState
            @callFirstWith null, 'deactivate'
            reject()
    
  loadProfile: (profileId, animate = true) ->
    @loadingProfileId profileId
    @showProfileLoadingPercentage false
    
    loadPan = if animate then AEc.getPanForElement @$("[data-id=#{profileId}]")[0] else 0
    @audio.loadPan loadPan
    @audio.load true
    await _.waitForSeconds 0.5 if animate
    
    @loadingVisible true
    await _.waitForSeconds 0.5 if animate
    @loadingTextVisible true
    
    loadPromise = LOI.adventure.loadGame(profileId).catch (error) =>
      if LOI.adventure.loadingStoredProfile()
        LOI.adventure.showDialogMessage """
            很遗憾，最后一个可用的存档无法自动加载。
            游戏现在将从菜单页面重新启动，但如果问题持续存在的话，
            以下信息可能会有用：#{error.reason}
          """
        
        , =>
          @callFirstWith null, 'deactivate'
      
      else
        LOI.adventure.showDialogMessage """
          很遗憾，这个游戏存档似乎损坏了。这多半是我的问题，我会尽快修复的！
          你的存档应该已经备份了，它可能会帮你恢复部分进度。
          如果可以，请联系我，我可以帮助你尝试解决这个问题。
          这些信息可能也会有用：#{error.reason}
        """
      
      @loadingVisible false
      @loadingTextVisible false
      @loadingProfileId null
      @audio.load false
      
    # Now that the profile has started loading, see if you should show the loading
    # percentage if it seems the game will load for more than half a second.
    await _.waitForSeconds 0.5
    @showProfileLoadingPercentage Persistence.profileLoadingPercentage() < 100
    
    # When the audio is on, make loading last a while to hear the sweet floppy drive sounds.
    await _.waitForSeconds 2 if LOI.adventure.audioManager.enabled()
    
    await loadPromise
    @loadingProfileId null
    
    @audio.load false
    @loadingTextVisible false
    
    @callFirstWith null, 'deactivate' if LOI.adventure.profileId()
  
  onActivate: (finishedActivatingCallback) ->
    await _.waitForSeconds 0.5
    finishedActivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    await _.waitForSeconds 0.5
    @loadingVisible false
    finishedDeactivatingCallback()

  showBackButton: ->
    not (@loadingVisible() or @autoLoadedProfileId())
    
  profilesStyle: ->
    offset = @firstProfileOffset()

    left: "-#{offset * profileWidth}rem"

  nextButtonDisabledAttribute: ->
    disabled: true if @firstProfileOffset() is @maxFirstProfileOffset()

  previousButtonDisabledAttribute: ->
    disabled: true if @firstProfileOffset() is 0

  nextButtonVisibleClass: ->
    'visible' if @maxFirstProfileOffset() > 0

  previousButtonVisibleClass: ->
    'visible' if @maxFirstProfileOffset() > 0

  profileActiveClass: ->
    profile = @currentData()
    'active' if @loadingProfileId() is profile._id or LOI.adventure.profileId() is profile._id

  profileName: ->
    profile = @currentData()
    profile.displayName or profile._id
    
  loadingVisibleClass: ->
    'visible' if @loadingVisible()
  
  loadingTextVisibleClass: ->
    'visible' if @loadingTextVisible()
    
  profileLoadingPercentage: ->
    Math.floor Persistence.profileLoadingPercentage()

  events: ->
    super(arguments...).concat
      'click .profile': @onClickProfile
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onClickProfile: (event) ->
    profile = @currentData()
    @loadProfile profile._id

  onClickPreviousButton: (event) ->
    newIndex = Math.max 0, @firstProfileOffset() - 4

    @firstProfileOffset newIndex

  onClickNextButton: (event) ->
    newIndex = Math.min @maxFirstProfileOffset(), @firstProfileOffset() + 4

    @firstProfileOffset newIndex
