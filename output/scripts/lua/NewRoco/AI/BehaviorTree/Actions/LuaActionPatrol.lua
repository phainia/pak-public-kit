local NavigationDefines = require("NewRoco.AI.Navigation.NavigationDefines")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local LuaActionPatrol = Base:Extend("LuaActionPatrol")

function LuaActionPatrol:OnStart(AIController, ...)
  local owner = AIController
  local ownerNpc = owner.Npc
  local maxStepRange = self.MaxPatrolDis:GetValue(owner)
  local navFlag, navId = owner.Npc.AIComponent:GetNavPolyFlag()
  if 0 ~= navFlag & NavigationDefines.Area.SafeArea then
    self.d_PatrolFailed = DelayManager:DelayFrames(2, function(self)
      self.d_PatrolFailed = nil
      self:Finish(false)
    end, self)
    return
  end
  self.controller = owner
  self.maxTime = 0
  local area = ownerNpc:GetArea()
  local ownerPos = ownerNpc:GetActorLocation()
  local randomPos = ownerPos
  local bSucc = false
  local maxSearchTime = 5
  if area then
    repeat
      randomPos, bSucc = UE4.UNavigationSystemV1.Abs_K2_GetRandomReachablePointInRadius(owner, ownerPos, nil, maxStepRange, nil, UE4.UNRCNavFilter)
      maxSearchTime = maxSearchTime - 1
    until area:InnerContainsPoint(randomPos) or maxSearchTime <= 0
  end
  if nil == area or maxSearchTime <= 0 then
    if area then
      local pos = area._inRegion:GenerateRandomPoint()
      if 0 ~= pos:Size() then
        randomPos, bSucc = pos, true
        randomPos = UE4.UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(owner:GetWorld(), randomPos)
        if GlobalConfig.DebugLuaBTree then
          UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), randomPos, 100, 10, UE4.FLinearColor(0, 1, 0, 1), 5, 2)
        end
      end
    end
    if not bSucc then
      randomPos, bSucc = UE4.UNavigationSystemV1.Abs_K2_GetRandomReachablePointInRadius(owner, ownerPos, nil, maxStepRange, nil, UE4.UNRCNavFilter)
      if GlobalConfig.DebugLuaBTree then
        UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), randomPos, 100, 10, UE4.FLinearColor(1, 0, 0, 1), 5, 2)
      end
    end
  elseif GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), randomPos, 100, 10, UE4.FLinearColor(0, 0, 1, 1), 5, 2)
  end
  local speed = self.Speed:GetValue(owner) or 0
  if speed > 0 then
    owner.Npc:SetSpeed(speed)
  else
    speed = 100
  end
  if self.Movement then
    local MovementMode = self.Movement:GetValue(owner)
    local Model = owner.Npc.viewObj
    if Model and Model.CharacterMovement then
      Model.CharacterMovement:SetOverridenMoveAnim(MovementMode)
    end
  end
  local dir = ownerPos - randomPos
  self.maxTime = dir:Size() / speed + 5
  randomPos = SceneUtils.ConvertAbsoluteToRelative(randomPos)
  local AcceptRadius = self.AcceptRadius and self.AcceptRadius:GetValue(owner) or 5
  self.moveToProxyObj = UE4.UAIBlueprintHelperLibrary.CreateMoveToProxyObject(UE4Helper.GetCurrentWorld(), owner:K2_GetPawn(), randomPos, nil, AcceptRadius)
  self.onSuccess = owner:AddDelegateListener(self.moveToProxyObj.OnSuccess, self, self.OnSuccess)
  self.onFail = owner:AddDelegateListener(self.moveToProxyObj.OnFail, self, self.OnFail)
end

function LuaActionPatrol:OnUpdate(AIController, DeltaTime, ...)
  local owner = AIController
  if self.maxTime == nil then
    return
  end
  self.maxTime = self.maxTime - DeltaTime
  if self.maxTime < 0 then
    self:ClearNode()
    self:Finish(true)
  end
end

function LuaActionPatrol:ClearNode()
  if self.controller then
    if self.moveToProxyObj then
      self.controller:RemoveDelegateListener(self.moveToProxyObj.OnSuccess, self.onSuccess)
      self.controller:RemoveDelegateListener(self.moveToProxyObj.OnFail, self.onFail)
    end
    self.controller = nil
  end
  self.moveToProxyObj = nil
  self.onSuccess = nil
  self.onFail = nil
end

function LuaActionPatrol:OnSuccess(MovementResult)
  self:ClearNode()
  self:Finish(true)
end

function LuaActionPatrol:OnFail(MovementResult)
  self:ClearNode()
  self:Finish(false)
end

function LuaActionPatrol:OnInterrupt(AIController, ...)
  local owner = AIController
  owner:StopMovement()
  self:ClearNode()
  if self.d_PatrolFailed then
    DelayManager:CancelDelayById(self.d_PatrolFailed)
    self.d_PatrolFailed = nil
  end
end

return LuaActionPatrol
