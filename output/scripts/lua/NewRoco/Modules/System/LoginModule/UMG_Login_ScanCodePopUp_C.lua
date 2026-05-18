local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local Base = _G.NRCPanelBase
local UMG_Login_ScanCodePopUp_C = Base:Extend("UMG_Login_ScanCodePopUp_C")

function UMG_Login_ScanCodePopUp_C:OnActive()
  self.TransparentBtn.OnClicked:Add(self, self.BackToPlatformChoose)
  self.Btn_WeiXin.OnClicked:Add(self, self.OnChooseWXQrLogin)
  self.Btn_QQ.OnClicked:Add(self, self.OnChooseQQQrLogin)
end

function UMG_Login_ScanCodePopUp_C:BackToPlatformChoose()
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_Login_New_C:ShowPlatformLoginPanel")
  self:DoClose()
end

function UMG_Login_ScanCodePopUp_C:OnChooseWXQrLogin()
  LoginUtils.SendEventToLoginFsm(LoginModuleEvent.VXLoginChosen)
  local loginModule = _G.NRCModuleManager:GetModule("LoginModule")
  if loginModule then
    loginModule.data:SetCondition(LoginEnum.Conditions.UseQrCodeLogin, true)
  end
  self:DoClose()
end

function UMG_Login_ScanCodePopUp_C:OnChooseQQQrLogin()
  LoginUtils.SendEventToLoginFsm(LoginModuleEvent.QQLoginChosen)
  local loginModule = _G.NRCModuleManager:GetModule("LoginModule")
  if loginModule then
    loginModule.data:SetCondition(LoginEnum.Conditions.UseQrCodeLogin, true)
  end
  self:DoClose()
end

function UMG_Login_ScanCodePopUp_C:DoClose()
  _G.NRCModuleManager:DoCmd(_G.LoginModuleCmd.SetSelectTabIndex, 0)
  Base.DoClose(self)
end

function UMG_Login_ScanCodePopUp_C:OnDeactive()
end

function UMG_Login_ScanCodePopUp_C:OnAddEventListener()
end

return UMG_Login_ScanCodePopUp_C
