local CollisionComponent = require("NewRoco.Modules.Core.Scene.Component.Collision.CollisionComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local CollisionData = Class("CollisionData")

function CollisionData:Ctor(rocoFxComp, spawnTransform, autoActive, delayStop)
  self.rocoFxComp = rocoFxComp
  self.spawnTransform = spawnTransform
  self.autoActive = autoActive
  self.delayStop = delayStop
end

local CollisionModule = NRCModuleBase:Extend("CollisionModule")

function CollisionModule:OnConstruct()
  _G.CollisionModuleCmd = reload("NewRoco.Modules.Core.Collision.CollisionModuleCmd")
  self.data = self:SetData("CollisionModuleData", "NewRoco.Modules.Core.Collision.CollisionModuleData")
  self.HitFxList = {}
  self.HitFxData = {}
  self.HitFxRefList = {}
  self.HitFxDelayStopTimerIds = {}
end

function CollisionModule:OnActive()
  UpdateManager:UnRegister(self)
end

function CollisionModule:GetCollisionComp(owner, viewObj)
  if owner.collisionComps == nil then
    owner.collisionComps = {}
  end
  local ucomp = owner:GetCollisionCompByUComp(viewObj)
  if ucomp then
    return
  end
  return self:GetNewCollisionComp(owner, viewObj)
end

function CollisionModule:GetNewCollisionComp(owner, viewObj)
  local collisionComp = CollisionComponent()
  collisionComp:Attach(owner)
  collisionComp:BindViewObject(viewObj)
  table.insert(owner.collisionComps, collisionComp)
  self:AddCollisionComp(collisionComp)
  return collisionComp
end

function CollisionModule:AddCollisionComp(collisionComp)
  if table.contains(self.data.collisionComps, collisionComp) then
    return
  end
  table.insert(self.data.collisionComps, collisionComp)
  collisionComp:SetModule(self)
  if 1 == #self.data.collisionComps then
    UpdateManager:Register(self)
  end
end

function CollisionModule:RemoveCollisionComp(collisionComp)
  if not table.contains(self.data.collisionComps, collisionComp) then
    return
  end
  table.removeValue(self.data.collisionComps, collisionComp)
  if 0 == #self.data.collisionComps then
    UpdateManager:UnRegister(self)
  end
end

function CollisionModule:RemoveAllCollisionComp(onlyMelee)
  for _, comp in pairs(self.data.collisionComps) do
    if not onlyMelee or onlyMelee and comp.isMelee then
      comp:CancelAllComponentCollisionListen()
      self:RemoveCollisionComp(comp)
      comp:ClearCacheCollisionInfo()
    end
  end
end

function CollisionModule:OnTick(DeltaTime)
  for _, collisionComp in pairs(self.data.collisionComps) do
    collisionComp:Update(DeltaTime)
  end
end

function CollisionModule:PlayHitFx(caster, victim, fxPath, hitPos, HitDir, fxScale, autoActive, delayStop)
  local fxPlayEntity = victim or caster
  Log.Debug("CollisionModule:PlayHitFx", caster, victim, fxPath, hitPos, HitDir, fxScale, autoActive, delayStop)
  if not (fxPlayEntity and fxPlayEntity.viewObj) or not fxPath then
    return
  end
  local rocoFxComp = fxPlayEntity.viewObj:GetComponentByClass(UE.URocoFXComponent)
  if not rocoFxComp and fxPlayEntity.caster then
    rocoFxComp = fxPlayEntity.caster.viewObj:GetComponentByClass(UE.URocoFXComponent)
    if not rocoFxComp then
      Log.Error("CollisionModule:PlayHitFx No rocoFxComp")
    end
    return
  end
  if not self.isDebug then
    hitPos = SceneUtils.ConvertAbsoluteToRelative(hitPos)
  end
  local spawnTransform = UE.UKismetMathLibrary.MakeTransform(hitPos, UE.UKismetMathLibrary.Conv_VectorToRotator(HitDir), UE.FVector(fxScale, fxScale, fxScale))
  local FxPath = fxPath
  if "" == FxPath then
    return
  end
  FxPath = _G.NRCUtils.FormatResPackageNameToFullPath(FxPath)
  local hitFx = self.HitFxList[FxPath]
  if not hitFx and not _G.NRCEventCenter:HasListener("CollisionModule", self, _G.NRCGlobalEvent.OnSkillResLoaded, self.OnResLoadedSuccess) then
    _G.NRCEventCenter:RegisterEvent("CollisionModule", self, _G.NRCGlobalEvent.OnSkillResLoaded, self.OnResLoadedSuccess)
  end
  if hitFx and rocoFxComp then
    Log.Debug("CollisionModule:PlayHitFxByAsset", hitFx, rocoFxComp, spawnTransform, autoActive, delayStop)
    self:PlayHitFxByAsset(hitFx, rocoFxComp, spawnTransform, autoActive, delayStop)
  end
  if not hitFx and self.isDebug then
    hitFx = UE.UKismetSystemLibrary.LoadAsset_Blocking(fxPath)
    if not hitFx then
      Log.Error("CollisionModule:PlayHitFx No hitFxRes")
      return
    end
    self.HitFxList[FxPath] = hitFx
    self:PlayHitFxByAsset(hitFx, rocoFxComp, spawnTransform, autoActive, delayStop)
  end
end

function CollisionModule:PlayHitFxByAsset(FxAsset, rocoFxComp, spawnTransform, autoActive, delayStop)
  if not UE.UObject.IsValid(rocoFxComp) or not rocoFxComp.PlayFx_Location then
    Log.Error("CollisionModule:PlayHitFxByAsset")
    return
  end
  Log.Debug("CollisionModule:PlayHitFxByAsset", FxAsset, spawnTransform, autoActive)
  local fxId = rocoFxComp:PlayFx_Location(FxAsset, spawnTransform, autoActive)
  if delayStop and delayStop > 0 then
    local fxStopTimerId = self.HitFxDelayStopTimerIds[fxId]
    if fxStopTimerId then
      _G.DelayManager:CancelDelayById(fxStopTimerId)
    end
    fxStopTimerId = _G.DelayManager:DelaySeconds(delayStop, self.OnStopFx, self, rocoFxComp, fxId)
    self.HitFxDelayStopTimerIds[fxId] = fxStopTimerId
  end
end

function CollisionModule:OnStopFx(rocoFxComp, fxId)
  if UE.UObject.IsValid(rocoFxComp) then
    rocoFxComp:StopFx(fxId)
  end
  _G.table.removeKey(self.HitFxDelayStopTimerIds, fxId)
end

function CollisionModule:OnResLoadedSuccess(req, asset)
  Log.Debug("CollisionModule:OnResLoadedSuccess", req, asset)
  if not asset then
    Log.Error("CollisionModule:OnResLoadedSuccess Not asset!!!")
    return
  end
  if req.assetPath then
    self.HitFxList[req.assetPath] = asset
  end
  local collisionData = self.HitFxData[req.sessionId]
  if not collisionData then
    Log.Debug("CollisionModule:OnResLoaded Not collisionData!!!")
    return
  end
  Log.Debug("CollisionModule:OnResLoaded", asset, collisionData.rocoFxComp, collisionData.spawnTransform, collisionData.autoActive, collisionData.delayStop)
  self:PlayHitFxByAsset(asset, collisionData.rocoFxComp, collisionData.spawnTransform, collisionData.autoActive, collisionData.delayStop)
end

function CollisionModule:OnResLoadedFailed(req, msg)
  Log.Error("CollisionModule:OnResLoadedFailed: ", msg, req.assetPath)
end

function CollisionModule:OnRelogin()
end

function CollisionModule:AddHitResCache(assetPath, asset)
  self.HitFxList[assetPath] = asset
  table.insert(self.HitFxRefList, UnLua.Ref(asset))
end

function CollisionModule:OnDeactive()
  self.HitFxList = {}
  self.HitFxRefList = {}
  self.HitFxData = {}
  self:RemoveAllCollisionComp()
  for _, timerId in pairs(self.HitFxDelayStopTimerIds) do
    _G.DelayManager:CancelDelayById(timerId)
  end
  self.HitFxDelayStopTimerIds = {}
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnSkillResLoaded, self.OnResLoadedSuccess)
end

function CollisionModule:OnDestruct()
end

return CollisionModule
