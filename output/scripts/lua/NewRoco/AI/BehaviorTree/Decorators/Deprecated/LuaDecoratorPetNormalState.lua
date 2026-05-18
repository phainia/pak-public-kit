local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorPetNormalState = Base:Extend("LuaDecoratorPetNormalState")

function LuaDecoratorPetNormalState:PerformConditionCheck(OwnerController, ...)
  local distance = self.Distance:GetValue(OwnerController)
  local compareDis = self.CompareDistance:GetValue(OwnerController)
  local sensity = self.Sensity:GetValue(OwnerController)
  return distance > compareDis and sensity <= 0
end

return LuaDecoratorPetNormalState
