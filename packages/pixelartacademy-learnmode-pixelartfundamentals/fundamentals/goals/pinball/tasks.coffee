AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Goal = LM.PixelArtFundamentals.Fundamentals.Goals.Pinball
Pinball = PAA.Pixeltosh.Programs.Pinball

class Goal.OpenPinballMachine extends Goal.Task
  @id: -> "#{Goal.id()}.OpenPinballMachine"
  @goal: -> Goal

  @directive: -> "打开你的弹球机"

  @instructions: -> """
    在Pixeltosh软件内，进入“弹球机创作工具包”磁盘，并打开“我的弹球机”文件。
  """

  @interests: -> ['pinball', 'gaming']

  @requiredInterests: -> ['smooth curve (pixel art)']

  @initialize()

  @completedConditions: -> LM.PixelArtFundamentals.Fundamentals.state 'openedPinballMachine'
  
  reset: ->
    super arguments...
    
    LM.PixelArtFundamentals.Fundamentals.state 'openedPinballMachine', false
  
class Goal.DrawBall extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawBall"
  @goal: -> Goal

  @directive: -> "绘制弹球"

  @instructions: -> """
    在绘图软件内，找到弹球项目，然后将弹球的像素素材画成圆形。
  """
  
  @predecessors: -> [Goal.OpenPinballMachine]
  
  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.Ball
    Pinball.Assets.Plunger
  ]
  
  Task = @
  
  class @RedrawBall extends PAA.PixelPad.Systems.Instructions.Instruction
    @id: -> "#{Task.id()}.RedrawBall"
    
    @message: -> """
      哦不！看起来弹球画成了个方块！在绘图软件中把它改成球形，这样它就能滚动了。
    """
    
    @activeConditions: ->
      return unless Task.getAdventureInstance().active()
      
      # Show when we're in the active Pinball program.
      return unless os = PAA.PixelPad.Apps.Pixeltosh.getOS()
      program = os.activeProgram()
      return unless program instanceof PAA.Pixeltosh.Programs.Pinball
      program.projectId() is PAA.Pixeltosh.Programs.Pinball.state 'activeProjectId'
    
    @delayDuration: -> 5
    
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
    
class Goal.PlayBall extends Goal.Task
  @id: -> "#{Goal.id()}.PlayBall"
  @goal: -> Goal

  @directive: -> "试一下新的弹球"

  @instructions: -> """
    返回弹球机，测试一下新的弹球在弹球台上移动的情况。
  """
  
  @predecessors: -> [Goal.DrawBall]

  @initialize()

  @completedConditions: ->
    return unless ballTravelExtents = Pinball.state 'ballTravelExtents'
    
    # The ball must have reached into the top third.
    ballTravelExtents.z.min < Pinball.SceneManager.shortPlayfieldDepth / 3
    
  reset: ->
    super arguments...
    
    Pinball.resetBallExtents()
  
class Goal.DrawPlayfield extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawPlayfield"
  @goal: -> Goal

  @directive: -> "重绘弹球台"

  @instructions: -> """
    在弹球项目中，绘制一条位于弹球台顶部的曲线，用于将球从发射通道引导至弹球台内。
  """
  
  @predecessors: -> [Goal.PlayBall]

  @initialize()
  
  @onActive: ->
    super arguments...
    
    # Make sure we get a fresh start on the extents in case the ball bounced out of the shooter lane by chance.
    # We do this in this step instead of the next since completedConditions can otherwise run before onActive.
    Pinball.resetBallExtents()
  
  @unlockedAssets: -> [
    Pinball.Assets.Playfield
  ]
  
class Goal.PlayPlayfield extends Goal.Task
  @id: -> "#{Goal.id()}.PlayPlayfield"
  @goal: -> Goal

  @directive: -> "试一下新的弹球台"

  @instructions: -> """
    返回Pixeltosh软件，用力发射弹球，让它顺着你新画的曲线移动。
  """
  
  @predecessors: -> [Goal.DrawPlayfield]

  @initialize()

  @completedConditions: ->
    return unless ballTravelExtents = Pinball.state 'ballTravelExtents'
    
    # The ball must have reached into the left third.
    ballTravelExtents.x.min < Pinball.SceneManager.playfieldWidth / 3
  
  reset: ->
    super arguments...
    
    Pinball.resetBallExtents()
    
class Goal.DrawGobbleHole extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawGobbleHole"
  @goal: -> Goal

  @directive: -> "绘制吞球洞"

  @instructions: -> """
    在弹球项目中，按照你想要的样子来重绘吞球洞的像素素材。
  """
  
  @predecessors: -> [Goal.PlayPlayfield]

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.GobbleHole
  ]
  
