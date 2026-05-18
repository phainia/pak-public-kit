local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionSearchHabitatNpc = Base:Extend("LuaActionSearchHabitatNpc")

function LuaActionSearchHabitatNpc:OnStart(owner)
  local ownerNpc = owner.Npc
  local AIComp = ownerNpc.AIComponent
  local AIManager = AIComp.GetManager()
  local SearchRange = self.SearchRange:GetValue(owner)
  local SearchType = self.SearchType:GetValue(owner)
  local HabitatIdToSearch
  if 0 == SearchType then
    local HabitatID = self.HabitatID:GetValue(owner)
    if 0 == HabitatID then
      HabitatIdToSearch = AIComp.cfg_habitat
    else
      HabitatIdToSearch = HabitatID
    end
  elseif 1 == SearchType then
    local habData = AIManager.HabitatRelationMap[AIComp.cfg_habitat]
    if habData and habData.first_neighbor then
      HabitatIdToSearch = habData.first_neighbor.habitat_id
    end
  elseif 2 == SearchType then
    local habData = AIManager.HabitatRelationMap[AIComp.cfg_habitat]
    if habData and habData.second_neighborthen then
      HabitatIdToSearch = habData.second_neighbor.habitat_id
    end
  end
  if nil == HabitatIdToSearch or 0 == HabitatIdToSearch then
    return self:Finish(false)
  end
  local NpcModule = ownerNpc.module
  local LocationToSelf = 9.0E9
  local SelfLocation = ownerNpc:GetActorLocation()
  local NearestNpc
  for _, npc in pairs(NpcModule._npcIterDic) do
    if npc ~= ownerNpc and npc.AIComponent and npc.AIComponent.cfg_habitat == HabitatIdToSearch then
      local LocationToNpc = SelfLocation:Dist(npc:GetActorLocation())
      if SearchRange > LocationToNpc and LocationToSelf > LocationToNpc then
        LocationToSelf = LocationToNpc
        NearestNpc = npc
      end
    end
  end
  if nil == NearestNpc then
    return self:Finish(false)
  end
  self.NearestNpc:SetValue(owner, NearestNpc)
  self:Finish(true)
end

return LuaActionSearchHabitatNpc
