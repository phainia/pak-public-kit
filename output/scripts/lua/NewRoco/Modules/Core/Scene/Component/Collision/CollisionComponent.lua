local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Delegate = require("Utils.Delegate")
local Base = ActorComponent
local CollisionProxy = Class("CollisionProxy")

function CollisionProxy:Ctor(owner)
  Base.Ctor(self)
  self.owner = owner
  self.delegate = Delegate()
  self.params = {}
  self.cacheActor = {}
  self.cacheResult = {}
  self.lastInvokeTime = nil
end

function CollisionProxy:SetDelegateData(caller, callback, params)
  self.delegate:Add(caller, callback)
  self.params = params
end

function CollisionProxy:StoreCollisionData(selfComp, otherActor, result)
  result = self.owner:CalcAccurateHitResult(selfComp, otherActor)
  if not result then
    return
  end
  if not table.contains(self.cacheActor, otherActor) then
    table.insert(self.cacheActor, otherActor)
  end
  if not table.contains(self.cacheResult, otherActor) then
    table.insert(self.cacheResult, result)
  end
end

function CollisionProxy:RemoveCollisionData(idx)
  if actorIdx ~= nil then
    table.removeKey(self.cacheActor, idx)
    table.removeKey(self.cacheResult, idx)
  end
end

function CollisionProxy:ClearData()
  self.params = {}
  self.cacheActor = {}
  self.cacheResult = {}
end

local CollisionComponent = Base:Extend("CollisionComponent")

function CollisionComponent:Ctor()
  Base.Ctor(self)
  self.hitProxy = CollisionProxy(self)
  self.beginOverlapProxy = CollisionProxy(self)
  self.endOverlapProxy = CollisionProxy(self)
end

function CollisionComponent:BindViewObject(primitiveComp)
  if not primitiveComp:IsA(UE.UPrimitiveComponent) then
    return
  end
  self.viewObj = primitiveComp
  self.viewObj:SetCollisionEnabled(UE.ECollisionEnabled.QueryOnly)
end

function CollisionComponent:SetModule(module)
  self.module = module
end

function CollisionComponent:Update(deltaTime)
  if not self.viewObj or not UE4.UObject.IsValid(self.viewObj) then
    self:ClearCacheCollisionInfo()
    self.module:RemoveCollisionComp(self)
    return
  end
  self.lastComponentPos = self.viewObj:Abs_K2_GetComponentLocation()
  if #self.beginOverlapProxy.cacheActor <= 0 then
    return
  end
  if self.beginOverlapProxy.lastInvokeTime ~= nil and os.time() <= self.beginOverlapProxy.lastInvokeTime + self.eventCD then
    return
  end
  self.beginOverlapProxy.lastInvokeTime = os.time()
  if not self.viewObj then
    return
  end
  for idx, actor in pairs(self.beginOverlapProxy.cacheActor) do
    self.beginOverlapProxy.delegate:Invoke(actor, self.beginOverlapProxy.cacheResult[idx], self.lastHitDir, table.unpack(self.beginOverlapProxy.params))
    if UE4.UObject.IsValid(self.viewObj) and actor ~= self.viewObj:GetOwner() then
      self.beginOverlapProxy:ClearData()
    end
  end
end

function CollisionComponent:ClearCacheCollisionInfo()
  if UE.UObject.IsValid(self.viewObj) then
    self.viewObj:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
  end
  self.viewObj = nil
  self.hitProxy:ClearData()
  self.beginOverlapProxy:ClearData()
  self.endOverlapProxy:ClearData()
end

function CollisionComponent:BindCollisionEvent(caller, eventType, callBack, eventCD, isMelee, ...)
  if type(callBack) ~= "function" then
    return
  end
  if eventType == UE.ECollisionListenType.BeginOverlap or eventType == UE.ECollisionListenType.EndOverLap then
    self.viewObj:SetGenerateOverlapEvents(true)
  end
  self.eventType = eventType
  self.eventCD = eventCD
  self.isMelee = isMelee
  if eventType == Enum.CollisionEventType.ON_COMPONENT_HIT then
    self.hitProxy:SetDelegateData(caller, callBack, {
      ...
    })
    self.viewObj.OnComponentHit:Add(self.owner.viewObj, self.OnComponentHit)
  end
  if eventType == Enum.CollisionEventType.ON_COMPONENT_BEGINOVERLAP then
    self.beginOverlapProxy:SetDelegateData(caller, callBack, {
      ...
    })
    self.viewObj.OnComponentBeginOverlap:Add(self.owner.viewObj, self.OnComponentBeginOverlap)
  end
  if eventType == Enum.CollisionEventType.ON_COMPONENT_ENDOVERLAP then
    self.endOverlapProxy:SetDelegateData(caller, callBack, {
      ...
    })
    self.viewObj.OnComponentEndOverlap:Add(self.owner.viewObj, self.OnComponentEndOverlap)
  end
  if self.viewObj and UE.UObject.IsValid(self.viewObj) then
    UE.UNRCStatics.ApplyPrimitiveComponentSweep(self.viewObj, _G.FVectorZero)
  end
end

function CollisionComponent:OnComponentHit(selfComp, otherActor, otherComp, impluse, result)
  self = self.sceneCharacter:GetCollisionCompByUComp(selfComp)
  if not self then
    return
  end
  if self.eventType ~= Enum.CollisionEventType.ON_COMPONENT_HIT and self.isMelee then
    return
  end
  if self.isMelee then
    self.hitProxy.delegate:Invoke(otherActor, result, self.lastHitDir or selfComp:GetOwner():GetActorForwardVector(), table.unpack(self.hitProxy.params))
  else
    self.beginOverlapProxy.delegate:Invoke(otherActor, result, self.lastHitDir or selfComp:GetOwner():GetActorForwardVector(), table.unpack(self.hitProxy.params))
  end
