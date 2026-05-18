local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionAddRemoveBuff = Base:Extend("LuaActionAddRemoveBuff")

function LuaActionAddRemoveBuff:OnStart(AIController, ...)
  self:Finish(true)
end

return LuaActionAddRemoveBuff
