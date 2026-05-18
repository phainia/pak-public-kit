local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.MagicAbility.CastMagicAbilityBase")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local CastLightAbility = Base:Extend("CastLightAbility")

function CastLightAbility:Init(AbilityConf)
  Base.Init(self, AbilityConf)
  self._abilityId = AbilityConf.id
end

function CastLightAbility:CastMagic(...)
  self.SkillTime = 0
  self.bOnThrow = false
  self.bOnMozhangDisappear = false
  self:PlayAnimAndSkill()
  if self.caster.isLocal then
    self.buff:GetController():ChangeThrowAimStat(false)
  else
    _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.RemoveMagicStarCounts, self.caster.serverData.base.actor_id)
  end
end

function CastLightAbility:Interrupt()
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.RemoveMagicStarCounts, self.caster.serverData.base.actor_id)
  self:Recover()
end

function CastLightAbility:Recover()
  if not self.buff then
    self.buff = AbilityHelperManager.GetHelper(self._abilityId):GetBuff(self.caster)
  end
  if not self.buff then
    return
  end
  self:CancelThrow()
  self:Finish()
end

function CastLightAbility:CancelThrow()
  if self.buff.magicInfo.customMagicInfo.LightBallLua then
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteThrowLightBall, self.buff.magicInfo.customMagicInfo.LightBallLua)
    self.buff.magicInfo.customMagicInfo.LightBallLua = nil
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

function CastLightAbility:PlayAnimAndSkill()
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

function CastLightAbility:OnTick(DeltaTime)
  self.SkillTime = self.SkillTime + DeltaTime
  if self.SkillTime > 0.2 and not self.bOnThrow then
    self.bOnThrow = true
    self:OnThrow()
    return
  end
  if self.SkillTime > 0.5 and not self.bOnMozhangDisappear then
    self.bOnMozhangDisappear = true
    self:OnMozhangDisappear()
    return
  end
  if self.SkillTime > 0.67 then
    self:Finish()
    return
  end
end

function CastLightAbility:OnSkillEvent(Event)
  Base.OnSkillEvent(self, Event)
  if "OnThrow" == Event then
    self:OnThrow()
  end
  if "OnMozhangDisappear" == Event then
    self:OnMozhangDisappear()
  end
  if "End" == Event then
    self:Finish()
  end
end

function CastLightAbility:OnThrow()
  if self.buff == nil then
    return
  end
  if self.buff.magicInfo.customMagicInfo.LightBallLua then
    if self.caster.isLocal then
      self.caster.viewObj:K2_SetActorRotation(UE4.FRotator(0, self.buff:GetController():GetControlRotation().Yaw, 0), false)
      NRCModuleManager:DoCmd(MainUIModuleCmd.ShowFrontSight, false)
    end
    self.buff:UpdateDirection()
    self.LightBallNPC = self.buff.magicInfo.customMagicInfo.LightBallLua.viewObj
    self.LightBallNPC:SetActorHiddenInGame(false)
    self.LightBallNPC:K2_DetachFromActor(UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative)
    local ActorScale = self.LightBallNPC:GetActorScale3D()
    self.LightBallNPC:Abs_K2_SetActorTransform_WithoutHit(UE4.FTransform(UE4.FQuat(), self.buff:GetStartPos(), ActorScale))
    if self.buff.chargedLevel <= 1 then
      self.buff.magicInfo.mozhangBP:PlayFXOnce(self.buff.magicInfo.mozhangBP.LightRelease1)
    elseif 2 == self.buff.chargedLevel then
      self.buff.magicInfo.mozhangBP:PlayFXOnce(self.buff.magicInfo.mozhangBP.LightRelease2)
    elseif 3 == self.buff.chargedLevel then
      self.buff.magicInfo.mozhangBP:PlayFXOnce(self.buff.magicInfo.mozhangBP.LightRelease3)
    end
    self.buff.magicInfo.customMagicInfo.LightBallLua:OnThrowStart()
    if self.buff.magicInfo.mozhangBP then
      self.buff.magicInfo.mozhangBP.inCasting = true
      self.buff.magicInfo.mozhangBP:ClearFX()
    end
    local ProjectileMovement = self.LightBallNPC:GetComponentByClass(UE4.UProjectileMovementComponent)
    ProjectileMovement.bIsHomingProjectile = false
    ProjectileMovement.HomingTargetComponent = nil
    ProjectileMovement.HomingAccelerationMagnitude = 0
    self.buff.magicInfo.throwStrength = self.LightBallNPC.MaxSpeed
    local Velocity = self.buff:CalculateVelocity()
    self.LightBallNPC:SetInitialVelocity(Velocity)
    ProjectileMovement.Velocity = Velocity
    ProjectileMovement:SetActive(true)
    self.buff.magicInfo.customMagicInfo.LightBallLua = nil
    self.LightBallNPC = nil
  end
end

function CastLightAbility:OnMozhangDisappear()
  if self.buff and self.buff.magicInfo.mozhangBP then
    self.buff.magicInfo.mozhangBP:ClearFX()
    self.buff.magicInfo.mozhangBP:OnDisappear()
    self.buff.magicInfo.mozhangBP = nil
    if self.buff.magicInfo.customMagicInfo.LightBallLua then
      _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteThrowLightBall, self.buff.magicInfo.customMagicInfo.LightBallLua)
      self.buff.magicInfo.customMagicInfo.LightBallLua = nil
      if not self.caster.isLocal then
        self.caster.viewObj:SetAimMode(false, 0)
        return
      end
      self.caster.viewObj:ChangeThrowAnim(0)
    end
  end
end

function CastLightAbility:Finish(Force)
  _G.UpdateManager:UnRegister(self)
  Base.Finish(self, Force)
end

return CastLightAbility
