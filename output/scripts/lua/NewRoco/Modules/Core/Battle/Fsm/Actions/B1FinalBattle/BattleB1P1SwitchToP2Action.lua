local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleSwitchConfigAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.B1FinalBattle.BattleSwitchConfigAction")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleSwitchConfigAction
local BattleB1P1SwitchToP2Action = Base:Extend("BattleB1P1SwitchToP2Action")
FsmUtils.MergeMembers(Base, BattleB1P1SwitchToP2Action, {})

function BattleB1P1SwitchToP2Action:OnEnter()
  if not BattleUtils.IsB1FinalBattleP1() then
    self:Finish()
    return
  end
  BattleEventCenter:Bind(self, BattleEvent.PLAYER_SPAWNED)
  Base.OnEnter(self)
end

function BattleB1P1SwitchToP2Action:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PLAYER_SPAWNED then
    local player = (...)
    if player.model then
      self:Finish()
    end
  end
end

return BattleB1P1SwitchToP2Action
