local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local Base = RocoSkillAction
local RocoShowHideSelfEffectAction = Base:Extend("RocoShowHideSelfEffectAction")

function RocoShowHideSelfEffectAction:Ctor()
  Base.Ctor(self)
end

function RocoShowHideSelfEffectAction:OnActionStart()
  local caster = self:GetActorByActorInfo(self.DefaultExecuteActorInfo)
  if not caster then
    return
  end
  if caster.FxIDs then
    for i, v in pairs(caster.FxIDs) do
      caster.RocoFX:ShowHideFxByID(v, self.bShowSelfActive)
    end
  end
  if not self.bShowSelfActive then
    caster.needHideSelf = true
  end
end

return RocoShowHideSelfEffectAction
