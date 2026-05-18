local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local LineTraceUtils = {}
LineTraceUtils.EnableNewGoundedFunc = false
local deepCheckMaxTime = 10

function LineTraceUtils.GetPointValidLocationByLine(pos, halfHeight, containNPCBase, BattleCenter, lintraceLength, ActorsToIgnore)
  if not pos then
    Log.Error("zgx pos should not be nil!!!")
    return pos, false, false
  end
  lintraceLength = lintraceLength or BattleConst.BattleFieldValidCheck.zLineSweepRange
  if BattleUtils.IsDeepWater() then
    local posWater, isHitWater = LineTraceUtils.GetPointValidLocationByLineOnWater(pos, halfHeight, lintraceLength, 1, ActorsToIgnore)
    local posGround, isHitGround = LineTraceUtils.GetPointValidLocationByLineOnGround(pos, halfHeight, lintraceLength, containNPCBase, BattleCenter, 1, ActorsToIgnore)
    if isHitWater and isHitGround then
      if posGround.Z > posWater.Z and posGround.Z - posWater.Z < 200 then
        return posGround, false, isHitGround
      else
        return posWater, true, isHitWater
      end
    elseif isHitWater then
      return posWater, true, isHitWater
    elseif isHitGround then
      return posGround, false, isHitGround
    end
  else
    local posGround, isHitGround = LineTraceUtils.GetPointValidLocationByLineOnGround(pos, halfHeight, lintraceLength, containNPCBase, BattleCenter, 1, ActorsToIgnore)
    return posGround, false, isHitGround
  end
  Log.Error("LineTraceUtils.GetPointValidLocationByLine fail")
  return pos, false, false
end

