local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleActionBase")
local Base = BattleActionBase
local PreEnterBloodTeamBattlePerformAction = Base:Extend("PreEnterBloodTeamBattlePerformAction")
FsmUtils.MergeMembers(Base, PreEnterBloodTeamBattlePerformAction, {})

function PreEnterBloodTeamBattlePerformAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientAnimAction)
end

function PreEnterBloodTeamBattlePerformAction:OnEnter()
  if self:CheckTeamPlay() then
    BattlePiecesManager:Play("NewRoco.Modules.Core.Battle.BattleCore.Pieces.Instances.BattlePiecesTeamEnterPerform", self, self.Finish)
  else
    self:Finish()
  end
end

function PreEnterBloodTeamBattlePerformAction:CheckTeamPlay()
  if _G.BattleManager.battleRuntimeData.battleStartParam:IsReconnect() then
    return false
  elseif _G.BattleManager.battleRuntimeData:IsInReplayMode() then
    return true
  end
  return true
end

function PreEnterBloodTeamBattlePerformAction:SaveBlackboard(blackboard, name)
  FsmUtils.SaveAsProperty(self.fsm, blackboard, name)
end

return PreEnterBloodTeamBattlePerformAction
