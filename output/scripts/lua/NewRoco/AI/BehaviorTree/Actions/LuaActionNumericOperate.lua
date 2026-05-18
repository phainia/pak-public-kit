local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionNumericOperate = Base:Extend("LuaActionNumericOperate")

function LuaActionNumericOperate:OnStart(AIController, ...)
  Base.OnStart(self, ...)
  local leftType = self.LeftValue:GetType()
  local rightType = self.RightValue:GetType()
  local resultType = self.ResultValue:GetType()
  if leftType ~= rightType and leftType ~= resultType then
    Log.Error("Argument types not compatible")
    self:Finish(false)
    return
  end
  local aiController = AIController
  local opValue = self.Operation:GetValue(aiController)
  local leftValue = self.LeftValue:GetValue(aiController)
  local rightValue = self.RightValue:GetValue(aiController)
  local resultValue = LuaBTUtils.SPT_NumericOp.Execute(leftValue, rightValue, opValue)
  self.ResultValue:SetValue(aiController, resultValue)
  self:Finish(true)
end

return LuaActionNumericOperate
