local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = DebugTabBase
local DebugTabBattleRecord = Base:Extend("DebugTabBattleRecord")

function DebugTabBattleRecord:Ctor()
  Base.Ctor(self)
end

function DebugTabBattleRecord:SetupTabs()
  self:AddSample("\230\146\173\230\148\190\230\136\152\230\150\151\229\189\149\229\131\143", "TestReplayBattle")
  self:AddSample("\230\146\173\230\148\190\230\136\152\230\150\151\229\189\149\229\131\143(GM)", "ReplayBattleGM")
  self:AddSample("\230\146\173\230\148\190\230\136\152\230\150\151\229\189\149\229\131\143(\233\153\132\232\191\145)", "TestReplayBattleNearby")
  self:AddSample("\228\184\139\232\189\189\230\137\128\230\156\137\230\136\152\230\150\151\229\189\149\229\131\143", "DownBattleData")
  self:AddSample("\228\191\157\229\173\152\230\137\128\230\156\137\230\136\152\230\150\151\229\189\149\229\131\143", "SaveBattleData")
  self:AddSample("\228\191\157\229\173\152\228\184\138\228\184\128\229\156\186\230\136\152\230\150\151\229\189\149\229\131\143", "SaveCurBattleData")
  self:AddSample("\228\184\138\228\188\160\228\184\138\228\184\128\229\156\186\230\136\152\230\150\151\229\189\149\229\131\143", "ReportCurBattleData")
  self:AddSample("\231\191\187\232\175\145\230\136\152\230\150\151\230\149\176\230\141\174", "TranslateBattleData")
  self:AddSample("\232\189\172\229\140\150json\230\160\188\229\188\143", "AdaptJson")
  self:AddSample("\230\137\147\229\188\128\230\183\177\230\139\183\232\180\157\228\191\157\229\173\152\230\136\152\230\150\151\229\189\149\229\131\143", "EnableDeepCopyBattleReplay")
end

function DebugTabBattleRecord:TestReplayBattle(Name, Panel, InputText)
  local fileName
  if Panel then
    fileName = Panel:GetInputString()
  else
    fileName = InputText
  end
  if string.IsNilOrEmpty(fileName) then
    Log.Error("TestReplayBattle: fileName is empty")
    return
  end
  local result = self:ReplayBattleGM(Name, Panel, fileName)
  if result then
    self:ClosePanel()
  else
    Log.Error("ReplayBattleGM failed")
  end
end

function DebugTabBattleRecord:ReplayBattleGM(Name, Panel, fileName)
  if string.IsNilOrEmpty(fileName) then
    return false
  end
  Log.WarningFormat("ReplayBattleGM: %s", fileName)
  _G.UseNearbyLocationInsteadOfRealLocation = false
  local loadResult = BattleReplayCachePool:LoadBattleData(fileName)
  if not loadResult then
    return false
  end
  local battleID = BattleReplayCachePool:TryGetBattleIDByName(fileName)
  BattleReplayManager:DoReplayBattle(battleID)
  BattleReplayCachePool:DumpBattleDataToString(battleID, false)
  return true
end

function DebugTabBattleRecord:TestReplayBattleNearby(Name, Panel, InputText)
  _G.UseNearbyLocationInsteadOfRealLocation = true
  local fileName
  if Panel then
    fileName = Panel:GetInputString()
  else
    fileName = InputText
  end
  if string.IsNilOrEmpty(fileName) then
    Log.Error("TestReplayBattle: fileName is empty")
    return
  end
  BattleReplayCachePool:LoadBattleData(fileName)
  local battleID = BattleReplayCachePool:TryGetBattleIDByName(fileName)
  BattleReplayManager:DoReplayBattle(battleID)
  BattleReplayCachePool:DumpBattleDataToString(battleID, false)
  self:ClosePanel()
end

function DebugTabBattleRecord:DownBattleData()
  UE.UNRCStatics.DownBattleRecord()
end

function DebugTabBattleRecord:SaveBattleData()
  BattleReplayCachePool:SaveBattleData()
end

function DebugTabBattleRecord:SaveCurBattleData()
  BattleReplayCachePool:SaveCurBattleData()
end

function DebugTabBattleRecord:ReportCurBattleData()
  BattleReplayCachePool:UploadBattleDataTOCrashSight("\230\181\139\232\175\149")
end

function DebugTabBattleRecord:TranslateBattleData(Name, Panel, InputText)
  local fileName
  if Panel then
    fileName = Panel:GetInputString()
  else
    fileName = InputText
  end
  if "" == fileName then
    fileName = "03-03_15_04_18_4611729139899039821"
  end
  BattleReplayCachePool:LoadBattleData(fileName)
  local battleID = BattleReplayCachePool:TryGetBattleIDByName(fileName)
  Log.Debug("debugba  TranslateBattleData:", fileName, battleID, type(battleID))
  BattleReplayCachePool:DumpBattleDataToString(battleID, true)
end

function DebugTabBattleRecord:AdaptJson(Name, Panel, InputText)
  local JsonUtils = require("Common.JsonUtils")
  local rapidjson = require("rapidjson")
  local fileName
  if Panel then
    fileName = Panel:GetInputString()
  else
    fileName = InputText
  end
  if "" == fileName then
    return
  end
  local data = JsonUtils.LoadSaved(fileName, {})
  local Content = rapidjson.encode(data, {pretty = true, sort_keys = true})
  local File = string.format("%s%s.json", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), fileName .. "Adapt")
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local Success = UE4.UNRCStatics.WriteToFile(File, Content)
  self:ClosePanel()
end

function DebugTabBattleRecord:EnableDeepCopyBattleReplay(Name, Panel)
  BattleReplayCachePool.isUsingStreaming = false
end

return DebugTabBattleRecord
