local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.Helper.Magic.MagicAbilityBaseHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local WindAbilityHelper = Base:Extend("WindAbilityHelper")

function WindAbilityHelper:Ctor(abilityConfig)
  Base.Ctor(self, abilityConfig)
  self._buffName = "PrepareWindBuff"
end

return WindAbilityHelper
