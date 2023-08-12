AE = Artificial.Everywhere
AEc = Artificial.Echo

class AEc.Variable
  @_variablesById = {}

  @getVariableForId: (id) -> @_variablesById[id]
  
  @getVariables: -> _.values @_variablesById
  
  @getVariableIds: -> _.keys @_variablesById
  
  constructor: (id, valueTypeOrVariableOptions) ->
    if _.isObject valueTypeOrVariableOptions
      options = valueTypeOrVariableOptions
      valueType = options.valueType
    
    else
      options = {}
      valueType = valueTypeOrVariableOptions
    
    defaultValue = switch valueType
      when AEc.ValueTypes.Trigger, AEc.ValueTypes.Boolean then false
      when AEc.ValueTypes.Number then 0
      else null
    
    globalValue = new ReactiveField defaultValue
    values = {}

    getValueFieldForInstanceId = (instanceId, createField) ->
      if instanceId
        values[instanceId] ?= new ReactiveField defaultValue if createField
        values[instanceId] or globalValue
        
      else
        globalValue
    
    # We want Variable to behave as a setter.
    variable = (valueOrInstanceId, instanceId) ->
      if valueType is AEc.ValueTypes.Trigger
        valueField = getValueFieldForInstanceId valueOrInstanceId, true
        
        # Trigger needs to become true for a single frame.
        valueField true
        
        console.log "Variable", id, "triggered." if AEc.debug

        Meteor.setTimeout =>
          valueField false
        ,
          0
        
      else
        value = valueOrInstanceId
        valueField = getValueFieldForInstanceId instanceId, true
        
        # Set the new value.
        valueField value
        
        console.log "Variable", id, "set to", value if AEc.debug
        
    if options.throttle
      if _.isNumber options.throttle
        throttleWait = options.throttle
        throttleOptions = trailing: false
        
      else
        throttleWait = options.throttle.wait
        throttleOptions = options.throttle.options
        
      variable = _.throttle variable, throttleWait, throttleOptions
    
    variable.id = id
    variable.valueType = valueType
    
    variable.value = (instanceId) ->
      valueField = getValueFieldForInstanceId instanceId
      valueField()
    
    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf variable, @constructor.prototype

    # Allow access by ID.
    @constructor._variablesById[id] = variable
    
    # Return the setter (return must be explicit).
    return variable
