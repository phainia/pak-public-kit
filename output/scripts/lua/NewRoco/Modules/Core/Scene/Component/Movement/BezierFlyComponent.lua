local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Delegate = require("Utils.Delegate")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local CurveStatics = require("NewRoco.Utils.CurveStatics")
local AIDefines = require("NewRoco.AI.AIDefines")
local Base = ActorComponent
local BezierFlyComponent = Base:Extend("BezierFlyComponent")
local USE_MONTAGE = false
local UPDATE_PARAMS = true
local ENABLE_ROTATION = false
local MIN_REACH_THRESHOLD = 75
local USE_PATH_COMP = true
local ActorLocationCache = UE4.FVector(0, 0, 0)
local ActorRotationCache = UE4.FRotator(0, 0, 0)
local toDirCache = UE4.FVector(0, 0, 0)
local TempVector1 = UE4.FVector(0, 0, 0)
local TempVector2 = UE4.FVector(0, 0, 0)
local TempVector3 = UE4.FVector(0, 0, 0)
local TempVector4 = UE4.FVector(0, 0, 0)

function BezierFlyComponent:GetCachedActorLocation()
  self.owner:GetActorLocationInplace(ActorLocationCache)
  return ActorLocationCache
end

function BezierFlyComponent:GetCachedActorRotation()
  self.owner:GetActorRotationInplace(ActorRotationCache)
  return ActorRotationCache
end

function BezierFlyComponent:Attach(owner)
  Base.Attach(self, owner)
  self.state = AIDefines.ActionState.Idle
  self.speedBase = 500
  self.speed = 500
  self.enableTick = false
  self.FlowRequestId = -1
  self.totalT = 10
  self.curT = 1
  self.curTarget = nil
  self.dir = UE4.FVector(0, 0, 0)
  self.p0 = nil
  self.c0 = nil
  self.c1 = nil
  self.p1 = nil
  self.curvatureFactor = 0
  self.curvatureFactorTarget = 0
  self.pitchFactor = 0
  self.rotSide = false
  self.caller = nil
  self.callback = nil
  self.blockingTime = 0
  self.lastPos = UE4.FVector(0, 0, 0)
  self.pitchCurve = CurveStatics:LoadOrGetCurveAsync(UEPath.C_BEZFLY_PITCH_TO_SPEED)
  self.rollCurve = CurveStatics:LoadOrGetCurveAsync(UEPath.C_BEZFLY_CURVATURE_TO_ROLL)
  self.CircularPlotReq = nil
  self.CircularPlot = nil
  self.CircularPlotRef = nil
  self.reachThreshold = MIN_REACH_THRESHOLD
  self.OnFlowEndDelegate = _G.SimpleDelegateFactory:CreateCallback(self, self.OnFlowEnd)
end

function BezierFlyComponent:DeAttach()
  self.disablePostFlySetting = true
  self.disablePreFlySetting = true
  self:FinishFly(AIDefines.ActionResult.Aborted)
  self:ClearCircularPlot()
end

function BezierFlyComponent:ResLoaded()
  return self.pitchCurve.asset ~= nil and nil ~= self.rollCurve.asset
end

local CacheBezPointList = UE.TArray(UE.FVector)

function BezierFlyComponent:StartFlyWithPoints(initialSpeed, pts, times, caller, callback)
  self:StartFly_Internal(1, initialSpeed, nil, nil, nil, nil, nil, pts, times, caller, callback)
end

function BezierFlyComponent:StartFly(initialSpeed, p0, c0, c1, p1, split, caller, callback)
  self:StartFly_Internal(0, initialSpeed, p0, c0, c1, p1, split, nil, nil, caller, callback)
end

