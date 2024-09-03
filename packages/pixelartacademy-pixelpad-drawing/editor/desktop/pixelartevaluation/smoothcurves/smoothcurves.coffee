AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAE = PAA.Practice.PixelArtEvaluation
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.SmoothCurves extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.SmoothCurves'
  @register @id()
  
  @CriteriaNames:
    AbruptSegmentLengthChanges: '生硬的线段长度变化'
    StraightParts: '接近直线的部分'
    InflectionPoints: '拐点'
    
  @CategoryNames:
    AbruptSegmentLengthChanges:
      Minor: '影响较小 (B级–D级)'
      Major: '影响较大 (F级)'
    StraightParts:
      End: '位于末尾处 (A级-C级)'
      Middle: '位于中间部分 (A级-F级)'
    InflectionPoints:
      Isolated: '较少 (A级)'
      Sparse: '稀疏 (B级–D级)'
      Dense: '密集 (F级)'

  onCreated: ->
    super arguments...
    
    @pixelArtEvaluation = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation

    @smoothCurvesProperty = new ComputedField =>
      @pixelArtEvaluation.bitmap()?.properties?.pixelArtEvaluation?.smoothCurves
      
    @editable = new ComputedField => @smoothCurvesProperty()?.editable ? @pixelArtEvaluation.editable()
    
    @criteria = new ComputedField =>
      smoothCurvesProperty = @smoothCurvesProperty()
      editable = @editable()
      
      criteria = []
      
      for criterion of PAE.Subcriteria.SmoothCurves
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and all otherwise so we can toggle them on and off).
        continue unless editable or smoothCurvesProperty?[criterionProperty]?
        
        if enabled = smoothCurvesProperty?[criterionProperty]?
          categories = for category of PAE.Line.Part.Curve[criterion]
            id: category
            name: @constructor.CategoryNames[criterion][category]
            count: smoothCurvesProperty[criterionProperty].counts[_.lowerFirst category]
        
        else
          categories = null
        
        criteria.push
          id: criterion
          parentId: PAE.Criteria.SmoothCurves
          property: criterionProperty
          propertyPath: "smoothCurves.#{criterionProperty}"
          name: @constructor.CriteriaNames[criterion]
          enabled: enabled
          score: smoothCurvesProperty?[criterionProperty]?.score
          categories: categories
      
      criteria
      
  scorePercentage: (value) -> Markup.percentage value
  
  events: ->
    super(arguments...).concat
      'pointerenter .score, pointerenter .count': @onPointerEnterScoreOrCount
      'pointerleave .score, pointerleave .count': @onPointerLeaveScoreOrCount
  
  onPointerEnterScoreOrCount: (event) ->
    criterionOrCategory = @currentData()

    @pixelArtEvaluation.hoveredFilterValue criterionOrCategory.id
  
  onPointerLeaveScoreOrCount: (event) ->
    @pixelArtEvaluation.hoveredFilterValue null
