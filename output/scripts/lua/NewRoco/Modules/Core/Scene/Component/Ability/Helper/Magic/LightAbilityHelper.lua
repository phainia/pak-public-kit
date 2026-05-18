local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.Helper.Magic.MagicAbilityBaseHelper")
local LightAbilityHelper = Base:Extend("LightAbilityHelper")

function LightAbilityHelper:Ctor(abilityConfig)
  Base.Ctor(self, abilityConfig)
  self._buffName = "PrepareLightBuff"
end

return LightAbilityHelper
