local Base = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.BattleAutoCommand")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local AutoReplayBattleCommand = Base:Extend("AutoReplayBattleCommand")

function AutoReplayBattleCommand:Ctor(fileName, isOutBattle, isReadFromSaved)
  Base.Ctor(self)
  self.replayFileName = fileName
  self.IsOutBattleCommand = isOutBattle
  self.isReadFromSaved = isReadFromSaved
end

function AutoReplayBattleCommand:AddListener()
  NRCEventCenter:RegisterEvent("AutoReplayBattleCommand", self, MainUIModuleEvent.MAINUIOPEN, self.CompleteCommand)
  NRCEventCenter:RegisterEvent("AutoReplayBattleCommand", self, TaskModuleEvent.BattleOver, self.CompleteCommand)
end

function AutoReplayBattleCommand:ExecuteCommand()
  Base.ExecuteCommand(self)
  Log.Warning("BattleAutoTest  \229\188\128\229\167\139\230\146\173\230\148\190\230\136\152\230\150\151\229\155\158\230\148\190  \229\155\158\230\148\190\230\150\135\228\187\182\229\144\141\231\167\176 ", self.replayFileName)
  _G.BattleEventCenter:Bind(self, BattleEvent.PUSHBACK_CMD_SENT, BattleEvent.ROUND_STATE_SELECT)
  local loadResult = BattleReplayCachePool:LoadBattleData(self.replayFileName, true, self.isReadFromSaved)
  if loadResult then
    local battleID = BattleReplayCachePool:TryGetBattleIDByName(self.replayFileName)
    BattleReplayManager:DoReplayBattle(battleID)
    BattleReplayCachePool:DumpBattleDataToString(battleID, false)
    self:CloseTimer()
    self.CheckDeadTimer = _G.TimerManager:CreateTimer(self, "AutoReplayBattleCommand", 40, nil, self.OnTimeOut, 3)
  else
    Log.Error("BattleAutoTest.AutoReplayBattleCommand \230\137\167\232\161\140\229\164\177\232\180\165,\229\155\158\230\148\190\230\150\135\228\187\182\229\138\160\232\189\189\229\164\177\232\180\165, \229\155\158\230\148\190\230\150\135\228\187\182\229\144\141\231\167\176: ", self.replayFileName)
    BattleAutoTest:AddAutoPlayFileErrorLog(self.replayFileName, string.format("\229\155\158\230\148\190\230\150\135\228\187\182\229\138\160\232\189\189\229\164\177\232\180\165, \229\155\158\230\148\190\230\150\135\228\187\182\229\144\141\231\167\176: %s", self.replayFileName))
    _G.BattleAutoTest:AddFailNumber()
    self:CompleteCommand()
  end
end

function AutoReplayBattleCommand:RestartTimer()
  if self.CheckDeadTimer ~= nil then
    self.CheckDeadTimer:Restart()
  end
end

function AutoReplayBattleCommand:CloseTimer()
  if self.CheckDeadTimer ~= nil then
    self.CheckDeadTimer:Stop()
    self.CheckDeadTimer:Clear()
    self.CheckDeadTimer = nil
  end
end

function AutoReplayBattleCommand:RemoveListener()
  NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.MAINUIOPEN, self.CompleteCommand)
  NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.BattleOver, self.CompleteCommand)
  _G.BattleEventCenter:UnBind(self)
end

function AutoReplayBattleCommand:LogFinish()
  self:CloseTimer()
  Log.Warning("BattleAutoTest  \230\146\173\230\148\190\230\136\152\230\150\151\229\155\158\230\148\190\231\187\147\230\157\159 \229\155\158\230\148\190\230\150\135\228\187\182\229\144\141\231\167\176 ", self.replayFileName)
end

function AutoReplayBattleCommand:OnTimeOut()
  Log.Warning("BattleAutoTest.AutoReplayBattleCommand \229\155\158\230\148\190\232\182\133\230\151\182, \229\155\158\230\148\190\230\150\135\228\187\182\229\144\141\231\167\176: ", self.replayFileName)
  BattleAutoTest:AddAutoPlayFileErrorLog(self.replayFileName, string.format("\229\155\158\230\148\190\232\182\133\230\151\182, \229\155\158\230\148\190\230\150\135\228\187\182\229\144\141\231\167\176: %s", self.replayFileName))
  self:BreakInternal()
end

function AutoReplayBattleCommand:Break()
  Log.Error("BattleAutoTest.AutoReplayBattleCommand \230\137\167\232\161\140\229\164\177\232\180\165,\230\163\128\230\181\139\229\136\176\229\155\158\230\148\190\232\191\135\231\168\139\229\135\186\231\142\176\229\141\161\230\173\187, \229\155\158\230\148\190\230\150\135\228\187\182\229\144\141\231\167\176: ", self.replayFileName)
  self:BreakInternal()
end

function AutoReplayBattleCommand:BreakInternal()
  self:CloseTimer()
  _G.BattleAutoTest:AddFailNumber()
  _G.BattleEventCenter:Dispatch(BattleEvent.EnterNormalOver)
end

function AutoReplayBattleCommand:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PUSHBACK_CMD_SENT then
    self:RestartTimer()
    return true
  elseif eventName == BattleEvent.ROUND_STATE_SELECT then
    self:RestartTimer()
    return true
  end
end

return AutoReplayBattleCommand
