local AuraEffectRegistry = {
  [Enum.AuraEffect.AE_ICE] = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectIce"),
  [Enum.AuraEffect.AE_HP_REDUCE] = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectReduceHP"),
  [Enum.AuraEffect.AE_AI_AVOID] = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectAiAvoid"),
  [Enum.AuraEffect.AE_MAGIC_WIND] = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectMagicWind")
}

function AuraEffectRegistry.Get(Owner, Index, Effect)
  if not Owner then
    return nil
  end
  local Type = Effect.aura_effect_type
  if not Type then
    return nil
  end
  if 0 == Type then
    return nil
  end
  local Klass = AuraEffectRegistry[Type]
  if not Klass then
    return nil
  end
  return Klass(Owner, Index, Effect)
end

return AuraEffectRegistry
