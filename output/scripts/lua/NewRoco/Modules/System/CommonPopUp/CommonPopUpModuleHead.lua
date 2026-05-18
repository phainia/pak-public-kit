local CommonPopUpModuleHead = NRCModuleHeadBase:Extend("CommonPopUpModuleHead")

function CommonPopUpModuleHead:OnConstruct()
  _G.CommonPopUpModuleCmd = reload("NewRoco.Modules.System.CommonPopUp.CommonPopUpModuleCmd")
  self:BindCmd(_G.CommonPopUpModuleCmd.OpenRemindPanel, "OnCmdOpenRemindPanel")
  self:BindCmd(_G.CommonPopUpModuleCmd.CloseRemindPanel, "OnCmdCloseRemindPanel")
  self:BindCmd(_G.CommonPopUpModuleCmd.OpenCommonPopUpWithItem, "OpenCommonPopUpWithItem")
  self:BindCmd(_G.CommonPopUpModuleCmd.OpenActivityCommonPanel, "OpenActivityCommonPanel")
end

return CommonPopUpModuleHead
