AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Sprite extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Sprite'

  onCreated: ->
    super

    getSpriteIdLocation = =>
      property = @data()
      property.options.dataLocation.child 'spriteId'

    @spriteId = =>
      spriteIdLocation = getSpriteIdLocation()
      spriteIdLocation()

    @spriteList = new LOI.Assets.Components.AssetsList
      documentClass: LOI.Assets.Sprite
      getAssetId: @spriteId
      setAssetId: (spriteId) =>
        # Set the new sprite.
        spriteIdLocation = getSpriteIdLocation()
        spriteIdLocation spriteId

        # Close the selection UI.
        @showSpriteList false

    @showSpriteList = new ReactiveField false

    @lightDirection = new ReactiveField new THREE.Vector3(0, -1, -1).normalize()

    @spriteImage = new LOI.Assets.Components.SpriteImage
      spriteId: @spriteId
      lightDirection: @lightDirection

  showSpritePreview: ->
    @spriteId()

  events: ->
    super.concat
      'click .choose-sprite-button': @onClickChooseSpriteButton
      'click .sprite-preview': @onClickSpritePreview
      'mousemove .sprite-preview': @onMouseMoveSpritePreview
      'mouseleave .sprite-preview': @onMouseLeaveSpritePreview

  onClickChooseSpriteButton: (event) ->
    @showSpriteList not @showSpriteList()

  onClickSpritePreview: (event) ->
    window.open FlowRouter.path 'LandsOfIllusions.Assets.SpriteEditor', spriteId: @spriteId()

  onMouseMoveSpritePreview: (event) ->
    percentageX = event.offsetX / $('.sprite-preview').outerWidth() * 2 - 1
    percentageY = event.offsetY / $('.sprite-preview').outerHeight() * 2 - 1
    @lightDirection new THREE.Vector3(-percentageX, percentageY, -1).normalize()

  onMouseLeaveSpritePreview: (event) ->
    @lightDirection new THREE.Vector3(0, -1, -1).normalize()