class Goal.PlayGobbleHole extends Goal.Task
  @id: -> "#{Goal.id()}.PlayGobbleHole"
  @goal: -> Goal

  @directive: -> "得点分数"

  @instructions: -> """
    使用弹球机创作工具包的编辑模式，在弹球台上放置一个（或好几个）吞球洞，然后一直玩弹球，直到记分板上显示得分为止。
  """
  
  @predecessors: -> [Goal.DrawGobbleHole]

  @initialize()

  @completedConditions: ->
    @playfieldHasPart(Pinball.Parts.GobbleHole) and Pinball.state 'highScore'
  
  reset: ->
    super arguments...
    
    LM.PixelArtFundamentals.Fundamentals.state 'highScore', 0
    
class Goal.AddPins extends Goal.Task
  @id: -> "#{Goal.id()}.AddPins"
  @goal: -> Goal
  
  @directive: -> "添加挡针"
  
  @instructions: -> """
    在你的弹球台上放置挡针，从而使弹球的运动轨迹更加有趣。\n
    你可以通过两种方式来完成此任务：在编辑模式下，将单个挡针拖到弹球台上。\n
    或者，直接在弹球台的像素素材中绘制1×1或2×2的像素点。
  """
  
  @predecessors: -> [Goal.PlayGobbleHole]
  
  @initialize()
  
  @completedConditions: ->
    return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    return unless project = PAA.Practice.Project.documents.findOne activeProjectId

    # See if there are any pin parts on the playfield.
    for playfieldPartId, partData of project.playfield
      return true if partData.type is Pinball.Parts.Pin.id()
      
    # Alternatively, pins could be drawn as isolated points on the playfield bitmap.
    return unless playfieldAsset = _.find project.assets, (asset) => asset.id is Pinball.Assets.Playfield.id()
    return unless playfieldBitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId playfieldAsset.bitmapId
    
    pixelArtEvaluation = new PAA.Practice.PixelArtEvaluation playfieldBitmap
    isolatedPointFound = _.find pixelArtEvaluation.layers[0].points, (point) => not point.neighbors.length
    pixelArtEvaluation.destroy()
    
    isolatedPointFound

class Goal.DrawBallTrough extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawBallTrough"
  @goal: -> Goal

  @directive: -> "绘制球槽"

  @instructions: -> """
    球槽和吞球洞相似，都是允许弹球掉入的洞口，但球槽不会增加分数。\n
    它通常会被设计为额外的洞口，放置在弹球台的底端。
  """
  
  @predecessors: -> [Goal.PlayGobbleHole]

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.BallTrough
  ]
  
class Goal.PlayBallTrough extends Goal.Task
  @id: -> "#{Goal.id()}.PlayBallTrough"
  @goal: -> Goal

  @directive: -> "添加球槽"

  @instructions: -> """
    在你的弹球台上放置球槽。\n
    你也可以重新设计弹球台，让它引导弹球滚向底部的球槽。
  """
  
  @predecessors: -> [Goal.DrawBallTrough]

  @initialize()

  @completedConditions: -> @playfieldHasPart Pinball.Parts.BallTrough
  
class Goal.DrawBumper extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawBumper"
  @goal: -> Goal

  @directive: -> "绘制弹射器"

  @instructions: -> """
    设计并绘制弹射器的像素素材。\n
    弹簧将会安装在弹射器的轮廓上，从而使它能够弹开弹球。
  """
  
  @predecessors: -> [
    Goal.AddPins
    Goal.PlayBallTrough
  ]

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.Bumper
  ]
  
class Goal.PlayBumper extends Goal.Task
  @id: -> "#{Goal.id()}.PlayBumper"
  @goal: -> Goal

  @directive: -> "在弹球台上放置弹射器"

  @instructions: -> """
    依你所需，你可以清理弹球台上的部分区域，从而让你有足够的空间放置多个弹射器。\n
    你可以在“设置”标签内调整弹射器的弹性。
  """
  
  @predecessors: -> [Goal.DrawBumper]

  @initialize()

  @completedConditions: -> @playfieldHasPart Pinball.Parts.Bumper
  
class Goal.DrawGate extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawGate"
  @goal: -> Goal

  @directive: -> "绘制挡板"

  @instructions: -> """
    为了防止弹球掉回发射通道，我们需要给弹球机添加一个挡板。\n
    在弹球项目中，根据喜好修改挡板的像素素材。
  """
  
  @predecessors: -> [Goal.PlayBumper]

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.Gate
  ]
  
class Goal.PlayGate extends Goal.Task
  @id: -> "#{Goal.id()}.PlayGate"
  @goal: -> Goal

  @directive: -> "在发射通道中添加一个挡板"

  @instructions: -> """
    将挡板放置在发射通道的出口处，并将它旋转到合适的角度，确保弹球只能单向通过。
  """
  
  @predecessors: -> [Goal.DrawGate]

  @initialize()

  @completedConditions: -> @playfieldHasPart Pinball.Parts.Gate
  
