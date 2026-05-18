local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorBoolOp = Base:Extend("LuaDecoratorBoolOp")

function LuaDecoratorBoolOp:PerformConditionCheck(OwnerController, ...)
  local leftValue = self.LeftValue:GetValue(OwnerController)
  local rightValue = self.RightValue:GetValue(OwnerController)
  local operation = self.Operation:GetValue(OwnerController)
  if "and" == operation or "&&" == operation then
    return leftValue and rightValue
  end
  if "or" == operation or "|" == operation then
    return leftValue or rightValue
  end
  if "not" == operation or "!" == operation then
    return not leftValue or not rightValue
  end
  return false
end

return LuaDecoratorBoolOp
