AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.FileManager.Directory extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Components.FileManager.Directory'
  @register @id()
  
  constructor: (@options) ->
    super arguments...

    @_id = Random.id()

    @selectedItems = new ReactiveField []

  onCreated: ->
    super arguments...

    @_selectedNames = new ReactiveField []
    @_previousSelectedNames = new ReactiveField []
    @_startRangeName = new ReactiveField null

    @width = new ReactiveField 100

    @documents = new ComputedField =>
      documentSources = @options.fileManager.options.documents
      documentSources = [documentSources] unless _.isArray documentSources

      documents = for documentSource in documentSources
        documentSource.fetch
          name: new RegExp "^#{@options.path}"

      _.flatten documents

    @newFolders = new ReactiveField []

    @currentItems = new ComputedField =>
      # Scan all documents and sort them into folders and files.
      folders = []
      files = []

      for document in @documents() when document.name
        nameParts = LOI.Assets.Components.FileManager.itemNameParts document, @options.path
        if firstFolder = nameParts.folders[0]
          # This is a file deeper inside the folder so just see if we need to add the folder.
          folders.push firstFolder unless firstFolder in folders

        else
          # This is a file at top level of the path.
          document.sortingName = _.toLower nameParts.filename
          files.push document

      # Create full folder objects.
      folders = for folder in folders
        new @constructor.Folder "#{@options.path}#{folder}", _.toLower folder

      actuallyNewFolders = _.filter @newFolders(), (folder) =>
        not _.find folders, (existingFolder) => folder.name is existingFolder.name

      folders.push actuallyNewFolders...

      items = folders.concat files

      # Update selected items when current items change.
      selectedNames = @_selectedNames()
      @selectedItems _.filter items, (item) => item.name in selectedNames

      _.sortBy items, 'sortingName'

    @editingNameItem = new ReactiveField null

    @draggingOverDirectoryCount = new ReactiveField 0
    @draggingOverFolder = new ReactiveField null
    @draggingOverFolderCount = new ReactiveField 0

  onRendered: ->
    super arguments...

    $(document).on "keydown.landsofillusions-assets-components-filemanager-directory-#{@_id}", (event) => @onKeyDown event

  onDestroyed: ->
    super arguments...

    $(document).off ".landsofillusions-assets-components-filemanager-directory-#{@_id}"

  newFolder: ->
    newFolderName = "untitled folder"
    newFolder = new @constructor.Folder "#{@options.path}#{newFolderName}", newFolderName

    newFolders = @newFolders()
    newFolders.push newFolder
    @newFolders newFolders

    @startRenamingItem newFolder, true

  startRenamingItem: (item, selectAll) ->
    @editingNameItem item

    Tracker.afterFlush =>
      $nameInput = @$('.name-input')
      $nameInput.focus()
      $nameInput.select() if selectAll

  nameOrId: ->
    item = @currentData()

    if item.name
      nameParts = LOI.Assets.Components.FileManager.itemNameParts item
      nameParts.filename

    else
      "#{data._id.substring 0, 5}…"

  selectedClass: ->
    item = @currentData()

    'selected' if item in @selectedItems()

  typeClass: ->
    item = @currentData()

    _.toLower item.constructor.name

  iconUrl: ->
    item = @currentData()

    "/landsofillusions/assets/components/filemanager/#{_.toLower item.constructor.name}.png"

  directoryStyle: ->
    width: "#{@width()}rem"

  editingName: ->
    item = @currentData()
    item is @editingNameItem()

  directoryDropTargetClass: ->
    'drop-target' if @draggingOverFolderCount() is 0 and @draggingOverDirectoryCount() > 0

  itemDropTargetClass: ->
    item = @currentData()
    'drop-target' if item is @draggingOverFolder() and @draggingOverFolderCount() > 0

  draggableAttribute: ->
    draggable: true unless @editingName()

  events: ->
    super(arguments...).concat
      'click': @onClick
      'mousedown .divider': @onMouseDownDivider
      'contextmenu': @onContextMenu
      'click .item': @onClickItem
      'dragstart .item': @onDragStartItem
      'dragenter .folder': @onDragEnterFolder
      'dragover .folder': @onDragOverFolder
      'dragleave .folder': @onDragLeaveFolder
      'drop .folder': @onDropFolder
      'dragenter .items': @onDragEnterDirectory
      'dragover .items': @onDragOverDirectory
      'dragleave .items': @onDragLeaveDirectory
      'drop .items, .drop .item': @onDropDirectory
      'click .name': @onClickName
      'change .name-input, blur .name-input': @onChangeNameInput

  onClick: (event) ->
    @options.fileManager.focusDirectory @

  onMouseDownDivider: (event) ->
    # Prevent browser select/dragging behavior.
    event.preventDefault()

    # Remember starting position of drag.
    @_dragStart = event.pageX

    # Remember starting width.
    @_widthStart = @width()

    display = @callAncestorWith 'display'
    scale = display.scale()

    # Wire dragging handlers.
    $document = $(document)

    $document.on 'mousemove.landsofillusions-assets-components-filemanager-directory', (event) =>
      dragDelta = event.pageX - @_dragStart
      @width @_widthStart + dragDelta / scale

    $document.on 'mouseup.landsofillusions-assets-components-filemanager-directory', (event) =>
      # End drag mode.
      $document.off '.landsofillusions-assets-components-filemanager-directory'

  onContextMenu: (event) ->
    # Prevent normal context menu from opening.
    event.preventDefault()

    @options.fileManager.focusDirectory @

    display = @callAncestorWith 'display'
    scale = display.scale()

    dialog =
      directory: @
      type: FM.Menu.Dropdown.id()
      left: event.pageX / scale
      top: event.pageY / scale
      canDismiss: true
      items: [
        LOI.Assets.Components.FileManager.Directory.NewFolder.id()
      ]

    @ancestorComponentOfType(FM.Interface).displayDialog dialog

  onClickItem: (event) ->
    return if @editingNameItem()

    item = @currentData()
    items = @currentItems()

    selectedNames = @_selectedNames()
    previousSelectedNames = @_previousSelectedNames()
    startRangeName = @_startRangeName()

    keyboardState = AC.Keyboard.getState()

    if keyboardState.isKeyDown(AC.Keys.shift)
      # Update range selection.
      endRangeName = item.name

    else if keyboardState.isCommandOrControlDown()
      # Add or remove the file from selection.
      if item.name in selectedNames
        # Remove the file from the selection
        if selectedNames.length is 1
          # We're removing the last item so we need to clear everything.
          previousSelectedNames = []
          startRangeName = null
          endRangeName = null

        else
          # Remove the clicked item and the last added one, which that will become the new range.
          _.pull selectedNames, item.name

          startRangeName = _.last selectedNames
          _.pull selectedNames, startRangeName

          endRangeName = startRangeName
          previousSelectedNames = selectedNames

      else
        # Add the file to the selection.
        previousSelectedNames = selectedNames
        startRangeName = item.name
        endRangeName = item.name

    else
      # Replace selection.
      previousSelectedNames = []
      startRangeName = item.name
      endRangeName = item.name

    if endRangeName
      startRangeIndex = Math.max 0, _.findIndex items, (item) => item.name is startRangeName
      endRangeIndex = _.findIndex items, (item) => item.name is endRangeName

      # Make sure start index is smaller than the end one.
      [startRangeIndex, endRangeIndex] = [endRangeIndex, startRangeIndex] if startRangeIndex > endRangeIndex

      selectedNames = _.union previousSelectedNames, (item.name for item in items[startRangeIndex..endRangeIndex])

    else
      selectedNames = previousSelectedNames

    @_startRangeName startRangeName
    @_previousSelectedNames previousSelectedNames
    @_selectedNames selectedNames

    selectedItems = _.filter items, (item) => item.name in selectedNames
    @selectedItems selectedItems

  onDragStartItem: (event) ->
    item = @currentData()
    event.originalEvent.dataTransfer.dropEffect = 'move'

    # See if we're dragging one of the selected files or another one.
    selectedItems = @selectedItems()

    if item in selectedItems
      draggedItems = selectedItems

    else
      draggedItems = [item]

    @options.fileManager.startDrag draggedItems

  onDragEnterFolder: (event) ->
    folder = @currentData()
    event.preventDefault()
    event.originalEvent.dataTransfer.dropEffect = 'move'

    if folder is @draggingOverFolder()
      @draggingOverFolderCount @draggingOverFolderCount() + 1

    else
      @draggingOverFolder folder
      @draggingOverFolderCount 1

  onDragOverFolder: (event) ->
    event.preventDefault()
    event.originalEvent.dataTransfer.dropEffect = 'move'

  onDragLeaveFolder: (event) ->
    # Make sure we're leaving the active folder.
    folder = @currentData()
    return unless folder is @draggingOverFolder()

    event.preventDefault()

    @draggingOverFolderCount Math.max 0, @draggingOverFolderCount() - 1

  onDropFolder: (event) ->
    folder = @currentData()
    event.preventDefault()

    @options.fileManager.endDrag folder

    @draggingOverFolderCount 0
    @draggingOverDirectoryCount 0

  onDragEnterDirectory: (event) ->
    # Only allow dragging onto a directory that's not the source of the dragged items.
    return if @options.fileManager.draggedItems()?[0] in @currentItems()

    event.preventDefault()
    event.originalEvent.dataTransfer.dropEffect = 'move'

    @draggingOverDirectoryCount @draggingOverDirectoryCount() + 1

  onDragOverDirectory: (event) ->
    event.preventDefault()
    event.originalEvent.dataTransfer.dropEffect = 'move'

  onDragLeaveDirectory: (event) ->
    event.preventDefault()

    @draggingOverDirectoryCount Math.max 0, @draggingOverDirectoryCount() - 1

  onDropDirectory: (event) ->
    # Make sure we're dragging over the directory.
    return if @draggingOverDirectoryCount() is 0

    # Only handle dropping onto the whole directory if we're not hovering over a folder.
    return if @draggingOverFolderCount() > 0

    event.preventDefault()

    # Remove trailing slash from the path.
    folderName = _.trimEnd @options.path, '/'
    folder = new @constructor.Folder folderName

    @options.fileManager.endDrag folder
    @draggingOverDirectoryCount 0

  onClickName: (event) ->
    item = @currentData()

    # We can only rename an item if it's the only selected items.
    selectedItems = @selectedItems()
    return unless selectedItems.length is 1 and item in selectedItems

    @startRenamingItem item

  onChangeNameInput: (event) ->
    # Make sure the input is still relevant.
    return unless item = @editingNameItem()

    $input = $(event.target)
    newFilename = $input.val()
    newName = "#{@options.path}#{newFilename}"

    # Make sure this is a new name.
    if newName.length and newName isnt item.name
      if item instanceof @constructor.Folder
        # Rename all documents with this folder's path.
        for document in @documents() when _.startsWith document.name, item.name
          newDocumentName = document.name.replace item.name, newName
          assetClassName = document.constructor.name

          LOI.Assets.Asset.update assetClassName, document._id,
            $set:
              name: newDocumentName

        # Rename the new folder.
        newFolders = @newFolders()

        if item in newFolders
          item.name = newName
          item.sortingName = _.toLower newFilename
          @newFolders newFolders

      else
        # Rename the document.
        assetClassName = item.constructor.name
        LOI.Assets.Asset.update assetClassName, item._id,
          $set:
            name: newName

    @editingNameItem null
    @_selectedNames [newName]

    $input.closest('.entry').scrollLeft 0

  onKeyDown: (event) ->
    # Directory needs to be focused to react to key events.
    return unless @options.fileManager.focusedDirectory() is @

    # Only react if we have a selection or we're editing a name.
    selectedItems = @selectedItems()
    return unless selectedItems.length

    if @editingNameItem()
      switch event.which
        when AC.Keys.return
          @$('.name-input').blur()

    else
      items = @currentItems()

      switch event.which
        when AC.Keys.down, AC.Keys.up
          targetItem = _.last selectedItems
          targetItemIndex = items.indexOf(targetItem)

          if event.which is AC.Keys.down
            newItemIndex = Math.min items.length - 1, targetItemIndex + 1

          else
            newItemIndex = Math.max 0, targetItemIndex - 1

          newItem = items[newItemIndex]
          @_startRangeName newItem.name
          @_previousSelectedNames []
          @_selectedNames [newItem.name]
          @selectedItems [newItem]

          # Do not scroll by default.
          event.preventDefault()

        when AC.Keys.left
          directories = @options.fileManager.directories()
          directoryIndex = directories.indexOf @

          return unless directoryIndex > 0

          # Clear selection in this directory.
          @_startRangeName null
          @_previousSelectedNames []
          @_selectedNames []

          # Focus on previous directory.
          @options.fileManager.focusDirectory directories[directoryIndex - 1]

          # Do not let the newly focused directory also handle the event.
          event.stopImmediatePropagation()

          # Do not scroll by default.
          event.preventDefault()

        when AC.Keys.right
          # Make sure we're on a folder.
          selectedItems = @selectedItems()
          return unless selectedItems.length is 1 and selectedItems[0] instanceof @constructor.Folder

          # Focus on next directory.
          directories = @options.fileManager.directories()
          directoryIndex = directories.indexOf @
          newDirectory = directories[directoryIndex + 1]
          @options.fileManager.focusDirectory newDirectory

          # Do not let the newly focused directory also handle the event.
          event.stopImmediatePropagation()

          # Select first item in the new directory.
          item = newDirectory.currentItems()[0]
          newDirectory._previousSelectedNames []
          newDirectory._startRangeName item?.name
          newDirectory._selectedNames if item then [item.name] else []
          newDirectory.selectedItems if item then [item] else []

          # Do not scroll by default.
          event.preventDefault()

          # Scroll to right.
          $directories = @$('.landsofillusions-assets-components-filemanager-directory').closest('.directories')
          $directories.scrollLeft 1e8

        when AC.Keys.return
          if selectedItems.length is 1
            @startRenamingItem selectedItems[0]
