LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Memory.Progress extends AM.Document
  @id: -> 'LandsOfIllusions.Memory.Progress'
  # profileId: profile whose memory progress we're tracking
  # observedMemories: array of memories that have been observed already
  #   memory: the memory being tracked
  #     _id
  #   time: the time of the last action already observed by the profile
  #   discovered: boolean indicating if the game already advertised this memory to the player
  @Meta
    name: @id()
    fields: =>
      observedMemories: [
        memory: Document.ReferenceField LOI.Memory
      ]

  # Methods

  @updateProgress: @method 'updateProgress'
  @discoverMemory: @method 'discoverMemory'

  # Subscriptions

  @forProfile: @subscription 'forProfile'

  getTimeForMemoryId: (memoryId) ->
    observedMemory = _.find @observedMemories, (observedMemory) -> observedMemory.memory._id is memoryId

    observedMemory?.time
