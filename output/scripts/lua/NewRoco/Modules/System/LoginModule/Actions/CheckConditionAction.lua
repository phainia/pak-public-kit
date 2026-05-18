local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local CheckConditionAction = Base:Extend("CheckConditionAction")

function CheckConditionAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.Condition = properties.Condition
  self.ExpectedConditionValue = properties.ExpectedConditionValue
  if self.ExpectedConditionValue == nil then
    self.ExpectedConditionValue = true
  end
  self.SuccessEvent = properties.Success
  self.FailEvent = properties.Fail
end

function CheckConditionAction:OnEnter()
  Log.Debug("CheckConditionAction OnEnter:", self.name)
  local Module = _G.NRCModuleManager:GetModule("LoginModule")
  if not Module then
    self.fsm:SendEvent(self.FailEvent, self)
    self:Finish()
    return
  end
  local TargetConditionValue = Module:GetData("LoginData"):GetCondition(self.Condition)
  Log.Debug("CheckConditionAction: TargetConditionValue ", TargetConditionValue, " ExpectedConditionValue ", self.ExpectedConditionValue)
  if TargetConditionValue ~= self.ExpectedConditionValue then
    if self.FailEvent then
      self.fsm:SendEvent(self.FailEvent, self)
    else
      self:Finish()
    end
  elseif self.SuccessEvent then
    self.fsm:SendEvent(self.SuccessEvent, self)
  else
    self:Finish()
  end
end

function CheckConditionAction:OnExit()
  Log.Debug("CheckConditionAction OnExit:", self.name)
end

return CheckConditionAction
