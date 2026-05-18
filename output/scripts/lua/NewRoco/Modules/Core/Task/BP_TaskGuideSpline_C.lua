local Visualize = false
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local CinematicModuleEvent = require("NewRoco.Modules.Core.Cinematic.CinematicModuleEvent")
local BP_TaskGuideSpline_C = Class("BP_TaskGuideSpline_C")

function BP_TaskGuideSpline_C:Initialize(GuideConf)
  self.Guide = GuideConf
  self.MaxLifeTime = self.Guide.max_lifetime
  self.TriggerRange = self.Guide.trigger_range
  self.MoveSpeed = self.Guide.move_speed
  self.SideRange = math.max(self.Guide.trigger_range, self.Guide.side_trigger_range or 0)
  self.Task = nil
  self.LargestInputKey = 0
  self.CurrentDistance = 0
  self.bIsMoving = false
  self.bHasStarted = false
  self.bHasReachEnd = false
  self.CachedMidPoints = {}
  self.SplinePointCount = 0
  self.CurrentLifeTime = 0.0
  self.SplineLengthInEachStage = {}
  self.CurrentStage = 0
  self.CurrentSpeed = 0.0
  self.SpeedGradientRatio = 0.0
  if nil ~= self.Guide.speed_gradient_ratio then
    self.SpeedGradientRatio = self.Guide.speed_gradient_ratio
  end
end

function BP_TaskGuideSpline_C:ReceiveBeginPlay()
  self:UpdateSpline(self.Guide)
  self:InitSplineLengthInEachStage(self.Guide)
  self.Overridden.ReceiveBeginPlay(self)
  self.Sphere:K2_SetWorldLocation(self.Spline:GetLocationAtSplineInputKey(0, UE.ESplineCoordinateSpace.World), false, nil, false)
  self.CurrentDistance = 0
  self:InitializeCurrentStage()
  self.SpeedGradientRatio = math.clamp(self.SpeedGradientRatio, 0, 0.5)
  _G.UpdateManager:Register(self)
  _G.NRCEventCenter:RegisterEvent("BP_TaskGuideSpline_C", self, CinematicModuleEvent.Started, self.OnCinematicStarted)
  _G.NRCEventCenter:RegisterEvent("BP_TaskGuideSpline_C", self, CinematicModuleEvent.Ended, self.OnCinematicEnd)
end

function BP_TaskGuideSpline_C:ReceiveEndPlay(EndPlayReason)
  _G.NRCEventCenter:UnRegisterEvent(self, CinematicModuleEvent.Started, self.OnCinematicStarted)
  _G.NRCEventCenter:UnRegisterEvent(self, CinematicModuleEvent.Ended, self.OnCinematicEnd)
  _G.UpdateManager:UnRegister(self)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
end

function BP_TaskGuideSpline_C:GetBallLocation()
  return self.Sphere:Abs_K2_GetComponentLocation()
end

function BP_TaskGuideSpline_C:UpdateSpline(GuideConf)
  self.Guide = GuideConf
  UE.UNRCStatics.FillSpline(self.Spline, "GUIDE_CONF", self.Guide.id)
  self.SplinePointCount = self.Spline:GetNumberOfSplinePoints()
  self.TotalLength = self.Spline:GetSplineLength()
  if #self.Guide.mid_point_index > 0 then
    table.clear(self.CachedMidPoints)
    for Index, MidPoint in ipairs(self.Guide.mid_point_index) do
      if 1 == Index and 0 ~= MidPoint then
        table.insert(self.CachedMidPoints, 0)
      end
      table.insert(self.CachedMidPoints, MidPoint)
      if Index == #self.Guide.mid_point_index and MidPoint ~= self.SplinePointCount - 1 then
        table.insert(self.CachedMidPoints, self.SplinePointCount - 1)
      end
    end
  end
  if Visualize then
    for Index, Key in ipairs(self.CachedMidPoints) do
      local Loc = self.Spline:GetLocationAtSplinePoint(Key, UE.ESplineCoordinateSpace.World)
      UE.UKismetSystemLibrary.DrawDebugSphere(self, Loc, 120, 8, UE.FLinearColor(1, 1, 1, 1), 9999, 2)
    end
  end
