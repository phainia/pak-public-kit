local FarmModuleHead = NRCModuleHeadBase:Extend("FarmModuleHead")

function FarmModuleHead:OnConstruct()
  _G.FarmModuleCmd = reload("NewRoco.Modules.System.Farm.FarmModuleCmd")
  self:BindCmd(_G.FarmModuleCmd.RefreshAllLandState, "RefreshAllLandState")
  self:BindCmd(_G.FarmModuleCmd.RefreshCurrentStandLandInfo, "RefreshCurrentStandLandInfo")
  self:BindCmd(_G.FarmModuleCmd.GetHarvestIconPath, "GetHarvestIconPath")
  self:BindCmd(_G.FarmModuleCmd.ShowLandUnlockHighlight, "ShowLandUnlockHighlight")
  self:BindCmd(_G.FarmModuleCmd.HideLandUnlockHighlight, "HideLandUnlockHighlight")
  self:BindCmd(_G.FarmModuleCmd.GetAvailableUnlockFarmLandNum, "GetAvailableUnlockFarmLandNum")
  self:BindCmd(_G.FarmModuleCmd.OnHomePlantChangeNotify, "OnHomePlantChangeNotify")
  self:BindCmd(_G.FarmModuleCmd.GetLandNPC, "GetLandNPC")
  self:BindCmd(_G.FarmModuleCmd.OnHomePlantPlantCrop, "OnHomePlantPlantCrop")
  self:BindCmd(_G.FarmModuleCmd.OnHomeBasicInfoChangeNotify, "OnHomeBasicInfoChangeNotify")
  self:BindCmd(_G.FarmModuleCmd.GetCurrentStandingLandId, "OnCmdGetCurrentStandingLandId")
  self:BindCmd(_G.FarmModuleCmd.GetModuleData, "GetModuleData")
  self:BindCmd(_G.FarmModuleCmd.OnCmdGetIsInFarm, "OnCmdGetIsInFarm")
  self:BindCmd(_G.FarmModuleCmd.OnCollectAllLandOptionStatus, "OnCollectAllLandOptionStatus")
end

return FarmModuleHead