function LineTraceUtils.GetPointValidLocationByLineOnGround(pos, halfHeight, lintraceLength, containNPCBase, BattleCenter, deepCheckTime, ActorsToIgnore)
  halfHeight = halfHeight or 0
  deepCheckTime = deepCheckTime or 1
  lintraceLength = lintraceLength or BattleConst.BattleFieldValidCheck.zLineSweepRange
  halfHeight = math.min(halfHeight, BattleConst.BattleFieldValidCheck.LineTraceMaxLength)
  lintraceLength = math.min(lintraceLength, BattleConst.BattleFieldValidCheck.LineTraceMaxLength)
  local lineBegin = UE4.FVector(pos.X, pos.Y, pos.Z)
  lineBegin.Z = lineBegin.Z + lintraceLength * deepCheckTime
  local lineEnd = UE4.FVector(pos.X, pos.Y, pos.Z)
  lineEnd.Z = lineEnd.Z - lintraceLength * deepCheckTime - halfHeight
  Log.Debug("[Battle]LineTraceUtils GetPointValidLocationByLineOnGround:", pos, lineBegin, lineEnd, halfHeight, lintraceLength, deepCheckTime)
  local gap, HitPoint, CurIsObstructed
  local OffsetVector = UE4.FVector(0, 0, 150)
  local channel = {
    UE4.ECollisionChannel.ECC_WorldStatic
  }
  local SphereTraceRadius = 15
  local hitResults, isHit = UE4.UKismetSystemLibrary.Abs_SphereTraceMultiForObjects(UE4Helper.GetCurrentWorld(), lineBegin, lineEnd, SphereTraceRadius, channel, false, ActorsToIgnore, 0, nil)
  if isHit then
    hitResults = hitResults:ToTable()
    table.sort(hitResults, function(a, b)
      return a.ImpactPoint.Z < b.ImpactPoint.Z
    end)
    for i = #hitResults, 1, -1 do
      local Hit = hitResults[i]
      local hitActor = Hit.Actor
      local lastHitZ
      if hitActor and (containNPCBase or not hitActor:IsA(UE.ARocoCharacter) and not hitActor:IsA(UE.ANPCBaseActor)) then
        local hitName = Hit.Actor:GetName()
        if nil ~= hitName then
          local foundIdx = string.find(hitName, "SM_HLOD2")
          if nil == foundIdx or foundIdx < 0 then
            local curGap = math.abs(pos.Z - Hit.ImpactPoint.Z)
            HitPoint = HitPoint or UE4.FVector(pos.X, pos.Y, pos.Z)
            if not gap then
              gap = curGap
              HitPoint.Z = Hit.ImpactPoint.Z
              Log.Debug("LineTraceUtils GetPointValidLocationByLineOnGround 1:", hitName, curGap, HitPoint.Z, Hit.ImpactPoint.Z, gap)
            elseif curGap < gap and (not lastHitZ or math.abs(lastHitZ - Hit.ImpactPoint.Z) > 200) then
              if BattleCenter then
                if nil == CurIsObstructed then
                  CurIsObstructed = LineTraceUtils.IsHitWorldStatic(BattleCenter + OffsetVector, HitPoint + OffsetVector, ActorsToIgnore)
                end
                local newHit = UE4.FVector(Hit.ImpactPoint.X, Hit.ImpactPoint.Y, Hit.ImpactPoint.Z)
                local newIsObstructed = LineTraceUtils.IsHitWorldStatic(BattleCenter + OffsetVector, newHit + OffsetVector, ActorsToIgnore)
                if CurIsObstructed or not newIsObstructed then
                  gap = curGap
                  HitPoint.Z = Hit.ImpactPoint.Z
                  Log.Debug("LineTraceUtils GetPointValidLocationByLineOnGround 2:", hitName, curGap, HitPoint.Z, Hit.ImpactPoint.Z, gap)
                  CurIsObstructed = newIsObstructed
                end
              else
                gap = curGap
                HitPoint.Z = Hit.ImpactPoint.Z
                Log.Debug("LineTraceUtils GetPointValidLocationByLineOnGround 3:", hitName, curGap, HitPoint.Z, Hit.ImpactPoint.Z, gap)
              end
            end
            lastHitZ = Hit.ImpactPoint.Z
            Log.Debug("LineTraceUtils GetPointValidLocationByLineOnGround 4:", hitName, curGap, HitPoint.Z, Hit.ImpactPoint.Z, gap)
          else
            Log.Debug("LineTraceUtils GetPointValidLocationByLineOnGround 5:", hitName)
            return pos, false
          end
        end
      end
    end
  elseif deepCheckTime < deepCheckMaxTime then
    return LineTraceUtils.GetPointValidLocationByLineOnGround(pos, halfHeight, lintraceLength, containNPCBase, BattleCenter, deepCheckTime + 1, ActorsToIgnore)
  end
  if HitPoint then
    return HitPoint, true
  else
    return pos, false
  end
end

function LineTraceUtils.GetPointValidLocationByLineOnWater(pos, halfHeight, lintraceLength, deepCheckTime, ActorsToIgnore)
  deepCheckTime = deepCheckTime or 1
  lintraceLength = lintraceLength or BattleConst.BattleFieldValidCheck.zLineSweepRange
  halfHeight = halfHeight or 0
  local lineBegin = UE4.FVector(pos.X, pos.Y, pos.Z)
  lineBegin.Z = lineBegin.Z + lintraceLength * deepCheckTime
  local lineEnd = UE4.FVector(pos.X, pos.Y, pos.Z)
  lineEnd.Z = lineEnd.Z - lintraceLength * deepCheckTime - halfHeight
  local TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel2)
  local Hit, Success = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(_G.UE4Helper.GetCurrentWorld(), lineBegin, lineEnd, TraceChannel, false, ActorsToIgnore, 0, nil)
  if Success then
    local target = UE.FVector(Hit.ImpactPoint.X, Hit.ImpactPoint.Y, Hit.ImpactPoint.Z)
    return target, true
  elseif deepCheckTime < deepCheckMaxTime then
    return LineTraceUtils.GetPointValidLocationByLineOnWater(pos, halfHeight, lintraceLength, deepCheckTime + 1, ActorsToIgnore)
  end
  return pos, false
