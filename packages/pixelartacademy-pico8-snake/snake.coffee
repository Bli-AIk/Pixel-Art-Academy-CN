LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Snake extends PAA.Pico8.Cartridge
  # highScore: the top result the player has achieved
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Snake'
  
  @gameSlug: -> 'snake'
  @projectClass: -> @Project

  @initialize()

  onInputOutput: (address, value) ->
    # Read score from address 1.
    return unless address is 1 and value?

    highScore = @state('highScore') or 0
    return unless value > highScore

    @state 'highScore', value
  
  # Assets
  
  class @Body extends PAA.Practice.Project.Asset.Bitmap
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Snake.Body'
    
    @displayName: -> "贪吃蛇-蛇身"
    
    @description: -> """
      一格长的蛇身。贪吃蛇每吃一份食物就会增加一格长度。
    """
    
    @fixedDimensions: -> width: 8, height: 8
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
    @backgroundColor: ->
      paletteColor:
        ramp: 10
        shade: 0
    
    @initialize()
  
  class @Food extends PAA.Practice.Project.Asset.Bitmap
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Snake.Food'
    
    @displayName: -> "贪吃蛇-食物"
    
    @description: -> """
      一块让蛇吃了之后长的更长的食物。
    """
    
    @fixedDimensions: -> width: 8, height: 8
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
    @backgroundColor: ->
      paletteColor:
        ramp: 10
        shade: 0
    
    @initialize()
