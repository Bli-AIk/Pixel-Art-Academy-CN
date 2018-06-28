AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.VisualAsset.updatePalette.method (assetClassName, assetId, paletteId) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check paletteId, Match.DocumentId

  RA.authorizeAdmin()

  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  LOI.Assets.VisualAsset._requireAsset assetId, assetClass

  # Make sure the palette exists.
  palette = LOI.Assets.Palette.documents.findOne paletteId
  throw new AE.ArgumentException "Palette doesn't exist." unless palette

  assetClass.documents.update assetId,
    $set:
      "palette._id": paletteId

LOI.Assets.VisualAsset.updateMaterial.method (assetClassName, assetId, index, materialUpdate) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check index, Match.Integer
  check materialUpdate, Match.OptionalOrNull Match.ObjectIncluding
    name: Match.OptionalOrNull String
    ramp: Match.OptionalOrNull Match.Integer
    shade: Match.OptionalOrNull Match.Integer
    dither: Match.OptionalOrNull Number

  RA.authorizeAdmin()

  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass

  asset = assetClass.documents.findOne assetId
  throw new AE.ArgumentException "Asset does not exist." unless asset

  # Get existing material or create new entry.
  material = asset.materials?[index] or {}

  # Update the fields that are set. (We don't use extend because that introduces null values.)
  if materialUpdate
    for key, value of materialUpdate
      material[key] = value if value?

  assetClass.documents.update assetId,
    $set:
      "materials.#{index}": material

LOI.Assets.VisualAsset.updateLandmark.method (assetClassName, assetId, index, landmarkUpdate) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check index, Match.Integer
  check landmarkUpdate, Match.OptionalOrNull Match.ObjectIncluding
    name: Match.OptionalOrNull String
    x: Match.OptionalOrNull Number
    y: Match.OptionalOrNull Number
    z: Match.OptionalOrNull Number

  RA.authorizeAdmin()

  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass

  asset = assetClass.documents.findOne assetId
  throw new AE.ArgumentException "Asset does not exist." unless asset

  # If we don't have landmarks at all, we create it as an array
  # so that sets will create index entries not object properties.
  unless asset.landmarks
    assetClass.documents.update assetId,
      $set:
        landmarks: []

  # Get existing landmark or create new entry.
  landmark = asset.landmarks?[index] or {}

  # Update the fields that are set. (We don't use extend because that introduces null values.)
  if landmarkUpdate
    for key, value of landmarkUpdate
      landmark[key] = value if value?

  assetClass.documents.update assetId,
    $set:
      "landmarks.#{index}": landmark
