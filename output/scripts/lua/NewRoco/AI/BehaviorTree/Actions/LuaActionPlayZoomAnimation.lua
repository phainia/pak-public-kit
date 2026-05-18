local HangingComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.HangingComponent")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionPlayZoomAnimation = Base:Extend("LuaActionPlayZoomAnimation")

function LuaActionPlayZoomAnimation:OnStart(AIController, ...)
  local owner = AIController
  self.owner = owner
  local hangingComp = owner.Npc:EnsureComponent(HangingComponent)
  local AnimName = self.AnimName:GetValue(owner)
  local LoopAnimName = self.LoopAnimName:GetValue(owner)
  local Target = self.Target:GetValue(owner)
  local From = owner.Npc:GetActorLocation()
  local AttachToTop = self.AttachToTop:GetValue(owner)
  local PlayRate = self.PlayRate:GetValue(owner)
  local BlendIn = self.BlendIn:GetValue(owner)
  local BlendOut = self.BlendOut:GetValue(owner)
  local DecreasingCurve = self.DecreasingCurve:GetValue(owner)
  if AttachToTop > 0 then
    local offsetZ = hangingComp:GetHangingSocketOffsetZ()
    if AttachToTop < 20 then
      Target.Z = Target.Z - offsetZ
    else
      Target.Z = Target.Z - offsetZ
    end
  elseif AttachToTop < 0 then
    local Hit, success = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(owner.Npc.viewObj, Target, Target - UE.FVector(0, 0, 200), UE4.ETraceTypeQuery.TraceTypeQuery_MAX, false, owner.Npc.viewObj)
    if success then
      Target.Z = Hit.ImpactPoint.Z + owner.Npc:GetScaledHalfHeight()
    end
  end
  self.UpdateMovementMode(owner.Npc, DecreasingCurve)
  local result = hangingComp:RequestDirectLerpMoving(AnimName, From, Target, PlayRate, BlendIn, BlendOut, DecreasingCurve, LoopAnimName)
  if not result then
    return self:Finish(false)
  end
  self.callbackHandle = hangingComp:BindDelegate(self, self.MoveEnd)
end

function LuaActionPlayZoomAnimation:OnInterrupt(AIController, Finalize)
  local owner = AIController
  local hangingComp = owner.Npc:GetComponent(HangingComponent)
  local handle = self.callbackHandle
  self.callbackHandle = nil
  if hangingComp then
    hangingComp:RemoveDelegate(handle)
    if not Finalize then
      hangingComp:Abort()
    end
  end
  self.owner = nil
end

function LuaActionPlayZoomAnimation:MoveEnd(IsAnimEnd)
  if self.owner then
    local hangingComp = self.owner.Npc:EnsureComponent(HangingComponent)
    hangingComp:RemoveDelegate(self.callbackHandle)
  end
  self.callbackHandle = nil
  self.owner = nil
  self:Finish(IsAnimEnd)
end

function LuaActionPlayZoomAnimation.UpdateMovementMode(npc, DecreasingCurve)
  local char = npc.viewObj
  local moveComp = char.GetMovementComponent and char:GetMovementComponent() or nil
  if moveComp then
    if DecreasingCurve then
      moveComp:SetMovementMode(UE.EMovementMode.MOVE_Falling, UE.ERocoCustomMovementMode.MOVE_N)
    else
      moveComp:SetMovementMode(UE.EMovementMode.MOVE_Custom, UE.ERocoCustomMovementMode.MOVE_N)
    end
  end
end

return LuaActionPlayZoomAnimation
