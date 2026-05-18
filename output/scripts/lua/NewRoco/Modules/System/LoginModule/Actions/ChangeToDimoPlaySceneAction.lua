local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local ChangeToDimoPlaySceneAction = Base:Extend("SwitchLevelAction")

function ChangeToDimoPlaySceneAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function ChangeToDimoPlaySceneAction:OnEnter()
  Log.Debug("SwitchLevelAction OnEnter:", self.name)
  local CurLevelName = LevelHelper:GetLevelName()
  if "Plot_A1_LearnMagic_New_Release" == CurLevelName then
    self:Finish()
  else
    NRCModeManager:ActiveMode("CreatePlayerMode")
    NRCEventCenter:RegisterEvent("OnMapLoaded", self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnMapLoaded)
  end
end

function ChangeToDimoPlaySceneAction:OnMapLoaded()
  Log.Debug("ChangeToDimoPlaySceneAction OnMapLoaded:", self.name)
  self:Finish()
end

function ChangeToDimoPlaySceneAction:OnExit()
  Log.Debug("SwitchLevelAction OnExit:", self.name)
end

return ChangeToDimoPlaySceneAction
