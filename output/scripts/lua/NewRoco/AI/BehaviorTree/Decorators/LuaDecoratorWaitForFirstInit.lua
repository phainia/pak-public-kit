local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaDecoratorWaitForFirstInit = Base:Extend("LuaActionWaitForFirstInit")

function LuaDecoratorWaitForFirstInit:PerformConditionCheck(OwnerController, ...)
  local owner = OwnerController
  if owner.LuaDecoratorWaitForFirstInit_Flag then
    return false
  end
  owner.LuaDecoratorWaitForFirstInit_Flag = true
  return true
end

return LuaDecoratorWaitForFirstInit
