local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.Helper.Magic.MagicAbilityBaseHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local MagicTransformAbilityHelper = Base:Extend("MagicTransformAbilityHelper")

function MagicTransformAbilityHelper:Ctor(abilityConfig)
  Base.Ctor(self, abilityConfig)
  self._buffName = "MagicTransformBuff"
end

return MagicTransformAbilityHelper
