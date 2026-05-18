local BattleLogger = NRCClass()

function BattleLogger:Ctor()
  self.logPath = "Logs"
  self.logLst = {}
end

function BattleLogger:Log(logStr)
  if false then
    local milliseconds = os.msTime()
    local current_time = os.date("*t")
    local formatted_time = string.format("%04d-%02d-%02d %02d:%02d:%02d%s", math.round(current_time.year), math.round(current_time.month), math.round(current_time.day), math.round(current_time.hour), math.round(current_time.min), math.round(current_time.sec), string.format(".%03d", math.round(milliseconds)))
    table.insert(self.logLst, {formatted_time, logStr})
  end
end

function BattleLogger:Save()
  if false then
    local current_time = os.msTime()
    local File = string.format("%s%s.txt", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), "BattleLog" .. current_time)
    File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
    Log.Debug("BattleLogger Save filename:", File)
    local dumpStr = ""
    for i = 1, #self.logLst do
      dumpStr = dumpStr .. "[" .. self.logLst[i][1] .. "]" .. self.logLst[i][2] .. "\n"
    end
    local Content = dumpStr
    local Success = UE4.UNRCStatics.WriteToFile(File, Content)
  end
end

function BattleLogger.CheckDebugModuleFuncIsValid(path, funcName)
  if _G.AppMain:HasDebug() then
    local tab = NRCModuleManager:DoCmd(DebugModuleCmd.GetTabData, path)
    if tab then
      return nil ~= tab[funcName]
    else
      return false
    end
  else
    return false
  end
end

return BattleLogger
