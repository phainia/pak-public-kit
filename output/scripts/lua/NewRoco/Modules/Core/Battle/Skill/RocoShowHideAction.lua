local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local RocoShowHideAction = RocoSkillAction:Extend("RocoShowHideAction")

function RocoShowHideAction:ShowHideSelfFx(Target, IsShow)
  if not self.bUpdateSelfFx then
    return
  end
  if Target.FxIDs then
    for i, v in pairs(Target.FxIDs) do
      Target.RocoFX:ShowHideFxByID(v, IsShow)
    end
  end
  if not IsShow then
    Target.needHideSelf = true
  end
end

return RocoShowHideAction
