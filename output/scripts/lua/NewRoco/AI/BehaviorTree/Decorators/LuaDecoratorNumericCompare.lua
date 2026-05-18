local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorNumericCompare = Base:Extend("LuaDecoratorNumericCompare")

function LuaDecoratorNumericCompare:Ctor(LuaBTNode)
  Base.Ctor(self, LuaBTNode)
end

function LuaDecoratorNumericCompare:PerformConditionCheck(OwnerController, ...)
  local leftValue = self.LeftValue:GetValue(OwnerController)
  local rightValue = self.RightValue:GetValue(OwnerController)
  local op = self.Operation:GetValue(OwnerController)
  if ">" == op then
    return leftValue > rightValue
  elseif ">=" == op then
    return leftValue >= rightValue
  elseif "==" == op then
    return leftValue == rightValue
  elseif "<" == op then
    return leftValue < rightValue
  elseif "<=" == op then
    return leftValue <= rightValue
  elseif "!=" == op then
    return leftValue ~= rightValue
  else
    Log.Error("Arguments error: unknown numeric compare operation")
    return false
  end
  return false
end

return LuaDecoratorNumericCompare
