local SeasonIntegrationModuleHead = NRCModuleHeadBase:Extend("SeasonIntegrationModuleHead")

function SeasonIntegrationModuleHead:OnConstruct()
  _G.SeasonIntegrationModuleCmd = reload("NewRoco.Modules.System.SeasonIntegration.SeasonIntegrationModuleCmd")
  self:BindCmd(_G.SeasonIntegrationModuleCmd.OpenSeasonIntegrationPanel, "OpenSeasonIntegrationPanel")
  self:BindCmd(_G.SeasonIntegrationModuleCmd.GetSeasonInfo, "GetSeasonInfo")
  self:BindCmd(_G.SeasonIntegrationModuleCmd.ShowSeasonBeginsTips, "ShowSeasonBeginsTips")
  self:BindCmd(_G.SeasonIntegrationModuleCmd.OpenSeasonIntegrationPopUp, "OpenSeasonIntegrationPopUp")
  self:BindCmd(_G.SeasonIntegrationModuleCmd.OpenSeasonPopup, "OpenSeasonPopup")
  self:BindCmd(_G.SeasonIntegrationModuleCmd.SendZoneSetSeasonFirstPopReq, "SendZoneSetSeasonFirstPopReq")
end

return SeasonIntegrationModuleHead
