AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAG = PAA.Practice.PixelArtEvaluation
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.EvenDiagonals extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.EvenDiagonals'
  @register @id()
  
  @CriteriaNames:
    SegmentLengths: "Segment lengths"
    EndSegments: "End segments"
  
  @CategoryNames:
    SegmentLengths:
      Even: "Even (A)"
      Alternating: "Alternating (A–C)"
      Broken: "Broken (C–F)"
    EndSegments:
      Matching: "Matching (A)"
      Shorter: "Shorter (A–F)"
  
  onCreated: ->
    super arguments...
    
    @pixelArtEvaluation = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation

    @evenDiagonalsProperty = new ComputedField =>
      @pixelArtEvaluation.bitmap()?.properties?.pixelArtEvaluation?.evenDiagonals
      
    @editable = new ComputedField => @evenDiagonalsProperty()?.editable ? @pixelArtEvaluation.pixelArtEvaluationProperty()?.editable
    
    @criteria = new ComputedField =>
      evenDiagonalsProperty = @evenDiagonalsProperty()
      editable = @editable()
      
      criteria = []
      
      for criterion of PAG.Subcriteria.EvenDiagonals
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and all otherwise so we can toggle them on and off).
        continue unless editable or evenDiagonalsProperty?[criterionProperty]?
        
        if enabled = evenDiagonalsProperty?[criterionProperty]?
          categories = for category of PAG.Line.Part.StraightLine[criterion]
            id: category
            name: @constructor.CategoryNames[criterion][category]
            count: evenDiagonalsProperty[criterionProperty].linePartCounts[_.lowerFirst category]
            
        else
          categories = null
        
        criteria.push
          id: criterion
          parentId: PAG.Criteria.EvenDiagonals
          property: criterionProperty
          propertyPath: "evenDiagonals.#{criterionProperty}"
          name: @constructor.CriteriaNames[criterion]
          enabled: enabled
          score: evenDiagonalsProperty?[criterionProperty]?.score
          categories: categories
      
      criteria
  
  scorePercentage: (value) -> Markup.percentage value
  
  events: ->
    super(arguments...).concat
      'pointerenter .category .count': @onPointerEnterCategory
      'pointerleave .category .count': @onPointerLeaveCategory
  
  onPointerEnterCategory: (event) ->
    category = @currentData()
    criterion = Template.parentData()

    @pixelArtEvaluation.hoveredCategoryValue
      property: criterion.property
      value: category.id
  
  onPointerLeaveCategory: (event) ->
    @pixelArtEvaluation.hoveredCategoryValue null
