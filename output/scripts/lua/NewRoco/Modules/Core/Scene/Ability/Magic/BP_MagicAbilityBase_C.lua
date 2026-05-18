require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local MagicBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerMagicBaseBuff")
local NPCLuaUtils = require("NewRoco.Modules.Core.NPC.NPCLuaUtils")
local BP_MagicAbilityBase_C = Base:Extend("BP_MagicAbilityBase_C")

function BP_MagicAbilityBase_C:Start(OnFinished, CustomParams, ...)
  Log.Debug("On Magic Start")
  if not self.caster then
    self.caster.statusComponent:RemoveStatus(Enum.WorldPlayerStatusType.WPST_MAGIC)
    return
  end
  local animComponent = self.caster:GetAnimComponent()
  if not animComponent or not animComponent:GetAnimInstance() then
    Log.Error("anim instance\228\184\141\229\173\152\229\156\168\239\188\140\229\188\186\232\161\140\231\187\136\230\173\162")
    self.caster.statusComponent:RemoveStatus(Enum.WorldPlayerStatusType.WPST_MAGIC)
    return
  end
  self.Caster = self.caster.viewObj
  local buffComp = self.caster.buffComponent
  if buffComp and buffComp:HasBuff(self.helper:GetBuffName()) then
    return
  end
  local AnimInstance = self.caster.viewObj.Mesh:GetAnimInstance()
  if AnimInstance and AnimInstance:IsAnyMontagePlaying() then
    AnimInstance:Montage_Stop(0.1)
  end
  local bpClass = NPCLuaUtils.GetClass("Blueprint'/Game/NewRoco/Modules/Core/NPC/MagicStar/BP_MoZhang.BP_MoZhang_C'")
  local params = {}
  params.sceneCharacter = nil
  local quat = UE4.FQuat.FromAxisAndAngle(UE4Helper.UpVector, 0)
  local fTransfom = UE4.FTransform(quat, UE4.FVector(0, 0, 0))
  self.MoZhangActor = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(bpClass, fTransfom, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, params)
  self:InitWand()
  self.MoZhangActor:K2_AttachToComponent(self.Caster:GetComponentByClass(UE4.USkeletalMeshComponent), "locator_right_hand", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  UE4.UNRCStatics.SetActorOwner(self.MoZhangActor, self.caster.viewObj)
  self.MoZhangActor.inCasting = false
  self.magicBuffInfo = MagicBuff:NewMagicBuffInfo()
  self.magicBuffInfo.abilityHelper = self.helper
  self.magicBuffInfo.mozhangBP = self.MoZhangActor
  if GlobalConfig.PlayBall then
    local Comp = self.MoZhangActor.SkeletalMesh
    Comp:K2_SetRelativeLocationAndRotation(UE4.FVector(0, 0, 40), UE4.FRotator(0, 0, 180), false, nil, true)
    Comp:SetCollisionProfileName("BlockAll", true)
    Comp:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Camera, UE.ECollisionResponse.ECR_Ignore)
    self.MoZhangActor:SetActorScale3D(UE.FVector(4, 4, 5))
    self.MoZhangActor:SetActorEnableCollision(true)
  end
  if self.maxSpeedCurve then
    self.magicBuffInfo.maxSpeedCurve = self.maxSpeedCurve
  end
  self:SetMagicBaseConfig()
  self.caster:GetAnimComponent():GetAnimInstance():SetRootMotionMode(UE.ERootMotionMode.RootMotionFromMontagesOnly)
  self.caster:GetAnimComponent():StopAllMontage(0.1)
end

function BP_MagicAbilityBase_C:PlayStartSkill(Skill)
  _G.PlayerResourceManager:LoadResources_PlayerPerform(self, UE4.UNRCStatics.GetSoftObjPath(Skill), self.caster.isLocal, self.SkillLoadSucc, self.SkillLoadFail)
end

function BP_MagicAbilityBase_C:SkillLoadSucc(Skill)
  if UE.UObject.IsValid(self.MoZhangActor) and self.MoZhangActor.RocoSkill then
    local skillComponent = self.MoZhangActor.RocoSkill
    if not UE4.UObject.IsValid(skillComponent) then
      return
    end
    local skillObj = skillComponent:FindOrAddSkillObj(Skill)
    if _G.bShutDownSafeReload and not skillObj then
      Log.Error("AbilityBase try reload skill obj ", skillObj and "true" or "false")
    end
    if skillObj or _G.bShutDownSafeReload then
      self._skillObj = skillObj
      self._skillObj.CanInterrupt = true
      skillObj:SetCaster(self.MoZhangActor)
      skillComponent:PlaySkill(skillObj)
    end
  end
end

function BP_MagicAbilityBase_C:SkillLoadFail(req, Skill)
  Log.Error("BP_MagicAbilityBase_C load skill obj false")
end

function BP_MagicAbilityBase_C:Recover(owner, CustomParams)
  Log.Debug("BP_MagicAbilityBase_C:Recover")
  if not self.caster.isLocal and PlayerModuleEvent then
    self:Start()
    if CustomParams and CustomParams.throw_aim_param then
      self.caster:SendEvent(PlayerModuleEvent.ON_STATUS_REFRESH, ProtoEnum.WorldPlayerStatusType.WPST_MAGIC, 1, ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH, CustomParams)
    end
  else
    self.caster.statusComponent:RemoveStatus(Enum.WorldPlayerStatusType.WPST_MAGIC)
  end
end

function BP_MagicAbilityBase_C:Interrupt()
  Log.Debug("BP_MagicAbilityBase_C:Interrupt")
  self:Start()
end

function BP_MagicAbilityBase_C:SetQuality()
end

function BP_MagicAbilityBase_C:InitWand()
  if not self.caster then
    return
  end
  local WandActor = self.MoZhangActor
  local WandConf = self.caster:GetCurWandConf()
  NPCLuaUtils.PreLoad(string.format("%s%s%s", "SkeletalMesh'", WandConf.WandMesh, "'"))
  local bpMesh = NPCLuaUtils.GetClass(string.format("%s%s%s", "SkeletalMesh'", WandConf.WandMesh, "'"))
  bpMesh = bpMesh or NPCLuaUtils.GetClass("SkeletalMesh'/Game/ArtRes/AnimSequence/Human/PC/PC3/Avatar/Mw/32500101/SKM_PC3_Mw_32500101.SKM_PC3_Mw_32500101'")
  _G.NRCAudioManager:SetEmitterSwitch("Suit", WandConf.WandName, self.caster.viewObj, "")
  WandActor.SkeletalMesh:SetSkeletalMesh(bpMesh)
  UE4.UNRCStatics.ForceUpdateStreamingAssets(bpMesh, 30)
  WandActor.SkeletalMesh:SetForcedLOD(1)
  WandActor.NRCNiagaraSystem:K2_AttachToComponent(WandActor.SkeletalMesh, "MoZhang_TX", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  WandActor.NRCNiagaraSystemOnce:K2_AttachToComponent(WandActor.SkeletalMesh, "MoZhang_TX", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  WandActor.WindFx:K2_AttachToComponent(WandActor.SkeletalMesh, "MoZhang_TX", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  self:SetQuality()
end

function BP_MagicAbilityBase_C:SetMagicBaseConfig()
  self.magicBuffInfo.magicBaseConfig = self.helper:GetMagicBaseConf(self.caster)
end

return BP_MagicAbilityBase_C
