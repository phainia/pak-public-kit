local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local TransformAbility = Base:Extend("TransformAbility")

function TransformAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
end

function TransformAbility:Start(onFinished, customParams)
  Log.Debug("TransformAbility:Start")
  self._buffName = "Transform_Buff"
  local buff = self.caster.buffComponent:HasBuff(self._buffName)
  if buff then
    self.caster.buffComponent:RemoveBuff(self._buffName, true)
  end
  self.caster.buffComponent:AddBuff(self._buffName, require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerTransformBuff"), self.caster, customParams)
  if self.caster.isLocal then
    _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.AddCondition, Enum.PlayerConditionType.PCT_TRANSFORMED)
  end
end

function TransformAbility:Recover(onFinished, customParams)
  if self.caster.isLocal and self.caster.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
    self.caster.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
  end
  self:Start(onFinished, customParams)
end

return TransformAbility
