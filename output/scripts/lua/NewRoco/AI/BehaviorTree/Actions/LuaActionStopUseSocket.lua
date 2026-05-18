local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionStopUseSocket = Base:Extend("LuaActionStopUseSocket")

function LuaActionStopUseSocket:OnStart(owner)
  local object = owner.Npc
  if object and object.__ai_socketUsage and object.__ai_socketUsage > 0 then
    object.__ai_socketUsage = object.__ai_socketUsage - 1
  end
  self:Finish(true)
end

return LuaActionStopUseSocket
