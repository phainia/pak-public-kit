local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local WaitForTimerCompleteAction = Base:Extend("SwitchUIAction")

function WaitForTimerCompleteAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function WaitForTimerCompleteAction:OnEnter()
  NRCEventCenter:RegisterEvent("WaitForTimerCompleteAction", self, LoginModuleEvent.TimerComplete, self.OnTimerComplete)
  self.fsm.UseTimerFlag = false
end

function WaitForTimerCompleteAction:OnTimerComplete()
  NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.TimerComplete, self.OnTimerComplete)
  self:Finish()
end

function WaitForTimerCompleteAction:OnExit()
  Log.Debug("SwitchUIAction OnExit:", self.name)
end

return WaitForTimerCompleteAction
