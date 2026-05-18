local CinematicAutomation
if _G.AppMain:HasDebug() then
  CinematicAutomation = require("NewRoco.Modules.System.Debug.Cinematic.CinematicAutomation")
end
CinematicAutomator = {}

function CinematicAutomator.StartTest()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "gc.TimeBetweenPurgingPendingKillObjects 999999999.1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.shadow.csmcaching 0")
  if _G.AppMain:HasDebug() then
    CinematicAutomation:StartAutomationWithSavedConfig()
  end
  return true
end

function CinematicAutomator.Reset()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "gc.TimeBetweenPurgingPendingKillObjects 60")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.shadow.csmcaching 1")
end

function CinematicAutomator.HasFinished()
  if _G.AppMain:HasDebug() and CinematicAutomation:IsFinished() then
    local SequencePerfSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.USequencePerfSubsystem)
    if SequencePerfSubsystem:GetRunningStatus() == UE.EPerfEventProfilerRunningStatus.Stopped then
      CinematicAutomator.Reset()
      return true
    end
  end
  return false
end

function CinematicAutomator.HasStarted()
  if not _G.AppMain:HasDebug() then
    return false
  end
  return CinematicAutomation.is_started
end

return CinematicAutomator
