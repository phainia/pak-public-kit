local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local EndTransformAbility = Base:Extend("EndTransformAbility")

function EndTransformAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
end

function EndTransformAbility:Start(onFinished, params)
  self._buffName = "Transform_Buff"
  Log.Debug("EndTransformAbility:Start")
  local buff = self.caster.buffComponent:GetBuff(self._buffName)
  if buff then
    if buff.isCustomPerform then
      buff:LiquefyPerformEnd()
    else
      self.caster.buffComponent:RemoveBuff(self._buffName)
    end
  end
  if self.caster.isLocal and params and params.transform_param then
    local cancel_reason = params.transform_param.cancel_reason
    local tips
    if cancel_reason == ProtoEnum.PlayerTransformCancelReason.PTCR_TIMEOUT then
      cancel_reason = "transformed_ended_timeout"
    end
    if cancel_reason == ProtoEnum.PlayerTransformCancelReason.PTCR_LEAVE_AREA then
      cancel_reason = "transformed_ended_outofbounds"
    end
    if tips then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.LuaText[tips])
    end
  end
  if self.caster.isLocal then
    _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_TRANSFORMED)
  end
end

function EndTransformAbility:Interrupt()
  self:Start()
end

function EndTransformAbility:Recover(owner)
  self:Start()
end

return EndTransformAbility
