local Base = require("NewRoco.Modules.Core.Scene.Ability.Magic.BP_MagicAbilityBase_C")
local PrepareWindBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerPrepareWindBuff")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PrepareWindAbility = Base:Extend("PrepareWindAbility")

function PrepareWindAbility:Start(OnFinished)
  Base.Start(self, OnFinished)
  local buffComp = self.caster.buffComponent
  if buffComp and buffComp:HasBuff(self.helper:GetBuffName()) then
    return
  end
  if not self.caster.isLocal then
    self:SyncStart()
    return
  end
  self.Anim_TakeOut = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicWindTakeOut")
  self.Anim_Aim = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicWindAim")
  self.caster.viewObj:ChangeThrowAnim(2)
  local typedConfig = DataConfigManager:GetSceneAbilityThrowConf(1)
  self.magicBuffInfo.skillTypedConfig = typedConfig
  self.magicBuffInfo.WindXuli = _G.NRCAudioManager:PlaySound3DWithActorAuto(1319, self.caster.viewObj, "PrepareWindAbility")
  buffComp:AddBuff(self.helper:GetBuffName(), PrepareWindBuff, self.caster, self.magicBuffInfo)
  self:PlayStartSkill(self.MoZhangActor.WindAppearSkill)
end

function PrepareWindAbility:SyncStart()
  self.caster.viewObj:SetAimMode(true, 2)
  local typedConfig = DataConfigManager:GetSceneAbilityThrowConf(1)
  self.magicBuffInfo.skillTypedConfig = typedConfig
  self.magicBuffInfo.WindXuli = _G.NRCAudioManager:PlaySound3DWithActorAuto(1319, self.caster.viewObj, "PrepareWindAbility")
  local buffComp = self.caster.buffComponent
  buffComp:AddBuff(self.helper:GetBuffName(), PrepareWindBuff, self.caster, self.magicBuffInfo)
  self:PlayStartSkill(self.MoZhangActor.WindAppearSkill)
end

function PrepareWindAbility:InitWand()
  Base.InitWand(self)
  if not self.caster then
    return
  end
  local WandActor = self.MoZhangActor
  local WandData = self.caster:GetCurWandDataByMagicType(ProtoEnum.SceneMagicType.SMT_WIND)
  if WandData then
    WandActor.WindAppearSkill = WandData.WindAppearSkill
    WandActor.WindLoop0 = WandData.NS_Wind_Loop_0
    WandActor.WindLoop1Start = WandData.NS_Wind_Loop_1_Start
    WandActor.WindLoop1 = WandData.NS_Wind_Loop_1
  end
end

return PrepareWindAbility
