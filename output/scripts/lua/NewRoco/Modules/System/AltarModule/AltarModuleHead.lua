local AltarModuleHead = NRCModuleHeadBase:Extend("AltarModuleHead")

function AltarModuleHead:OnConstruct()
  _G.AltarModuleCmd = reload("NewRoco.Modules.System.AltarModule.AltarModuleCmd")
  self:BindCmd(_G.AltarModuleCmd.OpenPetAltarPanel, "OpenPetAltarPanel")
  self:BindCmd(_G.AltarModuleCmd.OpenItemAltarPanel, "OpenItemAltarPanel")
  self:BindCmd(_G.AltarModuleCmd.ClosePetAltarPanel, "ClosePetAltarPanel")
  self:BindCmd(_G.AltarModuleCmd.CloseItemAltarPanel, "CloseItemAltarPanel")
  self:BindCmd(_G.AltarModuleCmd.OpenGivePetAwayTips, "OnCmdOpenGivePetAwayTips")
  self:BindCmd(_G.AltarModuleCmd.CloseGivePetAwayTips, "OnCmdCloseGivePetAwayTips")
  self:BindCmd(_G.AltarModuleCmd.OpenItemAltarPanelFree, "OpenItemAltarPanelFree")
  self:BindCmd(_G.AltarModuleCmd.CloseItemAltarPanelFree, "CloseItemAltarPanelFree")
end

return AltarModuleHead
