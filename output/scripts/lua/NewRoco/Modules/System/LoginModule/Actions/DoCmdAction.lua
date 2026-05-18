local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local DoCmdAction = Base:Extend("DoCmdAction")

function DoCmdAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
  self.timeout = properties.Timeout or self.timeout
end

function DoCmdAction:OnEnter()
  Log.Debug("DoCmdAction OnEnter:", self.name)
  local FinishEvent = self.properties.FinishEvent
  if FinishEvent then
    _G.NRCEventCenter:RegisterEvent("DoCmdAction", self, FinishEvent, self.OnReceiveFinishEvent)
  end
  if self.properties.DelayStart then
    _G.DelayManager:DelaySeconds(self.properties.DelayStart, self.ExecuteLogic, self)
  elseif self.properties.DoAfterFinish then
    _G.DelayManager:DelaySeconds(self.properties.DoAfterFinish, self.ExecuteLogic, self)
    self:Finish()
  else
    self:ExecuteLogic()
  end
  if self.properties.DelayTime then
    _G.DelayManager:DelaySeconds(self.properties.DelayTime + (0 or self.properties.DelayStart), self.Finish, self)
  end
end

function DoCmdAction:OnTimeout()
  Log.Warning("\229\143\145\231\148\159\232\182\133\230\151\182 StartFsmStateAction  FsmStateName:" .. (self.state.name or "nil") .. "  ActionName:" .. (self.name or "nil"))
end

function DoCmdAction:ExecuteLogic()
  if self.properties.Arguments then
    NRCModuleManager:DoCmd(self.properties.Cmd, table.unpack(self.properties.Arguments))
  else
    NRCModuleManager:DoCmd(self.properties.Cmd)
  end
  if self.properties.bDoAndContinue and not self.properties.DelayTime and not self.properties.DoAfterFinish then
    self:Finish()
  end
end

function DoCmdAction:OnReceiveFinishEvent()
  local FinishEvent = self.properties.FinishEvent
  _G.NRCEventCenter:UnRegisterEvent(self, FinishEvent, self.OnReceiveFinishEvent)
  self:Finish()
end

function DoCmdAction:OnExit()
  Log.Debug("DoCmdAction OnExit:", self.name)
end

return DoCmdAction
