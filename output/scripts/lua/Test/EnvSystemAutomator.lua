local EnvSystemAutomation
if _G.AppMain:HasDebug() then
  EnvSystemAutomation = require("NewRoco.Modules.System.Debug.EnvSystem.EnvSystemAutomation")
end
EnvSystemAutomator = {}

function EnvSystemAutomator.StartTest()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "gc.TimeBetweenPurgingPendingKillObjects 999999999.1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.shadow.csmcaching 0")
  if _G.AppMain:HasDebug() then
    return EnvSystemAutomation:StartTest()
  else
    return false
  end
end

function EnvSystemAutomator.Reset()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "gc.TimeBetweenPurgingPendingKillObjects 60")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.shadow.csmcaching 1")
end

function EnvSystemAutomator.HasFinished()
  if _G.AppMain:HasDebug() and EnvSystemAutomation:IsFinished() then
    local EnvSystemPerfSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UEnvSystemPerfSubsystem)
    if EnvSystemPerfSubsystem:GetRunningStatus() == UE.EPerfEventProfilerRunningStatus.Stopped then
      EnvSystemAutomator.Reset()
      return true
    end
  end
  return false
end

function EnvSystemAutomator.HasStarted()
  if not _G.AppMain:HasDebug() then
    return false
  end
  return EnvSystemAutomation:IsStarted()
end

return EnvSystemAutomator
