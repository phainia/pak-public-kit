local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local SwitchLevelAction = Base:Extend("SwitchLevelAction")

function SwitchLevelAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function SwitchLevelAction:OnEnter()
  Log.Debug("SwitchLevelAction OnEnter:", self.name)
  local CurLevelName = LevelHelper:GetLevelName()
  if "Login" == CurLevelName then
    self:Finish()
  else
    NRCEventCenter:RegisterEvent("OnMapLoaded", self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnMapLoaded)
    LevelHelper:OpenLevel("/Game/Levels/Login")
  end
end

function SwitchLevelAction:OnMapLoaded()
  Log.Debug("SwitchLevelAction OnMapLoaded:", self.name)
  self:Finish()
end

function SwitchLevelAction:OnExit()
  Log.Debug("SwitchLevelAction OnExit:", self.name)
end

return SwitchLevelAction
