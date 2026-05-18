local SystemSettingEnum = {}
SystemSettingEnum.Type = {
  None = 0,
  Fps = 1,
  MobileResolution = 2,
  FriendSuggest = 3,
  FriendSearch = 4
}
SystemSettingEnum.QualityID = {
  FPS = 1,
  MobileResolution = 2,
  ImageQuality = 3
}
SystemSettingEnum.CustomKeyMapRetCode = {
  Success = 0,
  DefaultError = 1,
  UnMappableKeyError = 2,
  ConflictError = 3,
  SaveError = 4
}
local settingButtonType = Enum.SettingButtonType
SystemSettingEnum.ButtonTypeName = {
  [settingButtonType.BUT_SYSTEM] = "button_setting_sub_title1",
  [settingButtonType.BUT_CONTROL] = "button_setting_sub_title2",
  [settingButtonType.BUT_BATTLE] = "button_setting_sub_title3"
}
SystemSettingEnum.KeyStrokeActMode = {
  WaitingInput = 0,
  ConflictResolve = 1,
  ResetCustomMapping = 2
}
return SystemSettingEnum
