local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleReplayManager = NRCClass:Extend()

function BattleReplayManager:Ctor()
  self.replayTargetRound = 1
  self.hasReplayFinished = false
end

function BattleReplayManager:InitClientEnv()
  _G.BattleManager.battleRuntimeData:SetBattleMode(BattleEnum.BattleMode.Replay)
end

function BattleReplayManager:ResetClientEnv()
  _G.BattleManager.battleNetManager.battleServer = _G.ZoneServer
end

function BattleReplayManager:DoReplayBattle(battleID)
  self.replayTargetRound = 1
  self.hasReplayFinished = false
  BattleReplayServer:Start()
  self:InitClientEnv()
  _G.BattleReplayServer:BattleEnter(battleID)
end

function BattleReplayManager:DoReplayRound(battleID, roundIdx)
  self:SetRoundSyncData(battleID, roundIdx)
  local notify = _G.BattleReplayCachePool:GetRoundData(battleID, roundIdx)
  Log.Debug("BattleReplayManager DoReplayRound:", table.tostring(notify))
  local performPlayer = _G.BattleManager:GetTurnPlayer()
  performPlayer:RunFlows(notify.flow_data.flow, notify.settle_info, self, self.OnReplayComplete, true)
end

function BattleReplayManager:SetRoundSyncData(battleID, roundIdx)
  local data = _G.BattleReplayCachePool:GetRoundSyncData(battleID, roundIdx)
  _G.BattleManager.battlePawnManager:RefreshBattleField(data.state_info)
end

function BattleReplayManager:OnReplayComplete()
  Log.Debug("BattleReplayManager OnRelayComplete")
  self.replayTargetRound = 1
  self.hasReplayFinished = true
end

return BattleReplayManager