end

function LineTraceUtils.IsHitWorldStatic(LineStart, LineEnd, Ignore)
  local channel = {
    UE4.ECollisionChannel.ECC_WorldStatic
  }
  local hitResult, isHit = UE4.UKismetSystemLibrary.Abs_LineTraceSingleForObjects(UE4Helper.GetCurrentWorld(), LineStart, LineEnd, channel, false, Ignore, 0, nil)
  if isHit and hitResult and hitResult.Actor then
    if not hitResult.Actor:IsA(UE.ARocoCharacter) and not hitResult.Actor:IsA(UE.ANPCBaseActor) then
      return true
    end
    return false
  end
  return isHit
end

function LineTraceUtils.IsHitSkeletalMesh(target)
  if target:IsA(UE.AActor) and target:GetComponentByClass(UE4.USkeletalMeshComponent) then
    Log.Error("LineTraceUtils IsHitSkeletalMesh:", target:GetName())
    return true
  end
  return false
end

function LineTraceUtils.GetPointValidLocation(pos, halfHeight)
  local posByLineCheck = LineTraceUtils.GetPointValidLocationByLine(pos, halfHeight)
  Log.Debug("LineTraceUtils GetPointValidLocation:", halfHeight, posByLineCheck)
  return true, posByLineCheck
end

function LineTraceUtils.HitWorldStatic(Begin, End, Ignore)
  local ObjectTypes = {
    UE4.ECollisionChannel.ECC_WorldStatic
  }
  local hitResults, isHit = UE4.UKismetSystemLibrary.Abs_LineTraceMultiForObjects(UE4Helper.GetCurrentWorld(), Begin, End, ObjectTypes, false, nil, 0, Ignore, true)
  if isHit then
    for i = hitResults:Length(), 1, -1 do
      local Hit = hitResults:Get(i)
      local hitActor = Hit.Actor
      if hitActor and not hitActor:IsA(UE.ARocoCharacter) and not hitActor:IsA(UE.ANPCBaseActor) then
        return Hit
      end
    end
  end
  return nil
end

function LineTraceUtils.HitWorldStaticMesh(Begin, End, Ignore)
  local ObjectTypes = {
    UE4.ECollisionChannel.ECC_WorldStatic
  }
  local hitResults, isHit = UE4.UKismetSystemLibrary.Abs_LineTraceMultiForObjects(UE4Helper.GetCurrentWorld(), Begin, End, ObjectTypes, false, nil, 0, Ignore, true)
  if isHit then
    for i = hitResults:Length(), 1, -1 do
      local Hit = hitResults:Get(i)
      local hitActor = Hit.Actor
      if hitActor and not hitActor:IsA(UE.ARocoCharacter) and not hitActor:IsA(UE.ANPCBaseActor) then
        local component = hitActor:GetComponentByClass(UE4.UStaticMeshComponent)
        if component then
          return Hit
        end
      end
    end
  end
  return nil
end

function LineTraceUtils.HitWaterSurface(Begin, End, Ignore)
  local ObjectTypes = {
    UE4.UNRCStatics.ConvertToObjectType(UE4.ECollisionChannel.ECC_GameTraceChannel13)
  }
  local hitResults, isHit = UE4.UKismetSystemLibrary.Abs_LineTraceMultiForObjects(UE4Helper.GetCurrentWorld(), Begin, End, ObjectTypes, false, nil, 0, Ignore, true)
  if isHit then
    for i = hitResults:Length(), 1, -1 do
      local Hit = hitResults:Get(i)
      local hitActor = Hit.Actor
      if hitActor and not hitActor:IsA(UE.ARocoCharacter) and not hitActor:IsA(UE.ANPCBaseActor) then
        return Hit
      end
    end
  end
  return nil
end

return LineTraceUtils
