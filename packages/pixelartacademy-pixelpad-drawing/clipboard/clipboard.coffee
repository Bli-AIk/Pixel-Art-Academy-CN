AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Clipboard extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Clipboard'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      open: AEc.ValueTypes.Trigger
      close: AEc.ValueTypes.Trigger
      
  onCreated: ->
    super arguments...
    
    @_wasDisplayingAsset = null
    
    @autorun (computation) =>
      displayingAsset = @drawing.portfolio().activeAsset()?
      
      if displayingAsset and not @_wasDisplayingAsset
        @audio.open()
        
      else if @_wasDisplayingAsset and not displayingAsset
        @audio.close()
      
      @_wasDisplayingAsset = displayingAsset
    
  @calculateAssetSize: (portfolioScale, bounds, options) ->
    width = bounds?.width or 1
    height = bounds?.height or 1

    # Asset in the clipboard should be bigger than in the portfolio.
    if portfolioScale < 1
      # The asset was scaled down in the portfolio, but we should remain at least pixel perfect in the clipboard.
      displayScale = LOI.adventure.interface.display.scale()
      minimumScale = 1 / displayScale
      scale = Math.max portfolioScale, minimumScale

    else
      # 1 -> 2
      # 2 -> 3
      # 3 -> 4
      # 4 -> 5
      # 5 -> 6
      # 6 -> 8
      scale = Math.ceil portfolioScale * 1.2
  
    # Apply minimum and maximum scale if provided (it could be a non-integer).
    scale = Math.max scale, options.scaleLimits.min if options?.scaleLimits?.min
    scale = Math.min scale, options.scaleLimits.max if options?.scaleLimits?.max

    contentWidth = width * scale
    contentHeight = height * scale

    borderWidth = 7

    {contentWidth, contentHeight, borderWidth, scale}
  
  constructor: (@drawing) ->
    super arguments...

  asset: ->
    @drawing.portfolio().displayedAsset()?.asset
    
  activeClass: ->
    'active' if @drawing.activeAssetClass() and not @drawing.displayedAssetCustomComponent()

  onBackButton: ->
    # Relay to asset clipboard component.
    clipboardComponent = @drawing.portfolio().displayedAsset()?.asset.clipboardComponent
    result = clipboardComponent?.onBackButton?()
    return result if result?
