local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleShowTeamBattleWinAction = BattlePlayAnimBaseAction:Extend("BattleShowTeamBattleWinAction")

function BattleShowTeamBattleWinAction:OnEnter()
  self.BattleManager = _G.BattleManager
  self.Boss = self.BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_TEAMBATTLE_BALANCELENS_END)
  if BattleUtils.IsBloodTeam() then
    local RewardData = self.BattleManager.battleRuntimeData.battleSettleData:BattleRewardData()
    if self.BattleManager.battleRuntimeData.battleExitParam.IsCatchSuccess and RewardData and RewardData.rewards and #RewardData.rewards > 0 then
      NRCModeManager:DoCmd(BattleUIModuleCmd.OpenGetItemsPanel, true, RewardData, self.BattleManager.battleRuntimeData.battleSettleData:BattlePrivilegeCliChannel(), self.BattleManager.battleRuntimeData.battleSettleData:BattleMedal())
    else
      self:CloseResult()
    end
  else
    self:CloseResult()
  end
end

function BattleShowTeamBattleWinAction:SafeExit()
  self:CloseResult()
end

function BattleShowTeamBattleWinAction:CloseResult()
  self.fsm:Resume()
  self:Finish()
end

function BattleShowTeamBattleWinAction:OnFinish()
  BattlePlayAnimBaseAction:OnFinish(self)
  self.Boss = nil
  self.BattleManager = nil
  _G.BattleEventCenter:UnBind(self)
end

function BattleShowTeamBattleWinAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.BATTLE_TEAMBATTLE_BALANCELENS_END then
    self:CloseResult(true)
    return true
  end
end

return BattleShowTeamBattleWinAction
