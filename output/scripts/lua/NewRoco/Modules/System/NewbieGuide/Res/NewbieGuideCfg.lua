local NewbieGuideCfg = {}
NewbieGuideCfg[1] = {
  id = 1,
  steps = {
    [1] = {
      type = "ShowGuideAndWaitBtnClick",
      path = {
        "BattleUIModule",
        "BattleMain",
        "UMG_Battle_Operate",
        "TutorialHighLightLoader"
      },
      btnName = "CatchToggleGuide"
    },
    [2] = {
      type = "ShowGuideAndWaitBtnClick",
      path = {
        "BattleUIModule",
        "BattleMain",
        "BallOperationLoader/SpecialLoader",
        "ArcScrollView/ScrollView",
        "UMG_BattleBallEntry",
        "TutorialHighLightLoader"
      },
      btnName = "BattleCardGuide"
    }
  }
}
return NewbieGuideCfg
