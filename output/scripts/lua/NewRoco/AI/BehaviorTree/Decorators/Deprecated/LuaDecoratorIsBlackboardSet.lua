local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorIsBlackboardSet = Base:Extend("LuaDecoratorIsBlackboardSet")

function LuaDecoratorIsBlackboardSet:PerformConditionCheck(OwnerController, ...)
  local isSet = self.IsSet:GetValue(OwnerController)
  if not self.BBObj.useBlackboardKey then
    self:LogWarning("param should use BlackboardKey, decorator passed")
    return true
  end
  if OwnerController.LocalGlobalConfig.BTreeUseLuaBlackboard then
    local Value = OwnerController.LuaBTBlackboard[self.BBObj.key]
    if nil ~= Value then
      return isSet
    else
      return not isSet
    end
  end
  self:LogWarning("called without lua blackboard, decorator passed")
  return true
end

return LuaDecoratorIsBlackboardSet
