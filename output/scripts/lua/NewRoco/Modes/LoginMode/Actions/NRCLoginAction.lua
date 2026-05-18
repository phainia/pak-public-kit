local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local NRCLoginAction = NRCModeAction:Extend("NRCLoginAction")

function NRCLoginAction:Ctor(name, properties)
  NRCModeAction.Ctor(self, name, properties)
  self.timeout = 99999999999999999
end

function NRCLoginAction:OnEnter()
  self:DoCmdAsyncToFinish(LoginModuleCmd.StartLogin)
end

function NRCLoginAction:OnExit()
  Log.Debug("NRCLoginAction OnLoginDone:", self.name)
end

return NRCLoginAction
