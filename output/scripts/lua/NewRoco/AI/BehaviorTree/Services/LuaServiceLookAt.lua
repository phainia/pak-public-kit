local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceBase = Base:Extend("LuaServiceBase")

function LuaServiceBase:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local target = owner:GetBlackboardValue(self.Target.key)
  if not target then
    return
  end
  local immediately = self.Immediately:GetValue(owner)
  if owner.Npc then
    owner.Npc:SetHeadLookAtActor(target.viewObj, immediately, false)
  end
end

function LuaServiceBase:OnEnd(AIController, Finalizing)
  if Finalizing then
    return
  end
  local owner = AIController
  if owner.Npc then
    owner.Npc:SetHeadLookAtActor(nil, true, false)
  end
end

return LuaServiceBase
