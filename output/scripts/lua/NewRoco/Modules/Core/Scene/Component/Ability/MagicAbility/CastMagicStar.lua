local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.MagicAbility.CastMagicAbilityBase")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local CastMagicStar = Base:Extend("CastMagicStar")

function CastMagicStar:Init(AbilityConf)
  Base.Init(self, AbilityConf)
  self._abilityId = AbilityID.MAGIC_STAR
end

function CastMagicStar:CastMagic(...)
  Log.Debug("\230\150\189\230\148\190\230\152\159\230\152\159\233\173\148\230\179\149\239\188\129\239\188\129\239\188\129")
  self.hasOnThrow = false
  self.hasOnMozhangDisappear = false
  self.SkillTime = 0
  self:PlayAnimAndSkill()
  self.caster:SendEvent(PlayerModuleEvent.ON_CHARGE_VITALITY_END, true)
  if self.caster.isLocal then
    self.buff:GetController():ChangeThrowAimStat(false)
  else
    NRCModuleManager:DoCmd(PlayerModuleCmd.RemoveMagicStarCounts, self.caster.serverData.base.actor_id)
  end
end

function CastMagicStar:Interrupt()
  Log.Debug("CastMagicStar:Recover")
  NRCModuleManager:DoCmd(PlayerModuleCmd.RemoveMagicStarCounts, self.caster.serverData.base.actor_id)
  self:Recover()
end

function CastMagicStar:Recover()
  Log.Debug("CastMagicStar:Recover")
  if self.buff == nil then
    self.buff = AbilityHelperManager.GetHelper(self._abilityId):GetBuff(self.caster)
  end
  if self.buff == nil then
    return
  end
  self:CancelThrow()
  self:Finish()
end

function CastMagicStar:CancelThrow()
  Log.Debug("CastMagicStar:CancelThrow")
  self.caster:SendEvent(PlayerModuleEvent.ON_CHARGE_VITALITY_END, false)
  if self.buff.magicInfo.customMagicInfo.ballLua then
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteThrowStar, self.buff.magicInfo.customMagicInfo.ballLua)
    self.buff.magicInfo.customMagicInfo.ballLua = nil
  end
  if self.buff and not self.buff.is_magic_cancel then
    self.buff:GetController().PlayerCameraManager:Reset()
  end
  if not self.caster.isLocal then
    self.caster.viewObj:SetAimMode(false, 0)
    return
  end
  self.caster:SendEvent(PlayerModuleEvent.ON_INTERRUPT_THROW)
  self.caster.viewObj:ChangeThrowAnim(0)
end

function CastMagicStar:PlayAnimAndSkill()
  if self.helper.g6SkillClass then
    _G.UpdateManager:Register(self)
    if self.buff.chargedLevel <= 1 then
      self.Anim = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicStarCast1")
    elseif 2 == self.buff.chargedLevel then
      self.Anim = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicStarCast2")
    elseif 3 == self.buff.chargedLevel then
      self.Anim = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicStarCast3")
    end
    local AnimInstance = self.caster.viewObj.Mesh:GetAnimInstance()
    local ThrowAnimInstance = AnimInstance:GetLinkedAnimGraphInstanceByTag("Locomotion"):GetLinkedAnimGraphInstanceByTag("Aim")
    if nil == ThrowAnimInstance then
      AnimInstance:PlaySlotAnimation(self.Anim, "UpperBody", 0, 0)
    else
      ThrowAnimInstance:PlaySlotAnimation(self.Anim, "UpperBody", 0, 0)
    end
  else
    self:Finish()
  end
end

function CastMagicStar:OnTick(DeltaTime)
  self.SkillTime = self.SkillTime + DeltaTime
  if self.SkillTime > 0.2 and not self.hasOnThrow then
    self.hasOnThrow = true
    self:OnThrow()
    return
  end
  if self.SkillTime > 0.5 and not self.hasOnMozhangDisappear then
    self.hasOnMozhangDisappear = true
    self:OnMozhangDisappear()
    return
  end
  if self.SkillTime > 0.67 then
    self:Finish()
    return
  end
