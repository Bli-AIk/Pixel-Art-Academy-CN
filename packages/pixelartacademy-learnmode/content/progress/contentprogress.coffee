AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress.ContentProgress extends LM.Content.Progress
  constructor: (@options) ->
    super arguments...

    @_weights = (content.progress.weight() for content in @content.contents())

  completed: ->
    _.every (content.completed() for content in @content.contents())

  # Total units

  unitsCount: ->
    if @options.recursive or @options.totalRecursive
      _.sum (content.progress.unitsCount?() for content in @content.contents())

    else
      @content.contents().length

  completedUnitsCount: ->
    if @options.recursive or @options.totalRecursive
      _.sum (content.progress.completedUnitsCount?() for content in @content.contents())

    else
      _.filter(@content.contents(), (content) -> content.completed()).length

  completedRatio: ->
    if @options.recursive or @options.totalRecursive
      @completedUnitsCount() / @unitsCount()

    else
      @_weightedAverage (content.completedRatio() or 0 for content in @content.contents())

  # Required units

  requiredUnitsCount: ->
    if @options.recursive or @options.requiredRecursive
      _.sum (content.progress.requiredUnitsCount?() for content in @content.contents())

    else
      @content.contents().length

  requiredCompletedUnitsCount: ->
    if @options.recursive or @options.requiredRecursive
      _.sum (content.progress.requiredCompletedUnitsCount?() for content in @content.contents())

    else
      _.filter(@content.contents(), (content) -> content.completed()).length

  requiredCompletedRatio: ->
    if @options.recursive or @options.requiredRecursive
      @requiredCompletedUnitsCount() / @requiredUnitsCount()

    else
      @_weightedAverage (content.requiredCompletedRatio() or 0 for content in @content.contents())

  _weightedAverage: (values) ->
    totalWeight = 0
    totalValue = 0

    for value, index in values when value?
      weight = @_weights[index]
      totalValue += value * weight
      totalWeight += weight

    totalValue / totalWeight
