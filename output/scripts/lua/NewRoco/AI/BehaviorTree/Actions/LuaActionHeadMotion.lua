local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionHeadMotion = Base:Extend("LuaActionHeadMotion")

function LuaActionHeadMotion:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  owner.Npc:DoHeadMotion(self.HeadMotionType:GetValue(owner))
  self:Finish(true)
end

return LuaActionHeadMotion
