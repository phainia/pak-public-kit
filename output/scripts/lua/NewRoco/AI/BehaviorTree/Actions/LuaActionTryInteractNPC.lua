local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionTryInteractNPC = Base:Extend("LuaActionPlaySkill")
local wild_action_max_range
local GlobalPetInteractCooldown = 1000
local GlobalPetInteractTimestamp = 0

function LuaActionTryInteractNPC:OnStart(owner)
  if not wild_action_max_range then
    wild_action_max_range = _G.DataConfigManager:GetNpcGlobalConfig("wild_action_max_range", true).num or 2000
  end
  local Target = self.Target:GetValue(owner)
  if Target and Target.InteractionComponent then
    if Target:GetActorLocation():Dist(owner.Npc:GetActorLocation()) > wild_action_max_range then
      return self:Finish(false)
    end
    if GlobalPetInteractTimestamp > ZoneServer:GetServerTime() then
      return self:Finish(false)
    end
    GlobalPetInteractTimestamp = ZoneServer:GetServerTime() + GlobalPetInteractCooldown
    Target.InteractionComponent:InteractWithNpc(owner.Npc)
    return self:Finish(true)
  end
  return self:Finish(false)
end

return LuaActionTryInteractNPC
