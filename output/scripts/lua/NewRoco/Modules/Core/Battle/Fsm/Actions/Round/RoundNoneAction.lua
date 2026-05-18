local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleRoundAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Round.BattleRoundAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleRoundAction
local RoundNoneAction = Base:Extend("RoundNoneAction")
FsmUtils.MergeMembers(Base, RoundNoneAction, {})

function RoundNoneAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function RoundNoneAction:OnEnter()
  self.fsm:Pause()
end

function RoundNoneAction:OnExit()
end

return RoundNoneAction
