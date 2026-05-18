local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorIsActorInBattleFiled = Base:Extend("LuaDecoratorIsActorInBattleFiled")

function LuaDecoratorIsActorInBattleFiled:PerformConditionCheck(OwnerController, ...)
  local owner = OwnerController
  local target = owner:GetBlackboardValue(self.Target.key)
  if target then
    local pos = target:GetActorLocation()
    local battleCenter, battleRange = owner:GetBattleCenterInfo()
    if nil ~= pos and nil ~= battleCenter and nil ~= battleRange then
      local dir = pos - battleCenter
      if dir.X * dir.X + dir.Y * dir.Y < battleRange * battleRange then
        return true
      end
    else
    end
  end
  return false
end

return LuaDecoratorIsActorInBattleFiled