function BezierFlyComponent:StartFly_Internal(mode, initialSpeed, p0, c0, c1, p1, split, to_pos_list, to_time_list, caller, callback)
  if self.state ~= AIDefines.ActionState.Idle then
    self:FinishFly(AIDefines.ActionResult.Continue)
  end
  self.caller = caller
  self.callback = callback
  if not USE_PATH_COMP and not self:ResLoaded() then
    self:FinishFly(AIDefines.ActionResult.Failed)
    return
  end
  if 0 == mode then
    self.p0 = p0
    if not self.p0 then
      local loc = self.owner:GetActorLocation()
      loc.Z = loc.Z - self.owner:GetHalfHeight()
      self.p0 = loc
    end
    self.c0 = c0
    self.c1 = c1
    self.p1 = p1
  elseif 1 == mode then
    self.p0 = SceneUtils.Pos2Vec(to_pos_list[1])
    self.c0 = self.p0
    self.p1 = SceneUtils.Pos2Vec(to_pos_list[#to_pos_list])
    self.c1 = self.p1
  else
    self:FinishFly(AIDefines.ActionResult.Invalid)
    return
  end
  self.reachThreshold = math.max(self.owner:GetScaledRadius(), MIN_REACH_THRESHOLD)
  if self.p0 and self.p1 then
    local distance = self.p0:Dist(self.p1)
    if distance < self.reachThreshold then
      self:FinishFly(AIDefines.ActionResult.Continue)
      return
    elseif distance < 500 then
      split = math.max(math.round(distance / 100), 3)
    end
  else
    Log.Debug("[BezComp] DebugUse: Invalid <Dist> params", self.p0, self.p1)
    self:FinishFly(AIDefines.ActionResult.Failed)
    return
  end
  self.curT = 1
  self.totalT = split or 10
  self.dir = UE4.FVector(0, 0, 0)
  self.dir:Set(initialSpeed.X, initialSpeed.Y, initialSpeed.Z)
  self.dir:Normalize()
  self.curTarget = self.p0
  if USE_PATH_COMP then
    local FlowComp = self:GetMultiPosFlowComponent()
    if not FlowComp then
      self:FinishFly(AIDefines.ActionResult.Failed)
      Log.Debug("[BezComp] Missing MultiPosFlowComponent", self.owner.config.name)
      return
    end
    FlowComp:ClearRoutes()
    if 0 == mode then
      FlowComp:AddMovePoint(self.p0, 0)
      UE.URocoAIHelper.GenBezierPoints(self.p0, self.p1, self.c0, self.c1, self.totalT, CacheBezPointList)
      FlowComp:FillMovePoints(CacheBezPointList)
    else
      FlowComp:LuaAddMovePoints(to_pos_list, to_time_list)
    end
    FlowComp:SetFollowingType(UE4.EMultiPosFollowingType.Direct)
    self.FlowRequestId = FlowComp:StartFollow()
    FlowComp.OnSuccess:Add(FlowComp, self.OnFlowEndDelegate)
    FlowComp.OnFail:Add(FlowComp, self.OnFlowEndDelegate)
  else
    self:SetTickable(true)
    self.blockingTime = 0
    self.speed = self.speedBase
  end
  self.state = AIDefines.ActionState.Working
  self:PreFlySettings()
end

function BezierFlyComponent:PreFlySettings()
  if self.disablePreFlySetting then
    return
  end
  if USE_MONTAGE then
    self.owner:PlayAnim("FlyHover", 1, 0, 0.2, 0, 9999, 0)
    return
  end
  local Model = self.owner.viewObj
  if Model then
    local moveComp = Model:GetMovementComponent()
    moveComp:SetMovementMode(UE4.EMovementMode.MOVE_Flying)
    Model:SetBpRotateRate(nil)
  end
end

function BezierFlyComponent:PostFlySettings()
  if self.disablePostFlySetting then
    return
  end
  if USE_MONTAGE then
    self.owner:StopAnim("FlyHover", 0.2)
    return
  end
  local Model = self.owner.viewObj
  if Model then
    local moveComp = Model:GetMovementComponent()
    moveComp:SetMovementMode(UE4.EMovementMode.MOVE_Falling)
    Model:SetBpRotateRate(UE4.FRotator(360, 360, 360))
    local actorRot = self.owner:GetActorRotation()
    Model:LerpToRotation(UE4.FRotator(0, actorRot.Yaw, 0))
  end
end

function BezierFlyComponent:ResetModelFlyProperty()
  if self.owner and not self.owner.isDestroy then
    local Model = self.owner.viewObj
    if Model and UE.UObject.IsValid(Model) and Model.SetFlyProperty then
      Model:SetFlyProperty(0, 0)
    end
  end
end

function BezierFlyComponent:IsFlying()
  return self.state == AIDefines.ActionState.Working
end

function BezierFlyComponent:OnTick(DeltaTime)
  local stillValid = self.owner and self.owner.viewObj and UE.UObject.IsValid(self.owner.viewObj)
  if not stillValid then
    self:FinishFly(AIDefines.ActionResult.Invalid)
    return
  end
  if self.state == AIDefines.ActionState.Working then
    self:UpdateSegment(DeltaTime)
    self:ApplyMovement(DeltaTime)
    if GlobalConfig.DebugLuaBTree then
      self:DebugDrawPath(0.1)
    end
  end
end

function BezierFlyComponent:UpdateSegment(DeltaTime)
  local actorPos = self:GetCachedActorLocation()
  local bIsLastSegment = self.curT >= self.totalT
  local Model = self.owner.viewObj
  if self:ReachedCurrentTarget() or self.blockingTime > 0.5 then
    if bIsLastSegment then
      self:FinishFly(AIDefines.ActionResult.Success)
    else
      local lastTarget = self.curTarget
      local lastDir = self.dir
      local t = self.curT / (self.totalT - 1.0)
      local u = 1 - t
      local w1 = u * u * u
      local w2 = 3 * u * u * t
      local w3 = 3 * u * t * t
      local w4 = t * t * t
      self.p0:MulInto(w1, TempVector1)
      self.c0:MulInto(w2, TempVector2)
      TempVector1:AddInto(TempVector2, TempVector3)
      self.c1:MulInto(w3, TempVector1)
      self.p1:MulInto(w4, TempVector2)
      TempVector1:AddInto(TempVector2, TempVector4)
      self.curTarget = TempVector3 + TempVector4
      self.curT = self.curT + 1
      if not USE_MONTAGE and UPDATE_PARAMS then
        if Model then
          local rot = self.dir:ToRotator()
          local dLoc = self.curTarget - lastTarget
          dLoc:Normalize()
          local cm = dLoc:Dot(lastDir)
          local upV = dLoc:Cross(lastDir)
          self.rotSide = upV:Dot(UE4Helper.UpVector) >= 0
          self.pitchFactor = math.clamp((-rot.Pitch + 30) / 90, 0, 1)
          if 0 ~= cm then
            self.curvatureFactorTarget = math.clamp(math.abs(1 - cm) / 0.06, 0, 1)
          end
          local result = math.max(self.curvatureFactorTarget, self.pitchFactor)
          Model:SetFlyProperty(0, result)
        else
          self:FinishFly(AIDefines.ActionResult.Invalid)
        end
      end
    end
  elseif UE4.UKismetMathLibrary.Vector_Distance(actorPos, self.lastPos) < self.speed * math.clamp(DeltaTime, 0, 0.1) / 10 then
    self.blockingTime = self.blockingTime + DeltaTime
  else
    self.blockingTime = 0
  end
  self.lastPos.X = actorPos.X
  self.lastPos.Y = actorPos.Y
  self.lastPos.Z = actorPos.Z
end

function BezierFlyComponent:ApplyMovement(DeltaTime)
  local actorPos = self:GetCachedActorLocation()
  local actorRot = self:GetCachedActorRotation()
  local bIsLastSegment = self.curT >= self.totalT
  local Model = self.owner.viewObj
  if not Model then
    self:FinishFly(AIDefines.ActionResult.Invalid)
    return
  end
  if not actorPos or not actorRot then
    self:FinishFly(AIDefines.ActionResult.Invalid)
    return
  end
  local disablePitchMultiplier = self.owner.AIComponent and self.owner.AIComponent.isServerAI
  if disablePitchMultiplier then
    self.speed = self.speedBase
  else
    self.speed = self.speedBase * self.pitchCurve.asset:GetFloatValue(math.clamp((-actorRot.Pitch + 30) / 90, 0, 1))
  end
  self.curTarget:SubInto(actorPos, self.dir)
  local MoveComp = Model:GetMovementComponent()
  self.dir:Normalize()
  self.dir:MulInto(self.speed, TempVector1)
  MoveComp:LuaRequestDirectMove(TempVector1, false)
  if ENABLE_ROTATION then
    local dirXYClamped = UE4.FVector(self.dir.X, self.dir.Y, 0)
    dirXYClamped:Normalize()
    dirXYClamped.Z = math.clamp(self.dir.Z, -0.86, 0.5)
    dirXYClamped:Normalize()
    local dirXYRot = dirXYClamped:ToRotator()
    local sideFactor = 1
    if self.rotSide then
      sideFactor = -1
    end
    dirXYRot.Roll = self.rollCurve.asset:GetFloatValue(self.curvatureFactor) * 45 * sideFactor
    self.owner:SetActorRotation(UE4.FQuat.Slerp(actorRot:ToQuat(), dirXYRot:ToQuat(), 5 * math.clamp(DeltaTime, 0, 0.1)):ToRotator(), true)
  end
end

function BezierFlyComponent:ReachedCurrentTarget()
  local actorPos = self:GetCachedActorLocation()
  self.curTarget:SubInto(actorPos, toDirCache)
  local toDir = toDirCache
  if self.dir:Dot(toDir) < 0 then
    if GlobalConfig.DebugLuaBTree then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), self.curTarget, 10, 10, UE4.FLinearColor(1, 0, 0, 1), 5, 1)
    end
    return true
  end
  if (UE.FVector.Dist(actorPos, self.curTarget) or 0) < self.reachThreshold then
    if GlobalConfig.DebugLuaBTree then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), self.curTarget, 10, 10, UE4.FLinearColor(0, 0, 1, 1), 5, 1)
    end
    return true
  end
  return false
