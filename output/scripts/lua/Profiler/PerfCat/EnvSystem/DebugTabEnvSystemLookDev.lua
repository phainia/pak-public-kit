local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local EnvSystemModuleCmd = require("NewRoco.Modules.System.EnvSystem.EnvSystemModuleCmd")
local EnvSystemProfiler = require("Profiler.PerfCat.EnvSystem.EnvSystemProfiler")
local EnvSystemAutomation = require("NewRoco.Modules.System.Debug.EnvSystem.EnvSystemAutomation")
local Base = DebugTabBase
local DebugTabEnvSystemLookDev = Base:Extend("DebugTabEnvSystemLookDev")

function DebugTabEnvSystemLookDev:Ctor()
  Base.Ctor(self)
end

function DebugTabEnvSystemLookDev:SetupTabs()
  self:Add("OpenLookDevLevel", self.OnEnterWorldClicked, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("PreviewWeather", self.PreviewWeather, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("Print CurrentTime", self.PrintCurrentTime, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("Test", self.Test, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("StartAutomationTest", self.StartAutomation, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
end

function DebugTabEnvSystemLookDev:OnEnterWorldClicked(name, panel)
  EnvSystemAutomation:Init()
  EnvSystemAutomation:OpenLevel()
  if panel then
    panel:DoClose()
  end
end

function DebugTabEnvSystemLookDev:StartAutomation(name, panel)
  EnvSystemAutomation:StartTest()
  if panel then
    panel:DoClose()
  end
end

function DebugTabEnvSystemLookDev:PreviewWeather(name, panel)
  if panel then
    local weather = panel:GetInputNumber(0)
    EnvSystemProfiler:PreviewWeather(weather)
  end
end

function DebugTabEnvSystemLookDev:PrintCurrentTime(name, panel)
  local game_time, _, _ = tonumber(NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime))
  local hh = math.floor(game_time / 3600)
  local mm = math.floor(math.fmod(game_time, 3600) / 60)
  local ss = math.floor(math.fmod(game_time, 60))
  local readable_time = string.format("%02d:%02d:%02d", hh, mm, ss)
  self:ShowTips(string.format("Current time is %s", readable_time))
end

function DebugTabEnvSystemLookDev:Test(name, panel)
  weather_list = {}
  for i in pairs(Enum.WeatherType) do
    table.insert(weather_list, {
      type = i,
      idx = Enum.WeatherType[i]
    })
  end
  table.sort(weather_list, function(a, b)
    return a.idx < b.idx
  end)
  for i, v in ipairs(weather_list) do
    Log.DebugFormat("WeatherType " .. v.type .. " = " .. v.idx)
  end
end

return DebugTabEnvSystemLookDev
