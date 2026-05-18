local Base = require("NewRoco.Modules.Core.Scene.Ability.Magic.BP_MagicAbilityBase_C")
local StarBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerMagicStarBuff")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local BP_MagicStar_C = Base:Extend("BP_MagicStar_C")

function BP_MagicStar_C:Start(OnFinished, CustomParams, ...)
  Log.Debug("BP_MagicStar_C:Start")
  local buffComp = self.caster.buffComponent
  if buffComp and buffComp:HasBuff(self.helper:GetBuffName()) then
    return
  end
  if not self.caster.isLocal then
    self:SyncStart(CustomParams)
    return
  end
  Base.Start(self, OnFinished, ...)
  NRCModuleManager:DoCmd(MainUIModuleCmd.ShowFrontSight, true)
  self.ballLua = _G.NRCModuleManager:DoCmd(NPCModuleCmd.CreateThrowStar, self.caster.isLocal, self.caster:GetServerId())
  self.ballBP = self.ballLua.viewObj
  local ProjectileMovement = self.ballBP:GetComponentByClass(UE4.UProjectileMovementComponent)
  ProjectileMovement:SetActive(false)
  self.ballBP:K2_AttachToComponent(self.MoZhangActor:GetComponentByClass(UE4.USkeletalMeshComponent), "MoZhang_TX", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.KeepWorld, false)
  self.Anim_TakeOut = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicStarTakeOut")
  self.Anim_Aim = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicStarAim")
  self.caster.viewObj:ChangeThrowAnim(1)
  self.MoZhangActor:DelayPlayFX(self.MoZhangActor.StarXuli0Loop, 0.4, false)
  self.typedConfig = DataConfigManager:GetSceneAbilityThrowConf(1)
  self.magicBuffInfo.customMagicInfo = {
    ballLua = self.ballLua
  }
  self.magicBuffInfo.skillTypedConfig = self.typedConfig
  self.magicBuffInfo.throwStrength = self.ThrowStrength
  self.magicBuffInfo.fastThrowAngleOffset = self.FastThrowAngleOffset
  self.magicBuffInfo.throwSpeedOffset = self.ThrowSpeedOffset
  buffComp:AddBuff(self.helper:GetBuffName(), StarBuff, self.caster, self.magicBuffInfo)
  self:PlayStartSkill(self.MoZhangActor.AppearSkill)
end

function BP_MagicStar_C:SyncStart(CustomParams)
  if not NRCModuleManager:DoCmd(PlayerModuleCmd.TryAddMagicStarCounts, self.caster.serverData.base.actor_id) then
    return
  end
  Base.Start(self)
  self.ballLua = _G.NRCModuleManager:DoCmd(NPCModuleCmd.CreateThrowStar, false, self.caster:GetServerId())
  self.ballBP = self.ballLua.viewObj
  if not UE.UObject.IsValid(self.MoZhangActor) then
    Log.Error("\233\173\148\230\157\150\229\183\178\233\148\128\230\175\129")
    return
  end
  local ProjectileMovement = self.ballBP:GetComponentByClass(UE4.UProjectileMovementComponent)
  ProjectileMovement:SetActive(false)
  self.ballBP:K2_AttachToComponent(self.MoZhangActor:GetComponentByClass(UE4.USkeletalMeshComponent), "MoZhang_TX", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.KeepWorld, false)
  self.MoZhangActor:DelayPlayFX(self.MoZhangActor.StarXuli0Loop, 0.4, false)
  self.caster.viewObj:SetAimMode(true, 1)
  self.typedConfig = DataConfigManager:GetSceneAbilityThrowConf(1)
  self.magicBuffInfo.customMagicInfo = {
    ballLua = self.ballLua
  }
  self.magicBuffInfo.skillTypedConfig = self.typedConfig
  self.magicBuffInfo.throwStrength = self.ThrowStrength
  self.magicBuffInfo.fastThrowAngleOffset = self.FastThrowAngleOffset
  self.magicBuffInfo.throwSpeedOffset = self.ThrowSpeedOffset
  local buffComp = self.caster.buffComponent
  buffComp:AddBuff(self.helper:GetBuffName(), StarBuff, self.caster, self.magicBuffInfo)
  self:PlayStartSkill(self.MoZhangActor.AppearSkill)
  if CustomParams and CustomParams.throw_aim_param then
    self.caster:SendEvent(PlayerModuleEvent.ON_STATUS_REFRESH, ProtoEnum.WorldPlayerStatusType.WPST_MAGIC, 1, ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH, CustomParams)
  end
end

function BP_MagicStar_C:SetQuality()
  local magic_star_quality = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetStarMagicQuality, self.caster.isLocal)
  local WandActor = self.MoZhangActor
  WandActor.NRCNiagaraSystem:SetNiagaraQualityLevel(magic_star_quality)
  WandActor.NRCNiagaraSystemOnce:SetNiagaraQualityLevel(magic_star_quality)
end

function BP_MagicStar_C:InitWand()
  Base.InitWand(self)
  if not self.caster then
    return
  end
  local WandActor = self.MoZhangActor
  local WandData = self.caster:GetCurWandDataByMagicType(ProtoEnum.SceneMagicType.SMT_STAR)
  if WandData then
    WandActor.AppearSkill = WandData.StarAppearSkill
    WandActor.StarXuli0Loop = WandData.NS_Star_Xuli_0_Loop
    WandActor.StarXuli1 = WandData.NS_Star_Xuli_1
    WandActor.StarXuli1Loop = WandData.NS_Star_Xuli_1_Loop
    WandActor.StarXuli2 = WandData.NS_Star_Xuli_2
    WandActor.StarXuli2Loop = WandData.NS_Star_Xuli_2_Loop
    WandActor.StarXuli3 = WandData.NS_Star_Xuli_3
    WandActor.StarXuli3Loop = WandData.NS_Star_Xuli_3_Loop
  end
end

return BP_MagicStar_C
