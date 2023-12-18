AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  # Override to provide reference images that need to be added to the bitmap.
  @references: -> null
  
  @initializeReferences: ->
    return unless references = @references()
    
    # Create reference images on the server. They should be exported as database content.
    if Meteor.isServer and not Meteor.settings.startEmpty
      Document.startup =>
        for reference in references
          # Allow sending in just the reference URL.
          imageUrl = reference.image?.url or reference
    
          LOI.Assets.Image.documents.insert url: imageUrl unless LOI.Assets.Image.documents.findOne url: imageUrl
          
  constructor: ->
    super arguments...
    
    return @ unless references = @constructor.references()
    return @ unless goalChoices = @resources.goalChoices
    
    referenceUrlChoices = (goalChoice.referenceUrl for goalChoice in goalChoices)

    @displayedReferenceUrlChoices = new AE.LiveComputedField =>
      return unless bitmap = @bitmap()
      return unless references = bitmap.references
      displayedReferences = _.filter references, (reference) => reference.displayed and reference.image.url in referenceUrlChoices
      
      reference.image.url for reference in displayedReferences
    ,
      EJSON.equals
 
    # Update step areas and resize the bitmap accordingly if needed.
    @_chosenReferencesAutorun = Tracker.autorun (computation) =>
      return unless displayedReferenceUrlChoices = @displayedReferenceUrlChoices()
      
      Tracker.nonreactive => Tracker.afterFlush =>
        return unless bitmapId = @bitmapId()
        return unless bitmap = @bitmap()
        
        assets = @tutorial.assetsData()
        asset = _.find assets, (asset) => asset.id is @id()
        
        # Note: create a clone of step areas since the object gets compared for equality.
        stepAreas = if asset.stepAreas then EJSON.clone asset.stepAreas else []
        
        # Remove references at the end that haven't been drawn on yet.
        fixedDimensions = @constructor.fixedDimensions()
        singleWidth = fixedDimensions.width
        
        removeNeeded = false
        
        for stepArea in stepAreas when stepArea.referenceUrl not in displayedReferenceUrlChoices
          removeNeeded = true
          break
        
        if removeNeeded
          for stepArea, index in stepAreas by -1
            startX = index * singleWidth
            
            found = false
            for x in [0...singleWidth]
              for y in [0...fixedDimensions.height]
                if bitmap.findPixelAtAbsoluteCoordinates startX + x, y
                  found = true
                  break
                  
              break if found
              
            # Stop removing unused references since the player has already drawn here.
            break if found
            
            # The player hasn't drawn so far, so if we don't want the reference anymore, we can remove it.
            if stepArea.referenceUrl not in displayedReferenceUrlChoices
              _.pull stepAreas, stepArea
        
        # Add new step areas.
        for referenceUrl in displayedReferenceUrlChoices
          stepAreas.push {referenceUrl} unless _.find stepAreas, (stepArea) => stepArea.referenceUrl is referenceUrl
        
        asset.stepAreas = stepAreas
        @tutorial.state 'assets', assets

        # If necessary, resize the bitmap to make space for all the chosen references.
        desiredWidth = singleWidth * Math.max 1, stepAreas.length
        
        bitmap = Tracker.nonreactive => LOI.Assets.Bitmap.documents.findOne bitmapId, fields: bounds: 1
        width = bitmap.bounds.right - bitmap.bounds.left + 1
        
        unless desiredWidth is width
          bitmap = Tracker.nonreactive => LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId

          # Create a change bounds action.
          changeBounds = new LOI.Assets.Bitmap.Actions.ChangeBounds @id(), bitmap,
            left: 0
            top: 0
            right: desiredWidth - 1
            bottom: fixedDimensions.height - 1
            fixed: true
            
          bitmap.executeAction changeBounds, true
          
  initializeSteps: ->
    super arguments...
    
    return unless goalChoices = @resources.goalChoices

    # Dynamically load steps of the chosen references. Note that initializeSteps
    # gets called from an autorun, so we have to continue in nonreactive context.
    Tracker.nonreactive =>
      @assetStepAreas = new AE.LiveComputedField =>
        assets = @tutorial.assetsData()
        return unless asset = _.find assets, (asset) => asset.id is @id()
        asset.stepAreas
      ,
        # Limit reactivity to changes in the reference URLs.
        (a, b) =>
          return unless _.isArray(a) and _.isArray(b) and a.length is b.length
          
          for i in [0...a.length]
            return unless a.referenceUrl is b.referenceUrl
            
          true
      
      @_referenceStepsAutorun = Tracker.autorun (computation) =>
        return unless assetStepAreas = @assetStepAreas()
        
        # Only react to changes of the asset data.
        Tracker.nonreactive =>
          stepAreas = @stepAreas()
          @stepAreas []
          stepArea.destroy() for stepArea in stepAreas
          
          fixedDimensions = @constructor.fixedDimensions()
          
          for stepAreaData, index in assetStepAreas
            stepAreaBounds =
              x: index * fixedDimensions.width
              y: 0
              width: fixedDimensions.width
              height: fixedDimensions.height
            
            stepArea = new @constructor.StepArea @, stepAreaBounds
    
            goalChoice = _.find goalChoices, (goalChoice) => goalChoice.referenceUrl is stepAreaData.referenceUrl
            @_createSteps stepArea, goalChoice
        
  destroy: ->
    super arguments...
    
    @displayedReferenceUrlChoices?.stop()
    @assetStepAreas?.stop()
    @_chosenReferencesAutorun?.stop()
    @_referenceStepsAutorun?.stop()
