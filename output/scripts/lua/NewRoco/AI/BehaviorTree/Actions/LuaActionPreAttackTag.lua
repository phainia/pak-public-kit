local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionPreAttackTag = Base:Extend("LuaActionPreAttackTag")

function LuaActionPreAttackTag:OnStart(AIController)
  local owner = AIController
  if self.IsSet:GetValue(owner) then
    owner.Npc.AIComponent:SetPreAttackTag(self.TagToSet:GetValue(owner))
  else
    owner.Npc.AIComponent:ClearPreAttackTag()
  end
  self:Finish(true)
end

return LuaActionPreAttackTag