end

function BP_TaskGuideSpline_C:OnTick(DeltaTime)
  if self.bHasReachEnd then
    return
  end
  self.CurrentLifeTime = self.CurrentLifeTime + DeltaTime
  if self.CurrentLifeTime > self.MaxLifeTime then
    self:Destroy(false, true)
    return
  end
  local Player = SceneUtils.GetPlayer()
  if not Player then
    return
  end
  local PlayerPos = SceneUtils.ConvertAbsoluteToRelative(Player:GetActorLocation())
  local TargetCeilKey = self:GetTargetCeilKey(self.CurrentStage)
  local ReachTarget = not self:CheckKeyInRange(PlayerPos, TargetCeilKey)
  if ReachTarget and self.CurrentStage < #self.SplineLengthInEachStage then
    self.CurrentStage = self.CurrentStage + 1
  end
  local PreUpdateDistance = self.CurrentDistance
  local CurrentNeedMoving = false
  local DistanceCurrentStage = self:GetDistanceOfTargetStage(self.CurrentStage)
  if self.CurrentStage <= #self.SplineLengthInEachStage then
    CurrentNeedMoving = DistanceCurrentStage > self.CurrentDistance
  end
  if CurrentNeedMoving then
    self:UpdateCurrentSpeed(DeltaTime)
    self.CurrentDistance = self.CurrentDistance + self.CurrentSpeed * DeltaTime
    if DistanceCurrentStage < self.CurrentDistance then
      self.CurrentDistance = DistanceCurrentStage
    end
    local Loc = self.Spline:GetLocationAtDistanceAlongSpline(self.CurrentDistance, UE.ESplineCoordinateSpace.World)
    self.Sphere:K2_SetWorldLocation(Loc, false, nil, false)
  end
  if Visualize then
    UE.UKismetSystemLibrary.DrawDebugSphere(self, Loc, 60, 8, UE.FLinearColor(1, 0, 0, 1), 1)
    local TargetPos = self.Spline:GetLocationAtSplineInputKey(TargetCeilKey, UE.ESplineCoordinateSpace.World)
    UE.UKismetSystemLibrary.DrawDebugSphere(self, TargetPos, 60, 8, UE.FLinearColor(0, 1, 0, 1), 1)
    local NearestPos = self.Spline:FindLocationClosestToWorldLocation(PlayerPos, UE.ESplineCoordinateSpace.World)
    UE.UKismetSystemLibrary.DrawDebugSphere(self, NearestPos, 60, 8, UE.FLinearColor(0, 0, 1, 1), 1)
  end
  if CurrentNeedMoving and not self.bIsMoving then
    if 0 == PreUpdateDistance then
      self:OnStart()
    else
      self:OnResume()
    end
  elseif not CurrentNeedMoving and self.bIsMoving then
    if self.CurrentDistance == self.TotalLength then
      self:OnStop()
    else
      self:OnPause()
    end
  end
  self.bIsMoving = CurrentNeedMoving
end

function BP_TaskGuideSpline_C:OnStart()
  self.bHasStarted = true
  self.bHasReachEnd = false
  self.CurrentLifeTime = 0
  self.Overridden.StartMove(self)
end

function BP_TaskGuideSpline_C:OnResume()
  self.CurrentLifeTime = 0
  self.Overridden.ResumeMove(self)
end

function BP_TaskGuideSpline_C:OnPause()
  self.Overridden.PauseMove(self)
end

function BP_TaskGuideSpline_C:OnStop()
  self.bHasReachEnd = true
  self.Overridden.StopMove(self)
  _G.DelayManager:DelaySeconds(5.0, self.Destroy, self, true, false)
end

