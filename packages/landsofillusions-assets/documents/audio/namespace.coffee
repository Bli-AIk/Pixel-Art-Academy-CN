AE = Artificial.Everywhere
AEc = Artificial.Echo
LOI = LandsOfIllusions

class LOI.Assets.Audio.Namespace
  constructor: (@id, @options = {}) ->
    # Create variables.
    @variables = {}
    
    for name, valueTypeOrVariableOptions of @options.variables
      @variables[name] = new AEc.Variable "#{@id}.#{name}", valueTypeOrVariableOptions

  load: (audioManager) ->
    # Don't load documents in a sub-namespace since they will already be handled from the top namespace.
    return if @options.subNamespace
    
    @unload()
  
    # Subscribe to audio assets in the namespace.
    path = @id.toLowerCase().replaceAll('.', '/')
    
    @_subscriptionAutorun = Tracker.autorun (computation) =>
      return unless audioManager.enabled()
      
      LOI.Assets.Audio.forNamespace.subscribe path
    
    # Create engine audio assets.
    @engineAudioAssets = {}
    
    @engineAudioDictionary = new AE.ReactiveDictionary =>
      audioAssets = {}
      audioAssets[audioAsset._id] = audioAsset for audioAsset in LOI.Assets.Audio.forNamespace.query(path).fetch()
      audioAssets
    ,
      added: (audioId, audioData) =>
        @engineAudioAssets[audioId] = Tracker.nonreactive =>
          nodesDataProvider = new ReactiveField audioData.nodes
          new AEc.Audio audioId, audioManager.context(), nodesDataProvider
      
      updated: (audioId, audioData) =>
        @engineAudioAssets[audioId].nodesDataProvider audioData.nodes
      
      removed: (audioId, audio) =>
        @engineAudioAssets[audioId].destroy()
        delete @engineAudioAssets[audioId]
      
  unload: ->
    return if @options.subNamespace
    
    @_subscriptionAutorun?.stop()
    @engineAudioDictionary?.stop()
