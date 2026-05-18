local EnvSystemModuleCmd = require("NewRoco.Modules.System.EnvSystem.EnvSystemModuleCmd")
local EnvSystemProfiler = require("Profiler.PerfCat.EnvSystem.EnvSystemProfiler")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local LocalModeEvent = require("NewRoco.Modes.LocalMode.NRCLocalModeEvent")
local JsonUtils = require("Common.JsonUtils")
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local configFileName = "EnvSystemAutomationConfig"
local EnvSystemAutomation = {}

function EnvSystemAutomation:Init()
  self.started = false
  self.config = self:LoadConfig() or {}
  local profiler_config = {
    weather_playlist = self.config.weather_list,
    preview_duration = self.config.duration,
    on_profiler_finished = function()
      Log.Debug("EnvSystemAutomation: Finished")
      if self.config.overdraw_mode then
        PerfCatCmd.DisableShaderComplexityPostProcess()
        PerfCatCmd.SetViewMode("lit")
      end
    end
  }
  self.profiler = EnvSystemProfiler(profiler_config)
  self:Setup()
  self.map_loaded_event = SceneEvent.BigWorldPrepared
  self.lookdev_level_path = "/Game/ArtRes/Level/Performance/EnvSystemLookDev"
end

function EnvSystemAutomation:LoadConfig()
  local config = JsonUtils.LoadSaved(configFileName)
  if not config then
    Log.ErrorFormat("Failed to load config file %s", configFileName)
    return nil
  end
  return config
end

function EnvSystemAutomation:Setup()
  NRCModeManager:DeactiveMode("LoginMode")
  NRCModeManager:ActiveMode("LocalMode")
  NRCModuleManager:RegisterModule("AreaAndZoneModule", "Type_System", "NewRoco.Modules.Core.Scene.Map.AreaAndZoneModuleHead", "NewRoco.Modules.Core.Scene.Map.AreaAndZoneModule")
  NRCModuleManager:RegisterModule("TaskModule", "Type_System", "NewRoco.Modules.Core.Task.TaskModuleHead", "NewRoco.Modules.Core.Task.TaskModule")
  NRCModuleManager:ActiveModule("AreaAndZoneModule")
  NRCModuleManager:ActiveModule("TaskModule")
end

function EnvSystemAutomation:OpenLevel()
  if self.config.overdraw_mode then
    PerfCatCmd.EnableShaderComplexityPostProcess()
    PerfCatCmd.SetViewMode("simpleoverdraw")
  end
  LevelHelper:OpenLevel(self.lookdev_level_path)
end

function EnvSystemAutomation:StartAutomation()
  self.started = true
  local DebugTabCommon = require("NewRoco.Modules.System.Debug.Tabs.DebugTabCommon")()
  pcall(function()
    DebugTabCommon:HideHUD()
  end)
  NRCEventCenter:RegisterEvent("EnvSystemProfilerAutomation", self, self.map_loaded_event, self.OnMapLoaded)
  self:OpenLevel()
end

function EnvSystemAutomation:StartTest()
  self:Init()
  self:StartAutomation()
  return true
end

function EnvSystemAutomation:OnMapLoaded()
  Log.DebugFormat("EnvSystemAutomation:OnMapLoaded")
  self.profiler:PreviewAllWeather()
end

function EnvSystemAutomation:IsFinished()
  if self.profiler.profiler_status == EnvSystemProfiler.ProfilerStatus.FINISHED then
    return true
  end
  return false
end

function EnvSystemAutomation:IsStarted()
  return self.started
end

return EnvSystemAutomation
