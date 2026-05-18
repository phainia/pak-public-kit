local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionUpdateLocalPlayer = Base:Extend("LuaActionUpdateLocalPlayer")

function LuaActionUpdateLocalPlayer:OnStart(AIController, ...)
  self:Finish(true)
end

return LuaActionUpdateLocalPlayer
