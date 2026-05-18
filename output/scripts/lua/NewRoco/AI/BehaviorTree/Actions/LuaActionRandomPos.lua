local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionRandomPos = Base:Extend("LuaActionRandomPos")
local DebugColor = 0

function LuaActionRandomPos:GetRandomPosInRing(center, rangeMin, rangeMax, direction, angle, direction_raid)
  local absAngle = math.rad(math.abs(angle))
  local baseAngle = direction_raid or 0
  local minRatio = 0
  if rangeMax > 0 then
    minRatio = rangeMin * rangeMin / (rangeMax * rangeMax)
  end
  local randomRange = rangeMax * math.sqrt(minRatio + (1.0 - minRatio) * math.random())
  local minAngle = 0
  local maxAngle = math.pi
  if nil ~= direction and (0 ~= direction.X or 0 ~= direction.Y) then
    baseAngle = math.atan(direction.Y, direction.X)
  end
  minAngle = baseAngle - absAngle / 2.0
  maxAngle = baseAngle + absAngle / 2.0
  local randomAngle = minAngle + (maxAngle - minAngle) * math.random()
  local randomPos = UE4.FVector(center.X + randomRange * math.cos(randomAngle), center.Y + randomRange * math.sin(randomAngle), center.Z)
  if GlobalConfig.DebugLuaBTree then
    DebugColor = DebugColor + 0.01
    if DebugColor > 1 then
      DebugColor = 0
    end
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), randomPos, 20, 3, UE4.FLinearColor(DebugColor, 0, 0, 1), 10, 2)
  end
  return randomPos
end

LuaActionRandomPos.Segment = nil

function LuaActionRandomPos.CreateSegment(direction, angle)
  local absAngle = math.abs(angle)
  local baseAngle = 0
  direction = direction or UE4.FVector(0, 1, 0)
  if 0 ~= direction.X then
    baseAngle = math.atan(direction.Y, direction.X)
  else
    baseAngle = direction.Y > 0 and 0 or math.pi
  end
  local begin = baseAngle - absAngle / 2.0
  if begin < -math.pi then
    begin = begin + 2 * math.pi
  end
  if begin >= math.pi then
    begin = begin - 2 * math.pi
  end
  return {begin = begin, length = absAngle}
end

function LuaActionRandomPos.AdjustSegments(segments)
  local pendingSeg = {}
  for i, v in ipairs(segments) do
    if v.begin + v.length > math.pi then
      table.insert(pendingSeg, {
        begin = v.begin,
        length = math.pi - v.begin
      })
      table.insert(pendingSeg, 1, {
        begin = -math.pi,
        length = v.begin + v.length - math.pi
      })
    else
      table.insert(pendingSeg, v)
    end
  end
  return pendingSeg
end

local stack = 0

function LuaActionRandomPos.SplitSegments(segments, splitter)
  stack = stack + 1
  if splitter.begin + splitter.length > math.pi then
    local seg = LuaActionRandomPos.SplitSegments(segments, {
      begin = splitter.begin,
      length = math.pi - splitter.begin
    })
    return LuaActionRandomPos.SplitSegments(seg, {
      begin = -math.pi,
      length = splitter.begin + splitter.length - math.pi
    })
  end
  local pendingSeg = LuaActionRandomPos.AdjustSegments(segments)
  local pendingInsert
  local pendingInsertPos = 1
  local pendingRemove = {}
  for i, v in ipairs(pendingSeg) do
    if v.begin <= splitter.begin then
      if v.begin + v.length <= splitter.begin then
      elseif v.begin + v.length <= splitter.begin + splitter.length then
        v.length = splitter.begin - v.begin
      else
        v.length = splitter.begin - v.begin
        pendingInsert = {
          begin = splitter.begin + splitter.begin,
          length = v.begin + v.length
        }
        pendingInsertPos = i + 1
        break
      end
    else
      if splitter.begin + splitter.length <= v.begin then
        break
      end
      if splitter.begin + splitter.length <= v.begin + v.length then
        v.begin = splitter.begin + splitter.length
        v.length = v.begin + v.length - (splitter.begin + splitter.length)
        break
      else
        table.insert(pendingRemove, 1, i)
      end
    end
  end
  if nil == pendingInsert then
    for i, v in ipairs(pendingRemove) do
      table.remove(pendingSeg, v)
    end
  else
    table.insert(pendingSeg, pendingInsertPos, pendingInsert)
  end
  return table.findAll(pendingSeg, nil, function(caller, v, k, tab)
    return v.length > 0.001
  end)
