AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Assets
  class @Asset extends PAA.Practice.Project.Asset.Bitmap
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Macintosh
    
    @backgroundColor: -> new THREE.Color '#edddb5'
    
  class @Ball extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Ball'
    
    @displayName: -> "弹球"
    
    @description: -> """
      一个可以在弹球台上弹跳的球。
      为了让它能够四处滚动，它必须被画成圆形。
    """
    
    @fixedDimensions: -> width: 7, height: 7
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/ball.png'
    
    @initialize()
  
  class @Plunger extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Plunger'
    
    @displayName: -> "弹射装置"
    
    @description: -> """
      一个带有弹簧的杆子，它把球推出发射通道。
    """
    
    @fixedDimensions: -> width: 15, height: 30
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/plunger.png'
    
    @initialize()
  
  class @Playfield extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Playfield'
    
    @displayName: -> "弹球台"
    
    @description: -> """
      弹球机的表面，它包括墙壁和球道。\n
      涂黑或涂白的部分会阻挡球，未涂色的部分则允许球自由滚动。
    """

    @fixedDimensions: -> width: 180, height: 200
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/ballguides.png'
    
    @initialize()

  class @GobbleHole extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.GobbleHole'

    @displayName: -> "吞球洞"

    @description: -> """
      弹球台上的一个洞，球掉进去后可以得分。\n
      它的轮廓必须是黑色的，但内部颜色任你选择，形状和大小也可由你自行决定。
    """

    @fixedDimensions: -> width: 50, height: 50
  
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/gobblehole.png'
    
    @initialize()

  class @BallTrough extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.BallTrough'

    @displayName: -> "球槽"

    @description: -> """
      一个不会让你得分的洞。\n
      它和吞球洞一样，都可以画成任意形状。
    """

    @fixedDimensions: -> width: 100, height: 50

    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/balltrough.png'
    
    @initialize()

  class @Bumper extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Bumper'

    @displayName: -> "弹射器"

    @description: -> """
      绘制一个顶部能弹回球的装置。\n
      画为圆形，效果最佳。
    """
    
    @fixedDimensions: -> width: 30, height: 30
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/bumper.png'
    
    @pixelArtEvaluation: -> true
    
    @initialize()
    
    @properties: ->
      pixelArtScaling: true
      pixelArtEvaluation: {}

  class @Gate extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Gate'

    @displayName: -> "挡板"

    @description: -> """
      一扇围绕其顶部旋转的翻盖门。\n
      画出它正面的样子，并且它的尺寸要大到能够挡住弹球。
    """

    @fixedDimensions: -> width: 20, height: 20
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/gate.png'
    
    @initialize()

  class @Flipper extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Flipper'

    @displayName: -> "弹板"

    @description: -> """
      弹球游戏的标志性元素！你需要画出左弹板静止时的样子。\n
      它会以它左上角斜向数到第七个像素的位置为轴心进行旋转。
    """

    @fixedDimensions: -> width: 30, height: 30
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/flipper.png'
    
    @initialize()

  class @SpinningTarget extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.SpinningTarget'

    @displayName: -> "旋转靶"

    @description: -> """
      一个在弹球经过时会旋转的金属板。
    """

    @fixedDimensions: -> width: 20, height: 20
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/spinningtarget.png'
    
    @initialize()
