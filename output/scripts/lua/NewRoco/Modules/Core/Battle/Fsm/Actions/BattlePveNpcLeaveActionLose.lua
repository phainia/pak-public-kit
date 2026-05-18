local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattlePlayAnimBaseAction
local BattlePveNpcLeaveActionLose = Base:Extend("BattlePveNpcLeaveActionLose")
FsmUtils.MergeMembers(Base, BattlePveNpcLeaveActionLose, {})

function BattlePveNpcLeaveActionLose:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattlePveNpcLeaveActionLose:OnEnter()
  Log.Debug("BattlePveNpcLeaveActionLose OnEnter")
  if BattleUtils.IsPve() then
    Log.Debug("BattlePveNpcLeaveActionLose OnEnter 1:", type(BattleManager.battlePawnManager:GetPlayerEnemyTeam().model))
    self:Play(BattleManager.battlePawnManager:GetPlayerEnemyTeam(), nil, BattleConst.Define.PveNPCLeaveBattleLose, false)
  else
    Log.Debug("BattlePveNpcLeaveActionLose OnEnter 2")
    self:Finish()
  end
end

function BattlePveNpcLeaveActionLose:OnExit()
end

return BattlePveNpcLeaveActionLose
