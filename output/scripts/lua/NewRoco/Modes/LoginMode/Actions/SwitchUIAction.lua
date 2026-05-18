local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local SwitchUIAction = Base:Extend("SwitchUIAction")

function SwitchUIAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.Event = properties.Event
  if self.Event == nil then
    Log.Error("SwitchUIAction event is nil")
  end
end

function SwitchUIAction:OnEnter()
  Log.Debug("SwitchUIAction OnEnter")
  NRCEventCenter:DispatchEvent(self.Event)
  self:Finish()
end

function SwitchUIAction:OnExit()
  Log.Debug("SwitchUIAction OnExit:", self.name)
end

return SwitchUIAction
