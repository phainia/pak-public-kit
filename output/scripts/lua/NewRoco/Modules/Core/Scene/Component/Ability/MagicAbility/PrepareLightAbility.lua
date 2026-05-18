local Base = require("NewRoco.Modules.Core.Scene.Ability.Magic.BP_MagicAbilityBase_C")
local PrepareLightBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerPrepareLightBuff")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local PrepareLightAbility = Base:Extend("PrepareLightAbility")

function PrepareLightAbility:Start(OnFinished, CustomParams)
  local BuffComp = self.caster.buffComponent
  if BuffComp and BuffComp:HasBuff(self.helper:GetBuffName()) then
    return
  end
  if not self.caster.isLocal then
    self:SyncStart(CustomParams)
    return
  end
  Base.Start(self, OnFinished)
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ShowFrontSight, true)
  self.LightBallLua = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.CreateThrowLightBall, self.caster.isLocal, self.caster:GetServerId())
  self.LightBallBP = self.LightBallLua.viewObj
  local ProjectileMovement = self.LightBallBP:GetComponentByClass(UE4.UProjectileMovementComponent)
  ProjectileMovement:SetActive(false)
  self.LightBallBP:K2_AttachToComponent(self.MoZhangActor:GetComponentByClass(UE4.USkeletalMeshComponent), "MoZhang_TX", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.KeepWorld, false)
  self.Anim_TakeOut = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicStarTakeOut")
  self.Anim_Aim = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicStarAim")
  self.caster.viewObj:ChangeThrowAnim(1)
  self.magicBuffInfo.customMagicInfo = {
    LightBallLua = self.LightBallLua
  }
  self.magicBuffInfo.skillTypedConfig = _G.DataConfigManager:GetSceneAbilityThrowConf(1)
  self.magicBuffInfo.throwStrength = self.LightBallBP.ThrowStrength
  BuffComp:AddBuff(self.helper:GetBuffName(), PrepareLightBuff, self.caster, self.magicBuffInfo)
  self:PlayStartSkill(self.MoZhangActor.LightAppearSkill)
end

function PrepareLightAbility:SyncStart(CustomParams)
  if not NRCModuleManager:DoCmd(PlayerModuleCmd.TryAddMagicStarCounts, self.caster.serverData.base.actor_id) then
    return
  end
  Base.Start(self)
  self.LightBallLua = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.CreateThrowLightBall, self.caster.isLocal, self.caster:GetServerId())
  self.LightBallBP = self.LightBallLua.viewObj
  local ProjectileMovement = self.LightBallBP:GetComponentByClass(UE4.UProjectileMovementComponent)
  ProjectileMovement:SetActive(false)
  self.LightBallBP:K2_AttachToComponent(self.MoZhangActor:GetComponentByClass(UE4.USkeletalMeshComponent), "MoZhang_TX", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.KeepWorld, false)
  self.caster.viewObj:SetAimMode(true, 1)
  self.magicBuffInfo.customMagicInfo = {
    LightBallLua = self.LightBallLua
  }
  self.magicBuffInfo.throwStrength = self.LightBallBP.ThrowStrength
  self.magicBuffInfo.skillTypedConfig = _G.DataConfigManager:GetSceneAbilityThrowConf(1)
  local BuffComp = self.caster.buffComponent
  if BuffComp then
    BuffComp:AddBuff(self.helper:GetBuffName(), PrepareLightBuff, self.caster, self.magicBuffInfo)
  end
  self:PlayStartSkill(self.MoZhangActor.LightAppearSkill)
  if CustomParams and CustomParams.throw_aim_param then
    self.caster:SendEvent(PlayerModuleEvent.ON_STATUS_REFRESH, ProtoEnum.WorldPlayerStatusType.WPST_MAGIC, 1, ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH, CustomParams)
  end
end

function PrepareLightAbility:InitWand()
  Base.InitWand(self)
  if not self.caster then
    return
  end
  local WandActor = self.MoZhangActor
  local WandData = self.caster:GetCurWandDataByMagicType(ProtoEnum.SceneMagicType.SMT_LIGHT)
  if WandData then
    WandActor.LightAppearSkill = WandData.LightAppearSkill
    WandActor.LightRelease1 = WandData.NS_Light_Release1
    WandActor.LightRelease2 = WandData.NS_Light_Release2
    WandActor.LightRelease3 = WandData.NS_Light_Release3
    WandActor.LightCharge1 = WandData.NS_Light_Charge1
    WandActor.LightCharge2 = WandData.NS_Light_Charge2
    WandActor.LightCharge3 = WandData.NS_Light_Charge3
    WandActor.LightLoop1 = WandData.NS_Light_Loop1
    WandActor.LightLoop2 = WandData.NS_Light_Loop2
    WandActor.LightLoop3 = WandData.NS_Light_Loop3
  end
end

return PrepareLightAbility
