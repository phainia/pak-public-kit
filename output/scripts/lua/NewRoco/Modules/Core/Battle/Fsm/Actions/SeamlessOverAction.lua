local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local SeamlessOverAction = BattleActionBase:Extend("SeamlessOverAction")
FsmUtils.MergeMembers(BattleActionBase, SeamlessOverAction, {})

function SeamlessOverAction:OnEnter()
  Log.Debug("SeamlessOverAction OnEnter")
  _G.BattleManager:RevertWorldPlayer()
  _G.BattleEventCenter:Dispatch(BattleEvent.BATTLE_STATE_SETTLEMENT)
  self:Finish()
end

function SeamlessOverAction:OnExit()
end

return SeamlessOverAction