function BP_TaskGuideSpline_C:Destroy(MarkFinished, MarkTimeout)
  _G.UpdateManager:UnRegister(self)
  if self.Task then
    self.Task:RemoveGuide(MarkFinished, MarkTimeout)
  else
    self:K2_DestroyActor()
  end
end

function BP_TaskGuideSpline_C:ToggleVisibility(Visible)
  self.Sphere:SetVisibility(Visible, true)
end

function BP_TaskGuideSpline_C:FindNext(Pos, Key)
  local Indices = self.CachedMidPoints
  local Count = self.SplinePointCount
  local NewKeyValid = false
  if Indices and #Indices > 0 then
    local LastKey
    for _, Value in ipairs(Indices) do
      if Key <= Value then
        NewKeyValid = self:CheckKeyInRange(Pos, Value)
        if NewKeyValid then
          return Value
        end
      end
      LastKey = Value
    end
    return LastKey
  else
    local CeilKey = math.ceil(Key) - 1
    repeat
      CeilKey = CeilKey + 1
      NewKeyValid = self:CheckKeyInRange(Pos, CeilKey)
    until NewKeyValid or Count <= CeilKey
    return CeilKey
  end
end

function BP_TaskGuideSpline_C:CheckKeyInRange(PlayerPos, Key)
  local TargetPos = self.Spline:GetLocationAtSplineInputKey(Key, UE.ESplineCoordinateSpace.World)
  local FixedRange
  if self.SideRange == self.TriggerRange then
    FixedRange = self.TriggerRange
  else
    local NextDir = self.Spline:GetDirectionAtSplineInputKey(Key, UE.ESplineCoordinateSpace.World)
    local PlayerToNextDir = TargetPos - PlayerPos
    PlayerToNextDir:Normalize()
    local DotValue = NextDir:Dot(PlayerToNextDir)
    DotValue = math.clamp(DotValue, 1.0E-6, 1)
    FixedRange = math.clamp(1 / DotValue * self.TriggerRange, self.TriggerRange, self.SideRange)
  end
  local Dist = TargetPos:Dist2D(PlayerPos)
  return FixedRange < Dist
end

function BP_TaskGuideSpline_C:MergeMax(Key)
  if Key > self.LargestInputKey then
    self.LargestInputKey = Key
  end
  return self.LargestInputKey
end

function BP_TaskGuideSpline_C:InitSplineLengthInEachStage(GuideConf)
  local midPoints = {}
  local MaxMidPoint = -1
  for _, MidPoint in ipairs(GuideConf.mid_point_index) do
    table.insert(midPoints, MidPoint)
    MaxMidPoint = math.max(MaxMidPoint, MidPoint)
  end
  if MaxMidPoint < self.SplinePointCount - 1 then
    table.insert(midPoints, self.SplinePointCount - 1)
  end
  self.StageMidPoints = {}
  local PreviousStageDistance = 0.0
  for _, MidPoint in ipairs(midPoints) do
    local CurrentStageDistance = self.Spline:GetDistanceAlongSplineAtSplineInputKey(MidPoint)
    local DistanceInThisState = CurrentStageDistance - PreviousStageDistance
    if DistanceInThisState > 0.0 then
      table.insert(self.SplineLengthInEachStage, DistanceInThisState)
      table.insert(self.StageMidPoints, MidPoint)
    end
    PreviousStageDistance = CurrentStageDistance
  end
end

function BP_TaskGuideSpline_C:GetDistanceOfTargetStage(TargetSage)
  local DistanceAccumulated = 0.0
  for index = 1, TargetSage do
    if index > #self.SplineLengthInEachStage then
      break
    end
    DistanceAccumulated = DistanceAccumulated + self.SplineLengthInEachStage[index]
  end
  return DistanceAccumulated
end

