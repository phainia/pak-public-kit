local Base = require("NewRoco.Modules.Core.Scene.Ability.Magic.BP_MagicAbilityBase_C")
local VideoBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerVideoBuff")
local PrepareVideoAbility = Base:Extend("PrepareVideoAbility")

function PrepareVideoAbility:Start(OnFinished)
  Base.Start(self, OnFinished)
  self.CastMagicThrowAnimType = 1
  self.SoundSource = "PrepareVideoAbility"
  self.SoundIdLoop = 202701
  local buffComp = self.caster.buffComponent
  if buffComp and buffComp:HasBuff(self.helper:GetBuffName()) then
    return
  end
  self.magicBuffInfo.SoundSourceCreate = self.SoundSource
  if not self.caster.isLocal then
    self:SyncStart()
    return
  end
  self.caster.viewObj:ChangeThrowAnim(self.CastMagicThrowAnimType)
  self.magicBuffInfo.SoundIdCreateLoop = _G.NRCAudioManager:PlaySound2DAuto(self.SoundIdLoop, self.SoundSource)
  self:PlaySkill()
end

function PrepareVideoAbility:SyncStart()
  self.caster.viewObj:SetAimMode(true, self.CastMagicThrowAnimType)
  self.magicBuffInfo.SoundIdCreateLoop = _G.NRCAudioManager:PlaySound3DWithActorAuto(self.SoundIdLoop, self.caster.viewObj, self.SoundSource)
  self:PlaySkill()
end

function PrepareVideoAbility:PlaySkill()
  if self.MoZhangActor.VideoMagicResource then
    self.MoZhangActor:PlayFX(self.MoZhangActor.VideoMagicResource.NS_Create_Loop, false)
    local startSkill = self.MoZhangActor.VideoMagicResource.CreateAppearSkill
    self:PlayStartSkill(startSkill)
  end
  local typedConfig = _G.DataConfigManager:GetSceneAbilityThrowConf(1)
  self.magicBuffInfo.skillTypedConfig = typedConfig
  self.caster.buffComponent:AddBuff(self.helper:GetBuffName(), VideoBuff, self.caster, self.magicBuffInfo)
end

function PrepareVideoAbility:InitWand()
  Base.InitWand(self)
  if not self.caster then
    return
  end
  local WandActor = self.MoZhangActor
  local WandData = self.caster:GetCurWandDataByMagicType(ProtoEnum.SceneMagicType.SMT_CREATE_MAGIC_VIDEO)
  if WandData then
    WandActor.VideoMagicResource = WandData.VideoMagicResource
  end
end

return PrepareVideoAbility