end

function CollisionComponent:OnComponentBeginOverlap(selfComp, otherActor, otherComp, otherBodyIndex, bFromSweep, result)
  self = self.sceneCharacter:GetCollisionCompByUComp(selfComp)
  if not self then
    return
  end
  if self.eventType ~= Enum.CollisionEventType.ON_COMPONENT_BEGINOVERLAP then
    return
  end
  if #self.beginOverlapProxy.params > 0 and self.beginOverlapProxy.params[1].FanAngle and self.beginOverlapProxy.params[1].FanAngle > 0 and not self:CheckTargetInAngle(selfComp:GetOwner().sceneCharacter, otherActor.sceneCharacter, self.beginOverlapProxy.params[1].FanAngle) then
    return
  end
  self.beginOverlapProxy:StoreCollisionData(selfComp, otherActor, result)
end

function CollisionComponent:OnComponentEndOverlap(selfComp, otherActor, otherComp, otherBodyIndex)
  self = self.sceneCharacter:GetCollisionCompByUComp(selfComp)
  self.endOverlapProxy.delegate:Invoke(selfComp, otherActor, otherComp, otherBodyIndex, table.unpack(self.endOverlapParams))
  local actorIdx = table.indexOf(self.beginOverlapProxy.cacheActor, otherActor, true)
  if nil ~= actorIdx then
    self.beginOverlapProxy:RemoveCollisionData(actorIdx)
  end
end

function CollisionComponent:CancelComponentCollisionListen()
  self.viewObj.OnComponentHit:Remove(self.owner.viewObj, self.OnComponentHit)
  self.viewObj.OnComponentBeginOverlap:Remove(self.owner.viewObj, self.OnComponentBeginOverlap)
  self.viewObj.OnComponentEndOverlap:Remove(self.owner.viewObj, self.OnComponentEndOverlap)
  self.viewObj:SetGenerateOverlapEvents(false)
end

function CollisionComponent:CancelAllComponentCollisionListen()
  self.viewObj.OnComponentHit:Clear()
  self.viewObj.OnComponentBeginOverlap:Clear()
  self.viewObj.OnComponentEndOverlap:Clear()
end

function CollisionComponent:DeAttach()
  Base.DeAttach(self)
  self:CancelComponentCollisionListen()
end

function CollisionComponent:CalcAccurateHitResult(selfComp, otherActor)
  local hitResult = UE.FHitResult()
  local traceStart = selfComp:Abs_K2_GetComponentLocation()
  local traceRotator = selfComp:K2_GetComponentRotation()
  self.lastHitDir = UE.UKismetMathLibrary.Normal(traceStart - (self.lastComponentPos or _G.FVectorZero), 0.01)
  local traceEnd = traceStart + self.lastHitDir * 100
  if selfComp:IsA(UE.USphereComponent) then
    local radius = selfComp:GetScaledSphereRadius()
    UE.UKismetSystemLibrary.Abs_SphereTraceSingleForObjects(UE4Helper.GetCurrentWorld() or selfComp:GetOwner():GetWorld(), traceStart, traceEnd, radius, {
      UE.EObjectTypeQuery.Hited
    }, true, nil, UE.EDrawDebugTrace.None, hitResult, true)
  elseif selfComp:IsA(UE.UBoxComponent) then
    local halfSize = selfComp:GetScaledBoxExtent()
    UE.UKismetSystemLibrary.Abs_BoxTraceSingleForObjects(UE4Helper.GetCurrentWorld() or selfComp:GetOwner():GetWorld(), traceStart, traceEnd, halfSize, traceRotator, {
      UE.EObjectTypeQuery.Hited
    }, true, nil, UE.EDrawDebugTrace.None, hitResult, true)
  elseif selfComp:IsA(UE.UCapsuleComponent) then
    local radius, halfHeight = selfComp:GetScaledCapsuleSize()
    UE.UKismetSystemLibrary.Abs_CapsuleTraceSingleForObjects(UE4Helper.GetCurrentWorld() or selfComp:GetOwner():GetWorld(), traceStart, traceEnd, radius, halfHeight, {
      UE.EObjectTypeQuery.Hited
    }, true, nil, UE.EDrawDebugTrace.None, hitResult, true)
  else
    local origin = UE.FVector(0, 0, 0)
    local extend = UE.FVector(0, 0, 0)
    selfComp:GetOwner():GetActorBounds(true, origin, extend, false)
    UE.UKismetSystemLibrary.Abs_CapsuleTraceSingleForObjects(UE4Helper.GetCurrentWorld() or selfComp:GetOwner():GetWorld(), traceStart, traceEnd, extend.X, extend.Z, {
      UE.EObjectTypeQuery.Hited
    }, true, nil, UE.EDrawDebugTrace.None, hitResult, true)
  end
  if otherActor ~= hitResult.Actor then
    return
  end
  if hitResult == UE.FHitResult() then
    hitResult = nil
  end
  return hitResult
end

function CollisionComponent:CheckTargetInAngle(caster, target, angle)
  if not caster or not target then
    return false
  end
  local casterForward = UE.UKismetMathLibrary.Conv_RotatorToVector(caster:GetActorRotation())
  local innerAngle = LuaMathUtils.AngleBetweenVectors(casterForward, target:GetActorLocation() - caster:GetActorLocation())
  if innerAngle <= angle / 2.0 then
    return true
  else
    return false
  end
end

return CollisionComponent
