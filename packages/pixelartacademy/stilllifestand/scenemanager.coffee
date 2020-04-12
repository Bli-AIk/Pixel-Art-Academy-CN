AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.SceneManager
  constructor: (@stillLifeStand) ->
    @scene = new THREE.Scene()
    @scene.manager = @

    # Create lighting.
    @ambientLight = new THREE.AmbientLight 0xffffff, 0.1
    @scene.add @ambientLight

    @directionalLight = new THREE.DirectionalLight 0xffffff, 0.5
    @directionalLight.position.set -100, 20, 100
    @scene.add @directionalLight

    @skydome = new LOI.Engine.Skydome
    @scene.add @skydome

    @_items = []
    @items = new ReactiveField @_items

    # Instantiate still life items based on the data.
    @stillLifeStand.autorun =>
      remainingItemIds = (item.id for item in @_items)

      newItemsData = @stillLifeStand.itemsData()

      sceneItemsChanged = false

      for newItemData in newItemsData
        if newItemData.id in remainingItemIds
          # Item has already been instantiated. See if its properties have changed.
          item = _.find @_items, (item) => item.id is newItemData.id

          unless EJSON.equals newItemData.properties, item.data.properties
            # Replace item with a new instance.
            @_removeItemWithId item.id
            @_addItem newItemData
            sceneItemsChanged = true

          _.pull remainingItemIds, newItemData.id

        else
          # This is a new item. Instantiate it and add it to the scene.
          @_addItem newItemData
          sceneItemsChanged = true

      # Any leftover remaining items have been removed.
      for itemId in remainingItemIds
        @_removeItemWithId itemId
        sceneItemsChanged = true

      # Update items array if any items were added or removed.
      if sceneItemsChanged
        @items @_items

  destroy: ->
    item.destroy() for item in @_items
    @skydome.destroy()

  _addItem: (itemData) ->
    itemClass = PAA.StillLifeStand.Item.getClassForId itemData.type
    item = new itemClass itemData

    @_items.push item
    @scene.add item.renderObject

  _removeItemWithId: (itemId) ->
    item = _.find @_items, (item) => item.id is itemId
    _.pull @_items, item
    @scene.remove item.renderObject
    item.destroy()
