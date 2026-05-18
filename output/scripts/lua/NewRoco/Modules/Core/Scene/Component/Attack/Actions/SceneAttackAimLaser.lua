local Base = require("NewRoco.Modules.Core.Scene.Component.Attack.SceneAttackBase")
local AttackComponent
local SceneAttackAimLaser = Base:Extend("SceneAttackAimLaser")
local GS_SceneBeam_Path = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneBattle/GS_SceneBeam.GS_SceneBeam_C'"

function SceneAttackAimLaser:Ctor()
  Base.Ctor(self)
  self.skillObj = nil
end

function SceneAttackAimLaser:Init(inComp)
  self.comp = inComp
  self.owner = inComp.owner
  self.targetActor = nil
  self.hitboxActor = nil
  self:Release()
  self.BeamSkillClassRequest = NRCResourceManager:LoadResAsync(self, GS_SceneBeam_Path, inComp.ResourcePriority, 10, self.LoadSucc, self.LoadFailed)
end

function SceneAttackAimLaser:Release()
  if self.BeamSkillClassRequest then
    self.BeamSkillClassRequest.asset = nil
    NRCResourceManager:UnLoadRes(self.BeamSkillClassRequest)
    self.BeamSkillClassRequest = nil
  end
end

function SceneAttackAimLaser:LoadSucc(req, asset)
  req.asset = asset
  req.assetRef = asset and UnLua.Ref(asset)
  self.comp:LoadFinished(true)
end

function SceneAttackAimLaser:LoadFailed(req, msg)
  self.comp:LoadFinished(false)
end

function SceneAttackAimLaser:OnStart(target, hitbox)
  if nil == target or nil == hitbox then
    Log.Warning("SceneAttackAimLaser:OnStart: \231\155\174\230\160\135\228\184\186\229\174\154\231\130\185\239\188\140\228\184\141\230\148\175\230\140\129\231\158\132\229\135\134")
    return false
  end
  self.targetActor = target
  self.hitboxActor = hitbox
  if GlobalConfig.DebugLuaBTree then
    self.Debug_InitialPos = target.viewObj:Abs_K2_GetActorLocation()
  end
  local skillClass = self.BeamSkillClassRequest.asset
  self.skillObj = self.owner.viewObj.RocoSkill:FindOrAddSkillObj(skillClass)
  if self.skillObj then
    self.skillObj:ClearDelegates()
    self.skillObj:SetCaster(self.owner.viewObj):SetTargets({hitbox}):RegisterEventCallback("End", self, self.OnLockEnd):RegisterEventCallback("PreEnd", self, self.OnLockEnd):RegisterEventCallback("PreEndAnim", self, self.OnLockEnd):RegisterEventCallback("Interrupt", self, self.OnLockEnd)
    self.skillObj.Blackboard:SetValueAsVector("Source", UE4Helper.ZeroVector)
    self.skillObj.Blackboard:SetValueAsVector("Target", self.hitboxActor:Abs_K2_GetActorLocation())
    self.owner.viewObj.RocoSkill:LoadAndPlaySkill(self.skillObj)
    if nil ~= self.owner.viewObj.IsAiming then
      self.owner.viewObj.IsAiming = true
    end
    _G.UpdateManager:Register(self)
  else
    Log.Warning("SceneAttackAimLaser:OnStart, Class load failed", GS_SceneBeam_Path)
    return false
  end
  return true
end

local TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel9)

function SceneAttackAimLaser:OnTick()
  if not AttackComponent then
    AttackComponent = require("NewRoco.Modules.Core.Scene.Component.Attack.AttackComponent")
  end
  if not self.comp.state == AttackComponent.State.Aiming then
    _G.UpdateManager:UnRegister(self)
    local vObj = self.owner.viewObj
    if not vObj then
      return Log.Warning("SceneAttackAimLaser, view missing")
    end
    vObj.RocoSkill:StopCurrentSkill()
    vObj.IsAiming = false
    vObj.IsAttacking = false
    self:OnEnd()
    return
  end
  local selfPos = self.owner:GetActorLocation()
  local selfYaw = self.owner:GetActorRotation().Yaw
  local OutHit, Success = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(_G.UE4Helper.GetCurrentWorld(), self:GetEyeLocation(), self.targetActor:GetActorLocation(), TraceChannel, false, self.owner.viewObj)
  if Success then
    self.hitboxActor:Abs_K2_SetActorLocation_WithoutHit(OutHit.Location)
  else
    self.hitboxActor:Abs_K2_SetActorLocation_WithoutHit(self.targetActor:GetActorLocation())
  end
  self.targetPos = self.hitboxActor:Abs_K2_GetActorLocation()
  self.skillObj.Blackboard:SetValueAsVector("Source", UE4Helper.ZeroVector)
  self.skillObj.Blackboard:SetValueAsVector("Target", self.hitboxActor:Abs_K2_GetActorLocation())
  if self.owner.viewObj.AimDeltaYaw then
    local targetDir = UE4.FVector(self.targetPos.X - selfPos.X, self.targetPos.Y - selfPos.Y, 0)
    local AimDeltaYaw = math.fmod(selfYaw - targetDir:ToRotator().Yaw, 360)
    if AimDeltaYaw > 180 then
      AimDeltaYaw = AimDeltaYaw - 360
    end
    if AimDeltaYaw < -180 then
      AimDeltaYaw = AimDeltaYaw + 360
    end
    self.owner.viewObj.AimDeltaYaw = AimDeltaYaw
  end
end

function SceneAttackAimLaser:OnLockEnd()
  _G.UpdateManager:UnRegister(self)
  _G.DelayManager:DelaySeconds(0.3, function(viewObj)
    if UE.UObject.IsValid(viewObj) then
      viewObj.IsAiming = false
    end
  end, self.owner.viewObj)
  self:OnEnd()
end

function SceneAttackAimLaser:OnEnd()
  self.skillObj = nil
  self.targetActor = nil
  self.hitboxActor = nil
  self.comp:AimEnd()
  Base.OnEnd(self)
end

function SceneAttackAimLaser:OnInterrupt()
  if self.skillObj then
    self.owner.viewObj.RocoSkill:CancelSkill(self.skillObj, UE.ESkillActionResult.SkillActionResultInterrupted)
  end
end

function SceneAttackAimLaser:GetEyeLocation()
  local mesh = self.owner.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
  return mesh:Abs_GetSocketLocation("locator_l_eye")
end

return SceneAttackAimLaser
