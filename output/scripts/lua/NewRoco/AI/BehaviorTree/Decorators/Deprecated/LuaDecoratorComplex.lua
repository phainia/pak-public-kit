local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorComplex = Base:Extend("LuaDecoratorComplex")

function LuaDecoratorComplex:PerformConditionCheck(OwnerController, ...)
  local args = {
    ...
  }
  local owner = OwnerController
  local bDT1, sOp1 = self:GetDecoratorCondition(self.DecoratorName1, self.Opreation1, owner, ...)
  local bDT2, sOp2 = self:GetDecoratorCondition(self.DecoratorName2, self.Opreation2, owner, ...)
  local bDT3, sOp3 = self:GetDecoratorCondition(self.DecoratorName3, self.Opreation3, owner, ...)
  local bDT4, sOp4 = self:GetDecoratorCondition(self.DecoratorName4, self.Opreation4, owner, ...)
  local temp1 = self:GetBoolOpResult(bDT1, sOp1, bDT2, sOp2)
  local temp2 = self:GetBoolOpResult(temp1, "", bDT3, sOp3)
  local temp3 = self:GetBoolOpResult(temp2, "", bDT4, sOp4)
  return temp3
end

function LuaDecoratorComplex:GetDecoratorCondition(DecoratorName, Operation, Owner, ...)
  local scriptName = DecoratorName:GetValue(Owner)
  local script = require(LuaBTUtils.GetDecorator(scriptName))
  if script then
    local scriptInstance = script()
    local result = scriptInstance:PerformConditionCheck(...)
    local operation = Operation:GetValue(Owner)
    return result, operation
  end
  return true, "and"
end

function LuaDecoratorComplex:GetBoolOpResult(left, opLeft, right, opRight)
  opLeft = string.lower(opLeft)
  if "not" == opLeft or "!" == opLeft then
    left = not left
  end
  if "and" == opRight or "&&" == opRight then
    return left and right
  elseif "not" == opRight or "!" == opRight then
    return left and not right
  elseif "or" == opRight or "|" == opRight then
    return left or right
  end
end

return LuaDecoratorComplex
