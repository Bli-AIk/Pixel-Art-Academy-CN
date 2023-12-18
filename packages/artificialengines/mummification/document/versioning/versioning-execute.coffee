AE = Artificial.Everywhere
AM = Artificial.Mummification

AM.Document.Versioning.executeAction = (versionedDocument, lastEditTime, action, actionTime, appendToLastAction = false) ->
  @_validateActionOrder versionedDocument, lastEditTime, actionTime
  
  # Increase history position.
  currentHistoryPosition = versionedDocument.historyPosition or 0
  lastAction = versionedDocument.history?[currentHistoryPosition - 1]
  appendToLastAction = false unless lastAction
  
  newHistoryPosition = currentHistoryPosition
  newHistoryPosition++ unless appendToLastAction
  
  if Meteor.isClient
    # On the client we need to update both the live document (which we're receiving in the versioned document) as well
    # as the document from the persistence collection. First, execute the action on the live document, unless it
    # was already executed with partial actions.
    if versionedDocument.partialAction
      # We assume all operations of action have already been applied through partial
      # execution and we can just remove the partial action to signify it's been fully applied.
      delete versionedDocument.partialAction
      
    else
      @executeOperations versionedDocument, action.forward
  
    versionedDocument.lastEditTime = actionTime
    versionedDocument.historyPosition = newHistoryPosition
    versionedDocument.history ?= []
    versionedDocument.history.splice currentHistoryPosition if versionedDocument.history.length > currentHistoryPosition
    
    if appendToLastAction
      # Note: We have to call the static append since actions don't get deserialized to rich objects.
      AM.Document.Versioning.Action.append lastAction, action
      
    else
      versionedDocument.history.push action
    
    # Proceed by applying the changes to the persistent document.
    versionedDocument = versionedDocument.constructor.documents.findOne versionedDocument._id
    versionedDocument.initialize?()
  
  changedFields = @executeOperations versionedDocument, action.forward

  # Change history. Store the new action's operations before they get
  # potentially overwritten so we can report them in the event later.
  executedOperations = action.forward
  action = lastAction if appendToLastAction
  
  modifier =
    $set:
      historyPosition: newHistoryPosition
      lastEditTime: actionTime
    $push:
      history:
        $position: newHistoryPosition - 1
        $each: [action]
        $slice: newHistoryPosition
    
  # We also need to apply the actual changes to the fields.
  @_addChangedFieldsToModifier versionedDocument, changedFields, modifier
  
  # Update the persistent/database document.
  versionedDocument.constructor.documents.update versionedDocument._id, modifier

  # On the client, raise an event that changes were made.
  versionedDocument.constructor.versionedDocuments.operationsExecuted versionedDocument, executedOperations, changedFields if Meteor.isClient
  
AM.Document.Versioning._validateActionOrder = (versionedDocument, lastEditTime, newLastEditTime) ->
  # If we have no last edit time we use the creation time.
  documentLastEditTime = versionedDocument.lastEditTime or versionedDocument.creationTime
  
  # Make sure the action is trying to be applied on the correct version of the document.
  throw new AE.InvalidOrderException "The current version of the document is ahead of the client." if documentLastEditTime > lastEditTime
  throw new AE.InvalidOrderException "The action is being applied on a version of the document that is behind the client." if documentLastEditTime < lastEditTime
  throw new AE.InvalidOrderException "The action must be applied at a later time than the document last edit time." unless newLastEditTime > documentLastEditTime
  throw new AE.InvalidOrderException "The time on the client is more than 10s different than the time on the server." if Math.abs(newLastEditTime.getTime() - Date.now()) > 10000

AM.Document.Versioning._addChangedFieldsToModifier = (versionedDocument, changedFields, modifier) ->
  traverseChangedFields = (path, node) =>
    # See if we've reached a leaf node.
    if _.isObject node
      # Traverse all node children.
      for name, child of node
        newPath = [path..., name]
        traverseChangedFields newPath, child

    else
      address = path.join '.'
      value = _.nestedProperty versionedDocument, address
      
      # Convert all rich objects to plain objects.
      toPlainObject = (value) ->
        return value unless _.isObject value
        
        # EJSON types are left as-is since they will be converted automatically.
        return value if value.toJSONValue or EJSON.isBinary(value) or value instanceof Date
        
        # See if the object provides its own plain object conversion.
        object = value
        return object.toPlainObject() if object.toPlainObject

        # Arrays require special iteration.
        return (toPlainObject element for element in value) if _.isArray value
        
        # Convert all properties of the object to plain objects.
        plainObject = {}
        
        for key, value of object when not _.isFunction value
          plainObject[key] = toPlainObject value

        plainObject

      value = toPlainObject value
      
      if value is undefined
        modifier.$unset ?= {}
        modifier.$unset[address] = true
        
      else
        modifier.$set[address] = value

  traverseChangedFields [], changedFields

AM.Document.Versioning.executePartialAction = (versionedDocument, action) ->
  @executeOperations versionedDocument, action.forward
  
  if versionedDocument.partialAction
    # This is a continuation of a partial action so merge it to the previous one.
    versionedDocument.partialAction.forward.push action.forward...
    versionedDocument.partialAction.backward.unshift action.backward...
    
  else
    # This is the start of a partial action.
    versionedDocument.partialAction = action

AM.Document.Versioning.executeOperations = (versionedDocument, operations) ->
  # Execute the operations and track which fields were changed.
  allChangedFields = for operation in operations
    changedFields = operation.execute versionedDocument

    # On the client, raise an event that changes were made.
    versionedDocument.constructor.versionedDocuments.operationExecuted versionedDocument, operation, changedFields if Meteor.isClient

    changedFields
    
  # Merge all changed fields, giving priority to changes of the whole field over partial ones.
  _.mergeWith {}, allChangedFields..., (targetField, sourceField) ->
    # A true value signifies the field as a whole has been changed.
    return true if targetField is true or sourceField is true
    
    # Do a normal merge of sub-fields.
    undefined

AM.Document.Versioning.reportExecuteActionError = (versionedDocument) ->
  versionedDocument.constructor.versionedDocuments.reportExecuteActionError versionedDocument._id
