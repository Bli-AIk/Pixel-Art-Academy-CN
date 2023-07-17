AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# A general instruction that is displayed after a delay if the asset is not completed.
class PAA.Tutorials.Drawing.Instructions.GeneralInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @activeConditions: ->
    return unless asset = @getActiveAsset()
    
    # Show until the asset is completed.
    not asset.completed()
  
  @delayDuration: -> @defaultDelayDuration
  
  @resetDelayOnOperationExecuted: -> true
