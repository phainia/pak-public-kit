local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local Base = RocoSkillAction
local RocoDispatchSkillEventAction = Base:Extend("RocoDispatchSkillEventAction")

function RocoDispatchSkillEventAction:Ctor()
  Base.Ctor(self)
end

function RocoDispatchSkillEventAction:OnActionStart()
  if _G.RocoSkillEventCenter then
    _G.RocoSkillEventCenter:DispatchEvent(self.RawSkillEvent)
    if self.RawSkillEvent == "HitFBBossShield" then
      _G.BattleEventCenter:Dispatch(BattlePerformEvent.WishPowerShow)
    end
  end
end

return RocoDispatchSkillEventAction
