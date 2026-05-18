local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceUpdateBlackboardValue = Base:Extend("LuaServiceUpdateBlackboardValue")

function LuaServiceUpdateBlackboardValue:OnUpdateService(OwnerController, DeltaTime, ...)
  local aiController = OwnerController
  local condition = self.Condition:GetValue(aiController)
  if not condition then
    return
  end
  local leftType = self.LeftValue:GetType()
  local rightType = self.RightValue:GetType()
  local resultType = self.ResultValue:GetType()
  if leftType ~= rightType or leftType ~= resultType then
    Log.Error("Arguments error: different type")
    return
  end
  local left = self.LeftValue:GetValue(aiController)
  local right = self.RightValue:GetValue(aiController)
  local op = self.Operation:GetValue(aiController)
  local result = LuaBTUtils.SPT_NumericOp.Execute(left, right, op)
  self.ResultValue:SetValue(aiController, result)
end

return LuaServiceUpdateBlackboardValue
