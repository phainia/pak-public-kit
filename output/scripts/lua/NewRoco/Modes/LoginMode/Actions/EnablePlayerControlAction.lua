local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local EnablePlayerControlAction = Base:Extend("EnablePlayerControlAction")

function EnablePlayerControlAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.Event = 1
  if self.Event == nil then
    Log.Error("EnablePlayerControlAction event is nil")
  end
end

function EnablePlayerControlAction:OnEnter()
  Log.Debug("EnablePlayerControlAction OnEnter")
  NRCEventCenter:DispatchEvent(self.Event)
  self:Finish()
end

function EnablePlayerControlAction:OnExit()
  Log.Debug("EnablePlayerControlAction OnExit:", self.name)
end

return EnablePlayerControlAction
