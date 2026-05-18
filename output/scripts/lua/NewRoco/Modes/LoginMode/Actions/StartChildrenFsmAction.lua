local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local StartChildrenFsmAction = Base:Extend("StartChildrenFsmAction")

function StartChildrenFsmAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.ChildrenFsm = properties.ChildrenFsm
  self.properties = properties
end

function StartChildrenFsmAction:OnEnter()
  Log.Debug("StartChildrenFsmAction OnEnter")
  if self.properties.TurnOff then
    self.ChildrenFsm:Stop()
    self:Finish()
  else
    self.ChildrenFsm:Stop()
    self.ChildrenFsm:Play()
  end
end

function StartChildrenFsmAction:SendEventToMainFsm(inEvent)
  Log.Error("depreciated")
  self:Finish()
end

function StartChildrenFsmAction:OnExit()
  Log.Debug("StartChildrenFsmAction OnExit:", self.name)
end

return StartChildrenFsmAction
