local AutoPlayBattleRecordsOutput = NRCClass:Extend()
local tInsert = table.insert
local sFormat = string.format

function AutoPlayBattleRecordsOutput:Ctor(playCount, timeInfo, uploadVersion)
  self.playCount = playCount
  self.errorCount = 0
  self.timeInfo = timeInfo
  self.uploadVersion = uploadVersion
  self.errorDetail = {}
end

function AutoPlayBattleRecordsOutput:AddErrorLog(battleId, serverName, errorReason)
  local errorList = self.errorDetail[battleId]
  if nil == errorList then
    errorList = {}
    errorList.serverName = serverName or ""
    errorList.reasonList = {}
    self.errorDetail[battleId] = errorList
    self.errorCount = self.errorCount + 1
  end
  tInsert(errorList.reasonList, errorReason)
end

function AutoPlayBattleRecordsOutput:AddFileError(fileName, errorReason)
  local battleID = BattleReplayCachePool:TryGetBattleIDByName(fileName)
  self:AddErrorLog(battleID, nil, errorReason)
end

function AutoPlayBattleRecordsOutput:WriteToFile()
  local File = sFormat("%sLogs/AutoReplayErrorRecords.txt", UE4.UBlueprintPathsLibrary.ProjectSavedDir())
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local Content = sFormat("\233\152\178\229\141\161\230\173\187\230\160\161\233\170\140\230\151\182\233\151\180 %s\239\188\140\229\144\136\232\174\161 %s \229\156\186\230\136\152\230\150\151\239\188\140\229\133\182\228\184\173 %s \229\156\186\229\164\141\231\142\176\229\188\130\229\184\184\239\188\140\229\174\162\230\136\183\231\171\175\231\137\136\230\156\172\229\143\183 %s \n", self.timeInfo, self.playCount, self.errorCount, self.uploadVersion)
  for battleId, reasonInfo in pairs(self.errorDetail) do
    local errorReasonStr = ""
    for i, reason in ipairs(reasonInfo.reasonList) do
      errorReasonStr = sFormat("\229\142\159\229\155\160:%s\t", reason)
    end
    if string.IsNilOrEmpty(reasonInfo.serverName) then
      Content = Content .. sFormat("\230\136\152\230\150\151 ID:%s, %s\n", battleId, errorReasonStr)
    else
      Content = Content .. sFormat("\230\136\152\230\150\151 ID:%s, \230\156\141\229\138\161\229\153\168\229\144\141\229\173\151:%s, %s\n", battleId, reasonInfo.serverName, errorReasonStr)
    end
  end
  local Success = UE4.UNRCStatics.WriteToFile(File, Content)
end

return AutoPlayBattleRecordsOutput
