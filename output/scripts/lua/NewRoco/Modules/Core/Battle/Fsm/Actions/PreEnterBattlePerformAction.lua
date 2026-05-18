local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleActionBase")
local Base = BattleActionBase
local PreEnterBattlePerformAction = Base:Extend("PreEnterBattlePerformAction")
FsmUtils.MergeMembers(Base, PreEnterBattlePerformAction, {})

function PreEnterBattlePerformAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientAnimAction)
end

function PreEnterBattlePerformAction:OnEnter()
  _G.BattleManager:InitBattleField()
  if self:CheckTeamPlay() then
    self:TeamBattlePrePerform()
  else
    self:Finish()
  end
end

function PreEnterBattlePerformAction:CheckTeamPlay()
  if BattleUtils.IsWeeklyChallenge() then
    return true
  elseif not BattleUtils.IsTeam() and not BattleUtils.IsFinalBattleP1() then
    return false
  elseif _G.BattleManager.battleRuntimeData.battleStartParam:IsReconnect() then
    return false
  elseif _G.BattleManager.battleRuntimeData:IsInReplayMode() then
    return true
  end
  return true
end

function PreEnterBattlePerformAction:TeamBattlePrePerform()
  if BattleUtils.IsBloodTeam() then
    BattlePiecesManager:Play("NewRoco.Modules.Core.Battle.BattleCore.Pieces.Instances.BattlePiecesTeamEnterPerform", self, self.Finish)
  elseif BattleUtils.IsBeastTeam() then
    BattlePiecesManager:Play("NewRoco.Modules.Core.Battle.BattleCore.Pieces.Instances.BattlePiecesBeastTeamEnterPerform", self, self.Finish)
  elseif BattleUtils.IsFinalBattleP1() then
    BattlePiecesManager:Play("NewRoco.Modules.Core.Battle.BattleCore.Pieces.Instances.BattleFinalP1EnterPerform", self, self.Finish)
  elseif BattleUtils.IsWeeklyChallenge() then
    _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OpenLoadingCurtain, self, self.Finish)
  else
    self:Finish()
  end
end

function PreEnterBattlePerformAction:SaveBlackboard(blackboard, name)
  FsmUtils.SaveAsProperty(self.fsm, blackboard, name)
end

return PreEnterBattlePerformAction
