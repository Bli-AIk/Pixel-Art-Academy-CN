LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.Snake extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake'

  @displayName: -> "- 贪吃蛇小游戏 -"

  @chapter: -> LM.Intro.Tutorial

  Goal = @
  
  class @Play extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake.Play'
    @goal: -> Goal

    @directive: -> "玩会游戏"

    @instructions: -> """
      在 PICO-8 软件里玩贪吃蛇小游戏。注意游戏内的像素素材（绿色的蛇和棕色的食物）。
      游戏得分达到5分或以上才能继续。
    """

    @interests: -> ['pico-8', 'gaming']

    @requiredInterests: -> ['pixel art software']

    @initialize()

    @completedConditions: ->
      # Require score of 5 or higher. Since we reset the high score when the
      # snake project is created, we also keep this task completed based on that.
      PAA.Pico8.Cartridges.Snake.state('highScore') >= 5 or PAA.Pico8.Cartridges.Snake.Project.state 'activeProjectId'

  class @Draw extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake.Draw'
    @goal: -> Goal

    @directive: -> "绘制贪吃蛇的像素素材"

    @instructions: -> """
      在绘图软件的“项目”部分找到贪吃蛇游戏的像素素材。
      重绘蛇和食物块的像素画。
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @interests: -> ['snake', 'food']

    @predecessors: -> [Goal.Play]

    @initialize()
    
    @completedConditions: ->
      return unless projectId = PAA.Pico8.Cartridges.Snake.Project.state 'activeProjectId'
      return unless project = PAA.Practice.Project.documents.findOne projectId

      for asset in project.assets
        return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId

        # We know the player has changed the bitmap if the history position is not zero.
        return unless bitmap.historyPosition

      true

  class @PlayAgain extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Snake.PlayAgain'
    @goal: -> Goal

    @directive: -> "看看游戏运行时的像素素材"

    @instructions: -> """
      替换了游戏的像素素材后，再次打开 PICO-8，看看你的像素画在游戏中的效果吧。
      你随时可以修改像素素材，直到你满意为止。
      得分达到10分或以上才能继续。
    """

    @interests: -> ['learn mode tutorial project']

    @predecessors: -> [Goal.Draw]

    @initialize()

    @completedConditions: ->
      PAA.Pico8.Cartridges.Snake.state('highScore') >= 10
      
  @tasks: -> [
    @Play
    @Draw
    @PlayAgain
  ]

  @finalTasks: -> [
    @PlayAgain
  ]

  @initialize()
