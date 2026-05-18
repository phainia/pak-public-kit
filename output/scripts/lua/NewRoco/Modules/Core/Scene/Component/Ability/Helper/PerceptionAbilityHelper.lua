local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local PerceptionAbilityHelper = Base:Extend("PerceptionAbilityHelper")

function PerceptionAbilityHelper:Ctor(abilityConfig)
  Base.Ctor(self, abilityConfig)
  self._customParams = ProtoMessage:newPlayerStatusCustomParams()
end

function PerceptionAbilityHelper:HandleStatus(caster, pet, ...)
  local statusComponent = caster.statusComponent
  self._customParams.perception_param.pet_gid = pet.gid
  for _, v in pairs(self.config.add_status) do
    statusComponent:ApplyStatus(v, nil, self.config.add_sub_status, self._customParams, ...)
  end
  for _, v in pairs(self.config.remove_status) do
    statusComponent:RemoveStatus(v, nil, self.config.remove_sub_status, ...)
  end
end

return PerceptionAbilityHelper
