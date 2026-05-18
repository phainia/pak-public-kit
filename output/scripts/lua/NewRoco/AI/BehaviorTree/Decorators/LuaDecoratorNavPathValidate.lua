local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorNavPathValidate = Base:Extend("LuaDecoratorNavPathValidate")

function LuaDecoratorNavPathValidate:PerformConditionCheck(OwnerController, ...)
  Log.Error("LuaDecoratorNavPathValidate Using Cpp implement")
  return false
end

return LuaDecoratorNavPathValidate
