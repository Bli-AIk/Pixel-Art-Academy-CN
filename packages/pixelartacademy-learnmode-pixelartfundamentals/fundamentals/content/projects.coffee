PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.PixelArtFundamentals.Fundamentals.Content.Projects extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects'
  @displayName: -> "项目"
  @tags: -> [LM.Content.Tags.WIP]
  @contents: -> [
    @Pinball
    @PixelSuiteIcons
    @Maze
    @Invaders
    @BlockBreaker
    @Chess
  ]
  @initialize()

  constructor: ->
    super arguments...
    
    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 2
      totalUnits: "artworks"
      totalRecursive: true
      
  status: -> LM.Content.Status.Unlocked

  class @Invaders extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders'
    @displayName: -> "入侵者"
    @contents: -> [
      @Invader
      @Defender
      @InvaderProjectile
      @DefenderProjectile
      @Barricade
      @ScreenColorOverlay
    ]
    @initialize()
    
    class @Invader extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.Invader'
      @displayName: -> "入侵者"
      @initialize()
      
    class @Defender extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.Defender'
      @displayName: -> "防御者"
      @initialize()
    
    class @InvaderProjectile extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.InvaderProjectile'
      @displayName: -> "入侵者的射弹"
      @initialize()
    
    class @DefenderProjectile extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.DefenderProjectile'
      @displayName: -> "防御者的射弹"
      @initialize()
    
    class @Barricade extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.Barricade'
      @displayName: -> "路障"
      @initialize()
    
    class @ScreenColorOverlay extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.ScreenColorOverlay'
      @displayName: -> "屏幕颜色叠加"
      @initialize()
      
  class @PixelSuiteIcons extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PixelSuiteIcons'
    @displayName: -> "PixelSuite 图标"
    @initialize()
    
    @contents: -> [
      @Calculator
      @ContactCards
      @Calendar
    ]
    @initialize()
    
    class @Calculator extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PixelSuiteIcons.Calculator'
      @displayName: -> "计算器"
      @initialize()
    
    class @ContactCards extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PixelSuiteIcons.ContactCards'
      @displayName: -> "联系人卡片"
      @initialize()
    
    class @Calendar extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PixelSuiteIcons.Calendar'
      @displayName: -> "日历"
      @initialize()
  
  class @Pinball extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball'
    @displayName: -> "弹球"
    @tags: -> [LM.Content.Tags.WIP]
    
    @unlockInstructions: -> "Complete the Smooth curves challenge to start the Pinball project."
    
    @contents: -> [
      @Ball
      @Playfield
      @GobbleHole
      @BallTrough
      @Bumper
      @Gate
      @Flipper
      @SpinningTarget
    ]
    
    @initialize()
    
    constructor: ->
      super arguments...
      
      @progress = new LM.Content.Progress.ContentProgress
        content: @
        units: "pinball parts"
    
    status: -> if LM.PixelArtFundamentals.pinballEnabled() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
    
    class @Part extends LM.Content
      @asset = null # Override which project asset this sprite is.
      
      @displayName: -> @asset.displayName()
      
      constructor: ->
        super arguments...
        
        @progress = new LM.Content.Progress.ProjectAssetProgress
          content: @
          project: PAA.Pixeltosh.Programs.Pinball.Project
          asset: @constructor.asset
      
      status: -> LM.Content.Status.Unlocked
    
    class @Ball extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.Ball'
      
      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.Ball
      
      @initialize()
    
    class @Playfield extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.Playfield'
      
      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.Playfield
      
      @initialize()

    class @GobbleHole extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.GobbleHole'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.GobbleHole

      @initialize()

    class @BallTrough extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.BallTrough'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.BallTrough

      @initialize()

    class @Bumper extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.Bumper'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.Bumper

      @initialize()

    class @Gate extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.Gate'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.Gate

      @initialize()

    class @Flipper extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.Flipper'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.Flipper

      @initialize()

    class @SpinningTarget extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.SpinningTarget'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.SpinningTarget

      @initialize()
      
  class @BlockBreaker extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.BlockBreaker'
    @displayName: -> "打砖块"
    @initialize()
  
  class @Chess extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess'
    @displayName: -> "国际象棋"
    @initialize()
  
  class @Maze extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Maze'
    @displayName: -> "迷宫"
    @initialize()
