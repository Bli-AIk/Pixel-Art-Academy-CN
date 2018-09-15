PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry
IL = Illustrapedia

class Entry.Object.Task extends Entry.Object
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Object.Task'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'task'
    tag: 'p'
    class: 'pixelartacademy-pixelboy-apps-journal-journalview-entry-object-task'

  onCreated: ->
    super

    value = @value()
    taskClass = PAA.Learning.Task.getClassForId value.id
    
    unless taskClass
      console.warn "Unknown task with ID", value.id
      return

    @characterId = new ComputedField =>
      @entryComponent()?.entry().journal.character._id
    ,
      true
      
    goalClass = taskClass.goal()

    @goal = new goalClass
      characterId: @characterId
      
    @task = _.find @goal.tasks(), (task) => task instanceof taskClass

    @taskComponent = new @constructor[taskClass.type] @

    @_taskEntrySubscription = new ComputedField =>
      return unless characterId = @characterId()

      PAA.Learning.Task.Entry.forCharacterTaskIds.subscribe characterId, [@task.id()]
    ,
      true

  onDestroyed: ->
    super

    @goal?.destroy()
    @characterId?.stop()
    @taskEntry?.stop()
    @_taskEntrySubscription?.stop()

  completedClass: ->
    'completed' if @task.completed()

  active: ->
    return if @readOnly()
    
    @task.active @goal.tasks()

  activeClass: ->
    'active' if @active()

  ready: ->
    @_taskEntrySubscription()?.ready()

  readyClass: ->
    # We are ready when we're sure we got the entry if it exists.
    'ready' if @ready()

  readOnlyClass: ->
    'read-only' if @readOnly()

  prerequisitesAll: ->
    @task.constructor.predecessorsCompleteType() is PAA.Learning.Task.PredecessorsCompleteType.All

  prerequisites: ->
    tasks = @goal.tasks()
    prerequisites = []

    # See if we only need one predecessor completed.
    anyCompleted = @task.constructor.predecessorsCompleteType() is PAA.Learning.Task.PredecessorsCompleteType.Any

    for predecessorClass in @task.predecessors()
      predecessor = _.find tasks, (task) => task instanceof predecessorClass

      if predecessor.completed()
        # We found a completed predecessor. If we only need to find one, there are no other prerequisites.
        return [] if anyCompleted

      else
        # Add this uncompleted task as a prerequisite.
        prerequisites.push predecessor

    prerequisites
