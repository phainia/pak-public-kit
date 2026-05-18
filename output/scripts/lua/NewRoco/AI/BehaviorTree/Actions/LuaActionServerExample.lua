local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionServerExample = Base:Extend("LuaActionServerExample")

function LuaActionServerExample:OnStart(AIController, ...)
  self:Finish(true)
end

return LuaActionServerExample
