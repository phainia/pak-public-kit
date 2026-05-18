local TowerModeModuleHead = NRCModuleHeadBase:Extend("TowerModeModuleHead")

function TowerModeModuleHead:OnConstruct()
  _G.TowerModeCmd = reload("NewRoco.Modules.Core.TowerMode.TowerModeCmd")
  self:BindCmd(_G.TowerModeCmd.OpenMainPanel, "OnOpenMainPanel")
  self:BindCmd(_G.TowerModeCmd.OpenRewardPanel, "OnCmdOpenRewardPanel")
end

return TowerModeModuleHead
