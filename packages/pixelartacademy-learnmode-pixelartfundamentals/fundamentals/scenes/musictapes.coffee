LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.MusicTapes extends LOI.Adventure.Scene
  # displayedNotificationIds: a list of notification IDs that have already been displayed.
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.MusicTapes'

  @location: -> PAA.Music.Tapes

  @initialize()
  
  things: ->
    tapes = []
    
    # You immediately get the first tapes.
    # TODO: When more original compositions are added, move these as rewards later on.
    tapes.push
      artist: 'Extent of the Jam'
      title: 'musicdisk01'
    
    tapes.push
      artist: 'Shnabubula'
      title: 'Finding the Groove'

    # Tape for Elements of art: line.
    if PAA.Tutorials.Drawing.ElementsOfArt.Line.completed()
      tapes.push
        artist: 'HOME'
        title: 'Resting State'
      
    # Tape for Pixel art lines.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.completed()
      tapes.push
        artist: 'glaciære'
        'sides.0.title': 'shower'
        
    # Tape for Pixel art diagonals.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.completed()
      tapes.push
        artist: 'Revolution Void'
        title: 'The Politics of Desire'
    
    # Tape for Pixel art curves.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.completed()
      tapes.push
        artist: 'State Azure'
        title: 'Stellar Descent'
      
    # Tape for Pixel art line width.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.completed()
      tapes.push
        artist: 'Three Chain Links'
        'sides.0.title': 'The Happiest Days Of Our Lives'
    
    tapes

  class @NotificationsProvider extends PAA.PixelPad.Systems.Notifications.Provider
    @id: -> "#{MusicTapes.id()}.NotificationsProvider"
    @initialize()
    
    @NotificationArtists =
      FirstTapes: 'Shnabubula'
      HOME: 'HOME'
      Glaciaere: 'glaciære'
      RevolutionVoid: 'Revolution Void'
      StateAzure: 'State Azure'
      ThreeChainLinks: 'Three Chain Links'
    
    availableNotificationIds: ->
      # See which tapes are available.
      return [] unless musicTapes = LOI.adventure.getCurrentScene MusicTapes
      tapes = musicTapes.things()
      
      potentialNotificationIds = []
      
      for className, artist of @constructor.NotificationArtists
        continue unless _.find tapes, (tape) => tape.artist is artist
        potentialNotificationIds.push MusicTapes[className].id()
        
      # Remove all notifications that were already displayed.
      displayedNotificationIds = LM.PixelArtFundamentals.Fundamentals.MusicTapes.state('displayedNotificationIds') or []
      _.difference potentialNotificationIds, displayedNotificationIds
      
  class @Notification extends PAA.PixelPad.Systems.Notifications.Notification
    @displayStyle: -> @DisplayStyles.Always
    
    @priority: -> -1
    
    @retroClasses: ->
      body: PAA.PixelPad.Systems.Notifications.Retro.BodyClasses.Walkman
      
    updateLastDisplayedTime: ->
      super arguments...
      
      displayedNotificationIds = LM.PixelArtFundamentals.Fundamentals.MusicTapes.state('displayedNotificationIds') or []
      displayedNotificationIds.push @id()
      LM.PixelArtFundamentals.Fundamentals.MusicTapes.state 'displayedNotificationIds', displayedNotificationIds
  
  class @FirstTapes extends @Notification
    @id: -> "#{MusicTapes.id()}.FirstTapes"
    
    @message: -> """
      现在你可以播放额外的音乐了！

      在音乐软件内，你可以听到Extent of the Jam制作的一些优秀的DOS芯片风格音乐，还有Shnabubula创作的的钢琴即兴演奏。
      
      这些音乐让我想起了《模拟人生》的建筑模式。  
    """

    @displayStyle: -> @DisplayStyles.Always
    
    @initialize()
  
  class @HOME extends @Notification
    @id: -> "#{MusicTapes.id()}.HOME"
    
    @message: -> """
      嘿，我搞到了一张HOME的演示专辑，他就是那个发明了chillsynth风格的天才！你可以在音乐软件中找到它。
    """
    
    @initialize()
    
  class @Glaciaere extends @Notification
    @id: -> "#{MusicTapes.id()}.Glaciaere"
    
    @message: -> """
      我给你买了一盘新的磁带，里面有两张Glaciære制作的蒸汽波专辑。
    """
    
    @initialize()
    
  class @RevolutionVoid extends @Notification
    @id: -> "#{MusicTapes.id()}.RevolutionVoid"
    
    @message: -> """
      是时候嗨起来了！你可以在音乐软件中播放《Revolution Void》了。
    """
    
    @initialize()
  
  class @StateAzure extends @Notification
    @id: -> "#{MusicTapes.id()}.StateAzure"
    
    @message: -> """
      如果你想听一些轻松的环境音乐，我刚好从State Azure那儿拿到了一盘很长的磁带。
    """
    
    @initialize()
  
  class @ThreeChainLinks extends @Notification
    @id: -> "#{MusicTapes.id()}.ThreeChainLinks"
    
    @message: -> """
      我还为你准备了更多音乐——两张来自Three Chain Links的专辑。
      
      他的作品受到了80年代和老式电子游戏的启发，非常酷。
    """
    
    @initialize()
