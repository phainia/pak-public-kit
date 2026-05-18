local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorSimple = Base:Extend("LuaDecoratorBoolOp")

function LuaDecoratorSimple:PerformConditionCheck(OwnerController, ...)
  local result = self.Result:GetValue(OwnerController) or false
  return result
end

return LuaDecoratorSimple
