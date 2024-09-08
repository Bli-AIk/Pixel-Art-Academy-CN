AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Instructions
  class @Instruction extends PAA.PixelPad.Systems.Instructions.Instruction
    @getPinball: ->
      return unless os = PAA.PixelPad.Apps.Pixeltosh.getOS()
      program = os.activeProgram()
      return unless program instanceof PAA.Pixeltosh.Programs.Pinball
      program
    
  class @InvalidPlayfield extends @Instruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Instructions.InvalidPlayfield"
    
    @message: -> """
      哎呀，弹球台似乎无效了！是不是有洞重叠了？
    """
      
    @activeConditions: ->
      return unless pinball = @getPinball()
      
      # Show when the playfield doesn't have a valid shape.
      return unless playfield = pinball.sceneManager()?.getPartOfType Pinball.Parts.Playfield
      return unless shape = playfield.shape()
      not shape.geometryData.indexBufferArray.length
    
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
  
  class @FlatPlayfield extends @Instruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Instructions.FlatPlayfield"
    
    @message: -> """
      哎呀，弹球台是平的！你得在设置里把它的角度调到0度以上。
    """
    
    @activeConditions: ->
      return unless pinball = @getPinball()
      
      # Show when the playfield's angle is 0.
      return unless playfield = pinball.sceneManager()?.getPartOfType Pinball.Parts.Playfield
      playfield.data().angleDegrees is 0
    
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
  
  class @InvalidPartInstruction extends @Instruction
    @invalidPart: -> throw new AE.NotImplementedException "Invalid part instruction must determine the invalid part."
    
    @activeConditions: -> @invalidPart()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
    
    message: ->
      templateMessage = super arguments...
      
      return unless invalidPart = @constructor.invalidPart()
      
      templateMessage.replace "%%partName%%", invalidPart.fullName()
  
  class @InvalidPartRequiringACore extends @InvalidPartInstruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Instructions.InvalidPartRequiringACore"

    @message: -> """
      哎呀，%%partName%%似乎有问题！它是否有至少3x3的区域被填色了？
    """
    
    @invalidPart: ->
      return unless pinball = @getPinball()
      
      partClassesRequiringACore = [
        Pinball.Parts.BallSpawner
        Pinball.Parts.BallTrough
        Pinball.Parts.Bumper
        Pinball.Parts.Flipper
        Pinball.Parts.Gate
        Pinball.Parts.GobbleHole
        Pinball.Parts.Plunger
        Pinball.Parts.SpinningTarget
      ]
      
      parts = []
      
      # If the parts view is open, we can determine if the part is OK before it is placed on the playfield.
      if partsView = pinball.os.interface.getView Pinball.Interface.Parts
        parts.push part for part in partsView.parts when part.constructor in partClassesRequiringACore
      
      # Even if the parts view is not open, make sure all parts
      # have their shape (parts view might not even be unlocked yet).
      for partClass in partClassesRequiringACore
        continue unless part = pinball.sceneManager()?.getPartOfType partClass
        parts.push part
        
      for part in parts
        continue unless shape = part.shape()
        return part if shape instanceof Pinball.Part.Avatar.Box
        
      null
      
    @initialize()
  
  class @InvalidPart extends @InvalidPartInstruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Pinball.Instructions.InvalidPart"
    
    @message: -> """
      哎呀，%%partName%%似乎有问题！你在它上面画东西了么？
    """
    
    @invalidPart: ->
      return unless pinball = @getPinball()
     
      parts = _.clone pinball.sceneManager().parts()
      
      # If the parts view is open, we can determine if the part is OK before it is placed on the playfield.
      if partsView = pinball.os.interface.getView Pinball.Interface.Parts
        parts.push partsView.parts...

      for part in parts
        continue unless part.pixelArtEvaluation()
        return part unless part.shape()
      
      null
    
    @initialize()