end

function LuaActionRandomPos:GenerateRandWithSplitter(centerPos, direction, rangeMin, rangeMax, angle, splitters)
  local randomPos
  local segment = self.CreateSegment(direction, math.rad(angle))
  local segments = {}
  table.insert(segments, segment)
  segments = self.AdjustSegments(segments)
  stack = 0
  for i, v in ipairs(splitters) do
    segments = self.SplitSegments(segments, v)
  end
  if #segments > 0 then
    local totalSegLength = 0
    for i, v in ipairs(segments) do
      totalSegLength = totalSegLength + v.length
    end
    local randBeginAngle = math.random() * totalSegLength
    totalSegLength = 0
    for i, v in ipairs(segments) do
      if randBeginAngle < totalSegLength + v.length then
        randBeginAngle = v.begin + randBeginAngle - totalSegLength
        break
      end
      totalSegLength = totalSegLength + v.length
    end
    randomPos = self:GetRandomPosInRing(centerPos, rangeMin, rangeMax, nil, 1, randBeginAngle)
  end
  return randomPos
end

function LuaActionRandomPos:OnStart(AIController, ...)
  local owner = AIController
  local rangeMax = 0
  local rangeMin = 0
  local direction
  local angle = 360
  if not self.Center then
    self.Center = {
      key = "SelfActor",
      type = LuaParamType.Object,
      GetValue = function(ctrl)
        return owner.Npc
      end
    }
  end
  if not self.RangeMax and self.Range then
    rangeMin = 0
    rangeMax = self.Range:GetValue(owner)
  else
    rangeMin = self.RangeMin:GetValue(owner)
    rangeMax = self.RangeMax:GetValue(owner)
    if rangeMin == rangeMax then
      rangeMin = 0
    end
    direction = self.Direction:GetValue(owner)
    angle = self.Angle:GetValue(owner)
  end
  local centerPos
  if self.Center.type == LuaParamType.Vector then
    centerPos = self.Center:GetValue(owner)
  elseif self.Center.type == LuaParamType.Object then
    local centerObject = self.Center:GetValue(owner)
    if not centerObject then
      self:Finish(false)
      return
    end
    if centerObject.GetActorLocation then
      if not centerObject.viewObj then
        Log.Debug("[Randompos] cant find center object")
        return self:Finish(false)
      end
      local ctrl = centerObject.viewObj:GetInstigatorController()
      if ctrl then
        centerPos = UE.UNRCNavLibrary.GetNavAgentLocation(ctrl)
        centerPos = SceneUtils.ConvertRelativeToAbsolute(centerPos)
      else
        centerPos = centerObject:GetActorLocation()
        centerPos.Z = centerPos.Z - centerObject:GetScaledHalfHeight()
      end
    else
      centerPos = centerObject:Abs_K2_GetActorLocation()
    end
  else
    centerPos = UE.FVector()
  end
  local patrol = self.Patrol and self.Patrol:GetValue(owner) or false
  local randomPos
  if patrol then
    randomPos = self:GenPatrolPoint(owner, centerPos, rangeMax)
    self.OutPoint:SetValue(owner, randomPos)
    return self:Finish(true)
  end
  local relatedBlockingArea = _G.NRCModeManager:DoCmd(SceneModuleCmd.GetRelatedBlockingArea, centerPos, rangeMax)
  local BlockingAreaCentroid = UE4.FVector(0, 0, 0)
  local splitters = {}
  for i, v in ipairs(relatedBlockingArea) do
    if v.location then
      local dir = v.location - centerPos
      local dirSize = dir:Size()
      if 0 == dirSize then
        dirSize = 1
      end
      local splitter = self.CreateSegment(dir, 2 * math.asin(math.clamp(v.radius / dirSize, -1, 1)))
      table.insert(splitters, splitter)
      BlockingAreaCentroid = BlockingAreaCentroid + v.location
    end
  end
  if #relatedBlockingArea > 0 then
    BlockingAreaCentroid = BlockingAreaCentroid / #relatedBlockingArea
  end
  randomPos = self:GenerateRandWithSplitter(centerPos, direction, rangeMin, rangeMax, angle, splitters)
  if nil == randomPos then
    randomPos = self:GenerateRandWithSplitter(centerPos, direction, rangeMin, rangeMax, 360, splitters)
    if nil == randomPos then
      local leaveDir = UE4.UKismetMathLibrary.Subtract_VectorVector(centerPos, BlockingAreaCentroid)
      randomPos = self:GenerateRandWithSplitter(centerPos, leaveDir, rangeMin, rangeMax, 45, {})
    end
  end
  if nil ~= randomPos then
    local bSucc = false
    local retVal = true
    if self.NeedWalkable and self.NeedWalkable:GetValue(owner) then
      local ProjectedPoint
      ProjectedPoint, bSucc = UE4.UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(owner, randomPos, nil, nil, UE4.UNRCNavFilter, FVectorZero)
      if bSucc then
        local SelfPos = UE.UNRCNavLibrary.GetNavAgentLocation(owner)
        retVal = UE.UNRCNavLibrary.Abs_TestPathBetween(owner, SelfPos, ProjectedPoint, false)
      else
        retVal = false
      end
    else
      local ProjectedPoint
      ProjectedPoint, bSucc = UE4.UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(owner, randomPos, nil, nil, UE4.UNRCNavFilter, FVectorZero)
      if bSucc then
        randomPos = ProjectedPoint
      end
    end
    self.OutPoint:SetValue(owner, randomPos)
    return self:Finish(retVal)
  end
  self.OutPoint:SetValue(owner, centerPos)
  return self:Finish(true)
