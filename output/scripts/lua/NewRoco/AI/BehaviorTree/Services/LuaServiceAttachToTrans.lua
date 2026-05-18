local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceAttachToTrans = Base:Extend("LuaServiceAttachToTrans")

function LuaServiceAttachToTrans:Ctor(LuaBTNodeBase)
  self.updateMoveTo = false
  self.curAttachPos = nil
  self.moveToSpeed = 0
end

function LuaServiceAttachToTrans:OnStart(OwnerController, Finalizing)
  if Finalizing then
    return
  end
  local owner = OwnerController
  local absPos = self.AttachPos:GetValue(owner)
  local Pos = UE4.UNRCStatics.AbsoluteToRelative(absPos)
  local RotV = self.AttachRot:GetValue(owner)
  local Rot = UE4.FRotator(RotV.X, RotV.Y, RotV.Z)
  local RotUp = Rot:GetUpVector()
  RotUp:Normalize()
  local AllowRotate = self.AllowRotate and self.AllowRotate:GetValue(owner) or false
  local PinToSurface = self.PinToSurface and self.PinToSurface:GetValue(owner) or false
  local RotationSpeed = self.RotationSpeed and self.RotationSpeed:GetValue(owner) or 360
  local OverrideAnimation = self.OverrideAnimation and self.OverrideAnimation:GetValue(owner) or nil
  local MoveSpeed = self.MoveSpeed and self.MoveSpeed:GetValue(owner) or 0
  self.moveToSpeed = MoveSpeed
  if PinToSurface then
    local _h = owner.Npc:GetScaledHalfHeight()
    local _r = owner.Npc:GetRadius()
    local fromOffset = RotUp * _h
    local traceStart = absPos
    local traceEnd = absPos - fromOffset * 4
    local Hit, success = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(owner.Npc.viewObj, traceStart, traceEnd, UE4.ETraceTypeQuery.TraceTypeQuery_MAX, true, {
      owner.Npc.viewObj
    })
    if GlobalConfig.DebugLuaBTree then
      UE4.UKismetSystemLibrary.Abs_DrawDebugLine(owner.Npc.viewObj, traceStart, traceEnd, UE4.FLinearColor(1, 0, 0), 100, 5)
    end
    if success then
      if Hit.bStartPenetrating then
        self:SetCurAttachPos(absPos)
      else
        local final = UE4.UKismetMathLibrary.Add_VectorVector(Hit.Location, fromOffset)
        self:SetCurAttachPos(final)
      end
    else
      self:SetCurAttachPos(absPos)
    end
  else
    self:SetCurAttachPos(absPos)
  end
  owner.Npc:SetNPCGravity(0)
  local Model = owner.Npc.viewObj
  if Model then
    if AllowRotate then
      Model:SetBpRotateRate(UE4.FRotator(RotationSpeed, RotationSpeed, RotationSpeed))
      Model:LerpToRotation(Rot)
    end
    local moveComp = Model:GetMovementComponent()
    moveComp:SetMovementMode(UE4.EMovementMode.MOVE_None)
  end
  if not string.IsNilOrEmpty(OverrideAnimation) then
    owner.Npc:PlayAnim(OverrideAnimation)
  end
end

function LuaServiceAttachToTrans:OnUpdateService(OwnerController, DeltaTime, ...)
  local owner = OwnerController
  if self.updateMoveTo then
    self:UpdateTransform(owner, DeltaTime)
  end
end

function LuaServiceAttachToTrans:OnEnd(OwnerController, Finalizing)
  if Finalizing then
    return
  end
  local owner = OwnerController
  owner.Npc:SetNPCGravity(1)
  local Model = owner.Npc.viewObj
  if Model then
    Model:LerpToRotation(UE4.FRotator(0, owner.Npc:GetActorRotation().Yaw, 0))
    local moveComp = Model:GetMovementComponent()
    moveComp:SetMovementMode(UE4.EMovementMode.MOVE_Falling)
  end
  local OverrideAnimation
  if self.OverrideAnimation then
    OverrideAnimation = self.OverrideAnimation:GetValue(owner)
  end
  if not string.IsNilOrEmpty(OverrideAnimation) then
    owner.Npc:StopAnim(OverrideAnimation)
  end
  self.curAttachPos = nil
end

function LuaServiceAttachToTrans:SetCurAttachPos(pos)
  if pos then
    self.curAttachPos = pos
    self.updateMoveTo = true
  end
end

function LuaServiceAttachToTrans:UpdateTransform(owner, DeltaTime)
  if not owner.Npc.viewObj then
    self.updateMoveTo = false
    return
  end
  if 0 == self.moveToSpeed and self.curAttachPos then
    owner.Npc.viewObj:Abs_K2_SetActorLocation_WithoutHit(self.curAttachPos, true, true)
    self.updateMoveTo = false
    return
  end
  local selfPos = owner.Npc:GetActorLocation()
  local dir = self.curAttachPos - selfPos
  local dist = dir:Size()
  if dist < 10 then
    self.updateMoveTo = false
    return
  end
  dir:Normalize()
  local ratio = math.min(dist, self.moveToSpeed)
  dir = dir * ratio
  local MoveComp = owner.Npc.viewObj:GetComponentByClass(UE.UCharacterNavMovementComponent)
  if MoveComp then
    MoveComp:LuaRequestDirectMove(dir, false)
  else
    dir = dir * DeltaTime + selfPos
    owner.Npc:SetActorLocation(dir)
  end
end

return LuaServiceAttachToTrans
