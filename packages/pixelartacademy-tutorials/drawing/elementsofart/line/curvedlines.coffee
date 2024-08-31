LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.CurvedLines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "曲线"
  @displayNameBack: -> "Curved lines"
  
  @description: -> """
    曲线比直线更难画，它需要更多地进行练习。
    
    但在画像素画时，你总能很容易地修理它们。
  """
  
  @fixedDimensions: -> width: 38, height: 35
  
  @initialize()
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> Asset
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      asset.stepAreas()[0].activeStepIndex() is @stepNumber() - 1
    
    @resetDelayOnOperationExecuted: -> true
    
  class @FirstWay extends @StepInstruction
    @id: -> "#{Asset.id()}.FirstWay"
    @stepNumber: -> 1
    
    @message: -> """
      用铅笔工具画曲线有很多方法。

      其中最困难，但画着最顺手的方法是：
      1. 点击并沿着参考线拖动，一气呵成地完成它。
    """
    
    @initialize()
  
  class @SecondWay extends @StepInstruction
    @id: -> "#{Asset.id()}.SecondWay"
    @stepNumber: -> 2
    
    @message: -> """
      如果你画的线条看起来歪歪扭扭、凹凸不平，请不要担心，很快你将会学习如何清理线条。

      现在，来尝试一种可以确保曲线有1像素格宽的方法吧：
      2. 点击起始处的像素块，然后按住 Shift 键。沿着参考线一段一段地画直线，从而画出由多个直线段组成的曲线。
    """
    
    @initialize()
  
  class @ThirdWay extends @StepInstruction
    @id: -> "#{Asset.id()}.ThirdWay"
    @stepNumber: -> 3
    
    @message: -> """
      最后一种方法虽然最耗时，但能提供最大的精确度：
      3. 放大画布，找到并点击参考线与像素格明显交叉处的像素点。
    """
    
    @initialize()
  
  class @AnyWay extends @StepInstruction
    @id: -> "#{Asset.id()}.AnyWay"
    @stepNumber: -> 4
    
    @message: -> """
      以你喜欢的任一方法绘制最后的曲线。
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show until the asset is completed.
      return if asset.completed()
      
      super arguments...
      
    @initialize()
    
  class @Complete extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
        你做到了！

        别担心，如果你认为现在的曲线效果不完美，也没事。
        
        你很快就会学到像素曲线的基本规则。
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
