local AppearanceLoginModuleHead = NRCModuleHeadBase:Extend("AppearanceLoginModuleHead")

function AppearanceLoginModuleHead:OnConstruct()
  _G.AppearanceLoginModuleCmd = reload("NewRoco.Modules.System.AppearanceLogin.AppearanceLoginModuleCmd")
  self:BindCmd(_G.AppearanceLoginModuleCmd.OpenBeautyLoginPanel, "OnCmdOpenBeautyLoginPanel")
  self:BindCmd(_G.AppearanceLoginModuleCmd.SetBeautyTabEnum, "OnCmdSetBeautyTabEnum")
  self:BindCmd(_G.AppearanceLoginModuleCmd.SetAvatarSalon, "OnCmdSetAvatarSalon")
  self:BindCmd(_G.AppearanceLoginModuleCmd.SetAvatarSuit, "OnCmdSetAvatarSuit")
  self:BindCmd(_G.AppearanceLoginModuleCmd.SetBeautyColorList, "OnCmdSetBeautyColorList")
  self:BindCmd(_G.AppearanceLoginModuleCmd.GetUIColorIndexToColorMap, "OnCmdGetUIColorIndexToColorMap")
  self:BindCmd(_G.AppearanceLoginModuleCmd.GetAvatarSalonIdToSalonIds, "OnCmdGetAvatarSalonIdToSalonIds")
  self:BindCmd(_G.AppearanceLoginModuleCmd.GetTempBeautyDataByGender, "OnCmdGetTempBeautyDataByGender")
  self:BindCmd(_G.AppearanceLoginModuleCmd.GetColorBGResByColorType, "OnCmdGetColorBGResByColorType")
  self:BindCmd(_G.AppearanceLoginModuleCmd.GetInitialOptionalSuitIds, "OnCmdGetInitialOptionalSuitIds")
  self:BindCmd(_G.AppearanceLoginModuleCmd.GetInitialSelectedSuitId, "OnCmdGetInitialSelectedSuitId")
end

return AppearanceLoginModuleHead
