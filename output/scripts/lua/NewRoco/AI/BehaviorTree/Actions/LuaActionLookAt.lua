local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionLookAt = Base:Extend("LuaActionLookAt")

function LuaActionLookAt:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local target = owner:GetBlackboardValue(self.Target.key)
  local enable = self.Enable:GetValue(owner)
  local immediately = self.Immediately:GetValue(owner)
  if owner.Npc and target then
    owner.Npc:SetHeadLookAtActor(enable and target.viewObj or nil, immediately, false)
  end
  self:Finish(true)
end

return LuaActionLookAt
