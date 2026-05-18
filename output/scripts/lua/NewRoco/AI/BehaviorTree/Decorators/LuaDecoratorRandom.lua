local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorRandom = Base:Extend("LuaDecoratorRandom")

function LuaDecoratorRandom:PerformConditionCheck(OwnerController, ...)
  local probability = self.Probability:GetValue(OwnerController)
  local randomValue = math.random(0.0, 100.0)
  local result = probability > randomValue
  return result
end

return LuaDecoratorRandom
