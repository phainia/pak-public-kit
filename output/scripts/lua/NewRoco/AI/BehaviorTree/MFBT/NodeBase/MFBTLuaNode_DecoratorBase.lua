local Base = require("NewRoco.AI.BehaviorTree.MFBT.MFBTNode_LuaBase")
local MFBTLuaNode_DecoratorBase = Base:Extend("MFBTLuaNode_DecoratorBase")

function MFBTLuaNode_DecoratorBase:Ctor(LuaBTNodeBase)
  self.LuaFileFolderPath = "NewRoco.AI.BehaviorTree.Decorators"
end

function MFBTLuaNode_DecoratorBase:PerformConditionCheck()
  self:Init()
  if self.Action then
    local result = self:MFBTNodeCallActionFunc(self.Action, self.Action.PerformConditionCheck)
    return result
  end
  return false
end

return MFBTLuaNode_DecoratorBase
