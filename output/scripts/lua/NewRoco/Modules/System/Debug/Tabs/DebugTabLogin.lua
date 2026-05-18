local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local Base = DebugTabBase
local DebugTabLogin = Base:Extend("DebugTabLogin")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")

function DebugTabLogin:SetupTabs()
end

function DebugTabLogin:StartCameraOnPhone()
  NRCModuleManager:DoCmd(LoginModuleCmd.ShowCanvas, LoginEnum.CanvasNames.WebCameraPanel, true)
  NRCModuleManager:DoCmd(LoginModuleCmd.TurnCamera)
end

function DebugTabLogin:SkipLoginMovie()
  NRCEventCenter:DispatchEvent(LoginModuleEvent.SkipLoginMovie)
end

function DebugTabLogin:ChangeBlackScreenSpeed(Name, Panel, InputText)
  local Text
  if Panel then
    Text = Panel.InputBox:GetText()
  else
    Text = InputText
  end
  LoginUtils.BlackSpeed = tonumber(Text)
end

function DebugTabLogin:SwitchCondition(Condition, Value)
  if nil == Value then
    Value = not _G.NRCModuleManager:GetModule("LoginModule"):GetData("LoginData"):GetCondition(Condition)
  end
  Log.Error("OverwriteAndSaveCondition", Condition, Value)
  if Value and Condition == LoginEnum.Conditions.SkipMSDK then
    LoginUtils.SendEventToLoginFsm("FINISHED")
  end
  NRCModuleManager:DoCmd(LoginModuleCmd.OverwriteAndSaveCondition, Condition, Value)
end

function DebugTabLogin:SwitchVideos(Name, Panel)
  self:SwitchCondition(LoginEnum.Conditions.SkipVideos)
end

function DebugTabLogin:SwitchSimulateMSDK(Name, Panel, InputText)
  local Text
  if Panel then
    Text = Panel.InputBox:GetText()
  else
    Text = InputText
  end
  if "0" == Text then
    self:SwitchCondition(LoginEnum.Conditions.SkipMSDK, true)
    self:SwitchCondition(LoginEnum.Conditions.IsOnPc, true)
  elseif "1" == Text then
    self:SwitchCondition(LoginEnum.Conditions.SkipMSDK, false)
    self:SwitchCondition(LoginEnum.Conditions.IsOnPc, false)
  else
    self:SwitchCondition(LoginEnum.Conditions.SkipMSDK)
    self:SwitchCondition(LoginEnum.Conditions.IsOnPc)
  end
end

function DebugTabLogin:SwitchServerChoose()
  NRCEventCenter:DispatchEvent(LoginModuleEvent.ForceEnableSelection)
end

return DebugTabLogin