end

function BezierFlyComponent:DebugDrawPath(Duration)
  UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), self.curTarget, math.sqrt(self.speed), 10, UE4.FLinearColor(1, 1, 0, 1), Duration, 2)
  UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), self.c0, 15, 10, UE4.FLinearColor(0, 1, 0, 1), Duration, 2)
  UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), self.c1, 15, 10, UE4.FLinearColor(0, 1, 0, 1), Duration, 2)
  UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), self.p0, 20, 10, UE4.FLinearColor(0, 0, 1, 1), Duration, 2)
  UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), self.p1, 20, 10, UE4.FLinearColor(0, 0, 1, 1), Duration, 2)
  UE4.UKismetSystemLibrary.Abs_DrawDebugLine(UE4Helper.GetCurrentWorld(), self.c0, self.p0, UE4.FLinearColor(0, 1, 0, 1), Duration, 2)
  UE4.UKismetSystemLibrary.Abs_DrawDebugLine(UE4Helper.GetCurrentWorld(), self.c1, self.p1, UE4.FLinearColor(0, 1, 0, 1), Duration, 2)
  local lastP = self.p0
  for _ = 1, self.totalT - 1 do
    local t = _ / (self.totalT - 1.0)
    local u = 1 - t
    local w1 = u * u * u
    local w2 = 3 * u * u * t
    local w3 = 3 * u * t * t
    local w4 = t * t * t
    local t1 = UE4.UKismetMathLibrary.Add_VectorVector(UE4.UKismetMathLibrary.Multiply_VectorFloat(self.p0, w1), UE4.UKismetMathLibrary.Multiply_VectorFloat(self.c0, w2))
    local t2 = UE4.UKismetMathLibrary.Add_VectorVector(UE4.UKismetMathLibrary.Multiply_VectorFloat(self.c1, w3), UE4.UKismetMathLibrary.Multiply_VectorFloat(self.p1, w4))
    local c = UE4.UKismetMathLibrary.Add_VectorVector(t1, t2)
    UE4.UKismetSystemLibrary.Abs_DrawDebugLine(UE4Helper.GetCurrentWorld(), lastP, c, UE4.FLinearColor(0, 0, 1, 1), Duration, 2)
    lastP = c
  end
