local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleSpecialDelayPveStopMovieAction = Base:Extend("BattleSpecialDelayPveStopMovieAction")
FsmUtils.MergeMembers(Base, BattleSpecialDelayPveStopMovieAction, {})

function BattleSpecialDelayPveStopMovieAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleSpecialDelayPveStopMovieAction:OnEnter()
end

function BattleSpecialDelayPveStopMovieAction:OnExit()
end

return BattleSpecialDelayPveStopMovieAction
