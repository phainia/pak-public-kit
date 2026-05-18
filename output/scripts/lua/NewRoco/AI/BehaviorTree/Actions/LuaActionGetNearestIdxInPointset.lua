local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetNearestIdxInPointset = Base:Extend("LuaActionPatrolByPointset")

function LuaActionGetNearestIdxInPointset:OnStart(AIController, ...)
  local owner = AIController
  self.controller = owner
  local ownerNpc = owner.Npc
  local selfPos = ownerNpc:GetActorLocation()
  local pointsetId = self.Pointset:GetValue(owner)
  local areaConf = DataConfigManager:GetAreaConf(pointsetId, true)
  local MinDistance = math.huge
  local idx = 1
  if areaConf then
    for i, v in ipairs(areaConf.pos) do
      local Pos = UE.FVector(v.position_xyz[1], v.position_xyz[2], v.position_xyz[3])
      local dist = UE.FVector.DistSquared2D(selfPos, Pos)
      if MinDistance > dist then
        idx = i
        MinDistance = dist
      end
    end
  else
    Log.Error("[LuaActionGetNearestIdxInPointset] cant find pointset", pointsetId)
    return self:Finish(false)
  end
  self.Idx:SetValue(owner, idx - 1)
  self:Finish(true)
end

return LuaActionGetNearestIdxInPointset
