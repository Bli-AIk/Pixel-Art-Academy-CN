AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Line::evaluate = ->
  return @_evaluation if @_evaluation
  
  doubles = @_analyzeDoubles()
  corners = @_analyzeCorners()
  widthType = @_analyzeWidthType()
  
  @_evaluation = {widthType, doubles, corners}
  
  @_evaluation
  
PAE.Line::_analyzeDoubles = ->
  doubles = @getDoubles()
  
  # Side-steps need to be diagonals instead of axis-aligned.
  sideStepsCount = 0
  diagonalSideStepsCount = 0
  
  for edgeSegment in @edgeSegments when edgeSegment.isSideStep
    sideStepsCount++
    diagonalSideStepsCount++ unless edgeSegment.edge.isAxisAligned
    
  sideStepScore = if sideStepsCount then diagonalSideStepsCount / sideStepsCount else 1
  
  score: sideStepScore
  pixels: doubles

PAE.Line::_analyzeCorners = ->
  corners = @getCorners()

  # Count how many total transitions there were on this line so we can compare how many of these are corners.
  transitionsCount = 0

  for edgeSegment, edgeSegmentIndex in @edgeSegments when not edgeSegment.isSideStep
    break unless nextEdgeSegment = @getEdgeSegment edgeSegmentIndex + 1
    continue if nextEdgeSegment.isSideStep
    transitionsCount++
    
  score: if transitionsCount then 1 - corners.length / transitionsCount else 1
  count: corners.length

PAE.Line::_analyzeWidthType = ->
  # Analyze single and double points.
  radiusCounts = _.countBy @points, 'radius'
  singleCount = radiusCounts[0.5]
  doubleCount = radiusCounts[1]
  
  return @constructor.WidthType.Variable if singleCount and doubleCount
  return @constructor.WidthType.Wide if doubleCount
  
  # We only have single points so we need to determine if the line is thin or thick.
  sideStepEdgeSegments = _.filter  @edgeSegments, (edgeSegment) => edgeSegment.isSideStep
  
  axisAlignedCount = _.countBy sideStepEdgeSegments, (edgeSegment) => edgeSegment.edge.isAxisAligned
  thinCount = axisAlignedCount[false]
  thickCount = axisAlignedCount[true]
  
  return @constructor.WidthType.Variable if thinCount and thickCount
  return @constructor.WidthType.Thick if thickCount
  @constructor.WidthType.Thin
