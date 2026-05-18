local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorMovementMode = Base:Extend("LuaDecoratorNavPathValidate")

function LuaDecoratorMovementMode:PerformConditionCheck(OwnerController, ...)
  Log.Error("LuaDecoratorMovementMode Using Cpp implement")
  return false
end

return LuaDecoratorMovementMode
