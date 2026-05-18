local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local AutoUseSkillCommand = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.AutoUseSkillCommand")
local AutoChangePetInBagCommand = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.AutoChangePetInBagCommand")
local AutoClickPetInSceneCommand = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.AutoClickPetInSceneCommand")
local AutoWaitSecondCommand = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.AutoWaitSecondCommand")
local AutoEscapeCommand = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.AutoEscapeCommand")
local AutoClickDialogCommand = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.AutoClickDialogCommand")
local AutoCatchPetInBagCommand = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.AutoCatchPetInBagCommand")
local AutoReplayBattleCommand = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.AutoReplayBattleCommand")
local AutoPlayBattleRecordsOutput = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.AutoPlayBattleRecordsOutput")
local JsonUtils = require("Common.JsonUtils")
local BattleAutoTest = NRCClass:Extend()

function BattleAutoTest:Ctor()
  self.IsStartBattle = false
  self.IsAutoBattle = false
  self.CommandsInBattle = {}
  self.CommandsOutBattle = {}
  self.CurCommand = nil
  self.failNumber = 0
  self.TotalNum = 0
  self.TestNum = 0
  self.ErrorNum = 0
  self.TimeInfo = ""
  self.PlatForm = ""
  NRCEventCenter:RegisterEvent("BattleAutoTest", self, BattleEvent.EnterBattle, self.OnEnterBattle)
  NRCEventCenter:RegisterEvent("BattleAutoTest", self, MainUIModuleEvent.MAINUIOPEN, self.OnExitBattle)
  NRCEventCenter:RegisterEvent("BattleAutoTest", self, TaskModuleEvent.BattleOver, self.OnExitBattle)
end

function BattleAutoTest:Destroy()
  self:SetIsStart(false)
  NRCEventCenter:UnRegisterEvent(self, BattleEvent.EnterBattle, self.OnEnterBattle)
  NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.MAINUIOPEN, self.OnExitBattle)
  NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.BattleOver, self.OnExitBattle)
end

function BattleAutoTest:SetIsStart(isStart)
  if self.IsAutoBattle ~= isStart then
    self.IsAutoBattle = isStart
    UE4.UNRCStatics.ExecConsoleCommand("Stat UnitGraph")
    if not isStart then
      UE4.UNRCStatics.ExecConsoleCommand("Stat Unit")
      if self.IsAutoPlayBattleRecords then
        self.IsAutoPlayBattleRecords = false
        self.AutoReplayErrorRecords:WriteToFile()
        self.AutoReplayErrorRecords = nil
      end
    end
  end
end

function BattleAutoTest:OnEnterBattle()
  self.IsStartBattle = true
  if self.IsAutoBattle then
    UE4.UNRCPlatformGameInstance.GetInstance():StartErrorCount()
  end
  self:ExecuteNext()
end

function BattleAutoTest:OnExitBattle()
  if self.IsStartBattle then
    self.IsStartBattle = false
    self.CommandsInBattle = {}
    if self.IsAutoBattle then
      UE4.UNRCPlatformGameInstance.GetInstance():EndErrorCount()
    end
  end
  if self.IsAutoBattle then
    self:ExecuteNext(true)
  end
end