end

function BezierFlyComponent:AbortFly()
  self.callback = nil
  self.caller = nil
  self:FinishFly(AIDefines.ActionResult.Aborted)
end

function BezierFlyComponent:FinishFly(result, FinalPos, StartCompensating)
  result = result or AIDefines.ActionResult.Success
  if USE_PATH_COMP then
    if result == AIDefines.ActionResult.Aborted then
      local FlowComp = self:GetMultiPosFlowComponent()
      if FlowComp then
        if FinalPos then
          FlowComp:AbortFollowing(FinalPos, StartCompensating)
        else
          FlowComp:AbortFollowing()
        end
      end
    end
  else
    self:SetTickable(false)
  end
  self.FlowRequestId = 0
  self:ResetModelFlyProperty()
  self.state = AIDefines.ActionState.Idle
  if self.callback then
    local callback = self.callback
    local caller = self.caller
    self.callback = nil
    self.caller = nil
    callback(caller, result)
  end
  if (result == AIDefines.ActionResult.Success or result == AIDefines.ActionResult.Aborted) and self.state == AIDefines.ActionState.Idle then
    self:PostFlySettings()
  end
end

function BezierFlyComponent:SetTickable(enable)
  if enable ~= self.enableTick then
    if enable then
      _G.UpdateManager:Register(self, true)
    else
      _G.UpdateManager:UnRegister(self)
    end
    self.enableTick = enable
  end
