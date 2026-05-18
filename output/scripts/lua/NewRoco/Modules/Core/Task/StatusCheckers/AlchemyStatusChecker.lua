local AlchemyModuleEvent = require("NewRoco.Modules.System.Alchemy.AlchemyModuleEvent")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local AlchemyStatusChecker = Base:Extend("AlchemyStatusChecker")

function AlchemyStatusChecker:Ctor()
  Base.Ctor(self)
end

function AlchemyStatusChecker:CheckPass()
  if _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.CheckWaitingFormRequestUpgradeProtocol) then
    return false
  end
  if 1 == _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetAlchemyStatus) then
    return true
  end
  return false
end

function AlchemyStatusChecker:StartCheck()
  self:RegisterGlobalEvent(AlchemyModuleEvent.AlchemyOnStatusChange, self.OnStatusChange)
end

function AlchemyStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(AlchemyModuleEvent.AlchemyOnStatusChange, self.OnStatusChange)
  if self._delayIdx then
    _G.DelayManager:CancelDelayById(self._delayIdx)
  end
end

function AlchemyStatusChecker:OnStatusChangeNextFrame()
  if self._delayIdx then
    _G.DelayManager:CancelDelayById(self._delayIdx)
  end
  self._delayIdx = _G.DelayManager:DelayFrames(1, function()
    self:OnStatusChange()
  end)
end

function AlchemyStatusChecker:OnStatusChange()
  if self:CheckPass() then
    self:FireCallback()
  end
end

return AlchemyStatusChecker
