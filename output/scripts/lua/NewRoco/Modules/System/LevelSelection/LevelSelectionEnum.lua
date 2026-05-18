local LevelSelectionEnum = {}
LevelSelectionEnum.RewardTab = {StarReward = 0, ClearanceReward = 1}
LevelSelectionEnum.DefeatState = {
  Defeated = 0,
  NotDefeated = 1,
  Unlocked = 2
}
LevelSelectionEnum.UnlockedState = {locked = 0, Unlocked = 1}
LevelSelectionEnum.BattlePanel = {Silhouette = 0, Boss = 1}
return LevelSelectionEnum
