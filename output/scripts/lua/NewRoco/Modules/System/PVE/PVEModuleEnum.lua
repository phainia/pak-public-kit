local PVEModuleEnum = {}
PVEModuleEnum.TalentNodeUmgCls = {
  [1] = "WidgetBlueprint'/Game/NewRoco/Modules/System/PVE/Res/UMG_PVE_Talent_Item1.UMG_PVE_Talent_Item1_C'",
  [2] = "WidgetBlueprint'/Game/NewRoco/Modules/System/PVE/Res/UMG_PVE_Talent_Item2.UMG_PVE_Talent_Item2_C'",
  [3] = "WidgetBlueprint'/Game/NewRoco/Modules/System/PVE/Res/UMG_PVE_Talent_Item3.UMG_PVE_Talent_Item3_C'"
}
PVEModuleEnum.TalentNodeStatus = {
  Locked = 1,
  CanUnlock = 3,
  Unlocked = 2
}
return PVEModuleEnum
