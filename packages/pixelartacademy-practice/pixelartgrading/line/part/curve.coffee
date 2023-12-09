AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

_point = new THREE.Vector2

class PAG.Line.Part.Curve extends PAG.Line.Part
  constructor: (..., @isClosed) ->
    super arguments...

    # Create display points.
    @displayPoints = []
    
    segmentParameter = 0.5
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      
      # Exclude side-step segments from generating curve points, except at end points.
      continue unless segment.pointSegmentsCount or segmentIndex in [@startSegmentIndex, @endSegmentIndex]
      
      startPointIndex = segment.startPointIndex
      endPointIndex = segment.endPointIndex
      
      startPointIndex = Math.max startPointIndex, @startPointIndex if segmentIndex is @startSegmentIndex
      endPointIndex = Math.min endPointIndex, @endPointIndex if segmentIndex is @endSegmentIndex
      
      startPoint = @line.getPoint startPointIndex
      endPoint = @line.getPoint endPointIndex
      
      unless @isClosed
        segmentParameter = switch segmentIndex
          when @startSegmentIndex then 0
          when @endSegmentIndex then 1
          else 0.5
        
      @displayPoints.push @_createDisplayPoint new THREE.Vector2().lerpVectors startPoint, endPoint, segmentParameter
      
    if @isClosed and (@displayPoints[0].x isnt @displayPoints[@displayPoints.length - 1].x or @displayPoints[0].y isnt @displayPoints[@displayPoints.length - 1].y)
      @displayPoints.push @displayPoints[0]
      
    if @displayPoints.length is 2
      startPoint = @line.getPoint @line.getEdgeSegment(@startSegmentIndex).endPointIndex
      endPoint = @line.getPoint @line.getEdgeSegment(@endSegmentIndex).startPointIndex
      
      @displayPoints.splice 1, 0, @_createDisplayPoint new THREE.Vector2().lerpVectors startPoint, endPoint, 0.5
    
    @_calculateControlPoints 0, @displayPoints.length - 1
  
  _createDisplayPoint: (position) ->
    position: position
    normal: new THREE.Vector2
    controlPoints:
      before: new THREE.Vector2
      after: new THREE.Vector2
  
  _calculateControlPoints: (displayPointStartIndex, displayPointEndIndex) ->
    for index in [displayPointStartIndex..displayPointEndIndex]
      point = @displayPoints[index]
      previousPoint = if @isClosed then @displayPoints[_.modulo index - 1, @displayPoints.length] else @displayPoints[index - 1]
      nextPoint = if @isClosed then @displayPoints[_.modulo index + 1, @displayPoints.length] else @displayPoints[index + 1]
      
      # Calculate the normal.
      unless previousPoint
        if @previousPart
          @previousPart.line2.delta point.normal
        
        else
          point.normal.subVectors nextPoint.position, point.position
          
      else unless nextPoint
        if @nextPart
          @nextPart.line2.delta point.normal
        
        else
          point.normal.subVectors point.position, previousPoint.position
          
      else
        point.normal.subVectors nextPoint.position, previousPoint.position
        
      point.normal.normalize()
      
      # Calculate control points.
      if previousPoint
        distance = point.position.distanceTo previousPoint.position
        point.controlPoints.before.copy(point.normal).multiplyScalar(-distance / 3).add point.position
        
      if nextPoint
        distance = point.position.distanceTo nextPoint.position
        point.controlPoints.after.copy(point.normal).multiplyScalar(distance / 3).add point.position
        
    # Explicit return to prevent result collection.
    null
  
  setNeighbors: ->
    super arguments...
    
    if @previousPart
      @projectToLine @startPointIndex, @previousPart, @displayPoints[0].position
      @_calculateControlPoints 0, 1
    
    if @nextPart
      @projectToLine @endPointIndex, @nextPart, @displayPoints[@displayPoints.length - 1].position
      @_calculateControlPoints @displayPoints.length - 2, @displayPoints.length - 1
  
  projectToLine: (pointIndex, straightLine, target) ->
    _point.copy @line.getPoint pointIndex
    straightLine.line2.closestPointToPoint _point, false, target
    
  _getPointSegment: (index) ->
    if @isClosed then @pointSegments[_.modulo index, @pointSegments.length] else @pointSegments[index]
    
  _getEdgeSegment: (index) ->
    return null unless @isClosed or @startSegmentIndex <= index <= @endSegmentIndex

    @line.getEdgeSegment index

  grade: ->
    # TODO
    {}
