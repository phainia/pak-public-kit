local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local UMG_Login_PrivacyTips_C = _G.NRCPanelBase:Extend("UMG_Login_PrivacyTips_C")

function UMG_Login_PrivacyTips_C:OnActive(...)
  Log.Debug("UMG_Login_PrivacyTips_C OnActive")
  local ArgContext = (...)
  self.TitleText:SetText(ArgContext.title ~= nil and ArgContext.title or "")
  if nil ~= ArgContext.content then
    self.ContentText:SetText(ArgContext.content)
  end
  self.ContentText:SetText(nil ~= ArgContext.content and ArgContext.content or "")
  self:AddButtonListener(self.Btn_Accept.btnLevelUp, self.OnUserConfirm)
  self:AddButtonListener(self.Btn_Refuse.btnLevelUp, self.OnUserCancel)
  self:AddButtonListener(self.FullScreen_Close, self.OnUserCancel)
  self:AddButtonListener(self.btnClose.btnClose, self.OnUserCancel)
end

function UMG_Login_PrivacyTips_C:OnUserConfirm()
  LoginUtils.SendEventToLoginFsm(LoginModuleEvent.PopUpWindowConfirm)
  self:OnClose()
end

function UMG_Login_PrivacyTips_C:OnUserCancel()
  _G.NRCModuleManager:DoCmd(LoginModuleCmd.SetConditionInData, LoginEnum.Conditions.ChosenChannelBtn, "")
  LoginUtils.SendEventToLoginFsm(LoginModuleEvent.PopUpWindowCancel)
  self:OnClose()
end

function UMG_Login_PrivacyTips_C:OnBtnCloseClicked()
  self:OnClose()
end

return UMG_Login_PrivacyTips_C
