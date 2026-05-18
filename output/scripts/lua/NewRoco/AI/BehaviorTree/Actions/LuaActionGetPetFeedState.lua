local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetPetFeedState = Base:Extend("LuaActionGetPetFeedState")

function LuaActionGetPetFeedState:OnStart(owner)
  local npc = owner.Npc
  if npc.config.npc_role_type ~= Enum.PetRoleTypeInNPCConf.PRTINC_HOME then
    return self:Finish(false)
  end
  if npc:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_HOME_PET_WAIT_PRODUCT) then
    self.OutState:SetValue(owner, 0)
    return self:Finish(true)
  end
  if npc:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_HOME_PET_IN_PRODUCT) then
    self.OutState:SetValue(owner, 1)
    return self:Finish(true)
  end
  if npc:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_HOME_PET_CAN_STEAL) or npc:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_HOME_PET_CANT_STEAL) then
    self.OutState:SetValue(owner, 2)
    return self:Finish(true)
  end
  Log.Debug("LuaActionGetPetFeetState: \229\174\182\229\155\173\231\178\190\231\129\181\239\188\140\228\189\134\230\152\175\230\178\161\230\156\137\228\187\187\228\189\149\229\150\130\233\163\159\231\155\184\229\133\179\231\154\132\231\138\182\230\128\129, %s", npc.config.name)
  return self:Finish(false)
end

return LuaActionGetPetFeedState
