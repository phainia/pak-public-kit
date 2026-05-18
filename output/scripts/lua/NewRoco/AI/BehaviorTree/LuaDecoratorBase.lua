local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaDecoratorBase = Base:Extend("LuaDecoratorBase")

function LuaDecoratorBase:Ctor(LuaBTNodeBase)
  Base.Ctor(self, LuaBTNodeBase)
  error("LuaDecorator is forbidden to create, implement in c++ instead!", self.Name)
end

function LuaDecoratorBase:PerformConditionCheck(OwnerController, ...)
  return false
end

return LuaDecoratorBase
