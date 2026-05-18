local MapRegionAreaUtil = require("NewRoco.Modules.Core.Scene.Map.MapRegionAreaUtil")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionPatrolByPointset = Base:Extend("LuaActionPatrolByPointset")

function LuaActionPatrolByPointset:OnStart(AIController, ...)
  self.interrupted = false
  self:ClearNode()
  local owner = AIController
  self.controller = owner
  local ownerNpc = owner.Npc
  local pointsetId = self.PointsetId:GetValue(owner)
  local startAtPosId = self.StartAtPosId:GetValue(owner)
  local speed = self.Speed:GetValue(owner)
  local isLoop = self.IsLoop:GetValue(owner)
  local isInverse = self.IsInverse:GetValue(owner)
  local AcceptRadius = self.AcceptRadius and self.AcceptRadius:GetValue(owner) or 100
  if 0 == AcceptRadius then
    AcceptRadius = 100
  end
  local areaConf = DataConfigManager:GetAreaConf(pointsetId, true)
  local nextPosId = startAtPosId
  local nextPos
  if areaConf then
    local areaTotalPointCount = #areaConf.pos
    local step = 1
    if isInverse then
      step = -1
    end
    if isLoop then
      nextPosId = (startAtPosId + step + areaTotalPointCount) % areaTotalPointCount
      if 0 == nextPosId then
        nextPosId = areaTotalPointCount
      end
    else
      nextPosId = math.clamp(startAtPosId + step, 0, areaTotalPointCount + 1)
    end
    local _nextPos = areaConf.pos[nextPosId]
    if _nextPos then
      nextPos = UE4.FVector(_nextPos.position_xyz[1], _nextPos.position_xyz[2], _nextPos.position_xyz[3])
    end
  end
  if not nextPos then
    self:Finish(false)
    return
  end
  self.OutCurPosId:SetValue(owner, nextPosId)
  local projPoint, projResult = UE4.UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(owner:GetWorld(), nextPos)
  if not projResult then
    local HitLocation, HitResult = UE4.UNavigationSystemV1.Abs_NavigationRaycast(owner.Npc.viewObj, owner.Npc:GetActorLocation(), nextPos)
    if HitResult then
      nextPos = HitLocation
    end
  else
    nextPos = projPoint
  end
  if GlobalConfig.DebugLuaBTree and nextPos then
    Log.PrintScreenMsg("PatrolByPointSet: %s(npc_id=%d) \230\173\163\229\156\168\230\178\191\231\157\128 %d \231\154\132\231\172\172 %d \228\184\170\231\130\185\231\167\187\229\138\168", owner.Npc.config.name, owner.Npc.config.id, pointsetId, nextPosId)
    UE4.UKismetSystemLibrary.Abs_DrawDebugArrow(UE4Helper.GetCurrentWorld(), owner.Npc:GetActorLocation(), nextPos, 50, UE4.FLinearColor(1, 1, 0, 1), 60, 10)
  end
  if speed and speed > 0 then
    owner.Npc:SetSpeed(speed)
  end
  if self.Movement then
    local MovementMode = self.Movement:GetValue(owner)
    local Model = owner.Npc.viewObj
    if Model and Model.CharacterMovement then
      Model.CharacterMovement:SetOverridenMoveAnim(MovementMode)
    end
  end
  nextPos = SceneUtils.ConvertAbsoluteToRelative(nextPos)
  self.patrolProxyObj = UE4.UAIBlueprintHelperLibrary.CreateMoveToProxyObject(UE4Helper.GetCurrentWorld(), owner:K2_GetPawn(), nextPos, nil, AcceptRadius)
  self.patrolProxyObjRef = UnLua.Ref(self.patrolProxyObj)
  self.onSuccessHandle = owner:AddDelegateListener(self.patrolProxyObj.OnSuccess, self, self.OnSuccess)
  self.onFailHandle = owner:AddDelegateListener(self.patrolProxyObj.OnFail, self, self.OnFail)
end

function LuaActionPatrolByPointset:ClearNode()
  if self.patrolProxyObj then
    self.controller:RemoveDelegateListener(self.patrolProxyObj.OnSuccess, self.onSuccessHandle)
    self.controller:RemoveDelegateListener(self.patrolProxyObj.OnFail, self.onFailHandle)
    self.patrolProxyObj.OnSuccess:Clear()
    self.patrolProxyObj.OnFail:Clear()
    self.patrolProxyObj:Release()
    self.patrolProxyObj = nil
    self.controller = nil
  end
  self.patrolProxyObjRef = nil
end

function LuaActionPatrolByPointset:OnSuccess(MovementResult)
  self:ClearNode()
  if not self.interrupted then
    self:Finish(true)
  end
end

function LuaActionPatrolByPointset:OnFail(MovementResult)
  self:ClearNode()
  if not self.interrupted then
    self:Finish(false)
  end
end

function LuaActionPatrolByPointset:OnInterrupt(AIController, ...)
  self.interrupted = true
  local owner = AIController
  owner:StopMovement()
  self:OnFail(nil)
end

return LuaActionPatrolByPointset
