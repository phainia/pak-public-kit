local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionObserveAndSet = Base:Extend("LuaActionObserveAndSet")

function LuaActionObserveAndSet:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local target = self.Target:GetValue(owner)
  if target and target.AIComponent and target.AIComponent.AIController then
    local targetCtrl = target.AIComponent.AIController
    local targetKeyName = string.split(self.TargetKey.key, "]_")[2]
    local targetBBVal = targetCtrl:QueryCrossBlackboardValue(targetKeyName, self.TargetKey.type)
    if nil ~= targetBBVal then
      local sameAs = self.SameAs:GetValue(owner)
      self.OutResult:SetValue(owner, nil ~= targetBBVal and sameAs == targetBBVal)
    else
      Log.Warning("Cant find target BBVal by [" .. targetKeyName .. "]")
    end
  end
  self:Finish(true)
end

return LuaActionObserveAndSet