end

function LuaActionRandomPos:GenPatrolPoint(owner, ownerPos, range)
  local ownerNpc = owner.Npc
  local area = ownerNpc:GetArea()
  local randomPos = ownerPos
  local bSucc = false
  local maxSearchTime = 5
  if area then
    repeat
      randomPos, bSucc = UE.UNavigationSystemV1.Abs_K2_GetRandomReachablePointInRadius(owner, ownerPos, nil, range, nil, UE.UNRCNavFilter)
      maxSearchTime = maxSearchTime - 1
    until area:InnerContainsPoint(randomPos) or maxSearchTime <= 0
  end
  if nil == area or maxSearchTime <= 0 then
    if area and area._inRegion then
      local pos = area._inRegion:GenerateRandomPoint()
      if 0 ~= pos:Size() then
        randomPos, bSucc = pos, true
        randomPos = UE.UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(owner:GetWorld(), randomPos)
        if _G.GlobalConfig.DebugLuaBTree then
          UE.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), randomPos, 100, 10, UE.FLinearColor(0, 1, 0, 1), 5, 2)
        end
      end
    end
    if not bSucc then
      randomPos, bSucc = UE.UNavigationSystemV1.Abs_K2_GetRandomReachablePointInRadius(owner, ownerPos, nil, range, nil, UE.UNRCNavFilter)
      if GlobalConfig.DebugLuaBTree then
        UE.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), randomPos, 100, 10, UE.FLinearColor(1, 0, 0, 1), 5, 2)
      end
    end
  elseif GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), randomPos, 100, 10, UE4.FLinearColor(0, 0, 1, 1), 5, 2)
  end
  return randomPos
end

return LuaActionRandomPos