function BattleAutoTest:StartAutoPlayBattleRecords(recordsFileName)
  if self.IsAutoBattle then
    Log.Error("BattleAutoTest  \229\183\178\231\187\143\229\156\168\232\135\170\229\138\168\229\140\150\230\181\139\232\175\149\228\184\173 \230\151\160\230\179\149\229\188\128\229\167\139\230\150\176\231\154\132\232\135\170\229\138\168\229\140\150\230\181\139\232\175\149")
    return
  end
  if string.IsNilOrEmpty(recordsFileName) then
    recordsFileName = "AutoPlayBattleRecords"
  end
  local RSPTable = require("Common.LocalServer.LocalBattleRSPTable")
  RSPTable.SwitchToAutoReplay()
  self.failNumber = 0
  self.TotalNum = 0
  self.TestNum = 0
  self.ErrorNum = 0
  local File = string.format("%sAutoBattle/%s.txt", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), recordsFileName)
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local result, success = UE4.UNRCStatics.LoadToString(File)
  if success then
    local commandString = string.Split(result, "\n")
    commandString = commandString or {result}
    local fileName
    local recordsLength = #commandString
    self.TimeInfo = string.gsub(commandString[1], "[\r\n]+$", "")
    local battleVersion = BattleReplayCachePool:GetUploadVersion()
    self.AutoReplayErrorRecords = AutoPlayBattleRecordsOutput(recordsLength - 1, self.TimeInfo, battleVersion)
    self.PlatForm = string.gsub(commandString[2], "[\r\n]+$", "")
    for i = 3, recordsLength do
      fileName = string.gsub(commandString[i], "[\r\n]+$", "")
      if not string.IsNilOrEmpty(fileName) then
        self.TotalNum = self.TotalNum + 1
        table.insert(self.CommandsOutBattle, AutoReplayBattleCommand(fileName, true, true))
        table.insert(self.CommandsOutBattle, AutoWaitSecondCommand(3, true))
      end
    end
    Log.Debug("StartAutoPlayBattleRecords", File, #self.CommandsOutBattle)
    if #self.CommandsOutBattle > 0 then
      self.IsAutoPlayBattleRecords = true
      self:SetIsStart(true)
      self.LogFilePath = UE4.UNRCPlatformGameInstance.GetInstance():StartAutoBattle()
      self:ExecuteNext(true)
    end
  else
    Log.Error("\232\135\170\229\138\168\229\140\150\229\155\158\230\148\190\232\132\154\230\156\172\228\184\141\229\173\152\229\156\168\239\188\129\239\188\129\239\188\129")
  end
  return nil
end

function BattleAutoTest:AddAutoPlayErrorLog(battleId, serverName, errorReason)
  self.AutoReplayErrorRecords:AddErrorLog(battleId, serverName, errorReason)
end

function BattleAutoTest:AddAutoPlayFileErrorLog(fileName, errorReason)
  self.AutoReplayErrorRecords:AddFileError(fileName, errorReason)
end

function BattleAutoTest:StartAutoBattle(FileName)
  if self.IsAutoBattle then
    Log.Error("BattleAutoTest  \229\183\178\231\187\143\229\156\168\232\135\170\229\138\168\229\140\150\230\181\139\232\175\149\228\184\173 \230\151\160\230\179\149\229\188\128\229\167\139\230\150\176\231\154\132\232\135\170\229\138\168\229\140\150\230\181\139\232\175\149")
    return
  end
  if string.IsNilOrEmpty(FileName) then
    FileName = "DefaultAutoBattle"
  end
  self.failNumber = 0
  local File = string.format("%sScript/Data/AutoBattle/%s.txt", UE4.UBlueprintPathsLibrary.ProjectContentDir(), FileName)
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local result, success = UE4.UNRCStatics.LoadToString(File)
  if success then
    local commandString = string.Split(result, "\n")
    commandString = commandString or {result}
    for i = 1, #commandString do
      self:CreatAndAddCommand(true, commandString[i])
    end
    if #self.CommandsOutBattle > 0 then
      self:SetIsStart(true)
      self.LogFilePath = UE4.UNRCPlatformGameInstance.GetInstance():StartAutoBattle()
      self:ExecuteNext(true)
    end
  else
    Log.Error("\232\135\170\229\138\168\229\140\150\232\132\154\230\156\172\228\184\141\229\173\152\229\156\168\239\188\129\239\188\129\239\188\129")
  end
  return nil
end

function BattleAutoTest:LoadBattleTest(isHandle, FileName)
  if isHandle and self.IsAutoBattle then
    return
  end
  local File = string.format("%sScript/Data/AutoBattle/%s.txt", UE4.UBlueprintPathsLibrary.ProjectContentDir(), FileName)
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local result, success = UE4.UNRCStatics.LoadToString(File)
  if success then
    local commandString = string.Split(result, "\n")
    for i = 1, #commandString do
      self:CreatAndAddCommand(false, commandString[i])
    end
    self:ExecuteNext()
  else
    Log.Error("\232\135\170\229\138\168\229\140\150\232\132\154\230\156\172\228\184\141\229\173\152\229\156\168\239\188\129\239\188\129\239\188\129")
  end
  return nil
end

function BattleAutoTest:CreatAndAddCommand(isOutBattle, command)
  local commands = command:split("\r")
  if commands and commands[1] then
    command = commands[1]
  end
  local params = string.Split(command, " ")
  if params and #params > 0 then
    for i = #params, 1, -1 do
      if "" == params[i] then
        table.remove(params, i)
      end
    end
    local commandsArray
    if isOutBattle then
      commandsArray = self.CommandsOutBattle
    else
      commandsArray = self.CommandsInBattle
    end
    if #params > 0 then
      if "\228\189\191\231\148\168\230\138\128\232\131\189" == params[1] then
        table.insert(commandsArray, AutoUseSkillCommand(tonumber(params[2])))
      elseif "\230\155\180\230\141\162\229\174\160\231\137\169" == params[1] then
        table.insert(commandsArray, AutoChangePetInBagCommand(tonumber(params[2])))
        table.insert(commandsArray, AutoWaitSecondCommand(2))
        table.insert(commandsArray, AutoClickPetInSceneCommand(false))
      elseif "\233\128\131\232\183\145" == params[1] then
        table.insert(commandsArray, AutoEscapeCommand())
        table.insert(commandsArray, AutoWaitSecondCommand(2))
        table.insert(commandsArray, AutoClickDialogCommand(true))
      elseif "\230\141\149\230\141\137\229\174\160\231\137\169" == params[1] then
        table.insert(commandsArray, AutoCatchPetInBagCommand(tonumber(params[2])))
        table.insert(commandsArray, AutoWaitSecondCommand(2))
        table.insert(commandsArray, AutoClickPetInSceneCommand(true))
      elseif "\229\155\158\230\148\190" == params[1] then
        for i = 2, #params do
          if params[i] and string.len(params[i]) > 0 then
            table.insert(commandsArray, AutoReplayBattleCommand(params[i], isOutBattle))
            table.insert(commandsArray, AutoWaitSecondCommand(3, isOutBattle))
          end
        end
      elseif "\229\174\160\231\137\169\230\173\187\228\186\161" == params[1] then
      end
    end
  end
end

function BattleAutoTest:ExecuteNext(isOutBattle)
  if isOutBattle then
    if #self.CommandsOutBattle > 0 then
      if not self.IsStartBattle and not self.CommandsOutBattle[1].IsExecuting and not self.CommandsOutBattle[1].IsExecuted then
        self.CommandsOutBattle[1]:ExecuteCommand()
        self.CurCommand = self.CommandsOutBattle[1]
      end
    else
      self:SetIsStart(false)
      self.CurCommand = nil
      UE4.UNRCPlatformGameInstance.GetInstance():EndAutoBattle()
      local logInfo = {
        platForm = self.PlatForm,
        time = self.TimeInfo,
        recordTotalNum = self.TotalNum,
        recordTestNum = self.TestNum,
        recordErrorNum = self.ErrorNum
      }
      if self.CacheError then
        self.ErrorNum = #self.CacheError
        logInfo.recordErrorNum = self.ErrorNum
        logInfo.recordData = self.CacheError
      else
        self.ErrorNum = 0
        logInfo.recordErrorNum = self.ErrorNum
      end
      JsonUtils.DumpSaved("AutoBattleErrorLog" .. os.date("%Y-%m-%d_%H_%M_%S", os.time()), logInfo)
    end
  elseif #self.CommandsInBattle > 0 and self.IsStartBattle and not self.CommandsInBattle[1].IsExecuting and not self.CommandsInBattle[1].IsExecuted then
    self.CommandsInBattle[1]:ExecuteCommand()
    self.CurCommand = self.CommandsInBattle[1]
  end
end

function BattleAutoTest:CommandComplete(command)
  if command.replayFileName then
    self.TestNum = self.TestNum + 1
  end
  local isOutBattle = command.IsOutBattleCommand
  local commandsArray
  if isOutBattle then
    commandsArray = self.CommandsOutBattle
  else
    commandsArray = self.CommandsInBattle
  end
  if commandsArray[1] == command and command.IsExecuted then
    table.remove(commandsArray, 1)
  end
  self.CurCommand = nil
  self:ExecuteNext(isOutBattle)
end

function BattleAutoTest:CommandBreak(command)
  if self.IsAutoBattle then
    self.CommandsInBattle = {}
    self.CommandsOutBattle = {}
    self:SetIsStart(false)
    self.CurCommand = nil
    self:AddFailNumber()
    UE4.UNRCPlatformGameInstance.GetInstance():EndAutoBattle()
  end
end

function BattleAutoTest:BreakCommand()
  if self.CurCommand then
    self.CurCommand:Break()
  end
end

function BattleAutoTest:AddFailNumber()
  if self.IsAutoBattle and self.IsStartBattle then
    self.failNumber = self.failNumber + 1
  end
end

return BattleAutoTest
