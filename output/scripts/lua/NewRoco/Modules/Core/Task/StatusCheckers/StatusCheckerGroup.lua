local StatusCheckerEnum = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerEnum")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local StatusCheckerGroup = Base:Extend("StatusCheckerGroup")
StatusCheckerGroup.CheckerRegistry = {
  [StatusCheckerEnum.None] = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase"),
  [StatusCheckerEnum.Battle] = require("NewRoco.Modules.Core.Task.StatusCheckers.BattleStatusChecker"),
  [StatusCheckerEnum.Dialogue] = require("NewRoco.Modules.Core.Task.StatusCheckers.DialogueStatusChecker"),
  [StatusCheckerEnum.Cinematic] = require("NewRoco.Modules.Core.Task.StatusCheckers.CinematicStatusChecker"),
  [StatusCheckerEnum.MainPanel] = require("NewRoco.Modules.Core.Task.StatusCheckers.MainPanelStatusChecker"),
  [StatusCheckerEnum.Teleport] = require("NewRoco.Modules.Core.Task.StatusCheckers.TeleportStatusChecker"),
  [StatusCheckerEnum.Scene] = require("NewRoco.Modules.Core.Task.StatusCheckers.SceneStatusChecker"),
  [StatusCheckerEnum.FullScreen] = require("NewRoco.Modules.Core.Task.StatusCheckers.FullScreenStatusChecker"),
  [StatusCheckerEnum.Loading] = require("NewRoco.Modules.Core.Task.StatusCheckers.LoadingStatusChecker"),
  [StatusCheckerEnum.Catch] = require("NewRoco.Modules.Core.Task.StatusCheckers.CatchStatusChecker"),
  [StatusCheckerEnum.FastLoading] = require("NewRoco.Modules.Core.Task.StatusCheckers.FastLoadingStatusChecker"),
  [StatusCheckerEnum.TaskInArea] = require("NewRoco.Modules.Core.Task.StatusCheckers.TaskInAreaChecker"),
  [StatusCheckerEnum.AlchemyIdle] = require("NewRoco.Modules.Core.Task.StatusCheckers.AlchemyStatusChecker"),
  [StatusCheckerEnum.OnlineState] = require("NewRoco.Modules.Core.Task.StatusCheckers.OnlineStatusChecker"),
  [StatusCheckerEnum.ImageFlow] = require("NewRoco.Modules.Core.Task.StatusCheckers.ImageFlowChecker")
}

function StatusCheckerGroup:Ctor(CheckFlags, LogLevel, LogPrefix)
  Base.Ctor(self)
  self.LogLevel = LogLevel or Log.LOG_LEVEL.ELogInfo
  self.LogPrefix = LogPrefix or "Unknown"
  self.Checkers = {}
  self:CreateFromFlags(CheckFlags)
end

function StatusCheckerGroup:CreateFromFlags(CheckFlags)
  self:Reset()
  table.clear(self.Checkers)
  if not CheckFlags then
    return
  end
  if 0 == #CheckFlags then
    return
  end
  for _, Flag in ipairs(CheckFlags) do
    local CheckerClass = StatusCheckerGroup.CheckerRegistry[Flag]
    if CheckerClass then
      local Instance = CheckerClass()
      Instance.LogLevel = self.LogLevel
      Instance.LogPrefix = self.LogPrefix
      table.insert(self.Checkers, Instance)
    end
  end
end

function StatusCheckerGroup:FindChecker(Flag)
  local CheckerClass = StatusCheckerGroup.CheckerRegistry[Flag]
  if not CheckerClass then
    return nil
  end
  for _, Checker in ipairs(self.Checkers) do
    if Checker.class == CheckerClass then
      return Checker
    end
  end
  return nil
end

function StatusCheckerGroup:Check(Caller, Callback, ...)
  if self.bPaused then
    Log.Debug("Post Check", self.className, "Paused")
    self:StoreCallback(Caller, Callback, {
      ...
    })
    return false
  end
  local Pass = true
  for _, Checker in ipairs(self.Checkers) do
    if not Checker:Check(self, self.InternalCheck) then
      self:Log("Checker failed", Checker.className)
      Pass = false
    end
  end
  self.LastCheckResult = Pass
  if Pass then
    self:Log("All Pass")
    self:Reset()
    if Callback then
      if Caller then
        Callback(Caller, ...)
      else
        Callback(...)
      end
    end
    return true
  else
    self:StoreCallback(Caller, Callback, {
      ...
    })
    return false
  end
end

function StatusCheckerGroup:InternalCheck()
  if self.bPaused then
    Log.Debug("Post Check", self.className, "Paused")
    return false
  end
  for _, Checker in ipairs(self.Checkers) do
    if not Checker:CheckPass() then
      Checker.LastCheckResult = Checker:Check(self, self.InternalCheck)
      self:Log("Post Check", Checker.className, "Still Failed")
      return
    end
  end
  self:Log("All Pass!")
  self:FireCallback()
end

function StatusCheckerGroup:CheckPass()
  for _, Checker in ipairs(self.Checkers) do
    if not Checker:CheckPass() then
      self:Log("StatusCheckerGroup:CheckPass", Checker.className, "Failed")
      return false
    end
  end
  return true
end

function StatusCheckerGroup:Reset()
  self.bPaused = false
  for _, Checker in ipairs(self.Checkers) do
    Checker:Reset()
  end
  Base.Reset(self)
end

function StatusCheckerGroup:Pause()
  self.bPaused = true
end

function StatusCheckerGroup:Resume()
  self.bPaused = false
  self:InternalCheck()
end

return StatusCheckerGroup
