local WorldCombatBossInfo = _G.MakeSimpleClass("WorldCombatBossInfo")
local moreCheckHeight = 200

function WorldCombatBossInfo.GetBossInfoFromNpc(npc)
  if not npc then
    return nil
  end
  if not npc.config then
    return nil
  end
  if npc.config.genre ~= _G.Enum.ClientNpcType.CNT_PETBOSS then
    return nil
  end
  local contentId = npc:GetContentId()
  local worldCombatConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_COMBAT_CONF):GetAllDatas()
  local combatConf
  for _, conf in pairs(worldCombatConf) do
    if conf.refresh_content_id == contentId then
      combatConf = conf
      break
    end
  end
  if not combatConf then
    return nil
  end
  local blockId = combatConf.block_id
  local blockConf = _G.DataConfigManager:GetBlockConf(blockId)
  if not blockConf then
    return nil
  end
  if not blockConf.position or #blockConf.position < 3 then
    return nil
  end
  if #blockConf.spline_point <= 2 then
    return nil
  end
  local bossInfo = WorldCombatBossInfo(npc, combatConf, blockConf)
  bossInfo.blockCenter = UE4.FVector(0, 0, blockConf.position[3])
  bossInfo.blockPolygon = UE4.TArray(UE.FVector2D)
  bossInfo.blockUpHeight = 0
  bossInfo.blockDownHeight = 0
  for _, splineData in pairs(blockConf.spline_point) do
    local point = UE4.FVector2D(splineData.Position[1] + blockConf.position[1], splineData.Position[2] + blockConf.position[2])
    bossInfo.blockCenter.X = bossInfo.blockCenter.X + point.X
    bossInfo.blockCenter.Y = bossInfo.blockCenter.Y + point.Y
    bossInfo.blockPolygon:Add(point)
    bossInfo.blockUpHeight = math.max(bossInfo.blockUpHeight, splineData.Position[3])
    bossInfo.blockDownHeight = math.min(bossInfo.blockDownHeight, splineData.Position[3])
  end
  bossInfo.blockCenter.X = bossInfo.blockCenter.X / #blockConf.spline_point
  bossInfo.blockCenter.Y = bossInfo.blockCenter.Y / #blockConf.spline_point
  bossInfo.blockUpHeight = bossInfo.blockUpHeight + moreCheckHeight
  bossInfo.blockDownHeight = math.abs(bossInfo.blockDownHeight) + moreCheckHeight
  local radiusSquare = 0
  for _, polygonPoint in tpairs(bossInfo.blockPolygon) do
    local offsetX = polygonPoint.X - bossInfo.blockCenter.X
    local offsetY = polygonPoint.Y - bossInfo.blockCenter.Y
    radiusSquare = math.max(radiusSquare, offsetX * offsetX + offsetY * offsetY)
  end
  bossInfo.blockRadius = math.sqrt(radiusSquare)
  return bossInfo
end

function WorldCombatBossInfo:Ctor(npc, combatConf, blockConf)
  self.npc = npc
  self.combatConf = combatConf
  self.blockConf = blockConf
end

function WorldCombatBossInfo:IsPointInHeightRange(position)
  if not self.blockCenter then
    return false
  end
  if not self.blockPolygon then
    return false
  end
  if position.Z < self.blockCenter.Z - self.blockDownHeight then
    return false
  end
  if position.Z > self.blockCenter.Z + self.blockUpHeight then
    return false
  end
  return true
end

function WorldCombatBossInfo:IsPointInPolygon(position)
  if not position then
    return false
  end
  if not self.blockPolygon then
    return false
  end
  if not self:IsPointInHeightRange(position) then
    return false
  end
  return UE4.UNewRocoHelperLibrary.PointInPolygon(position, self.blockPolygon)
end

function WorldCombatBossInfo:IsCircleInPolygon(position, radius)
  if not self.blockPolygon then
    return false
  end
  if not self:IsPointInHeightRange(position) then
    return false
  end
  if not UE4.UNewRocoHelperLibrary.PointInPolygon(position, self.blockPolygon) then
    return false
  end
  local DistSqr = UE.UNRCStatics.ClosestPointDistSqrToPolygon2D(position, self.blockPolygon)
  if DistSqr > radius * radius then
    return false
  end
  return true
end

function WorldCombatBossInfo:IsPointInCircle(position)
  if not position then
    return false
  end
  if not self:IsPointInHeightRange(position) then
    return false
  end
  if not self.blockCenter then
    return false
  end
  local offset = position - self.blockCenter
  local distanceSqrt = offset.X * offset.X + offset.Y * offset.Y
  return distanceSqrt <= self.blockRadius * self.blockRadius
end

function WorldCombatBossInfo:IsCircleOverlap(position, radius)
  if not position then
    return false
  end
  if not self:IsPointInHeightRange(position) then
    return false
  end
  if not self.blockCenter then
    return false
  end
  local offset = position - self.blockCenter
  local distanceSqrt = offset.X * offset.X + offset.Y * offset.Y
  local compareRadius = self.blockRadius + radius
  return distanceSqrt <= compareRadius * compareRadius
end

function WorldCombatBossInfo:GetDebugInfo()
  if not self.combatConf then
    return ""
  end
  return string.format("\233\166\150\233\162\134\230\136\152:%d-%d-%d-%s-%d", self.combatConf.id, self.combatConf.npc_id, self.combatConf.refresh_content_id, self.combatConf.editor_name, self.combatConf.block_id)
end

function WorldCombatBossInfo:IsNightmare()
  if not self.combatConf then
    return false
  end
  return self.combatConf.whether_nightmare
end

return WorldCombatBossInfo
