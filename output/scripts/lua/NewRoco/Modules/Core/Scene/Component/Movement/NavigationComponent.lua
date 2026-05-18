local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local Max_TimeOut = 5
local NavigationComponent = Base:Extend("NavigationComponent")

function NavigationComponent:Ctor()
  Base.Ctor(self)
  self:Cleanup()
end

function NavigationComponent:Cleanup()
  self.UnmountType = Enum.UnmountType.UT_NO
  self.EnableFixType = -1
  self.FixDistance = -1
  self.FixRotation = -1
  self.NavigationTime = -1
  self.statCurveID = -1
  self.statSpeedID = -1
  self.CallbackOwner = nil
  self.CallbackFunc = nil
  self.TargetActor = nil
  self.StopRideTimeoutHandler = -1
end

function NavigationComponent:Restore()
  if UE.UObject.IsValid(self.owner.viewObj) then
    local characterMovement = self.owner.viewObj.CharacterMovement
    if self.statCurveID > 0 then
      self.owner.statComponent:RemoveStat(StatType.MAX_WALK_SPEED_CURVE, self.statCurveID, characterMovement)
    end
    if self.statSpeedID > 0 then
      self.owner.statComponent:RemoveStat(StatType.MAX_WALK_SPEED, self.statSpeedID, characterMovement)
    end
  end
  self.owner:StopAnim("Walk", 0, "Locomotion")
end

function NavigationComponent:Attach(owner)
  Base.Attach(self, owner)
  self:SetEnable(false)
end

function NavigationComponent:OnReConnect()
  if not self.isLockPlayer then
    return
  end
  self:UnLockPlayerAndBattle()
end

function NavigationComponent:DeAttach()
  Base.DeAttach(self)
end

function NavigationComponent:Complete(Success)
  self:SetEnable(false)
  local CallbackOwner = self.CallbackOwner
  local CallbackFunc = self.CallbackFunc
  self:Restore()
  if self.TargetActor and self.TargetActor.viewObj then
    self.TargetActor.viewObj:OnNavInterFinish(Success)
  end
  self:Cleanup()
  self.owner:StopAnim("Walk", 0, "Locomotion")
  self.owner:ToggleRootMotion(true)
  if CallbackFunc then
    CallbackFunc(CallbackOwner, Success)
  end
end

function NavigationComponent:StartNavigate(UnmountType, EnableFixType, FixDistance, FixRotation, TargetActor, CallbackOwner, CallbackFunc)
  Log.Debug("NavigationComponent:StartNavigate")
  self.UnmountType = UnmountType
  self.EnableFixType = EnableFixType
  self.FixDistance = FixDistance
  self.FixRotation = FixRotation
  self.TargetActor = TargetActor
  self.CallbackFunc = CallbackFunc
  self.CallbackOwner = CallbackOwner
  local localPlayer = self.owner
  if not localPlayer then
    self:FixNavigation()
    return
  end
  if UnmountType == Enum.UnmountType.UT_NO then
    self:FixNavigation()
  else
    localPlayer:StopRide(nil, nil)
    self:FixNavigation()
  end
end

function NavigationComponent:OnStopRideTimeout()
  Log.Error("\232\176\131\231\148\168\231\142\169\229\174\182\232\186\171\228\184\138StopRide\230\142\165\229\143\163\231\154\1323\231\167\146\229\134\133\230\178\161\230\156\137\230\148\182\229\136\176\232\161\168\230\188\148\229\174\140\230\136\144\231\154\132\229\155\158\232\176\131\239\188\140\232\175\183\229\145\138\232\175\137sio")
  self:FixNavigation()
end

