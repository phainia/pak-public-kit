local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local EndLoginAction = Base:Extend("EndLoginAction")

function EndLoginAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function EndLoginAction:OnEnter()
  self:InjectProperties()
  Log.Debug("EndLoginAction OnEnter")
  local PropertyHolder = LoginUtils.GetPropertyHolder()
  local ActorHolder = LoginUtils.GetUObjectHolder()
  _G.NRCEventCenter:DispatchEvent(LoginModuleEvent.PendingLogin)
  if PropertyHolder.bIsMale == nil then
    LoginUtils.DestroyActors(ActorHolder)
    local LoginModule = NRCModuleManager:GetModule("LoginModule")
    LoginModule:ReqEnter()
  else
    LoginUtils.DestroyActors(ActorHolder)
    NRCEventCenter:DispatchEvent(LoginModuleEvent.EndLogin)
    self:Finish()
  end
end

function EndLoginAction:OnExit()
  Log.Debug("EndLoginAction OnExit:", self.name)
end

return EndLoginAction
