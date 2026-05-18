local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local NRCResourceManagerEnum = require("Core.Service.ResourceManager.NRCResourceManagerEnum")
local BEAM_LENGTH = 1800.0
local SOUND_ID_LAUNCH = 12503
local TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel9)
local SourceName = "Source"
local TargetName = "Target"
local LigatureComponent = Base:Extend("LigatureComponent")

function LigatureComponent:Attach(owner)
  Base.Attach(self, owner)
  self:ResetParam()
end

function LigatureComponent:OnTick(deltaTime)
  if self.target ~= nil and self.owner.viewObj then
    if nil ~= self.CasterMesh and nil ~= self.TargetMesh and UE4.UObject.IsValid(self.CasterMesh) and UE4.UObject.IsValid(self.TargetMesh) then
      local StartPos = self:GetLocationByBoneAddOn(self.CasterMesh, self.CasterBoneAddOn)
      local EndPos = self:GetLocationByBoneAddOn(self.TargetMesh, self.TargetBoneAddOn)
      if nil ~= StartPos and nil ~= EndPos then
        local ignoreActors = UE4.TArray(UE.AActor)
        ignoreActors:Add(self.CasterActor)
        ignoreActors:Add(self.owner.viewObj)
        local OutHit, result2 = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(_G.UE4Helper.GetCurrentWorld(), StartPos, EndPos, TraceChannel, false, ignoreActors, UE4.EDrawDebugTrace.None, nil, true, UE.FLinearColor(1, 0, 0, 1), UE.FLinearColor(0, 1, 0, 1), 1.0)
        if result2 then
          EndPos = OutHit.ImpactPoint
        end
        if self.Beam and UE4.UObject.IsValid(self.Beam) then
          self.Beam:SetVectorParameter("Target", UE4.UNRCStatics.AbsoluteToRelative(EndPos, self.owner.viewObj:GetWorld()))
        end
        if self.HitObject and UE4.UObject.IsValid(self.HitObject) then
          self.HitObject:Abs_K2_SetWorldLocation(EndPos, false, nil, false)
        end
      end
    end
  elseif self.bNeedDelayPlay and self.bReadyToPlay and self:StartLigature() then
    self.bNeedDelayPlay = false
    self.bReadyToPlay = false
  end
  if not self.bNeedDelayPlay and self.bReadyToPlay and self:StartLigature() then
    self.bNeedDelayPlay = false
    self.bReadyToPlay = false
  end
end

function LigatureComponent:PlayLigature(target, CasterBoneAddOn, TargetBoneAddOn, LineParticlePath, HitParticlePath)
  self.target = target
  self.CasterBoneAddOn = CasterBoneAddOn
  self.TargetBoneAddOn = TargetBoneAddOn
  self.PathBeam = LineParticlePath
  self.PathHit = HitParticlePath
  self:PreLoadResource()
  self:StartLigature()
  _G.UpdateManager:Register(self)
end

function LigatureComponent:PreLoadResource()
  self.bReadyToPlay = false
  if self.BeamResReq then
    _G.NRCResourceManager:UnLoadRes(self.BeamResReq)
  end
  self.BeamResource = nil
  if self.HitObjectResReq then
    _G.NRCResourceManager:UnLoadRes(self.HitObjectResReq)
  end
  self.HitObjectResource = nil
  self.HitObjectResourceRef = nil
  self.BeamResReq = _G.NRCResourceManager:LoadResAsync(self, self.PathBeam, PriorityEnum.Active_World_Combat_Boss, 0, self.BeamLoadedSuccess, self.BeamLoadFailed)
  self.HitObjectResReq = _G.NRCResourceManager:LoadResAsync(self, self.PathHit, PriorityEnum.Active_World_Combat_Boss, 0, self.HitLoadedSuccess, self.HitLoadFailed)
end

function LigatureComponent:BeamLoadedSuccess(req, Asset)
  self.BeamResource = Asset
  self.BeamResourceRef = Asset and UnLua.Ref(Asset)
  self.BeamResReq = nil
  if self.HitObjectResource then
    self.bReadyToPlay = true
  end
end

function LigatureComponent:BeamLoadFailed(req, msg)
  Log.Error("LigatureComponent:BeamLoadFailed Load Beam Failed")
  self.BeamResReq = nil
  _G.NRCResourceManager:UnLoadRes(req)
end

function LigatureComponent:HitLoadedSuccess(req, Asset)
  self.HitObjectResource = Asset
  self.HitObjectResourceRef = Asset and UnLua.Ref(Asset)
  self.HitObjectResReq = nil
  if self.BeamResource then
    self.bReadyToPlay = true
  end
end

function LigatureComponent:HitLoadFailed(req, msg)
  Log.Error("LigatureComponent:BeamLoadFailed Load HitRes Failed")
  self.HitObjectResReq = nil
  _G.NRCResourceManager:UnLoadRes(req)
end

