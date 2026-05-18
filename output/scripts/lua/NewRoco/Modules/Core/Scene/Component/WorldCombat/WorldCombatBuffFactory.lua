local WorldCombatBuffFactory = {}
WorldCombatBuffFactory.Registry = {
  [0] = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffBase"),
  [Enum.WorldBuffEffect.WBE_HP_REDUCE] = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffBase"),
  [Enum.WorldBuffEffect.WBE_BARRIER] = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffBarrier"),
  [Enum.WorldBuffEffect.WBE_GAIN_EXPOSE] = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffWeaknessExpose"),
  [Enum.WorldBuffEffect.WBE_STUN] = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffStun"),
  [Enum.WorldBuffEffect.WBE_MOVESPEED] = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffMoveSpeed"),
  [Enum.WorldBuffEffect.WBE_LIGATURE] = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffLigature"),
  [Enum.WorldBuffEffect.WBE_MAGIC_FALL] = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffMagicFall"),
  [Enum.WorldBuffEffect.WBE_CAST_SKILL] = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffCastSkill")
}

function WorldCombatBuffFactory.TryCreateBuff(Parent, Info)
  if not Info then
    Log.Error("\229\136\155\229\187\186Buff\229\164\177\232\180\165\239\188\140\230\178\161\230\156\137\230\149\176\230\141\174")
    return nil
  end
  local ID = Info.buff_cfg_id
  if not ID or 0 == ID then
    Log.Error("\229\136\155\229\187\186Buff\229\164\177\232\180\165\239\188\140ID\228\184\141\229\144\136\230\179\149")
    return nil
  end
  local Conf = _G.DataConfigManager:GetWorldBuffConf(ID)
  if not Conf then
    Log.Error("\229\136\155\229\187\186Buff\229\164\177\232\180\165\239\188\140\230\137\190\228\184\141\229\136\176Buff\230\149\176\230\141\174")
    return nil
  end
  local EffectType = Conf and Conf.buff_effect_type
  EffectType = EffectType or 0
  local Klass = WorldCombatBuffFactory.Registry[EffectType] or WorldCombatBuffFactory.Registry[1]
  return Klass(Parent, Info, Conf)
end

return WorldCombatBuffFactory