class Goal.RemoveGobbleHoles extends Goal.Task
  @id: -> "#{Goal.id()}.RemoveGobbleHoles"
  @goal: -> Goal

  @directive: -> "移除吞球洞"

  @instructions: -> """
    随着新的计分方式被引入，传统的机械弹球机逐渐地退出了历史舞台。\n
    从弹球台上移除吞球洞，给弹板腾出空间。
  """
  
  @predecessors: -> [Goal.PlayGate]

  @initialize()

  @completedConditions: -> not @playfieldHasPart Pinball.Parts.GobbleHole
  
class Goal.DrawFlipper extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawFlipper"
  @goal: -> Goal

  @directive: -> "绘制弹板"

  @instructions: -> """
    弹板来了哦！去绘制左弹板的像素素材吧，它将在静止状态下保持你画出的形状。
  """
  
  @predecessors: -> [Goal.RemoveGobbleHoles]

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.Flipper
  ]
  
class Goal.PlayFlipper extends Goal.Task
  @id: -> "#{Goal.id()}.PlayFlipper"
  @goal: -> Goal

  @directive: -> "使用弹板进行游戏"

  @instructions: -> """
    在弹球台的底部添加两个弹板。\n
    使用菜单栏中的编辑-水平翻转选项，将左弹板翻转为右弹板。\n
    在设置中根据需求调整弹板的角度范围。
  """
  
  @predecessors: -> [Goal.DrawFlipper]

  @initialize()

  @completedConditions: ->
    return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    return unless project = PAA.Practice.Project.documents.findOne activeProjectId
    
    leftFound = false
    rightFound = false
    
    for playfieldPartId, partData of project.playfield when partData.type is Pinball.Parts.Flipper.id()
      if partData.flipped
        rightFound = true
        
      else
        leftFound = true
    
    leftFound and rightFound
  
class Goal.DrawLowerThird extends Goal.RedrawPlayfieldTask
  @id: -> "#{Goal.id()}.DrawLowerThird"
  @goal: -> Goal

  @directive: -> "使弹球台的底部区域更加现代化"

  @instructions: -> """
    利用弹板设计一个现代化的弹球台底部布局，包括外轨道、内轨道和弹射器。\n
    编辑弹球台，直到你满意为止。
  """
  
  @predecessors: -> [Goal.PlayFlipper]

  @initialize()

class Goal.ActiveBumpers extends Goal.Task
  @id: -> "#{Goal.id()}.ActiveBumpers"
  @goal: -> Goal
  
  @directive: -> "给弹射器再加把劲儿"
  
  @instructions: -> """
    你现在可以在设置中把静态弹射器设置为主动弹射器。\n
    它们会用力把弹球创飞，从而使游戏更加惊险刺激。\n
    如果你愿意，还可以趁着这个机会重新布置弹射器，并优化弹球台布局，以提供一个能够让多个弹射器将弹球相互踢走的空间。
  """
  
  @predecessors: -> [Goal.DrawUpperThird]

  @initialize()
  
  @completedConditions: ->
    # Find a bumper with active set to true.
    return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    return unless project = PAA.Practice.Project.documents.findOne activeProjectId
    
    for playfieldPartId, partData of project.playfield
      return true if partData.type is Pinball.Parts.Bumper.id() and partData.active
    
    false

class Goal.DrawUpperThird extends Goal.RedrawPlayfieldTask
  @id: -> "#{Goal.id()}.DrawUpperThird"
  @goal: -> Goal
  
  @directive: -> "使弹球台的顶部区域更加精简"
  
  @instructions: -> """
    在弹球台的顶部绘制平滑的曲线轨道。\n
    同时，调整轨道的入口和出口方向，让它们面向弹板。\n
    当然，弹球台的上半部分也可以留出空间，从而使多个弹射器相互配合着进行弹射。
  """
  
  @predecessors: -> [Goal.DrawLowerThird]
  
  @initialize()

class Goal.DrawSpinningTarget extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawSpinningTarget"
  @goal: -> Goal
  
  @directive: -> "绘制旋转靶"
  
  @instructions: -> """
    为旋转靶绘制像素素材。你同样可以根据你的需要来调整它的大小。
  """
  
  @predecessors: -> [Goal.ActiveBumpers]

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.SpinningTarget
  ]

class Goal.PlaySpinningTarget extends Goal.Task
  @id: -> "#{Goal.id()}.PlaySpinningTarget"
  @goal: -> Goal
  
  @directive: -> "让旋转靶转起来"
  
  @instructions: -> """
    在弹球台上添加一些旋转靶，根据击打它们的难度来设置得分。\n
    然后，看看你能不能击中靶子，赢得高分吧。
  """
  
  @predecessors: -> [Goal.DrawSpinningTarget]

  @initialize()
  
  @completedConditions: -> @playfieldHasPart Pinball.Parts.SpinningTarget
