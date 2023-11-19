AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

edgeVectors = {}

getEdgeVector = (x, y) ->
  edgeVectors[x] ?= {}
  
  unless edgeVectors[x][y]
    edgeVectors[x][y] = new THREE.Vector2 x, y
    edgeVectors[x][y].isAxisAligned = x is 0 or y is 0
    
  edgeVectors[x][y]

class PAG.Line
  @edgeSegmentMinPointLengthForCorner = 3
  
  constructor: (@grading) ->
    @id = Random.id()
    
    @pixels = []
    @points = []
    @core = null
    
    @isClosed = false

    @edges = []
    @edgeSegments = []

    @potentialParts = []
    @potentialStraightLineParts = []
    @potentialCurveParts = []
    @pointPartIsCurve = []
    
    @parts = []
    
  destroy: ->
    pixel.unassignLine @ for pixel in @pixels
    point.unassignLine @ for point in @points
    @core?.unassignOutline @
    
  getEdgeSegment: (index) ->
    if @isClosed then @edgeSegments[_.modulo index, @edgeSegments.length] else @edgeSegments[index]

  getPoint: (index) ->
    if @isClosed then @points[_.modulo index, @points.length] else @points[index]
  
  isPointPartCurve: (index) ->
    if @isClosed then @pointPartIsCurve[_.modulo index, @points.length] else @pointPartIsCurve[index]

  assignPoint: (point, end = true) ->
    throw new AE.ArgumentException "The point is already assigned to this line.", point, @ if point in @points

    if end
      @points.push point
    
    else
      @points.unshift point
  
  assignCore: (core) ->
    throw new AE.ArgumentException "A core is already assigned to this line.", core, @ if @core
    @core = core
    
  unassignPoint: (point) ->
    throw new AE.ArgumentException "The point is not assigned to this line.", point, @ unless point in @points
    _.pull @points, point
  
  unassignCore: (core) ->
    throw new AE.ArgumentException "The core is not assigned to this line.", core, @ unless core is @core
    @core = null

  addPixel: (pixel) ->
    @pixels.push pixel
    pixel.assignLine @
  
  fillFromPoints: (pointA, pointB) ->
    # Start the line with these two points.
    @_addExpansionPoint pointA
    @_addExpansionPoint pointB

    # Now expand in both directions as far as you can.
    @_expandLine pointA, pointB, (point) => @_addExpansionPoint point
    @_expandLine pointB, pointA, (point) => @_addExpansionPoint point, false
  
  _expandLine: (previousPoint, currentPoint, operation) ->
    loop
      # Stop when we get to end segments or junctions.
      return unless currentPoint.neighbors.length is 2
      
      nextPoint = if currentPoint.neighbors[0] is previousPoint then currentPoint.neighbors[1] else currentPoint.neighbors[0]

      # Stop if we run into our own start/end, which makes for a closed line.
      if nextPoint is @points[0] or nextPoint is @points[@points.length - 1]
        @isClosed = true
        return
      
      operation nextPoint
      
      previousPoint = currentPoint
      currentPoint = nextPoint
  
  _addExpansionPoint: (point, end) ->
    @assignPoint point, end
    point.assignLine @
    
    for pixel in point.pixels
      @addPixel pixel unless pixel in @pixels
  
  addOutlinePoints: ->
    # For outlines, we expect the line already has all the pixels assigned and all the points already
    # have this line assigned to them, we just need to add the points in the correct order.
    startingPoint = _.find @pixels[0].points, (point) => @ in point.lines
    @points.push startingPoint

    previousPoint = startingPoint
    currentPoint = _.find startingPoint.neighbors, (point) => @ in point.lines
    @points.push currentPoint
    
    @isClosed = true
    
    loop
      nextPoint = _.find currentPoint.neighbors, (point) => @ in point.lines and point isnt previousPoint
      
      return if nextPoint is startingPoint
      
      @points.push nextPoint
      
      previousPoint = currentPoint
      currentPoint = nextPoint
      
  classifyLineParts: ->
    # Create edges.
    for point, index in @points
      nextPoint = @points[index + 1]
      
      unless nextPoint
        break unless @isClosed

        nextPoint = @points[0]
        
      dx = nextPoint.x - point.x
      dy = nextPoint.y - point.y
      @edges.push getEdgeVector dx, dy
      
    # Shift points in closed lines to consolidate same edges at the ends.
    if @isClosed
      while @edges[0] is @edges[@edges.length - 1]
        @points.push @points.shift()
        @edges.push @edges.shift()
        
    # Create edge segments.
    currentEdgeSegment = null
    
    for edge, edgeIndex in @edges
      if edge isnt currentEdgeSegment?.edge
        @edgeSegments.push currentEdgeSegment if currentEdgeSegment?
        
        currentEdgeSegment =
          edge: edge
          count: 0
          startPointIndex: edgeIndex
          endPointIndex: edgeIndex
          clockwise:
            before: null
            after: null
          curveClockwise:
            before: null
            after: null
          
      currentEdgeSegment.count++
      currentEdgeSegment.endPointIndex++
    
    @edgeSegments.push currentEdgeSegment
    
    # Analyze edge segments.
    for edgeSegment, edgeSegmentIndex in @edgeSegments
      edgeSegmentBefore = @getEdgeSegment edgeSegmentIndex - 1
      edgeSegmentAfter = @getEdgeSegment edgeSegmentIndex + 1

      edgeSegment.hasPointSegment =
        before: not edgeSegment.edge.isAxisAligned and not edgeSegmentBefore?.edge.isAxisAligned
        on: edgeSegment.edge.isAxisAligned or edgeSegment.count > 1
        after: not edgeSegment.edge.isAxisAligned and not edgeSegmentAfter?.edge.isAxisAligned
      
      if edgeSegment.edge.isAxisAligned
        # Axis aligned edge segments create 1 multiple-point segment.
        edgeSegment.pointSegmentsCount = 1
        edgeSegment.pointSegmentLength = if edgeSegment.startPointIndex? then edgeSegment.endPointIndex - edgeSegment.startPointIndex + 1 else 0
        
      else
        startPointIndex = edgeSegment.startPointIndex
        endPointIndex = edgeSegment.endPointIndex
        
        startPointIndex++ unless edgeSegment.hasPointSegment.before
        endPointIndex-- unless edgeSegment.hasPointSegment.after
        
        if startPointIndex > endPointIndex
          startPointIndex = null
          endPointIndex = null
          
        # Diagonal edge segments create multiple 1-point segments.
        edgeSegment.pointSegmentsCount = if startPointIndex? then endPointIndex - startPointIndex + 1 else 0
        edgeSegment.pointSegmentLength = 1
        
      angle = edgeSegment.edge.angle()
      angleAfter = edgeSegmentAfter?.edge.angle()
      
      edgeSegment.clockwise.after = if not edgeSegmentAfter? or edgeSegment.edge is edgeSegmentAfter.edge then null else _.angleDifference(angle, angleAfter) < 0
      edgeSegmentAfter?.clockwise.before = edgeSegment.clockwise.after

      edgeSegment.curveClockwise.after = edgeSegment.clockwise.after
      edgeSegmentAfter?.curveClockwise.before = edgeSegmentAfter.clockwise.before
      
      edgeSegment.corner = after: false
      
    for edgeSegment, edgeSegmentIndex in @edgeSegments
      continue unless edgeSegmentAfter = @getEdgeSegment edgeSegmentIndex + 1
      
      angle = edgeSegment.edge.angle()
      angleAfter = edgeSegmentAfter.edge.angle()
      
      if _.angleDistance(angle, angleAfter) > 1
        edgeSegment.corner.after = true
        
      else
        minPointLength = @constructor.edgeSegmentMinPointLengthForCorner
        edgeSegmentIsLong = edgeSegment.pointSegmentLength >= minPointLength or edgeSegment.pointSegmentsCount >= minPointLength
        edgeSegmentAfterIsLong = edgeSegmentAfter.pointSegmentLength >= minPointLength or edgeSegmentAfter.pointSegmentsCount >= minPointLength
        edgeSegment.corner.after = edgeSegmentIsLong and edgeSegmentAfterIsLong
    
    for edgeSegment, edgeSegmentIndex in @edgeSegments when edgeSegment.edge.isAxisAligned
      continue unless edgeSegmentAfter = @getEdgeSegment edgeSegmentIndex + 1
      continue unless edgeSegmentAfter.count is 1
      
      continue unless edgeSegmentAfter2 = @getEdgeSegment edgeSegmentIndex + 2
      continue unless edgeSegmentAfter2.edge is edgeSegment.edge
      
      # We have two neighboring point segments in the same direction so the curvature direction is dependent on the change of repetition count.
      if edgeSegmentAfter2.count is edgeSegment.count
        # This is a straight segment so no direction can be determined.
        edgeSegment.curveClockwise.after = null

      else if edgeSegmentAfter2.count > edgeSegment.count
        # The repeating count is increasing so the curve curves in the direction towards the after segment.
        edgeSegment.curveClockwise.after = edgeSegmentAfter2.curveClockwise.before
      
      edgeSegmentAfter.curveClockwise.before = edgeSegment.curveClockwise.after
      edgeSegmentAfter.curveClockwise.after = edgeSegment.curveClockwise.after
      edgeSegmentAfter2.curveClockwise.before = edgeSegment.curveClockwise.after
      
      # Side-step segments can't be corners.
      edgeSegment.corner.after = false
      edgeSegmentAfter.corner.after = false

    # Detect straight lines.
    lastStraightLineStartSegmentIndex = null
    lastStraightLineEndSegmentIndex = null
    
    addStraightLinePart = (startSegmentIndex, endSegmentIndex, averageSegmentCount) =>
      # Don't add a straight line that is already contained within the last straight line.
      return if lastStraightLineStartSegmentIndex? and startSegmentIndex >= lastStraightLineStartSegmentIndex and endSegmentIndex <= lastStraightLineEndSegmentIndex
      
      lastStraightLineStartSegmentIndex = startSegmentIndex
      lastStraightLineEndSegmentIndex = endSegmentIndex
      
      straightLine = new PAG.Line.Part.StraightLine @, startSegmentIndex, endSegmentIndex, null, null, averageSegmentCount
      @potentialParts.push straightLine
      @potentialStraightLineParts.push straightLine

    for startSegmentIndex in [0...@edgeSegments.length]
      startEdgeSegment = @edgeSegments[startSegmentIndex]
      
      # Start on edge segments that introduce point segments.
      continue unless startEdgeSegment.pointSegmentsCount

      sideEdgeClockwise = startEdgeSegment.clockwise.after

      # Straight lines are composed of equally sized segments, but allow for 1 count difference for intermediary lines,
      # so we need two possible main counts. Further, the starting and ending segment can be of any length shorter than
      # the main count.
      mainCount1 = null
      mainCount2 = null

      endSegmentIndex = startSegmentIndex
      
      loop
        # Stop if we reached a corner.
        edgeSegment = @getEdgeSegment endSegmentIndex
        break if edgeSegment.corner.after
        
        # Find a side-step segment.
        break unless nextEdgeSegment = @getEdgeSegment endSegmentIndex + 1
        break unless nextEdgeSegment.count is 1

        # Prevent diagonal to diagonal segments (most likely 90 degrees on a 45 degree diagonal).
        break unless startEdgeSegment.edge.isAxisAligned or nextEdgeSegment.edge.isAxisAligned

        # See if we have a next segment going into the right direction after this.
        endStraightLine = false
        endStraightLine = true unless secondNextEdgeSegment = @getEdgeSegment endSegmentIndex + 2
        endStraightLine = true unless secondNextEdgeSegment?.edge is startEdgeSegment.edge
        
        if endStraightLine
          # Include the final side-step segment if it provides a point.
          endSegmentIndex++ if nextEdgeSegment.pointSegmentsCount
          
          break
        
        # Determine how long the main (middle) parts of the diagonal are.
        determineExtraCount = false

        unless mainCount1
          # We're determining the initial count.
          if secondNextEdgeSegment.count > startEdgeSegment.count
            # The first element is shorter so we can consider it being the ending part.
            mainCount1 = secondNextEdgeSegment.count
            
          else
            mainCount1 = startEdgeSegment.count
            determineExtraCount = true
            
        else unless mainCount2
          determineExtraCount = true
          
        else unless secondNextEdgeSegment.count in [mainCount1, mainCount2]
          endStraightLine = true
          
        if determineExtraCount
          unless secondNextEdgeSegment.count is mainCount1
            # The extra count can only differ by 1 from main count.
            if Math.abs(mainCount1 - secondNextEdgeSegment.count) is 1
              mainCount2 = secondNextEdgeSegment.count
            
            else
              endStraightLine = true
          
        if endStraightLine
          # This segment is too much different than the main segment, but it could be the final part if it's shorter.
          if secondNextEdgeSegment.count < mainCount1
            # Allow this segment to be the end of the straight line.
            endSegmentIndex += 2
            
          break
        
        endSegmentIndex += 2
        
        break unless secondNextEdgeSegment.clockwise.after is sideEdgeClockwise
        
      mainCount1 ?= startEdgeSegment.count
      mainCount2 ?= mainCount1
      
      addStraightLinePart startSegmentIndex, endSegmentIndex, (mainCount1 + mainCount2) / 2
    
    # Detect curves.
    addCurvePart = (startSegmentIndex, endSegmentIndex) =>
      if endSegmentIndex >= startSegmentIndex + @edgeSegments.length
        endSegmentIndex = startSegmentIndex + @edgeSegments.length - 1
        isClosed = true
        
      else
        isClosed = false
        
        # Don't add a curve that is already contained within another part.
        for part in @potentialParts
          return if startSegmentIndex >= part.startSegmentIndex and endSegmentIndex <= part.endSegmentIndex
      
      curve = new PAG.Line.Part.Curve @, startSegmentIndex, endSegmentIndex, null, null, isClosed
      @potentialParts.push curve
      @potentialCurveParts.push curve

      curve
      
    for startSegmentIndex in [0...@edgeSegments.length]
      startEdgeSegment = @edgeSegments[startSegmentIndex]
      edgeSegment = startEdgeSegment
      
      # Start on edge segments that introduce point segments.
      continue unless edgeSegment.pointSegmentsCount
      clockwise = edgeSegment.curveClockwise.after
      endSegmentIndex = startSegmentIndex
      
      # Keep expanding until the turn of direction.
      while clockwise is edgeSegment.curveClockwise.after or not clockwise? or not edgeSegment.curveClockwise.after?
        clockwise ?= edgeSegment.curveClockwise.after

        # Stop if we reached a corner.
        break if edgeSegment.corner.after
        
        # Stop at the end, otherwise continue to next segment.
        break unless edgeSegment = @getEdgeSegment endSegmentIndex + 1
        endSegmentIndex++

        break if edgeSegment is startEdgeSegment
        
      continue unless clockwise?

      curve = addCurvePart startSegmentIndex, endSegmentIndex
      
      # No need to keep going if we found a closed curve.
      break if curve?.isClosed
      
    # Pick the most likely parts for each point.
    potentialCurvePart.calculatePointConfidence() for potentialCurvePart in @potentialCurveParts
    
    for point, pointIndex in @points
      @pointPartIsCurve[pointIndex] = false
      
      for potentialCurvePart in @potentialCurveParts
        if potentialCurvePart.pointConfidences[pointIndex]
          @pointPartIsCurve[pointIndex] = true
          break
      
    # Create final line parts.
    if @isClosed
      # For closed lines, first determine where the first edge between a curve and a straight line is.
      firstCurveStraightLineEdgePointIndex = null
      
      for pointIndex in [0...@points.length]
        unless @isPointPartCurve(pointIndex) is @isPointPartCurve(pointIndex + 1)
          firstCurveStraightLineEdgePointIndex = pointIndex + 1
          break
          
      # If we didn't find an edge at all it means all parts are the same.
      if firstCurveStraightLineEdgePointIndex is null
        if @isPointPartCurve 0
          # For curves, we can create a closed one.
          @parts.push new PAG.Line.Part.Curve @, 0, @edgeSegments.length - 1, 0, @points.length - 1, true
          return
      
        else
          # Straight polygons can be created from the start forward.
          firstCurveStraightLineEdgePointIndex ?= 0
      
    else
      # For open lines, we can simply start at the beginning since there will not be any wrap around.
      firstCurveStraightLineEdgePointIndex = 0
      
    pointPartIsCurve = null
    startSegmentIndex = null
    startPointIndex = null
    normalizedStartPointIndex = null
    
    segmentIndex = 0
    edgeSegment = @getEdgeSegment 0
    
    startRangePointIndex = firstCurveStraightLineEdgePointIndex
    endRangePointIndex = firstCurveStraightLineEdgePointIndex + @points.length - 1
    
    for pointIndex in [startRangePointIndex..endRangePointIndex]
      normalizedPointIndex = pointIndex % @points.length
      
      while normalizedPointIndex > edgeSegment.endPointIndex or normalizedPointIndex < edgeSegment.startPointIndex
        segmentIndex++
        edgeSegment = @getEdgeSegment segmentIndex
      
      startSegmentIndex ?= segmentIndex
      startPointIndex ?= pointIndex
      normalizedStartPointIndex ?= normalizedPointIndex
      pointPartIsCurve ?= @isPointPartCurve pointIndex
      
      # Keep expanding if we'll be on the same type of a part.
      continue if pointIndex isnt endRangePointIndex and @isPointPartCurve(pointIndex + 1) is pointPartIsCurve
      
      if pointPartIsCurve
        @parts.push new PAG.Line.Part.Curve @, startSegmentIndex, segmentIndex, normalizedStartPointIndex, normalizedPointIndex, false
        
      else
        # Find which straight line parts overlay the segment.
        potentialStraightLineParts = (part for part in @potentialStraightLineParts when part.overlaysPointRange normalizedStartPointIndex, normalizedPointIndex)

        for part, partIndex in potentialStraightLineParts
          startPointIndex = _.modulo Math.max(part.startPointIndex, normalizedStartPointIndex - 1), @points.length
          endPointIndex = _.modulo Math.min(part.endPointIndex, normalizedPointIndex + 1), @points.length
          
          startSegmentIndex = part.startSegmentIndex
          endSegmentIndex = part.endSegmentIndex
          
          startSegmentIndex++ while not @_edgeSegmentOverlaysPointRange startSegmentIndex, startPointIndex, endPointIndex
          endSegmentIndex-- while not @_edgeSegmentOverlaysPointRange endSegmentIndex, startPointIndex, endPointIndex
          
          @parts.push new PAG.Line.Part.StraightLine @, startSegmentIndex, endSegmentIndex
        
      startSegmentIndex = null
      startPointIndex = null
      normalizedStartPointIndex = null
      pointPartIsCurve = null
    
  _edgeSegmentOverlaysPointRange: (segmentIndex, startPointIndex, endPointIndex) ->
    segment = @getEdgeSegment segmentIndex
    return false unless segment.pointSegmentsCount
  
    pointCount = @points.length
    startPointIndex = startPointIndex % pointCount
    endPointIndex = endPointIndex % pointCount
    
    if endPointIndex >= startPointIndex
      startPointIndex <= segment.endPointIndex and endPointIndex >= segment.startPointIndex
    
    else
      startPointIndex <= segment.endPointIndex or endPointIndex >= segment.startPointIndex
