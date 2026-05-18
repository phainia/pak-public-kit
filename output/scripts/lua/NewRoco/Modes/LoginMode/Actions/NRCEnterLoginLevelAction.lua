local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local EnterLoginLevelAction = NRCModeAction:Extend("EnterLoginLevelAction")

function EnterLoginLevelAction:Ctor(name, properties)
  NRCModeAction.Ctor(self, name, properties)
  self.timeout = 99999999999999999
end

function EnterLoginLevelAction:OnEnter()
  local curLevelName = LevelHelper:GetLevelName()
  Log.Debug("EnterLoginLevelAction CurLevelName ", curLevelName)
  if "Login" == curLevelName or "Plot_A1_LearnMagic_New_Release" == curLevelName then
    self:Finish()
  else
    NRCEventCenter:RegisterEvent("OnMapLoaded", self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnMapLoaded)
    LevelHelper:OpenLevel("/Game/Levels/Login")
  end
end

function EnterLoginLevelAction:OnExit()
end

function EnterLoginLevelAction:OnMapLoaded()
  Log.Debug("EnterLoginLevelAction:OnMapLoaded")
  _G.DelayManager:DelayFrames(1, function()
    NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnMapLoaded)
    self:Finish()
  end)
end

return EnterLoginLevelAction
