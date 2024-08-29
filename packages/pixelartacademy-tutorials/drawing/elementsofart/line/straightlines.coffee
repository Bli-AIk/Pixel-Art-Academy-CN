LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.StraightLines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "直线"
  @displayNameBack: -> "Straight lines"
  
  @description: -> """
    最“直”接的一种线条！
    
    如果你已经熟悉了绘画工具，画这些线条就像按住Shift键点击一样简单。
  """
  
  @fixedDimensions: -> width: 28, height: 28
  
  @referenceNames: -> [
    'straightlines'
  ]
  

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      用铅笔画线吧。你可以选择：

      - 逐个点击线条上的每个像素。
      - 按住鼠标并沿线拖动，一笔带过。
      - 点击起始处的像素点，然后按住 Shift 键，再点击结束处的像素点。
    """
    
    @initialize()
