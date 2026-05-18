local MagicMessageModuleHead = NRCModuleHeadBase:Extend("MagicMessageModuleHead")

function MagicMessageModuleHead:OnConstruct()
  _G.MagicMessageModuleCmd = reload("NewRoco.Modules.System.MagicMessage.MagicMessageModuleCmd")
  self:BindCmd(_G.MagicMessageModuleCmd.SetNpcAppearance, "SetNpcAppearance")
  self:BindCmd(_G.MagicMessageModuleCmd.RegisterPreperform, "RegisterPreperform")
  self:BindCmd(_G.MagicMessageModuleCmd.GetPlayerHpFull, "GetPlayerHpFull")
  self:BindCmd(_G.MagicMessageModuleCmd.GetPetEnergyFull, "GetPetEnergyFull")
  self:BindCmd(_G.MagicMessageModuleCmd.AddLocalNpcToList, "AddLocalNpcToList")
  self:BindCmd(_G.MagicMessageModuleCmd.UpdateNpcByGridAndFeedId, "UpdateNpcByGridAndFeedId")
  self:BindCmd(_G.MagicMessageModuleCmd.DeleteNpcByGridAndFeedId, "DeleteNpcByGridAndFeedId")
  self:BindCmd(_G.MagicMessageModuleCmd.GetNpcByGridAndFeedId, "GetNpcByGridAndFeedId")
  self:BindCmd(_G.MagicMessageModuleCmd.DeleteNpcBeforeEnsure, "DeleteNpcBeforeEnsure")
  self:BindCmd(_G.MagicMessageModuleCmd.OnPickUpFlower, "OnPickUpFlower")
  self:BindCmd(_G.MagicMessageModuleCmd.CheckLandValid, "CheckLandValid")
  self:BindCmd(_G.MagicMessageModuleCmd.GetCanDrawDebug, "GetCanDrawDebug")
  self:BindCmd(_G.MagicMessageModuleCmd.AddVideoToList, "AddVideoToList")
  self:BindCmd(_G.MagicMessageModuleCmd.GetVideoByFileName, "GetVideoByFileName")
  self:BindCmd(_G.MagicMessageModuleCmd.GetVideoByFakeId, "GetVideoByFakeId")
end

return MagicMessageModuleHead
