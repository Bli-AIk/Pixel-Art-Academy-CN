# Extensions to Meteor's Match patterns.

# Numbers

Match.Range = (min, max) ->
  check min, Number
  check max, Number

  Match.Where (value) ->
    check value, Number
    min <= value <= max

Match.IntegerRange = (min, max) ->
  check min, Match.Integer
  check max, Match.Integer

  Match.Where (value) ->
    check value, Match.Integer
    min <= value <= max

Match.IntegerMin = (min) ->
  check min, Match.Integer

  Match.Where (value) ->
    check value, Match.Integer
    min <= value

Match.IntegerMax = (max) ->
  check max, Match.Integer

  Match.Where (value) ->
    check value, Match.Integer
    value <= max

Match.NonNegativeNumber = Match.Where (value) ->
  check value, Number
  value >= 0

Match.PositiveInteger = Match.Where (value) ->
  check value, Match.Integer
  value > 0

Match.NonNegativeInteger = Match.Where (value) ->
  check value, Match.Integer
  value >= 0

Match.Enum = (enumeration) ->
  Match.Where (value) ->
    value in _.values enumeration
