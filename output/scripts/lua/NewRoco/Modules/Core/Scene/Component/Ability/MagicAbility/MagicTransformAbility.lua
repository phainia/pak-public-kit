local Base = require("NewRoco.Modules.Core.Scene.Ability.Magic.BP_MagicAbilityBase_C")
local MagicTransformBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerMagicTransformBuff")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local MagicTransformAbility = Base:Extend("MagicTransformAbility")

function MagicTransformAbility:Start(OnFinished)
  Log.Debug("MagicTransformAbility:Start")
  Base.Start(self, OnFinished)
  local buffComp = self.caster.buffComponent
  if buffComp and buffComp:HasBuff(self.helper:GetBuffName()) then
    return
  end
  if not self.caster.isLocal then
    self.caster.viewObj:SetAimMode(true, 4)
  end
  if self.caster.viewObj and self.caster.viewObj.ChangeThrowAnim then
    self.caster.viewObj:ChangeThrowAnim(4)
  end
  local typedConfig = DataConfigManager:GetSceneAbilityThrowConf(1)
  self.magicBuffInfo.skillTypedConfig = typedConfig
  self.magicBuffInfo.magicBaseConfig = _G.DataConfigManager:GetMagicBaseConf(101)
  buffComp:AddBuff(self.helper:GetBuffName(), MagicTransformBuff, self.caster, self.magicBuffInfo)
  self:PlayStartSkill(self.MoZhangActor.MagicTransformAppearSkill)
  self.MoZhangActor:PlayFX(self.MoZhangActor.MagicTransform_Loop, false)
  if self.caster.isLocal then
    NRCModuleManager:DoCmd(MainUIModuleCmd.ShowFrontSight, true)
  end
  self.magicBuffInfo.AudioId = _G.NRCAudioManager:PlaySound3DWithActorAuto(202401, self.caster.viewObj, "MagicTransformAbility")
  local wandConf = self.caster:GetCurWandConf()
  _G.NRCAudioManager:SetEmitterSwitch("Suit", wandConf.WandName, self.caster.viewObj, "")
end

function MagicTransformAbility:InitWand()
  Base.InitWand(self)
  if not self.caster then
    return
  end
  local WandActor = self.MoZhangActor
  local WandData = self.caster:GetCurWandDataByMagicType(ProtoEnum.SceneMagicType.SMT_LIQUEFY)
  if WandData then
    WandActor.MagicTransformAppearSkill = WandData.MagicTransformAppearSkill
    WandActor.MagicTransform_Loop = WandData.MagicTransform_Loop
    WandActor.MagicTransform_Ball_Boom = WandData.MagicTransform_Ball_Boom
  end
end

return MagicTransformAbility