function LigatureComponent:StartLigature()
  local result = false
  if self.target == nil then
    self.bNeedDelayPlay = true
    return result
  end
  if not self.bReadyToPlay then
    return result
  end
  if not self.owner.viewObj then
    return result
  end
  self.CasterMesh = self.owner.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
  if self.target ~= nil and self.target.viewObj then
    self.TargetMesh = self.target.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
    self.CasterActor = self.owner.viewObj
  end
  if UE4.UObject.IsValid(self.CasterMesh) and UE4.UObject.IsValid(self.TargetMesh) then
    local StartPos = self:GetLocationByBoneAddOn(self.CasterMesh, self.CasterBoneAddOn)
    local EndPos = self:GetLocationByBoneAddOn(self.TargetMesh, self.TargetBoneAddOn)
    if nil == StartPos or nil == EndPos then
      return result
    end
    local ignoreActors = UE4.TArray(UE.AActor)
    ignoreActors:Add(self.CasterActor)
    ignoreActors:Add(self.owner.viewObj)
    local OutHit, result2 = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(_G.UE4Helper.GetCurrentWorld(), StartPos, EndPos, TraceChannel, false, ignoreActors)
    if result2 then
      EndPos = OutHit.ImpactPoint
    end
    local rotation = UE4.FRotator()
    if self.BeamResource and UE4.UObject.IsValid(self.BeamResource) then
      local FxManager = UE.UFXManager.Get()
      if FxManager then
        local FxParam = UE.FPlayFXParam()
        FxParam.FxSystemTemplate = self.BeamResource
        FxParam.AttachPointName = self.CasterBoneAddOn
        FxParam.AttachToSocket = true
        self.Beam = FxManager.SpawnFXAttached(FxParam, self.CasterMesh)
      end
      if self.Beam then
        self.BeamRef = UnLua.Ref(self.Beam)
      end
    end
    _G.NRCAudioManager:PlaySound3DAtLocationAuto(SOUND_ID_LAUNCH, StartPos)
    if self.Beam and UE4.UObject.IsValid(self.Beam) then
      self.Beam:SetVectorParameter("Target", UE4.UNRCStatics.AbsoluteToRelative(EndPos, self.owner.viewObj:GetWorld()))
    end
    if self.HitObjectResource and UE4.UObject.IsValid(self.HitObjectResource) then
      local FxManager = UE.UFXManager.Get()
      if FxManager then
        self.HitObject = FxManager.SpawnFXAtLocation(self.owner.viewObj, self.HitObjectResource, UE4.UKismetMathLibrary.MakeTransform(EndPos, rotation, UE4.FVector(1, 1, 1)))
      end
      if self.HitObject then
        self.HitObjectRef = UnLua.Ref(self.HitObject)
      end
    end
    result = true
  end
  return result
end

function LigatureComponent:StopLigature()
  if self.AimEffectID ~= nil then
    RocoFX:StopFx(self.AimEffectID)
  end
  if nil ~= self.LigatureInstanceID then
    RocoFX:StopFx(self.LigatureInstanceID)
  end
  self:ResetParam()
  _G.UpdateManager:UnRegister(self)
end

function LigatureComponent:ResetParam()
  self.LigatureInstanceID = nil
  self.AimEffectID = nil
  self.target = nil
  self.CasterBoneAddOn = nil
  self.TargetBoneAddOn = nil
  self.CasterMesh = nil
  self.CasterActor = nil
  self.TargetMesh = nil
  self.bNeedDelayPlay = false
  self.PathBeam = nil
  self.PathHit = nil
  self.bReadyToPlay = false
  if self.Beam and UE4.UObject.IsValid(self.Beam) then
    self.Beam:K2_DestroyComponent(self.Beam)
  end
  self.Beam = nil
  self.BeamRef = nil
  if self.HitObject and UE4.UObject.IsValid(self.HitObject) then
    self.HitObject:K2_DestroyComponent(self.HitObject)
  end
  self.BeamResource = nil
  self.BeamResourceRef = nil
  self.HitObjectResource = nil
  self.HitObjectResourceRef = nil
  self.BeamResReq = nil
  self.HitObjectResReq = nil
  self.HitObject = nil
  self.HitObjectRef = nil
end

function LigatureComponent:DeAttach()
  self:StopLigature()
end

function LigatureComponent:GetLocationByBoneAddOn(SkeletonMesh, AddOnName)
  if nil ~= SkeletonMesh and UE4.UObject.IsValid(SkeletonMesh) then
    local result = SkeletonMesh:Abs_GetSocketLocation(AddOnName)
    return result
  end
  return nil
end

function LigatureComponent:GetWorldLocationByBoneAddOn(SkeletonMesh, AddOnName)
  if nil ~= SkeletonMesh and UE4.UObject.IsValid(SkeletonMesh) then
    local result = SkeletonMesh:GetSocketLocation(AddOnName)
    return result
  end
  return nil
end

return LigatureComponent
