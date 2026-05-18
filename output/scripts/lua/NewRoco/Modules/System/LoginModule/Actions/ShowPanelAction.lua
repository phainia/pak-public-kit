local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local ShowPanelAction = Base:Extend("ShowPanelAction")

function ShowPanelAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function ShowPanelAction:OnEnter()
  Log.Debug("ShowPanelAction OnEnter:", self.name)
  local CurLevelName = LevelHelper:GetLevelName()
  if self.properties.bKeepInBigWorld then
    NRCModuleManager:DoCmd(UpdateUIModuleCmd.ShowPanel, self.properties.PanelName, self.properties.TurnOn, self, self.OnPanelOpened)
  elseif "UpdateLevel" == CurLevelName then
    NRCModuleManager:DoCmd(UpdateUIModuleCmd.ShowPanel, self.properties.PanelName, self.properties.TurnOn, self, self.OnPanelOpened)
  elseif "Login" == CurLevelName or "Plot_A1_LearnMagic_New_Release" == CurLevelName then
    NRCModuleManager:DoCmd(LoginModuleCmd.ShowPanel, self.properties.PanelName, self.properties.TurnOn, self, self.OnPanelOpened)
  end
end

function ShowPanelAction:OnPanelOpened()
  Log.Debug("ShowPanelAction OnPanelOpened:", self.name)
  self:Finish()
end

function ShowPanelAction:OnExit()
  Log.Debug("ShowPanelAction OnExit:", self.name)
end

return ShowPanelAction
