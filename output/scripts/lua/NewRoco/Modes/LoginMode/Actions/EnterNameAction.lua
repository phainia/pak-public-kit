local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local EnterNameAction = Base:Extend("EnterNameAction")

function EnterNameAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
  self.Event = LoginModuleEvent.EnterName
end

function EnterNameAction:OnEnter()
  Log.Debug("EnterNameAction OnEnter")
  self.fsm.BlockRestoreCameraActionFlag = 1
  NRCEventCenter:DispatchEvent(self.Event)
  if self.properties.endEvent then
    NRCEventCenter:RegisterEvent("EnterNameAction", self, self.properties.endEvent, self.EndAction)
  else
    self:Finish()
  end
end

function EnterNameAction:EndAction()
  self:Finish()
end

function EnterNameAction:OnFinish()
  NRCEventCenter:UnRegisterEvent(self, self.properties.endEvent, self.EndAction)
end

function EnterNameAction:OnExit()
  Log.Debug("EnterNameAction OnExit:", self.name)
end

return EnterNameAction