end

function BezierFlyComponent:ContinuousFly(enable)
  self.disablePostFlySetting = true
end

function BezierFlyComponent:GenCircularPos(Radius, VaryingRadius, MaxCircularHeight, ResetCenter, caller, callback)
  self.VaryingRadiusVal = VaryingRadius
  self.RadiusVal = Radius
  if self.CircularPlot ~= nil then
    if ResetCenter or not self.CircularPlot.bSeachSuccess then
      self.CircularPlot:Abs_K2_SetActorLocation_WithoutHit(self.owner:GetActorLocation(), false)
      self.CircularPlot:SetSizeAndGenerate(Radius + VaryingRadius, VaryingRadius, MaxCircularHeight, self.owner:GetActorLocation(), caller, callback)
    else
      callback(caller, self.CircularPlot:Abs_K2_GetActorLocation())
      return
    end
  elseif not self.CircularPlotReq then
    self.cpParam = {
      Radius = Radius,
      VaryingRadius = VaryingRadius,
      MaxCircularHeight = MaxCircularHeight,
      caller = caller,
      callback = callback
    }
    self.CircularPlotReq = NRCResourceManager:LoadResAsync(self, "Blueprint'/Game/NewRoco/Modules/AI/Tools/BP_BezCircularPlot.BP_BezCircularPlot_C'", PriorityEnum.Passive_World_AI_FlyRes, 0, self.LoadPlotSucc, self.LoadPlotFailed)
  else
    callback(caller, self.owner:GetActorLocation())
  end
end

function BezierFlyComponent:LoadPlotSucc(req, plotClass)
  if not self.cpParam then
    Log.Error("[BezComp] Fly Param was loss since loading Plot BP")
    return
  end
  self.CircularPlot = UE4Helper.GetCurrentWorld():Abs_SpawnActor(plotClass, self.owner.viewObj:Abs_GetTransform())
  self.CircularPlotRef = UnLua.Ref(self.CircularPlot)
  self.CircularPlot:SetSizeAndGenerate(self.cpParam.Radius + self.cpParam.VaryingRadius, self.cpParam.VaryingRadius, self.cpParam.MaxCircularHeight, self.owner:GetActorLocation(), self.cpParam.caller, self.cpParam.callback)
  self.cpParam = nil
end

function BezierFlyComponent:LoadPlotFailed()
  if not self.cpParam then
    Log.Error("[BezComp] Fly Param was loss, btw load plot failed")
    return
  end
  self.cpParam.callback(self.cpParam.caller, self.owner:GetActorLocation())
  self.CircularPlotReq = nil
end

function BezierFlyComponent:ClearCircularDelegate()
  if self.CircularPlot then
    self.CircularPlot:ClearDelegate()
  end
end

function BezierFlyComponent:ClearCircularPlot()
  if self.CircularPlot then
    if UE.UObject.IsValid(self.CircularPlot) then
      self.CircularPlot:K2_DestroyActor()
    end
    self.CircularPlot = nil
  end
  self.CircularPlotRef = nil
  if self.CircularPlotReq then
    NRCResourceManager:UnLoadRes(self.CircularPlotReq)
    self.CircularPlotReq = nil
  end
  self.cpParam = nil
end

function BezierFlyComponent:IsCircularSuccess()
  if self.CircularPlot then
    return self.CircularPlot.bSeachSuccess
  end
  return false
end

function BezierFlyComponent:GetCircularRadiusScale()
  if self.CircularPlot then
    return self.CircularPlot.ScaleRatio
  end
  return 1
end

function BezierFlyComponent:GetMultiPosFlowComponent()
  if not self.owner or self.owner.isDestroy then
    return nil
  end
  local AIComp = self.owner.AIComponent
  local AIController = AIComp and AIComp.AIController
  if AIController and UE4.UObject.IsValid(AIController) then
    return AIController.MultiposFlowComponent or nil
  end
  return nil
end

function BezierFlyComponent:OnFlowEnd(result, requestId)
  if self.state ~= AIDefines.ActionState.Idle and requestId >= self.FlowRequestId then
    if result == UE.EPathFollowingResult.Success then
      self:FinishFly(AIDefines.ActionResult.Success)
    else
      self:FinishFly(AIDefines.ActionResult.Failed)
    end
  end
end

return BezierFlyComponent
