local Base = require("NewRoco.Modules.Core.Scene.Component.Attack.SceneAttackBase")
local SceneAttackActionLaser = Base:Extend("SceneAttackActionLaser")
local BEAM_LENGTH = 1800.0
local PATH_BEAM = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/Common/NS_Perception_AmiyateAttack_01.NS_Perception_AmiyateAttack_01'"
local PATH_HIT = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Common/Perception/NS_Perception_Hit01.NS_Perception_Hit01'"
local SOUND_ID_LAUNCH = 1209
local SOUND_ID_HIT = 1260

function SceneAttackActionLaser:GetEyeLocation()
  local mesh = self.owner.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
  return mesh:Abs_GetSocketLocation("locator_l_eye")
end

function SceneAttackActionLaser:Init(inComp)
  self.comp = inComp
  self.owner = inComp.owner
  self:Release()
  self.preloadCount = 2
  self.beamFxRequest = NRCResourceManager:LoadResAsync(self, PATH_BEAM, inComp.ResourcePriority, 10, self.LoadSucc, self.LoadFail)
  self.hitFxRequest = NRCResourceManager:LoadResAsync(self, PATH_HIT, inComp.ResourcePriority, 10, self.LoadSucc, self.LoadFail)
end

function SceneAttackActionLaser:Release()
  if self.beamFxRequest then
    self.beamFxRequest.asset = nil
    self.beamFxRequest.assetRef = nil
    NRCResourceManager:UnLoadRes(self.beamFxRequest)
    self.beamFxRequest = nil
  end
  if self.hitFxRequest then
    self.hitFxRequest.asset = nil
    self.hitFxRequest.assetRef = nil
    NRCResourceManager:UnLoadRes(self.hitFxRequest)
    self.hitFxRequest = nil
  end
end

function SceneAttackActionLaser:LoadSucc(req, asset)
  req.asset = asset
  req.assetRef = asset and UnLua.Ref(asset)
  self.preloadCount = self.preloadCount - 1
  if 0 == self.preloadCount then
    self.comp:LoadFinished(true)
  end
end

function SceneAttackActionLaser:LoadFail(req, msg)
  self.comp:LoadFinished(false)
end

function SceneAttackActionLaser:OnStart(target, hitbox)
  self.hitbox = hitbox
  local targetPos = hitbox:Abs_K2_GetActorLocation()
  local eyePos = self:GetEyeLocation()
  local beamDir = targetPos - eyePos
  local length = beamDir:Size()
  local beamTrans = UE4.FTransform(beamDir:ToQuat(), eyePos, UE4.FVector(length / BEAM_LENGTH, length / BEAM_LENGTH, length / BEAM_LENGTH))
  local RocoFX = self.owner.viewObj.RocoFX
  if RocoFX then
    self.fxHandle = RocoFX:PlayFx_Location(self.beamFxRequest.asset, beamTrans, true, 0)
    _G.NRCAudioManager:PlaySound3DAtLocationAuto(SOUND_ID_LAUNCH, eyePos)
  end
  self:CleanDelayHandle()
  self.d_CheckHit = DelayManager:DelaySeconds(0.2, self.CheckHit, self)
  self.d_OnEnd = DelayManager:DelaySeconds(1, self.OnEnd, self)
  return true
end

local TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel9)

function SceneAttackActionLaser:CheckHit()
  self.d_CheckHit = nil
  if nil == self.owner then
    return
  end
  local hitboxPos = self.hitbox:Abs_K2_GetActorLocation()
  local hit = false
  local radius = self.comp.AttackParam.Radius
  local outActors, result = UE4.UKismetSystemLibrary.Abs_SphereOverlapActors(self.owner.viewObj, hitboxPos, radius, nil, nil, nil)
  if result then
    for i = 1, outActors:Length() do
      local curActor = outActors:Get(i)
      local sceneCharacter = curActor and curActor.sceneCharacter
      if self.comp:OnHit(sceneCharacter) then
        break
      end
    end
  end
  local curEye = self:GetEyeLocation()
  local endDir = hitboxPos - curEye
  endDir:Normalize()
  local outActor, result2 = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(self.owner.viewObj, curEye, hitboxPos + endDir, TraceChannel, false, self.owner.viewObj)
  if result2 or hit then
    local hitFx = self.hitFxRequest.asset
    local rotation = UE4.FRotator()
    UE4.UGameplayStatics.Abs_SpawnEmitterAtLocation(_G.UE4Helper.GetCurrentWorld(), hitFx, hitboxPos, rotation, UE4Helper.OneVector, true, UE4.EPSCPoolMethod.None, true)
    _G.NRCAudioManager:PlaySound3DAtLocationAuto(SOUND_ID_HIT, hitboxPos)
  end
  if GlobalConfig.DebugLuaBTree then
    if hit then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self.owner.viewObj, hitboxPos, radius, 10, UE4.FLinearColor(1.0, 0.1, 0.1), 1, 1)
    else
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self.owner.viewObj, hitboxPos, radius, 10, UE4.FLinearColor(0.1, 1.0, 0.1), 1, 1)
    end
  end
end

function SceneAttackActionLaser:OnEnd()
  self.d_OnEnd = nil
  self.comp:ActEnd()
  if self.fxHandle then
    local RocoFX = self.owner.viewObj.RocoFX
    RocoFX:StopFx(self.fxHandle)
    self.fxHandle = nil
  end
  self.target = nil
  self.hitbox = nil
  Base.OnEnd(self)
end

function SceneAttackActionLaser:OnInterrupt()
  self:CleanDelayHandle()
  if self.fxHandle then
    local RocoFX = self.owner.viewObj.RocoFX
    RocoFX:StopFx(self.fxHandle)
    self.fxHandle = nil
  end
  self.target = nil
  self.hitbox = nil
  Base.OnEnd(self)
end

function SceneAttackActionLaser:GetEyeLocation()
  local mesh = self.owner.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
  return mesh:Abs_GetSocketLocation("locator_l_eye")
end

function SceneAttackActionLaser:CleanDelayHandle()
  if self.d_CheckHit then
    DelayManager:CancelDelayById(self.d_CheckHit)
    self.d_CheckHit = nil
  end
  if self.d_OnEnd then
    DelayManager:CancelDelayById(self.d_OnEnd)
    self.d_OnEnd = nil
  end
end

return SceneAttackActionLaser
