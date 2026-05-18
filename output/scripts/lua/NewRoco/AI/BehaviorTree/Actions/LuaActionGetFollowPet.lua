local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetFollowPet = Base:Extend("LuaActionGetFollowPet")

function LuaActionGetFollowPet:OnStart(AIController)
  local owner = AIController
  if not UE.UObject.IsValid(owner) then
    return self:Finish(false)
  end
  local NpcModule = _G.NRCModuleManager:GetModule("NPCModule")
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local thrownPets = NpcModule:GetPetByPlayer(localPlayer.serverData.base.actor_id or 0)
  if 0 == #thrownPets then
    return self:Finish(false)
  end
  local followPetGetType = self.FollowPetGetType:GetValue(owner)
  local CandidateNpc
  if 0 == followPetGetType then
    local distSqr = 9.0E99
    for i = 1, #thrownPets do
      local npc = NpcModule:GetNpcByServerID(thrownPets[i])
      if npc and distSqr > npc.squaredDis2LocalIgnoreZ then
        distSqr = npc.squaredDis2LocalIgnoreZ
        CandidateNpc = npc
      end
    end
  elseif 1 == followPetGetType then
    local lastThrownPetId = thrownPets[#thrownPets]
    CandidateNpc = NpcModule:GetNpcByServerID(lastThrownPetId)
  elseif 2 == followPetGetType then
    local randomThrownPetId = thrownPets[math.random(1, #thrownPets)]
    CandidateNpc = NpcModule:GetNpcByServerID(randomThrownPetId)
  end
  if CandidateNpc and CandidateNpc.viewObj and UE.UObject.IsValid(CandidateNpc.viewObj) then
    self.OutFollowPetObject:SetValue(owner, CandidateNpc)
    return self:Finish(true)
  end
  return self:Finish(false)
end

return LuaActionGetFollowPet
