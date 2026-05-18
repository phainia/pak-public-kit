local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerMagicBaseBuff")
local ScenePlayerPrepareLightBuff = Base:Extend("ScenePlayerPrepareLightBuff")

function ScenePlayerPrepareLightBuff:OnBegin(Owner, MagicInfo)
  Base.OnBegin(self, Owner, MagicInfo)
  local WandData = Owner:GetCurWandDataByMagicType(ProtoEnum.SceneMagicType.SMT_LIGHT)
  self.magicInfo.mozhangBP.DisappearFx = WandData.NS_Light_Disappead
end

function ScenePlayerPrepareLightBuff:OnUpdate(DeltaTime)
  Base.OnUpdate(self, DeltaTime)
  if self.magicInfo.customMagicInfo.LightBallLua then
    self.magicInfo.customMagicInfo.LightBallLua.viewObj:SetChargeProcess(self.currentLevelProcess)
  end
end

function ScenePlayerPrepareLightBuff:OnCharged(NewLevel)
  if self.owner.isLocal then
    local CustomParams = self.owner.statusComponent._statusParams[ProtoEnum.WorldPlayerStatusType.WPST_MAGIC]
    CustomParams = CustomParams or ProtoMessage:newPlayerStatusCustomParams()
    CustomParams.throw_aim_param.aim_type = ProtoEnum.AimSyncType.AST_MODE_CHANGE
    CustomParams.throw_aim_param.charged_level = NewLevel
    self.owner.statusComponent:RefreshStatus(ProtoEnum.WorldPlayerStatusType.WPST_MAGIC, self.magicInfo.abilityHelper.config.add_status[1], ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH, CustomParams)
  end
  if not self.magicInfo.customMagicInfo.LightBallLua then
    return
  end
  self.magicInfo.customMagicInfo.LightBallLua.viewObj:SetChargeLevel(NewLevel)
  if 1 == NewLevel then
    self.magicInfo.mozhangBP:PlayFX(self.magicInfo.mozhangBP.LightLoop1, false)
    self.magicInfo.mozhangBP:PlayFXOnce(self.magicInfo.mozhangBP.LightCharge1)
  elseif 2 == NewLevel then
    self.magicInfo.mozhangBP:PlayFX(self.magicInfo.mozhangBP.LightLoop2, false)
    self.magicInfo.mozhangBP:PlayFXOnce(self.magicInfo.mozhangBP.LightCharge2)
    self:ChangeChargedAnim("MagicStarAim2")
  elseif 3 == NewLevel then
    self.magicInfo.mozhangBP:PlayFX(self.magicInfo.mozhangBP.LightLoop3, false)
    self.magicInfo.mozhangBP:PlayFXOnce(self.magicInfo.mozhangBP.LightCharge3)
    self:ChangeChargedAnim("MagicStarAim3")
  end
end

function ScenePlayerPrepareLightBuff:ChangeChargedAnim(AnimName)
  local Montage = self.owner.viewObj:GetAnimComponent():PrepareMontageByName(AnimName, "DefaultSlot", 0.25, 0.25)
  if not self.owner.viewObj.Mesh:GetAnimInstance() then
    Log.Error("\232\147\132\229\138\155\230\151\182\228\184\187\232\167\146ABP\228\184\162\228\186\134\239\188\140\232\175\183\230\136\170\229\155\190\232\129\148\231\179\187minot")
    return
  end
  local ThrowAnimInstance = self.owner.viewObj.Mesh:GetAnimInstance():GetLinkedAnimGraphInstanceByTag("Locomotion"):GetLinkedAnimGraphInstanceByTag("Aim")
  if ThrowAnimInstance then
    ThrowAnimInstance:Montage_Play(Montage)
    ThrowAnimInstance:Montage_SetNextSection("Default", "Default", Montage)
  end
end

return ScenePlayerPrepareLightBuff
