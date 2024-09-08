AM = Artificial.Mummification
LOI = LandsOfIllusions
PADB = PixelArtDatabase
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.References extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.References'

  @displayName: -> "参考图"

  @description: -> """
      参考图在你的创作过程中相当重要，它可以让你绘制出准确可信的图像。
    """

  @fixedDimensions: -> width: 7, height: 16
  @customPalette: ->
    new LOI.Assets.Palette
      ramps: [
        shades: [r: 0.95, g: 0.30, b: 0.5]
      ]

  @bitmapString: -> "" # Empty bitmap

  @goalBitmapString: -> """
      |   0
      |  0 0
      |  0 0
      |  0 0
      |  0 0
      |  0 0
      |  0 0
      | 0   0
      |0     0
      |0000000
      |0     0
      |0000000
      |0 0 0 0
      |0 0 000
      |0 00000
      |0000000
    """

  @references: -> [
    '/pixelartacademy/tutorials/drawing/pixelarttools/basics/susankare-brush.jpg'
  ]

  @bitmapInfo: -> """
      出自1982 年苏珊·凯尔(Susan Kare)绘制的艺术作品

      （已获得使用许可）
    """

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.References
  ]

  editorOptions: ->
    references:
      upload:
        enabled: false
      storage:
        enabled: false

  editorDrawComponents: ->
    # We send an empty array so we don't show the on-canvas reference.
    []
    
  Asset = @

  class @Tray extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tray"
    @assetClass: -> Asset
    
    @message: -> """
        打开装有参考图的托盘，然后把参考图拖到你的桌子上。
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show until the image has a displayed reference.
      bitmap = asset.bitmap()
      not bitmap.references[0].displayed
  
    @delayDuration: -> @defaultDelayDuration
    
    @initialize()
    
  class @Resize extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Resize"
    @assetClass: -> Asset
    
    @message: -> """
        你可以通过拖动参考图的边缘来调整它的大小。
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show after the image has a reference, until a reference resize step has been added.
      bitmap = asset.bitmap()
      return unless bitmap.references[0].displayed
      
      scaleOperationsCount = 0
      
      # Fetch history from the action archives if using them.
      unless history = bitmap.history
        history = AM.Document.Versioning.ActionArchive.getHistoryForDocument bitmap._id
      
      for action in history
        for operation in action.forward
          scaleOperationsCount++ if operation instanceof LOI.Assets.VisualAsset.Operations.UpdateReference and operation.changes.scale
  
      # We need at least 2 scale operations since displaying the reference will automatically create one.
      scaleOperationsCount < 2
  
    @delayDuration: -> @defaultDelayDuration
    
    @initialize()
    
if Meteor.isServer
  Document.startup ->
    return if Meteor.settings.startEmpty

    PADB.create
      artist:
        name:
          first: 'Susan'
          last: 'Kare'
      artworks: [
        type: PADB.Artwork.Types.Physical
        name: 'Brush'
        completionDate:
          year: 1982
        image:
          url: '/pixelartacademy/tutorials/drawing/pixelarttools/helpers/susankare-brush.jpg'
      ]