end

function CastMagicStar:OnSkillEvent(event)
  Base.OnSkillEvent(self, event)
  if "OnThrow" == event then
    self:OnThrow()
  end
  if "OnMozhangDisappear" == event then
    self:OnMozhangDisappear()
  end
  if "End" == event then
    self:Finish()
  end
end

function CastMagicStar:OnThrow()
  Log.Debug("CastMagicStar:OnThrow")
  if self.buff == nil then
    return
  end
  if self.buff.magicInfo.customMagicInfo.ballLua then
    if self.caster.isLocal then
      self.caster.viewObj:K2_SetActorRotation(UE4.FRotator(0, self.buff:GetController():GetControlRotation().Yaw, 0), false)
      NRCModuleManager:DoCmd(MainUIModuleCmd.ShowFrontSight, false)
    end
    self.buff:UpdateDirection()
    self.ballNPC = self.buff.magicInfo.customMagicInfo.ballLua.viewObj
    self.ballNPC:SetActorHiddenInGame(false)
    self.ballNPC:K2_DetachFromActor(UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative)
    local prev_scale = self.ballNPC:GetActorScale3D()
    self.ballNPC:Abs_K2_SetActorTransform_WithoutHit(UE4.FTransform(UE4.FQuat(), self.buff:GetStartPos(), prev_scale))
    if self.buff.magicInfo.mozhangBP then
      self.buff.magicInfo.mozhangBP.inCasting = true
      self.buff.magicInfo.mozhangBP:ClearFX()
    end
    local ProjectileMovement = self.ballNPC:GetComponentByClass(UE4.UProjectileMovementComponent)
    if SceneUtils.GetAutoHoming() then
      local TargetNPC = SceneUtils.QueryNPCInRange(self.ballNPC:Abs_K2_GetActorLocation())
      if TargetNPC then
        ProjectileMovement.Velocity = _G.FVectorZero
        ProjectileMovement.bIsHomingProjectile = true
        ProjectileMovement.HomingTargetComponent = TargetNPC:K2_GetRootComponent()
        ProjectileMovement.HomingAccelerationMagnitude = 1000000.0
      else
        ProjectileMovement.bIsHomingProjectile = false
        ProjectileMovement.HomingTargetComponent = nil
        ProjectileMovement.HomingAccelerationMagnitude = 0
        Log.Error("\230\159\165\232\175\162\228\184\141\229\136\176\233\153\132\232\191\145\231\154\132NPC\239\188\140\229\143\150\230\182\136\232\135\170\229\138\168\229\175\187\230\137\190")
      end
    else
      ProjectileMovement.bIsHomingProjectile = false
      ProjectileMovement.HomingTargetComponent = nil
      ProjectileMovement.HomingAccelerationMagnitude = 0
    end
    self.ballNPC:SetInitialVelocity(self.buff:CalculateVelocity())
    ProjectileMovement.Velocity = self.buff:CalculateVelocity()
    ProjectileMovement:SetActive(true)
    self.buff.magicInfo.customMagicInfo.ballLua:OnThrowStart()
    self.buff.magicInfo.customMagicInfo.ballLua = nil
    self.ballNPC = nil
  end
end

function CastMagicStar:OnMozhangDisappear()
  if self.buff and self.buff.magicInfo.mozhangBP then
    self.buff.magicInfo.mozhangBP:ClearFX()
    self.buff.magicInfo.mozhangBP:OnDisappear()
    self.buff.magicInfo.mozhangBP = nil
    if self.buff.magicInfo.customMagicInfo.ballLua then
      _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteThrowStar, self.buff.magicInfo.customMagicInfo.ballLua)
      self.buff.magicInfo.customMagicInfo.ballLua = nil
      if not self.caster.isLocal then
        self.caster.viewObj:SetAimMode(false, 0)
        return
      end
      self.caster.viewObj:ChangeThrowAnim(0)
    end
  end
end

function CastMagicStar:Finish(Force)
  _G.UpdateManager:UnRegister(self)
  Base.Finish(self, Force)
end

return CastMagicStar