function BP_TaskGuideSpline_C:InitializeCurrentStage()
  local Player = SceneUtils.GetPlayer()
  local PlayerPos = SceneUtils.ConvertAbsoluteToRelative(Player:GetActorLocation())
  local Key = self.Spline:FindInputKeyClosestToWorldLocation(PlayerPos)
  local CeilKey
  CeilKey = self:FindNext(PlayerPos, Key)
  local TargetStage = 0
  for Index, MidPoint in ipairs(self.StageMidPoints) do
    if MidPoint > CeilKey then
      break
    end
    TargetStage = Index
  end
  self.CurrentStage = TargetStage
  if self.CurrentStage > 0 then
    self.CurrentDistance = self:GetDistanceOfTargetStage(self.CurrentStage)
    local Loc = self.Spline:GetLocationAtDistanceAlongSpline(self.CurrentDistance, UE.ESplineCoordinateSpace.World)
    self.Sphere:K2_SetWorldLocation(Loc, false, nil, false)
    if self.CurrentDistance == self.TotalLength then
      self:OnStop()
    end
  end
end

function BP_TaskGuideSpline_C:GetTargetCeilKey(TargetSage)
  if 0 == TargetSage then
    return 0
  elseif TargetSage <= #self.StageMidPoints then
    return self.StageMidPoints[TargetSage]
  else
    return self.StageMidPoints[#self.StageMidPoints]
  end
end

function BP_TaskGuideSpline_C:GetSelfMovingStage()
  if 0.0 == self.CurrentDistance then
    return 0, self.SplineLengthInEachStage[1] or 1
  end
  local DistanceAccumulated = 0.0
  for Index = 1, #self.SplineLengthInEachStage do
    DistanceAccumulated = DistanceAccumulated + self.SplineLengthInEachStage[Index]
    if DistanceAccumulated >= self.CurrentDistance then
      return Index, self.SplineLengthInEachStage[Index]
    end
  end
  return 0, 0
end

function BP_TaskGuideSpline_C:UpdateCurrentSpeed(deltaTime)
  if 0.0 == self.SpeedGradientRatio then
    self.CurrentSpeed = self.MoveSpeed
    return
  end
  local SelfStage, LengthInSelfState = self:GetSelfMovingStage()
  if 0.0 == self.CurrentSpeed then
    local TotalMovingTime = LengthInSelfState / (self.MoveSpeed * (1 - self.SpeedGradientRatio))
    local AccelerateDuration = TotalMovingTime * self.SpeedGradientRatio
    self.CurrentSpeed = self.MoveSpeed * (deltaTime / AccelerateDuration)
    return
  end
  local DistanceOfSelfStage = self:GetDistanceOfTargetStage(SelfStage)
  local DistanceMovedInSelfStage = self.CurrentDistance - (DistanceOfSelfStage - LengthInSelfState)
  local AccelerateDistanceEndRatio = self.SpeedGradientRatio / 2.0 / (1 - self.SpeedGradientRatio)
  local DecelerateDistanceStartRatio = 1.0 - AccelerateDistanceEndRatio
  local MovedDistanceRatio = DistanceMovedInSelfStage / LengthInSelfState
  if AccelerateDistanceEndRatio > MovedDistanceRatio then
    local DistanceRatioInAccelerate = MovedDistanceRatio / AccelerateDistanceEndRatio
    self.CurrentSpeed = math.sqrt(DistanceRatioInAccelerate) * self.MoveSpeed
  elseif DecelerateDistanceStartRatio < MovedDistanceRatio then
    local DistanceRatioInDecelerate = (1 - MovedDistanceRatio) / AccelerateDistanceEndRatio
    self.CurrentSpeed = math.sqrt(DistanceRatioInDecelerate) * self.MoveSpeed
  else
    self.CurrentSpeed = self.MoveSpeed
  end
end

function BP_TaskGuideSpline_C:OnCinematicStarted()
  self:SetActorHiddenInGame(true)
end

function BP_TaskGuideSpline_C:OnCinematicEnd()
  self:SetActorHiddenInGame(false)
end

function BP_TaskGuideSpline_C.EnableTaskGuideVisualize()
  Visualize = true
end

return BP_TaskGuideSpline_C
