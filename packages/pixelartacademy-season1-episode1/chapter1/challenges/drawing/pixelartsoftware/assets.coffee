LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
CopyReference = C1.Challenges.Drawing.PixelArtSoftware.CopyReference
PADB = PixelArtDatabase

assets =
  Big1BitCharacterProtagonistLouBagelsWaffleBar:
    dimensions: -> width: 36, height: 49
    paletteName: -> LOI.Assets.Palette.SystemPaletteNames.black
    imageName: -> 'big-1bit-character-protagonist-loubagelswafflebar'
    spriteInfo: -> """
      Artwork from Lou Bagel's Waffle Bar, 2018

      Artist: Chris Taylor
    """
    artist:
      name:
        first: 'Chris'
        last: 'Taylor'
    artwork:
      completionDate:
        year: 2018

  BigColorCharacterEnemyIntoTheRift:
    dimensions: -> width: 30, height: 32
    imageName: -> 'big-color-character-enemy-intotherift'
    spriteInfo: -> """
      Artwork from [Into The Rift](http://www.starsoft.com/IntoTheRift/) (WIP)

      Artist: Weston Tracy
    """
    maxClipboardScale: -> 2.5
    artist:
      name:
        first: 'Weston'
        last: 'Tracy'
    artwork:
      completionDate:
        year: 2015

for assetId, asset of assets
  do (assetId, asset) ->
    class CopyReference[assetId] extends CopyReference
      @id: -> "PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.PixelArtSoftware.CopyReference.#{assetId}"
      @fixedDimensions: asset.dimensions
      # Note: we don't override restrictedPaletteName since we expect the function to exist.
      @paletteName: asset.paletteName
      @imageName: asset.imageName
      @spriteInfo: asset.spriteInfo
      @maxClipboardScale: asset.maxClipboardScale
      @initialize()

    # On the server also create PADB entries.
    if Meteor.isServer
      Document.startup =>
        referenceUrl = "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/pixelartsoftware/#{asset.imageName()}-reference.png"

        unless PADB.Artwork.forUrl.query(referenceUrl).count()
          artwork = _.extend {}, asset.artwork,
            type: PADB.Artwork.Types.Image
            image:
              url: "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/pixelartsoftware/#{asset.imageName()}.png"
            representations: [
              type: PADB.Artwork.RepresentationTypes.Image
              url: referenceUrl
            ]
            
          PADB.create
            artist: asset.artist
            artworks: [artwork]
