AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtSoftware.CopyReference extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @displayName: -> "Copy the reference"

  @description: -> """
      重绘这张参考图，来证明你已经学会了如何使用像素画软件。
    """

  @bitmap: -> "" # Empty bitmap

  @goalImageUrl: -> "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@imageName()}.png"

  @imageName: -> throw new AE.NotImplementedException "You must provide the image name for the asset."

  @references: -> [
    image:
      url: "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@imageName()}-reference.png"
    displayOptions:
      imageOnly: true
  ]

  @customPaletteImageUrl: ->
    return null if @restrictedPaletteName()

    "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@imageName()}-template.png"

  @briefComponentClass: ->
    # Note: We need to fully qualify the name instead of using @constructor
    # since we're overriding with a class with the same name.
    PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent
  
  constructor: ->
    super arguments...

    @uploadMode = new ReactiveField false

    @_clipboardPageComponent = new PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.ClipboardPageComponent @
  
  initializeSteps: ->
    super arguments...
    
    # Make the pixels step only show drawn errors.
    @stepAreas()[0].steps()[0].options.drawHintsForGoalPixels = false
    
  editorOptions: ->
    references:
      upload:
        enabled: false
      storage:
        enabled: false

  clipboardPageComponent: ->
    # We only show this page if we can upload.
    return unless PAA.PixelPad.Apps.Drawing.state('externalSoftware')?
    
    @_clipboardPageComponent

  availableToolKeys: ->
    # When we're in upload mode, don't show any tools in the editor.
    if @uploadMode() then [] else null

  templateUrl: ->
    "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@constructor.imageName()}-template.png"

  referenceUrl: ->
    @constructor.references()[0].image.url
