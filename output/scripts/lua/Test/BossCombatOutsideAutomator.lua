local BossCombatOutsideAutomation
if _G.AppMain:HasDebug() then
  BossCombatOutsideAutomation = require("NewRoco.Modules.System.Debug.BossCombatOutside.BossCombatOutsideAutomation")
end
BossCombatOutsideAutomator = {}

function BossCombatOutsideAutomator.StartTest()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "gc.TimeBetweenPurgingPendingKillObjects 999999999.1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.shadow.csmcaching 0")
  if _G.AppMain:HasDebug() then
    BossCombatOutsideAutomation:StartAutomationWithSavedConfig()
  end
  return true
end

function BossCombatOutsideAutomator.Reset()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "gc.TimeBetweenPurgingPendingKillObjects 60")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.shadow.csmcaching 1")
end

function BossCombatOutsideAutomator.HasFinished()
  if _G.AppMain:HasDebug() and BossCombatOutsideAutomation:IsFinished() then
    local PerfChannelSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UPerfChannelSubsystem)
    if PerfChannelSubsystem:GetRunningStatus() == UE.EPerfEventProfilerRunningStatus.Stopped then
      BossCombatOutsideAutomator.Reset()
      return true
    end
  end
  return false
end

function BossCombatOutsideAutomator.HasStarted()
  if not _G.AppMain:HasDebug() then
    return false
  end
  return BossCombatOutsideAutomation:IsStarted()
end

return BossCombatOutsideAutomator
