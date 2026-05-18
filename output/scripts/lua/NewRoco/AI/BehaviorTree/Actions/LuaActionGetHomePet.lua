local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetHomePet = Base:Extend("LuaActionGetHomePet")
local CountedPetsKey = {}
MakeWeakTable(CountedPetsKey)

function LuaActionGetHomePet:OnStart(owner)
  local HomeModule = _G.NRCModuleManager:GetModule("HomeModule")
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  if not HomeModule or not NPCModule then
    return self:Finish(false)
  end
  local HomePetGetType = self.HomePetGetType:GetValue(owner)
  local pairNestAndPet = HomeModule.data.pairNestAndPet
  local CandidateNpc
  if 3 == HomePetGetType then
    for _, npcInfo in pairs(pairNestAndPet) do
      if npcInfo.base and npcInfo.base.actor_id then
        table.insert(CountedPetsKey, npcInfo)
      end
    end
    if 0 ~= #CountedPetsKey then
      local actor_id = CountedPetsKey[math.random(1, #CountedPetsKey)].base.actor_id
      CandidateNpc = NPCModule:GetNpcByServerID(actor_id)
    end
    table.clear(CountedPetsKey)
  elseif 2 == HomePetGetType then
    local actor_id = 0
    local spawn_time = math.maxinteger
    for _, npcInfo in pairs(pairNestAndPet) do
      if npcInfo.base and npcInfo.base.born_time and spawn_time > npcInfo.base.born_time then
        actor_id = npcInfo.base.actor_id
        spawn_time = npcInfo.base.born_time
      end
    end
    CandidateNpc = NPCModule:GetNpcByServerID(actor_id)
  elseif 1 == HomePetGetType then
    local CenterPos = owner.Npc:GetActorLocation()
    local dist = 9.0E99
    for _, npcInfo in pairs(pairNestAndPet) do
      local npc = NPCModule:GetNpcByServerID(npcInfo.base.actor_id)
      if npc and npc.viewObj then
        local npcPos = npc:GetActorLocation()
        local curDist = CenterPos:Dist(npcPos)
        if dist > curDist then
          dist = curDist
          CandidateNpc = npc
        end
      end
    end
  elseif 0 == HomePetGetType then
    local distSqr = 9.0E99
    for _, npcInfo in pairs(pairNestAndPet) do
      local npc = NPCModule:GetNpcByServerID(npcInfo.base.actor_id)
      if npc and distSqr > npc.squaredDis2LocalIgnoreZ then
        distSqr = npc.squaredDis2LocalIgnoreZ
        CandidateNpc = npc
      end
    end
  else
    return self:Finish(false)
  end
  if CandidateNpc then
    self.OutPetObject:SetValue(owner, CandidateNpc)
    return self:Finish(true)
  end
  return self:Finish(false)
end

return LuaActionGetHomePet
