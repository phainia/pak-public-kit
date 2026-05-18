local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionMoveTo = Base:Extend("LuaActionMoveTo")

function LuaActionMoveTo:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  self.controller = owner
  if not self.Target then
    Log.Error("LuaActionMoveTo Error " .. owner.Npc.config.behavior_tree)
    return
  end
  local targetType = self.Target:GetType()
  local targetActor, targetPoint
  if targetType == LuaParamType.Object then
    local targetObj
    targetObj = self.Target:GetValue(owner)
    if targetObj then
      targetActor = targetObj.viewObj
    else
      Log.Warning("LuaActionMoveTo: Invalid Object! " .. self.Target.key)
      Log.Debug("\230\156\170\232\131\189\230\137\190\229\136\176\231\155\174\230\160\135\229\175\185\232\177\161\239\188\140\232\175\183\230\163\128\230\159\165\232\161\140\228\184\186\230\160\145\233\133\141\231\189\174")
      self:Finish(true)
      return
    end
  elseif targetType == LuaParamType.Vector then
    targetPoint = self.Target:GetValue(owner)
  else
    Log.Error("UnSupported MoveTo Target Param Type")
    self:Finish(true)
    return
  end
  if not targetActor then
    local navPoint = UE4.UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(owner:GetWorld(), targetPoint)
    if not navPoint then
      local HitLocation, HitResult = UE4.UNavigationSystemV1.Abs_NavigationRaycast(owner.Npc.viewObj, owner.Npc:GetActorLocation(), targetPoint)
      if HitResult then
        targetPoint = HitLocation
      end
    else
      targetPoint = navPoint
    end
  end
  local nonBlock = self.NonBlock:GetValue(owner)
  local speed = self.Speed:GetValue(owner)
  if speed and speed > 0 then
    owner.Npc:SetSpeed(speed)
  end
  if nonBlock then
    if targetActor then
      UE4.UAIBlueprintHelperLibrary.SimpleMoveToActor(owner.Npc.viewObj:GetController(), targetActor)
    else
      UE4.UAIBlueprintHelperLibrary.SimpleMoveToLocation(owner.Npc.viewObj:GetController(), targetPoint)
    end
    if GlobalConfig.DebugLuaBTree then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), targetPoint, 100, 10, UE4.FLinearColor(1, 1, 0, 1), 0.2, 2)
    end
    self:Finish(true)
    return
  end
  if self.moveToProxyObj then
    self.moveToProxyObj = nil
  end
  if targetActor then
    self.moveToProxyObj = UE4.UAIBlueprintHelperLibrary.CreateMoveToProxyObject(UE4Helper.GetCurrentWorld(), owner:K2_GetPawn(), targetPoint, targetActor)
  else
    self.moveToProxyObj = UE4.UAIBlueprintHelperLibrary.CreateMoveToProxyObject(UE4Helper.GetCurrentWorld(), owner:K2_GetPawn(), targetPoint)
  end
  if GlobalConfig.DebugLuaBTree then
    self.targetPoint = targetPoint
  end
  owner:AddDelegateListener(self.moveToProxyObj.OnSuccess, self, self.OnSuccess)
  owner:AddDelegateListener(self.moveToProxyObj.OnFail, self, self.OnFail)
end

function LuaActionMoveTo:OnUpdate(AIController, DeltaTime)
  if GlobalConfig.DebugLuaBTree and self.targetPoint then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), self.targetPoint, 100, 10, UE4.FLinearColor(1, 1, 0, 1), 0.1, 2)
  end
end

function LuaActionMoveTo:OnSuccess(MovementResult)
  if self.moveToProxyObj then
    self.controller:RemoveDelegateListener(self.moveToProxyObj.OnSuccess, self.onSuccess)
    self.controller:RemoveDelegateListener(self.moveToProxyObj.OnFail, self.onFail)
    self.moveToProxyObj:Release()
    self.moveToProxyObj = nil
    self.controller = nil
  end
  self:Finish(true)
end

function LuaActionMoveTo:OnFail(MovementResult)
  if self.moveToProxyObj then
    self.controller:RemoveDelegateListener(self.moveToProxyObj.OnSuccess, self.onSuccess)
    self.controller:RemoveDelegateListener(self.moveToProxyObj.OnFail, self.onFail)
    self.moveToProxyObj:Release()
    self.moveToProxyObj = nil
    self.controller = nil
  end
  self:Finish(false)
end

function LuaActionMoveTo:OnInterrupt(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  owner:StopMovement()
  self:OnFail(nil)
end

return LuaActionMoveTo
