local BezierFlyComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.BezierFlyComponent")
local AIDefines = require("NewRoco.AI.AIDefines")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionBezierFly = Base:Extend("LuaActionBezierFly")

function LuaActionBezierFly:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  self.owner = owner
  local anchorPitch = self.AnchorPitch:GetValue(owner)
  local anchorRotate = self.AnchorRotate:GetValue(owner)
  local anchorDistance = self.AnchorDistance:GetValue(owner)
  local ctrl1LengthFactor = self.Ctrl1LengthFactor:GetValue(owner)
  local ctrl2Pitch = self.Ctrl2Pitch:GetValue(owner)
  local ctrl2Rotate = self.Ctrl2Rotate:GetValue(owner)
  local ctrl2LengthFactor = self.Ctrl2LengthFactor:GetValue(owner)
  local selfPos = owner.Npc:GetActorLocation()
  local selfFwd = owner.Npc:GetForwardVector()
  local selfRgt = owner.Npc:GetRightVector()
  local selfUp = owner.Npc:GetUpVector()
  local _anchordirFwd = selfFwd:RotateAngleAxis(-anchorPitch, selfRgt)
  local _anchordirUp = selfUp:RotateAngleAxis(anchorPitch, selfRgt)
  local anchorDir = _anchordirFwd:RotateAngleAxis(anchorRotate, _anchordirUp)
  local anchorPos = UE4.UKismetMathLibrary.Add_VectorVector(anchorDir * anchorDistance, selfPos)
  local ctrl1Pos = UE4.UKismetMathLibrary.Add_VectorVector(selfFwd * (anchorDistance * ctrl1LengthFactor), selfPos)
  local _ctrl2Fwd = UE4.UKismetMathLibrary.Multiply_VectorFloat(anchorDir, -1)
  _ctrl2Fwd.Z = 0
  local _ctrl2Up = UE4.FVector(0, 0, 1)
  local _ctrl2Rgt = _ctrl2Fwd:RotateAngleAxis(90, UE4Helper.UpVector)
  _ctrl2Fwd = _ctrl2Fwd:RotateAngleAxis(ctrl2Pitch, _ctrl2Rgt)
  _ctrl2Up = _ctrl2Up:RotateAngleAxis(ctrl2Pitch, _ctrl2Rgt)
  local ctrl2Dir = _ctrl2Fwd:RotateAngleAxis(ctrl2Rotate, _ctrl2Up)
  ctrl2Dir:Normalize()
  local ctrl2Pos = UE4.UKismetMathLibrary.Add_VectorVector(ctrl2Dir * (anchorDistance * ctrl2LengthFactor), anchorPos)
  owner.Npc:Stop()
  local BezComp = owner.Npc:EnsureComponent(BezierFlyComponent)
  if not BezComp then
    return self:Finish(false)
  end
  BezComp:StartFly(selfFwd, selfPos, ctrl1Pos, ctrl2Pos, anchorPos, 20, self, self.FlyEnd)
end

function LuaActionBezierFly:FlyEnd(result)
  if AIDefines.ActionResult.Ok(result) then
    self:Finish(true)
  else
    self:Finish(false)
  end
end

function LuaActionBezierFly:OnInterrupt(AIController, ...)
  local owner = AIController
  local BezComp = owner.Npc.BezierFlyComponent
  if BezComp then
    BezComp:FinishFly(AIDefines.ActionResult.Aborted)
  end
end

return LuaActionBezierFly
