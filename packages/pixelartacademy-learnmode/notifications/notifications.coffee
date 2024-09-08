PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Notifications
  # Conditional notifications
  
  class @MoreElementsOfArt extends PAA.PixelPad.Systems.Notifications.Notification
    @id: -> "PixelArtAcademy.LearnMode.Notifications.MoreElementsOfArt"
    
    @message: -> """
        我计划在抢先体验阶段加入更多与绘画艺术相关的内容。 
        
        在此之前，先专注于线条练习吧。
        这将为你面对更复杂的元素——如色调和色彩时，做好充足的准备。
      """
    
    @displayStyle: -> @DisplayStyles.IfIdle
    
    @condition: ->
      # Show when some of the Elements of art: line tasks are completed.
      PAA.Tutorials.Drawing.ElementsOfArt.Line.completedAssetsCount() > 0
    
    @initialize()
    
    LM.ConditionalNotificationsProvider.registerNotificationClass @

  class @TheEnd extends LM.ConditionalNotificationsProvider.ConditionalNotification
    @id: -> "PixelArtAcademy.LearnMode.Notifications.TheEnd"
    
    @message: -> """
      你已经完成了游戏中的所有任务。
      希望你玩得开心，也有所收获！
      目前游戏处于抢先体验阶段，我们的目标是持续添加新内容。
      所以，请记得回来看看哦。
      
      如果可以的话，在Steam上写个评测吧，这对我们帮助很大。 非常感谢！
    """
    
    @priority: -> 2
    
    @displayStyle: -> @DisplayStyles.Always
    
    @condition: ->
      # Show when no tasks are active.
      for chapter in LOI.adventure.currentChapters()
        for task in chapter.tasks
          return if task.active()
          
      true
      
    @initialize()
    
    LM.ConditionalNotificationsProvider.registerNotificationClass @
  
  # Quotes
  
  @quotes =
    DaVinciKnowing: "达·芬奇曾说: \"单单学会并不够，还要学以致用；仅有意愿并不够，还要付诸行动。\""
    DaVinciBlackCanvas: "达·芬奇曾说: \"画家应当以黑色打底，因为自然界中的万物都黑暗，只有暴露在光中的地方才明亮。\""
    DaVinciNoDesire: "达·芬奇曾说: \"没有学习的意愿，将学不到任何东西。\""
    DaVinciNeverFinished: "达·芬奇曾说: \"艺术永无止境,唯有放弃之时方算终结。\""
    DaVinciScienceArt: "达·芬奇曾说: \"学习艺术的科学，学习科学的艺术。发展你的感官，尤其是学会如何看。要意识到，一切与一切都是相互联系的。\""
    ConfuciusDontStop: "孔子曾说: \"譬如平地，虽覆一篑，进，吾往也。\""
    PicassoEveryChild: "毕加索曾说: \"每个孩子都是艺术家。但问题是，长大后如何依旧保持艺术家之心。\""
    PicassoWhyNot: "毕加索曾说: \"其他人看到了现状，会问为什么。而我则是看到了事情可能的发展方向，并知道为什么会这样。\""
    PicassoLearnRules: "毕加索曾说: \"像行家般学会规则，像画家般打破规则。\""
    PicassoTomorrow: "毕加索曾说: \"只有那些就算你这辈子没做也死而无憾的事，才可以拖到明天做。\""
    PicassoYoung: "毕加索曾说: \"成为年轻人需要很长时间。\""
    PicassoDoing: "毕加索曾说: \"我总是在做我做不到的事情，这样我才能学会如何做到。\""
    PicassoMeaning: "毕加索曾说: \"生命的意义在于找到你的天赋，生命的目的在于将其奉献出去。\""
    AntoineDeSaintExuperyPerfection: "安托万·德·圣-埃克苏佩里曾说: \"完美不是在无事可做时达成，而是在无事可去除时达成。\""
    JessicaHischeProcrastinate: "杰西卡·希歇曾说: \"你在拖延时做的工作，可能正是你一生该做的事。\""
    DaliInspires: "达利曾说: \"真正的艺术家不是被启发的人，而是启发别人的人。\""
    EinsteinImaginationEncirclesTheWorld: "爱因斯坦曾说: \"我是在自己的想象上自由涂画的艺术家。想象力比知识更重要。知识是有限的，而想象力却包含整个世界。\""
    EinsteinImaginationWillGetYouEverywhere: "爱因斯坦曾说: \"逻辑可以把你从A带到Z；想象力可以带你去任何地方。\""
    EinsteinKeepMoving: "爱因斯坦曾说: \"生活就像骑自行车，保持平衡才能继续前行。\""
    EinsteinMistake: "爱因斯坦曾说: \"从未犯错的人，必定从未尝试过新事物。\""
    EinsteinPassion: "爱因斯坦曾说: \"我没有特别的才能，我只是极度好奇。\""
    GandhiLearn: "甘地曾说: \"像你明天就要死去一样生活，像你将永远活着一样学习。\""
    VanGoghPaint: "梵高曾说: \"如果你听到内心有个声音在说，“你不会画画”，那么竭尽努力去画吧，然后那个声音就会变哑巴。\""
    TuringImpossible: "图灵曾说: \"能够想象一切的人，可以创造不可能的事物。\""
    BramStokerFailure: "布拉姆·斯托克曾说: \"我们从失败中学习，而不是从成功中学习。\""
    RichardFeynmannStudy: "理查德·费曼曾说: \"用最不守纪律、不敬和原创的方式努力学习你最感兴趣的东西。\""
    RoyTBennettExperience: "罗伊·T·本内特曾说: \"有些事情是教不会的；必须亲身体验。你永远不会学到人生中最宝贵的教训，直到你经历自己的旅程。\""
    SylviaPlathDoubt: "西尔维亚·普拉斯曾说: \"创造力的最大敌人是自我怀疑。\""
    MayaAngelouCreativity: "玛雅·安杰卢曾说: \"你无法耗尽创造力。使用越多，你拥有的就越多。\""
    KenRobinsonCuriosity: "肯·罗宾逊曾说: \"好奇心是成就的引擎。\""
    HenriMatisseInspiration: "亨利·马蒂斯曾说: \"不要等待灵感，它会在你工作时降临。\""
    WaltDisneyDreams: "沃尔特·迪斯尼曾说: \"所有的梦想都能实现，只要我们有勇气去追求它们。\""
    WaltDisneyDoing: "沃尔特·迪斯尼曾说: \"开始行动的唯一方法就是停止空谈。\""
    WaltDisneyUnique: "沃尔特·迪斯尼曾说: \"你越喜欢自己，你就越不像别人，这使你独一无二。\""
    JohnDeweyReflecting: "约翰·杜威曾说: \"我们不是从经验中学习，而是从对经验的反思中学习。\""
    JohnDeweyArt: "约翰·杜威曾说: \"艺术是存在的最有效的交流方式。\""
    EdCatmullPerfect: "埃德·卡特穆尔曾说: \"不要等到事情完美再与他人分享。早点展示，频繁展示。虽然一路上不会好看，但最终会很漂亮。\""
    EdCatmullFailure: "埃德·卡特穆尔曾说: \"如果你没有经历失败，那么你犯了更大的错误: 你被避免失败的欲望所驱使。\""
    EdCatmullUnexpected: "埃德·卡特穆尔曾说: \"如果你只坚持熟悉的东西，你永远不会偶然发现意料之外的东西。\""
    EdCatmullCreativity: "埃德·卡特穆尔曾说: \"我们人类喜欢知道我们要去哪里，但创造力要求我们走未知的道路。\""
    AlanKayFuture: "艾伦·凯曾说: \"预测未来的最好方法就是创造它。\""
    AlanWattsEngaged: "艾伦·瓦茨曾说: \"这是生活的真正秘密——全心投入到你此刻正在做的事情中。不要称其为工作，而是把它当作游戏。\""
    RoaldDahlPlay: "罗尔德·达尔曾说: \"如果你玩游戏，生活会更有趣。\""
    GeorgeBernardShawPlaying: "乔治·萧伯纳曾说: \"我们不是因为老了才停止玩耍，而是因为停止玩耍才老了。\""
    BobRossMistakes: "鲍勃·罗斯曾说: \"我们不犯错，只有快乐的小意外。\""
    BobRossTalent: "鲍勃·罗斯曾说: \"天赋是追求的兴趣。任何你愿意练习的东西，你都可以做到。\""
    BobRossBelieving: "鲍勃·罗斯曾说: \"做任何事情的秘诀就是相信你能做到。只要你足够相信，你就能做到任何事情。\""
    ThichNhatHanhReflecting: "一行禅师曾说: \"如果学习没有跟随反思和实践，那就不是真正的学习。\""
  
  for quoteId, quote of @quotes
    do (quoteId, quote) =>
      class @[quoteId] extends PAA.PixelPad.Systems.Notifications.Notification
        @id: -> "PixelArtAcademy.LearnMode.QuoteNotifications.#{quoteId}"
        
        @message: -> quote
        
        @priority: -> -1
        
        @retroClassesDisplayed: ->
          face: PAA.PixelPad.Systems.Notifications.Retro.FaceClasses.Peaceful
        
        @initialize()
        
        LM.RandomNotificationsProvider.registerNotificationClass @
