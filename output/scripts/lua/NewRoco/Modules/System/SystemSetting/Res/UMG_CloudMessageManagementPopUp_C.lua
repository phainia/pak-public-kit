local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
local UMG_CloudMessageManagementPopUp_C = _G.NRCPanelBase:Extend("UMG_CloudMessageManagementPopUp_C")

function UMG_CloudMessageManagementPopUp_C:OnConstruct()
  self:SetChildViews(self.PopUp)
end

function UMG_CloudMessageManagementPopUp_C:OnActive()
  self:SetCommonPopUpInfo()
end

function UMG_CloudMessageManagementPopUp_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.ClosePanel
  CommonPopUpData.Btn_RightHandler = self.OnBtnRightClicked
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  self.PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_CloudMessageManagementPopUp_C:OnBtnRightClicked()
  self.module:DispatchEvent(SystemSettingModuleEvent.CloudMessageManagementBtnOKClicked)
end

function UMG_CloudMessageManagementPopUp_C:ClosePanel()
  self:OnClose()
end

return UMG_CloudMessageManagementPopUp_C
