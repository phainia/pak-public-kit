local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local PopWarningAction = Base:Extend("PopWarningAction")

function PopWarningAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function PopWarningAction:OnEnter()
  Log.Debug("PopWarningAction OnEnter:", self.name)
  local CurrentMode = _G.NRCModeManager:GetCurMode()
  local Title = self.properties.Title
  local Content = self.properties.Content
  local ConfirmEvent = self.properties.ConfirmEvent
  local CancelEvent = self.properties.CancelEvent
  local CurLevelName = LevelHelper:GetLevelName()
  if "UpdateLevel" == CurLevelName then
    NRCModuleManager:DoCmd(UpdateUIModuleCmd.PopUpWindow, Title, Content, ConfirmEvent, CancelEvent)
  elseif "Login" == CurLevelName or "Plot_A1_LearnMagic_New_Release" == CurLevelName then
    NRCModuleManager:DoCmd(LoginModuleCmd.PopUpWindow, Title, Content, ConfirmEvent, CancelEvent)
  end
end

function PopWarningAction:OnPanelOpened()
  Log.Debug("PopWarningAction OnPanelOpened:", self.name)
  self:Finish()
end

function PopWarningAction:OnExit()
  Log.Debug("PopWarningAction OnExit:", self.name)
end

return PopWarningAction
