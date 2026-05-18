local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorPetRelax = Base:Extend("LuaDecoratorPetRelax")

function LuaDecoratorPetRelax:PerformConditionCheck(OwnerController, ...)
  local distance = self.Distance:GetValue(OwnerController)
  local compareDis = self.CompareDistance:GetValue(OwnerController)
  local relaxCD = self.RelaxCD:GetValue(OwnerController)
  return distance <= compareDis and relaxCD <= 0
end

return LuaDecoratorPetRelax
