local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleFsmInitRouter = NRCClass()

function BattleFsmInitRouter:InitFsm(envPath)
  local env = require(envPath)
  if env then
    self.envInst = env()
    self.envInst:Init()
    self.envInst:InitStates()
    self.envInst:GetFsm():Play()
    Log.Error("BattleFsmInitRouter InitFsm:", envPath)
    return self
  else
    Log.Error("BattleFsmInitRouter InitFsm failed:", envPath)
  end
end

function BattleFsmInitRouter:GetFsm()
  if self.envInst then
    return self.envInst:GetFsm()
  else
    Log.Error("BattleFsmInitRouter GetFsm failed")
  end
end

function BattleFsmInitRouter:InitBattleFsmByType()
  Log.Error("BattleFsmInitRouter InitBattleFsmByType")
  local battleType = _G.BattleManager.battleRuntimeData.battleType
  Log.Debug("BattleInitAction onenter:", battleType)
  if BattleUtils.IsPvp() then
    if self:CheckIsReconnect() or BattleUtils.IsWatchingBattle() then
    else
    end
  elseif BattleUtils.IsNpcChallenge() then
    if self:CheckIsReconnect() or BattleUtils.IsWatchingBattle() then
    else
    end
  elseif battleType == Enum.BattleType.BT_PVESPECIAL then
    if self:CheckIsReconnect() or self:CheckIsDebugConnect() then
      self:InitFsm("NewRoco.Modules.Core.Battle.Fsm.Builders.BattleFsmWild1V1Env")
    else
      Log.Debug("BattleInitAction OnEnter true:", self.BattleManager.battleRuntimeData:GetEnterBattleType())
    end
  elseif BattleUtils.IsLeaderFight() or BattleUtils.IsWorldLeaderFight() or BattleUtils.IsLeaderChallenge() then
    if self:CheckIsReconnect() or self:CheckIsDebugConnect() then
    else
    end
  elseif BattleUtils.IsBloodTeam() then
    if self:CheckIsReconnect() then
    else
    end
  elseif BattleUtils.IsBeastTeam() then
    if self:CheckIsReconnect() then
    else
    end
  elseif BattleUtils.IsFinalBattleP1() then
    if self:CheckIsReconnect() then
    else
    end
  elseif self:CheckIsReconnect() or self:CheckIsDebugConnect() then
    Log.Error("BattleInitAction OnEnter true: ~~~~", _G.BattleManager.battleRuntimeData:GetEnterBattleType())
    self:InitFsm("NewRoco.Modules.Core.Battle.Fsm.Builders.BattleFsmWild1V1Env")
  else
    if not BattleUtils.HasEnemyPlayer() then
      Log.Debug("BattleInitAction OnEnter true:", _G.BattleManager.battleRuntimeData:GetEnterBattleType())
      self:InitFsm("NewRoco.Modules.Core.Battle.Fsm.Builders.BattleFsmWild1V1Env")
    else
    end
  end
end

function BattleFsmInitRouter:CheckIsReconnect()
  if _G.BattleManager.battleRuntimeData.battleStartParam:IsReconnect() then
    local showTip = _G.DataConfigManager:GetLocalizationConf("Reconnect_Battle_Tips").msg
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, showTip)
    return true
  end
  return false
end

function BattleFsmInitRouter:CheckIsDebugConnect()
  if not _G.BattleManager.battleRuntimeData:HasValidNPC() then
    return true
  end
  return false
end

return BattleFsmInitRouter
