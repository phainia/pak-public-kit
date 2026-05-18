local Base = require("NewRoco.Modules.Core.Scene.Ability.Magic.BP_MagicAbilityBase_C")
local CreateBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerCreateBuff")
local PrepareCreateAbility = Base:Extend("PrepareCreateAbility")

function PrepareCreateAbility:Start(OnFinished)
  Base.Start(self, OnFinished)
  self.CastMagicThrowAnimType = 1
  self.SoundSource = "PrepareCreateAbility"
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
  self:PlaySkill()
end

function PrepareCreateAbility:SyncStart()
  self.caster.viewObj:SetAimMode(true, self.CastMagicThrowAnimType)
  self:PlaySkill()
end

function PrepareCreateAbility:PlaySkill()
  if self.MoZhangActor.CreateMagicResource then
    self.MoZhangActor:PlayFX(self.MoZhangActor.CreateMagicResource.NS_Create_Loop, false)
    local startSkill = self.MoZhangActor.CreateMagicResource.CreateAppearSkill
    self:PlayStartSkill(startSkill)
  end
  local typedConfig = _G.DataConfigManager:GetSceneAbilityThrowConf(1)
  self.magicBuffInfo.skillTypedConfig = typedConfig
  self.caster.buffComponent:AddBuff(self.helper:GetBuffName(), CreateBuff, self.caster, self.magicBuffInfo)
  local wandConf = self.caster:GetCurWandConf()
  if wandConf then
    _G.NRCAudioManager:SetEmitterSwitch("Suit", wandConf.WandName, self.caster.viewObj, "")
  end
  self.magicBuffInfo.SoundIdCreateLoop = _G.NRCAudioManager:PlaySound3DWithActorAuto(self.SoundIdLoop, self.caster.viewObj, self.SoundSource)
end

function PrepareCreateAbility:InitWand()
  Base.InitWand(self)
  if not self.caster then
    return
  end
  local WandActor = self.MoZhangActor
  local WandData = self.caster:GetCurWandDataByMagicType(ProtoEnum.SceneMagicType.SMT_CREATE)
  if WandData then
    WandActor.CreateMagicResource = WandData.CreateMagicResource
  end
end

return PrepareCreateAbility
