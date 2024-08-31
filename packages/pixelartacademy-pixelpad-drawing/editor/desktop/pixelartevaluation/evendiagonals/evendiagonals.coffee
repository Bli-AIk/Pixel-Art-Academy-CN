AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAE = PAA.Practice.PixelArtEvaluation
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.EvenDiagonals extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.EvenDiagonals'
  @register @id()
  
  @CriteriaNames:
    SegmentLengths: "线段长度"
    EndSegments: "末尾线段"
  
  @CategoryNames:
    SegmentLengths:
      Even: "均匀 (A级)"
      Alternating: "交替 (A级–C级)"
      Broken: "断裂 (C级–F级)"
    EndSegments:
      Matching: "匹配 (A级)"
      Shorter: "稍短 (A级–F级)"
  
  onCreated: ->
    super arguments...
    
    @pixelArtEvaluation = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation

    @evenDiagonalsProperty = new ComputedField =>
      @pixelArtEvaluation.bitmap()?.properties?.pixelArtEvaluation?.evenDiagonals
      
    @editable = new ComputedField => @evenDiagonalsProperty()?.editable ? @pixelArtEvaluation.editable()
    
    @criteria = new ComputedField =>
      evenDiagonalsProperty = @evenDiagonalsProperty()
      editable = @editable()
      
      criteria = []
      
      for criterion of PAE.Subcriteria.EvenDiagonals
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and all otherwise so we can toggle them on and off).
        continue unless editable or evenDiagonalsProperty?[criterionProperty]?
        
        if enabled = evenDiagonalsProperty?[criterionProperty]?
          categories = for category of PAE.Line.Part.StraightLine[criterion]
            id: category
            name: @constructor.CategoryNames[criterion][category]
            count: evenDiagonalsProperty[criterionProperty].counts[_.lowerFirst category]
            
        else
          categories = null
        
        criteria.push
          id: criterion
          parentId: PAE.Criteria.EvenDiagonals
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

    @pixelArtEvaluation.hoveredFilterValue
      property: criterion.property
      value: category.id
  
  onPointerLeaveCategory: (event) ->
    @pixelArtEvaluation.hoveredFilterValue null
