local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionSearchEvolutionChainNpc = Base:Extend("LuaActionSearchEvolutionChainNpc")

function LuaActionSearchEvolutionChainNpc:OnStart(owner)
  local ownerNpc = owner.Npc
  local AIComp = ownerNpc.AIComponent
  local SearchRange = self.SearchRange:GetValue(owner)
  local EvolutionChainNum = self.EvolutionChainNum:GetValue(owner)
  local EvoIdToSearch = AIComp.cfg_evochain
  local NpcModule = owner.Npc.module
  local LocationToSelf = 9.0E9
  local SelfLocation = owner.Npc:GetActorLocation()
  local NearestNpc
  for _, npc in pairs(NpcModule._npcIterDic) do
    if npc ~= ownerNpc and npc.AIComponent and npc.AIComponent.cfg_evochain == EvoIdToSearch then
      local petbase = npc:GetConfPetData()
      if petbase and petbase.stage == EvolutionChainNum then
        local LocationToNpc = SelfLocation:Dist(npc:GetActorLocation())
        if SearchRange > LocationToNpc and LocationToSelf > LocationToNpc then
          LocationToSelf = LocationToNpc
          NearestNpc = npc
        end
      end
    end
  end
  if nil == NearestNpc then
    return self:Finish(false)
  end
  self.NearestNpc:SetValue(owner, NearestNpc)
  self:Finish(true)
end

return LuaActionSearchEvolutionChainNpc
