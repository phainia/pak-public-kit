local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local Base = NRCModeAction
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local SendEventAction = Base:Extend("SendEventAction")

function SendEventAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.bSendThenFinish = properties.bSendThenFinish
  self.bToParentFsm = properties.bToParentFsm
  if properties.GetEventHandler then
    self.bDetermineEventAtRuntime = true
    self.GetEventHandler = properties.GetEventHandler
  else
    self.bDetermineEventAtRuntime = false
    self.Event = properties.Event
  end
end

function SendEventAction:OnEnter()
  Log.Debug("SendEventAction OnEnter", self.Event)
  local FsmToUse = self.fsm
  if self.bToParentFsm then
    if self.fsm.ParentFsm then
      FsmToUse = self.fsm.ParentFsm
    else
      Log.Error("There is no parent fsm")
      return
    end
  end
  local EventToUse = self.Event
  if self.bDetermineEventAtRuntime then
    EventToUse = self.GetEventHandler()
  end
  FsmToUse:SendEvent(EventToUse)
  if self.bSendThenFinish then
    self:Finish()
  end
end

function SendEventAction:OnExit()
  Log.Debug("SendEventAction OnExit:", self.name)
end

return SendEventAction
