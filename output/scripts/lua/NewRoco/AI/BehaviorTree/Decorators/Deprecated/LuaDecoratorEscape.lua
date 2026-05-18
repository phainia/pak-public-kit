local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorEscape = Base:Extend("LuaDecoratorPetRelax")

function LuaDecoratorEscape:PerformConditionCheck(OwnerController, ...)
  local owner = OwnerController
  local distance = self.Distance:GetValue(owner)
  local compareDis = self.CompareDistance:GetValue(owner)
  local isExpose = self.IsExpose:GetValue(owner)
  local sensity = self.Sensity:GetValue(owner)
  local compareSensity = self.CompareSensity:GetValue(owner)
  return distance <= compareDis and isExpose or sensity >= compareSensity
end

return LuaDecoratorEscape