function NavigationComponent:FixNavigation()
  if self.StopRideTimeoutHandler > 0 then
    _G.DelayManager:CancelDelayById(self.StopRideTimeoutHandler)
    self.StopRideTimeoutHandler = -1
  end
  Log.Debug("NavigationComponent:FixNavigation")
  if self.FixDistance > 0 then
    local localPlayer = self.owner
    localPlayer:StopDash()
    self:LockPlayerAndBattle()
    local playerPos = localPlayer:GetActorLocation()
    local capsule = localPlayer.viewObj:K2_GetRootComponent()
    Log.Debug("Pre GetInterPos")
    local targetPos = self.TargetActor.viewObj:GetInterPos(playerPos, self.EnableFixType, self.FixDistance, self.FixRotation, capsule:GetScaledCapsuleRadius())
    if SceneUtils.debugInterNavTargetPoint then
      local debugStart = UE4.FVector(targetPos.X, targetPos.Y, targetPos.Z)
      local debugEnd = UE4.FVector(targetPos.X, targetPos.Y, targetPos.Z + 100)
      Log.Debug(debugStart.X, debugStart.Y, debugStart.Z)
      Log.Debug(debugEnd.X, debugEnd.Y, debugEnd.Z)
      UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), debugStart, debugEnd, UE4.FLinearColor(1, 0, 0, 1), 100)
    end
    local currentLocation = SceneUtils.GetPosInNearLand(playerPos) or playerPos
    local characterMovement = localPlayer.viewObj.CharacterMovement
    self.statCurveID = localPlayer.statComponent:ApplyStat(StatType.MAX_WALK_SPEED_CURVE, nil, nil, characterMovement)
    self.statSpeedID = localPlayer.statComponent:ApplyStat(StatType.MAX_WALK_SPEED, 300, nil, characterMovement)
    currentLocation = SceneUtils.ConvertAbsoluteToRelative(currentLocation)
    targetPos = SceneUtils.ConvertAbsoluteToRelative(targetPos)
    self.TargetActor.viewObj:PreNavInter()
    local Success = UE4.UNRCNavLibrary.MoveToLocationForce(localPlayer.viewObj, localPlayer:GetUEController(), currentLocation, targetPos, 20, SceneUtils.debugInterNavPathPoint, SceneUtils.debugInterNavPathForcePoint)
    if Success then
      localPlayer:ToggleRootMotion(false)
      localPlayer:PlayAnim("Walk", 1, 0, 0.25, 0.25, -1, 0, "Locomotion")
      self.NavigationTime = 0
      self:CheckNavigation()
    else
      Log.Warning("===amonsu=======NavigationComponent=======FixNavigation====", "MoveToLocationForce Is Failed!")
      UE4.UNRCNavLibrary.StopPathFollowingMove(localPlayer.viewObj, localPlayer:GetUEController())
      self:UnLockPlayerAndBattle()
      self:Complete(false)
    end
  else
    self:Complete(true)
  end
end

function NavigationComponent:CheckNavigation()
  local localPlayer = self.owner
  if not localPlayer then
    self:UnLockPlayerAndBattle()
    self:Complete(true)
    return
  end
  if UE4.UNRCNavLibrary.CheckIfPathFollowingIdle(localPlayer.viewObj, localPlayer:GetUEController()) then
    self:UnLockPlayerAndBattle()
    self:Complete(true)
  elseif self.NavigationTime > Max_TimeOut then
    Log.Debug("\229\175\188\232\136\170\232\182\133\230\151\182")
    UE4.UNRCNavLibrary.StopPathFollowingMove(localPlayer.viewObj, localPlayer:GetUEController())
    self:UnLockPlayerAndBattle()
    self:Complete(false)
  else
    self:SetEnable(true)
  end
end

function NavigationComponent:LockPlayerAndBattle()
  Log.Debug("NavigationComponent:LockPlayerAndBattle")
  self.isLockPlayer = true
  _G.GlobalConfig.DisableBattle = true
  self.owner.inputComponent:SetInputEnable(self, false, "Interaction")
end

function NavigationComponent:UnLockPlayerAndBattle()
  Log.Debug("NavigationComponent:UnLockPlayerAndBattle")
  self.isLockPlayer = false
  _G.GlobalConfig.DisableBattle = false
  self.owner.inputComponent:SetInputEnable(self, true, "Interaction")
end

function NavigationComponent:Update(deltaTime)
  if not self.enabled then
    return
  end
  self.NavigationTime = self.NavigationTime + deltaTime
  self:CheckNavigation()
end

function NavigationComponent:SetEnable(Value)
  Base.SetEnable(self, Value)
  Log.Debug("NavigationComponent:SetEnable", Value)
end

return NavigationComponent
