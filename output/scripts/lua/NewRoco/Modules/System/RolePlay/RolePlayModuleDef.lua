local RolePlayModuleDef = {}
RolePlayModuleDef.RolePlayType = {
  Action = 1,
  Sound = 2,
  Suit = 3,
  Interactive = 4,
  PutProp = 5
}
RolePlayModuleDef.RolePlayTypeEnumMapping = {
  [Enum.BehaviorType.BT_ACTION_SORT] = RolePlayModuleDef.RolePlayType.Action,
  [Enum.BehaviorType.BT_SUIT_SORT] = RolePlayModuleDef.RolePlayType.Suit,
  [Enum.BehaviorType.BT_PUTPRO_SORT] = RolePlayModuleDef.RolePlayType.PutProp
}

function RolePlayModuleDef.GetRolePlayTypeByEnum(Enum)
  return Enum and RolePlayModuleDef.RolePlayTypeEnumMapping[Enum]
end

RolePlayModuleDef.RolePlayBtnState = {
  Normal = 1,
  Selected = 2,
  Disabled = 3,
  Hide = 4
}
RolePlayModuleDef.RedPointKey = 240
RolePlayModuleDef.InterruptType = {
  CanInterrupt = 1,
  CanNotInterrupt = 2,
  CanParallel = 3
}
return RolePlayModuleDef
