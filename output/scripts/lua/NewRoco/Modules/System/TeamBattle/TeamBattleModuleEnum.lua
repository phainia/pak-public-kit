local TeamBattleModuleEnum = {}
TeamBattleModuleEnum.EnterConditionState = {
  None = 0,
  OnlyStarChainOK = 1,
  OnlyBallOK = 2,
  BothOK = 3
}
TeamBattleModuleEnum.PrepareState = {
  None = 0,
  Preparing = 1,
  Prepared = 2
}
TeamBattleModuleEnum.EntranceType = {
  None = 0,
  Map = 1,
  NPC = 2
}
TeamBattleModuleEnum.MyPrepareState = {
  None = 0,
  Preparing = 1,
  Prepared = 2
}
return TeamBattleModuleEnum
