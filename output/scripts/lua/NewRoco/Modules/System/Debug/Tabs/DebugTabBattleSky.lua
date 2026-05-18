local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Base = DebugTabBase
local DebugTabBattleSky = Base:Extend("DebugTabBattleSky")

function DebugTabBattleSky:Ctor()
  Base.Ctor(self)
end

function DebugTabBattleSky:SetupTabs()
end

function DebugTabBattleSky:OnEnableSkyBattle()
  BattleConst.EnableSkyBattle = true
end

function DebugTabBattleSky:OnChangeSkyBattleHeight(Name, Panel, id)
  if Panel then
    BattleConst.SkyPlatformHeight = Panel:GetInputNumber()
  elseif id then
    BattleConst.SkyPlatformHeight = id
  end
end

function DebugTabBattleSky:OnEnableSkyBattleCloud1()
end

function DebugTabBattleSky:OnEnableSkyBattleCloud2()
end

function DebugTabBattleSky:OnDisableSkyBattleCloud()
end

function DebugTabBattleSky:ChangeWeatherSunny(Name, Panel)
  local weather = 1
  Log.Debug("Debugtabbattlesky changeweather:", weather)
  self:ChangeWeather(weather)
end

function DebugTabBattleSky:ChangeWeatherCloudy(Name, Panel)
  local weather = 2
  Log.Debug("Debugtabbattlesky changeweather:", weather)
  self:ChangeWeather(weather)
end

function DebugTabBattleSky:ChangeWeatherLightRain(Name, Panel)
  local weather = 3
  Log.Debug("Debugtabbattlesky changeweather:", weather)
  self:ChangeWeather(weather)
end

function DebugTabBattleSky:ChangeWeatherHeavyRain(Name, Panel)
  local weather = 4
  Log.Debug("Debugtabbattlesky changeweather:", weather)
  self:ChangeWeather(weather)
end

function DebugTabBattleSky:ChangeWeatherStorm(Name, Panel)
  local weather = 5
  Log.Debug("Debugtabbattlesky changeweather:", weather)
  self:ChangeWeather(weather)
end

function DebugTabBattleSky:ChangeWeatherDustStorm(Name, Panel)
  local weather = 6
  Log.Debug("Debugtabbattlesky changeweather:", weather)
  self:ChangeWeather(weather)
end

function DebugTabBattleSky:ChangeWeatherFoggy(Name, Panel)
  local weather = 7
  Log.Debug("Debugtabbattlesky changeweather:", weather)
  self:ChangeWeather(weather)
end

function DebugTabBattleSky:ChangeWeatherAbnormal(Name, Panel)
  local weather = 8
  Log.Debug("Debugtabbattlesky changeweather:", weather)
  self:ChangeWeather(weather)
end

function DebugTabBattleSky:ChangeWeatherSnow(Name, Panel)
  local weather = 9
  Log.Debug("Debugtabbattlesky changeweather:", weather)
  self:ChangeWeather(weather)
end

function DebugTabBattleSky:ChangeWeather(weather)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeWeather, weather, true)
end

return DebugTabBattleSky
