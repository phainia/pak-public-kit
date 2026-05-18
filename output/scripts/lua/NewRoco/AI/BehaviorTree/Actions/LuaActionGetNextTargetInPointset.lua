local MapRegionAreaUtil = require("NewRoco.Modules.Core.Scene.Map.MapRegionAreaUtil")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetNextTargetInPointset = Base:Extend("LuaActionGetNextTargetInPointset")

function LuaActionGetNextTargetInPointset:OnStart(AIController, ...)
  local owner = AIController
  local ownerNpc = owner.Npc
  local pointsetId = self.PointsetId:GetValue(owner)
  local startPosIdx = self.StartPosIdx:GetValue(owner)
  local isLoop = self.IsLoop:GetValue(owner)
  local isInverse = self.IsInverse:GetValue(owner)
  local areaConf = _G.DataConfigManager:GetAreaConf(pointsetId, true)
  local nextPosId = startPosIdx
  local nextPos
  if areaConf then
    local areaTotalPointCount = #areaConf.pos
    local step = isInverse and -1 or 1
    if isLoop then
      nextPosId = (startPosIdx + step + areaTotalPointCount) % areaTotalPointCount
      if 0 == nextPosId then
        nextPosId = areaTotalPointCount
      end
    else
      nextPosId = math.clamp(startPosIdx + step, 0, areaTotalPointCount + 1)
    end
    local _nextPos = areaConf.pos[nextPosId]
    if _nextPos then
      nextPos = UE.FVector(_nextPos.position_xyz[1], _nextPos.position_xyz[2], _nextPos.position_xyz[3])
    end
  end
  if not nextPos then
    return self:Finish(false)
  end
  self.OutPosIdx:SetValue(owner, nextPosId)
  self.OutPos:SetValue(owner, nextPos)
  if GlobalConfig.DebugLuaBTree and nextPos then
    UE4.UKismetSystemLibrary.Abs_DrawDebugArrow(UE4Helper.GetCurrentWorld(), owner.Npc:GetActorLocation(), nextPos, 50, UE4.FLinearColor(1, 1, 0, 1), 30, 10)
  end
  return self:Finish(true)
end

return LuaActionGetNextTargetInPointset
