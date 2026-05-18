local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = ActorComponent
local HangingComponent = Base:Extend("HangingComponent")

function HangingComponent:PrepareNativeComponent()
  if not self.owner then
    return nil
  end
  local view = self.owner.viewObj
  if not view then
    return nil
  end
  local comp = view:GetComponentByClass(UE.UAnimDrivenMoveComponent)
  comp = comp or view:AddComponentByClass(UE.UAnimDrivenMoveComponent, false, UE4.FTransform(), false)
  return comp
end

function HangingComponent:Upward(target)
  local comp = self:PrepareNativeComponent()
  local selfPos = self.owner:GetActorLocation()
  comp:RequestDirectLerpMoving("HangingStart", selfPos, target, 1, 0.0, 0, false)
end

function HangingComponent:Downward(target)
  local comp = self:PrepareNativeComponent()
  local selfPos = self.owner:GetActorLocation()
  comp:RequestDirectLerpMoving("HangingEnd", selfPos, target, 1, 0.0, 0, true)
end

function HangingComponent:RequestDirectLerpMoving(animName, from, to, rate, blendInTime, blendOutTime, isDecreasingCurve, loopAnimName)
  local comp = self:PrepareNativeComponent()
  return comp:RequestDirectLerpMoving(animName, from, to, rate, blendInTime, blendOutTime, isDecreasingCurve, loopAnimName)
end

function HangingComponent:Abort()
  local comp = self:PrepareNativeComponent()
  if comp then
    comp:AbortLerpMoving()
  end
end

function HangingComponent:BindDelegate(caller, callback)
  local comp = self:PrepareNativeComponent()
  if comp and caller then
    local handle = _G.SimpleDelegateFactory:CreateCallback(caller, callback)
    comp.AnimDrivenMoveEndDelegate:Add(self.owner.viewObj, handle)
    return handle
  end
  return nil
end

function HangingComponent:RemoveDelegate(handle)
  local comp = self:PrepareNativeComponent()
  if comp and handle then
    comp.AnimDrivenMoveEndDelegate:Remove(self.owner.viewObj, handle)
  end
end

function HangingComponent:GetHangingSocketOffsetZ()
  local result = 0
  local mesh = SceneUtils.GetActorMesh(self.owner.viewObj)
  if mesh then
    local transform = mesh:GetSocketTransform("locator_hanging", UE4.ERelativeTransformSpace.RTS_Actor)
    result = transform.Translation.Z
  end
  return result
end

return HangingComponent
