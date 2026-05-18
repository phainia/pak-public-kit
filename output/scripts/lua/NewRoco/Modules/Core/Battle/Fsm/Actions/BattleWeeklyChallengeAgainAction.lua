local Base = BattleActionBase
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleWeeklyChallengeAgainAction = Base:Extend("BattleWeeklyChallengeAgainAction")
FsmUtils.MergeMembers(Base, BattleWeeklyChallengeAgainAction, {})

function BattleWeeklyChallengeAgainAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function BattleWeeklyChallengeAgainAction:OnEnter()
  BattleBudget:ProcessAll()
  self:Finish()
end

return BattleWeeklyChallengeAgainAction
