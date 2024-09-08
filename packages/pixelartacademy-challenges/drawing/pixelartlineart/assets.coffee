LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawLineArt = PAA.Challenges.Drawing.PixelArtLineArt.DrawLineArt
PADB = PixelArtDatabase

assets =
  MickeyMouseSoundCartoon:
    dimensions: -> width: 100, height: 120
    imageName: -> 'mickeymousesoundcartoon'
    bitmapInfo: -> """
      出自1928年乌布·艾沃克斯（Ub Iwerks）制作的《米老鼠有声动画》（Mickey Mouse Sound Cartoon），仅供学习同人像素画而使用。
    """

  SuperMarioBros3World5:
    dimensions: -> width: 100, height: 100
    imageName: -> 'supermariobros3world5'
    bitmapInfo: -> """
      出自1990年任天堂（Nintendo）出版的《任天堂攻略大全》（Nintendo Power Strategy Guide, vol. SG1/NP13），仅供学习同人像素画而使用。
    """
  
  SonicTheHedgehog3:
    dimensions: -> width: 80, height: 100
    imageName: -> 'sonicthehedgehog3'
    bitmapInfo: -> """
      出自1994年世嘉（SEGA）发行的《刺猬索尼克3》（Sonic the Hedgehog 3），仅供学习同人像素画而使用。
    """
    
  Zaxxon:
    dimensions: -> width: 70, height: 45
    imageName: -> 'zaxxon'
    bitmapInfo: -> """
      出自1982年世嘉（SEGA）发行的《空间逃脱》（Zaxxon），仅供学习同人像素画而使用。
    """
  
  Rayman:
    dimensions: -> width: 65, height: 100
    imageName: -> 'rayman'
    bitmapInfo: -> """
      出自1995年育碧（Ubisoft）发行的《雷曼》（Rayman），仅供学习同人像素画而使用。
    """
    
  ManiacMansion:
    dimensions: -> width: 200, height: 200
    imageName: -> 'maniacmansion'
    bitmapInfo: -> """
      出自1987年卢卡斯影业游戏公司（Lucasfilm Games）由Ken Macklin设计的《疯狂豪宅》（Maniac Mansion），仅供学习同人像素画而使用。
    """
  
  BubbleBobble:
    dimensions: -> width: 80, height: 70
    imageName: -> 'bubblebobble'
    bitmapInfo: -> """
      出自1986年太东（Taito）发行的《泡泡龙》（Bubble Bobble，仅供学习同人像素画而使用。
    """
  
  ZeldaII:
    dimensions: -> width: 100, height: 100
    imageName: -> 'zeldaii'
    bitmapInfo: -> """
      出自1987年任天堂（Nintendo）发行的《塞尔达传说II: 林克的冒险》（Zelda II: The Adventure of Link）使用说明书，仅供学习同人像素画而使用。
    """
  
  DayOfTheTentacle:
    dimensions: -> width: 60, height: 100
    imageName: -> 'dayofthetentacle'
    bitmapInfo: -> """
      出自1993年卢卡斯艺术公司（LucasArts）由Peter Chan设计的《触手也疯狂》（Day of the Tentacle），仅供学习同人像素画而使用。
    """
  
  TetrisGameBoy:
    dimensions: -> width: 180, height: 200
    imageName: -> 'tetrisgameboy'
    bitmapInfo: -> """
      出自1989年任天堂（Nintendo）发布的Game Boy版《俄罗斯方块》（Tetris），仅供学习同人像素画而使用。
    """
    binderScale: 0.5
    
for assetId, asset of assets
  do (assetId, asset) ->
    class DrawLineArt[assetId] extends DrawLineArt
      @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtLineArt.DrawLineArt.#{assetId}"
      @fixedDimensions: asset.dimensions
      @backgroundColor: -> null
      @imageName: asset.imageName
      @bitmapInfo: asset.bitmapInfo
      @maxClipboardScale: asset.maxClipboardScale
      @binderScale: -> asset.binderScale or super arguments...
      @initialize()
  
    PAA.Challenges.Drawing.PixelArtLineArt.drawLineArtClasses[assetId] = DrawLineArt[assetId]
