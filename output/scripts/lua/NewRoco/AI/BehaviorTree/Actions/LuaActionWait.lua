local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionWait = Base:Extend("LuaActionWait")

function LuaActionWait:OnStart(AIController, ...)
  local args = {
    ...
  }
  local Owner = AIController
  Base.OnStart(self, ...)
  local waitTime = self.WaitTime:GetValue(Owner)
  local randomDeviation = self.RandomDeviation:GetValue(Owner)
  local RemainingWaitTime = 0
  if randomDeviation and randomDeviation > 0 then
    RemainingWaitTime = math.rand(math.max(0, waitTime - randomDeviation), waitTime + randomDeviation)
  else
    RemainingWaitTime = waitTime
  end
  if RemainingWaitTime <= 0 then
    self:Finish(true)
  else
    self.DelayHandle = _G.DelayManager:DelaySeconds(RemainingWaitTime, self.OnTimeUp, self)
  end
end

function LuaActionWait:OnInterrupt()
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
end

function LuaActionWait:OnTimeUp()
  self.DelayHandle = nil
  self:Finish(true)
end

return LuaActionWait
