local DelayTaskQueue = require("Profiler.Utils.DelayTaskQueue")
local EnvSystemModuleCmd = require("NewRoco.Modules.System.EnvSystem.EnvSystemModuleCmd")
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local EnvSystemProfiler = NRCClass()
EnvSystemProfiler.ProfilerStatus = {
  IDLE = 0,
  PLAYING = 1,
  FINISHED = 2
}

function EnvSystemProfiler:Ctor(config)
  self.task_queue = DelayTaskQueue()
  local preview_duration = config.preview_duration or 360
  self.time_scale = 86400 / preview_duration
  self.weather_playlist = {}
  self.profiler_status = self.ProfilerStatus.IDLE
  self.on_finished = config.on_profiler_finished or function()
  end
  self:SetupTasks(config.weather_playlist)
end

function EnvSystemProfiler:SetupTasks(whitelist)
  local weather_list = {}
  for name, value in pairs(Enum.WeatherType) do
    if value == Enum.WeatherType.WT_NONE then
    elseif whitelist and #whitelist > 0 and not table.contains(whitelist, name) then
    else
      local task = {
        weather = name,
        time_scale = self.time_scale,
        time_begin = 0,
        is_blending = false,
        onTaskFinished = function()
          PerfCatCmd.EnvSystem.Pause()
          self:AddTask(1, self.PlayNext)
          self:ProcessTaskQueue()
        end
      }
      local blending_task = table.deepCopy(task)
      blending_task.is_blending = true
      blending_task.time_scale = 5760.0
      table.insert(weather_list, blending_task)
      table.insert(weather_list, task)
    end
  end
  table.sort(weather_list, function(a, b)
    if a.weather == b.weather then
      return a.is_blending and not b.is_blending
    else
      return Enum.WeatherType[a.weather] < Enum.WeatherType[b.weather]
    end
  end)
  self.weather_playlist = weather_list
  for i, task in ipairs(self.weather_playlist) do
    Log.DebugFormat("[Sort] Weather %s, time_scale: %f, time_begin: %d, blending: %s", task.weather, task.time_scale, task.time_begin, task.is_blending)
  end
end

function EnvSystemProfiler:PlayNext()
  if 0 == #self.weather_playlist then
    Log.Debug("No more weather to preview")
    PerfCatCmd.EnvSystem.Stop()
    self.profiler_status = self.ProfilerStatus.FINISHED
    PerfCatCmd.EnableScreenMsg()
    self.on_finished()
    return
  end
  Log.DebugFormat("PlayNext, weather task left: %d", #self.weather_playlist)
  local task = table.remove(self.weather_playlist, 1)
  local duration = math.floor(86400 / task.time_scale)
  self:AddTask(0, function()
    NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, task.time_begin, true)
    NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, task.time_scale, true)
    NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeWeather, Enum.WeatherType[task.weather], true)
  end)
  local cmd_args = string.format("%s#%.2f#%d#%d", task.weather, task.time_scale, task.time_begin, duration)
  if not task.is_blending then
    self:AddTask(0, PerfCatCmd.EnvSystem.Start, cmd_args)
    Log.DebugFormat("Playing weather %s, time_scale: %f, duration: %d sec, current time: %d (setting to %d)", task.weather, task.time_scale, math.floor(duration), math.floor(self:GetGameTime()), task.time_begin)
  else
    Log.DebugFormat("Blending weather %s, time_scale: %f, duration: %d sec, current time: %d (setting to %d)", task.weather, task.time_scale, math.floor(duration), math.floor(self:GetGameTime()), task.time_begin)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.RegisterTimeCallback, nil, 86400, false, task.onTaskFinished, self)
  self:ProcessTaskQueue()
end

function EnvSystemProfiler:ProcessTaskQueue()
  if self.task_queue.is_processing then
    Log.Debug("You should not call ProcessTaskQueue while processing in progress. It does nothing.")
    return
  end
  self.task_queue:ProcessTaskQueue()
end

function EnvSystemProfiler:AddTask(Delay, TaskFunction, ...)
  self.task_queue:Add(Delay, self, TaskFunction, ...)
end

function EnvSystemProfiler:PreviewWeather(weather)
  local midnight = 0
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, midnight, true)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, self.time_scale, true)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeWeather, weather, true)
  local current_time = NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime)
  Log.DebugFormat("Current time is %d", current_time)
end

function EnvSystemProfiler:InitializeEnvSystem()
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, 0, true)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0, true)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeWeather, Enum.WeatherType.WT_SUNNY, true)
end

function EnvSystemProfiler:PreviewAllWeather()
  self:AddTask(0, self.InitializeEnvSystem)
  PerfCatCmd.DisableScreenMsg()
  self.profiler_status = self.ProfilerStatus.PLAYING
  PerfCatCmd.EnvSystem.Start()
  self:AddTask(5, self.PlayNext)
  self:ProcessTaskQueue()
end

function EnvSystemProfiler:GetGameTime()
  local game_time, _, _ = tonumber(NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime))
  return game_time
end

return EnvSystemProfiler
