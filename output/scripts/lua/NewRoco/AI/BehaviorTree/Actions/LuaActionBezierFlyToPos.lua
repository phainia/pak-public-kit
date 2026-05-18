local BezierFlyComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.BezierFlyComponent")
local AIDefines = require("NewRoco.AI.AIDefines")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionBezierFlyToPos = Base:Extend("LuaActionBezierFly")

function LuaActionBezierFlyToPos:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local anchorPos = self.AnchorPos:GetValue(owner)
  local ctrl1LengthFactor = self.Ctrl1LengthFactor:GetValue(owner)
  local ctrl2Pitch = self.Ctrl2Pitch:GetValue(owner)
  local ctrl2Rotate = self.Ctrl2Rotate:GetValue(owner)
  local ctrl2LengthFactor = self.Ctrl2LengthFactor:GetValue(owner)
  local selfPos = owner.Npc:GetActorLocation()
  local selfFwd = owner.Npc:GetForwardVector()
  local anchorDistance = UE4.UKismetMathLibrary.Vector_Distance(selfPos, anchorPos)
  local anchorDir = anchorPos - selfPos
  local ctrl1Pos = UE4.UKismetMathLibrary.Add_VectorVector(selfFwd * (anchorDistance * ctrl1LengthFactor), selfPos)
  local _ctrl2Fwd = UE4.UKismetMathLibrary.Multiply_VectorFloat(anchorDir, -1)
  _ctrl2Fwd.Z = 0
  _ctrl2Fwd:Normalize()
  local _ctrl2Up = UE4.FVector(0, 0, 1)
  local _ctrl2Rgt = _ctrl2Fwd:RotateAngleAxis(90, _G.UE4Helper.UpVector)
  _ctrl2Fwd = _ctrl2Fwd:RotateAngleAxis(ctrl2Pitch, _ctrl2Rgt)
  _ctrl2Up = _ctrl2Up:RotateAngleAxis(ctrl2Pitch, _ctrl2Rgt)
  local ctrl2Dir = _ctrl2Fwd:RotateAngleAxis(ctrl2Rotate, _ctrl2Up)
  ctrl2Dir:Normalize()
  local ctrl2Pos = UE4.UKismetMathLibrary.Add_VectorVector(ctrl2Dir * (anchorDistance * ctrl2LengthFactor), anchorPos)
  local continuous = self.ContinuousFly and self.ContinuousFly:GetValue(owner) or false
  if continuous then
    owner.Npc:Stop()
  end
  local bezComp = owner.Npc:EnsureComponent(BezierFlyComponent)
  if not bezComp then
    return self:Finish(false)
  end
  bezComp:ContinuousFly(continuous)
  if self.d_Timeout then
    DelayManager:CancelDelayById(self.d_Timeout)
  end
  self.d_Timeout = DelayManager:DelaySeconds(10, self.OnTimeOut, self, owner.Npc)
  selfPos.Z = selfPos.Z - owner.Npc:GetHalfHeight()
  bezComp:StartFly(selfFwd, selfPos, ctrl1Pos, ctrl2Pos, anchorPos, 20, self, self.FlyEnd)
end

function LuaActionBezierFlyToPos:FlyEnd(result)
  if self.d_Timeout then
    DelayManager:CancelDelayById(self.d_Timeout)
  end
  if AIDefines.ActionResult.Ok(result) then
    self:Finish(true)
  else
    self:Finish(false)
  end
end

function LuaActionBezierFlyToPos:OnInterrupt(AIController, ...)
  local owner = AIController
  local bezComp = owner.Npc.BezierFlyComponent
  if not bezComp then
    return
  end
  if self.ContinuousFly and self.ContinuousFly:GetValue(owner) then
  else
    bezComp:ContinuousFly(false)
  end
  if self.d_Timeout then
    DelayManager:CancelDelayById(self.d_Timeout)
  end
  bezComp:AbortFly()
end

function LuaActionBezierFlyToPos:OnTimeOut(npc)
  self.d_Timeout = nil
  if npc and not npc.isDestroy and npc.BezierFlyComponent then
    npc.BezierFlyComponent:AbortFly()
  end
  self:Finish(false)
end

return LuaActionBezierFlyToPos
