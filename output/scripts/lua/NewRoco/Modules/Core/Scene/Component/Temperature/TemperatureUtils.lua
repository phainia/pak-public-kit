local TemperatureUtils = Class()
local _PhySurfaceTable = {
  [UE4.EPhysicalSurface.SurfaceType_Default] = "Land",
  [UE4.EPhysicalSurface.SurfaceType1] = "Grass",
  [UE4.EPhysicalSurface.SurfaceType2] = "Water",
  [UE4.EPhysicalSurface.SurfaceType3] = "Land",
  [UE4.EPhysicalSurface.SurfaceType4] = "DeepWater",
  [UE4.EPhysicalSurface.SurfaceType5] = "HighGrass",
  [UE4.EPhysicalSurface.SurfaceType6] = "Stone",
  [UE4.EPhysicalSurface.SurfaceType7] = "Wood",
  [UE4.EPhysicalSurface.SurfaceType8] = "Rock",
  [UE4.EPhysicalSurface.SurfaceType9] = "Soil",
  [UE4.EPhysicalSurface.SurfaceType10] = "Mud",
  [UE4.EPhysicalSurface.SurfaceType11] = "Sand",
  [UE4.EPhysicalSurface.SurfaceType12] = "Snow",
  [UE4.EPhysicalSurface.SurfaceType13] = "Ice",
  [UE4.EPhysicalSurface.SurfaceType14] = "Lava",
  [UE4.EPhysicalSurface.SurfaceType15] = "Fire"
}

function TemperatureUtils.GetSurfaceTypeName(surfaceType)
  if _PhySurfaceTable[surfaceType] then
    return _PhySurfaceTable[surfaceType]
  else
    Log.Debug("TemperatureUtils.GetSurfaceTypeName \230\156\170\230\137\190\229\136\176\231\154\132Surface\231\177\187\229\158\139")
    return "Land"
  end
end

function TemperatureUtils.GetSurfaceTemperature(name)
  local cfg = _G.DataConfigManager:GetEnvTagConfByPhysName(name)
  if cfg then
    return cfg.env_temp
  end
  return 40
end

function TemperatureUtils.GetWeatherTemp()
  local areaModule = _G.NRCModuleManager:GetModule("AreaAndZoneModule")
  if nil == areaModule then
    Log.Error("AreaAndZoneModule is error")
  end
  local areaEnvValue = areaModule and areaModule:GetZoneWeather() or _G.Enum.WeatherType.WT_NONE
  if areaEnvValue == _G.Enum.WeatherType.WT_NONE then
    return 0
  end
  local weatherConf = _G.DataConfigManager:GetWeatherConf(areaEnvValue)
  return weatherConf and weatherConf.temperature or 0
end

local _TimeStrToSecsDic = {}

local function GetSecFromHHMMSS(timeString)
  local secs = 0
  if nil == _TimeStrToSecsDic[timeString] then
    local timeParam = string.split(timeString, ":")
    for i, value in ipairs(timeParam) do
      secs = secs + tonumber(value) * (3600 / 60 ^ (i - 1))
    end
    _TimeStrToSecsDic[timeString] = secs
  else
    secs = _TimeStrToSecsDic[timeString]
  end
  return secs
end

function TemperatureUtils.GetTodTemp()
  local envSystem = _G.NRCModuleManager:GetModule("EnvSystemModule")
  local curTimeSecs = envSystem and envSystem:GetCurrentTime() or 0
  local allTodCfg = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.TOD_CONF):GetAllDatas()
  for _, cfg in ipairs(allTodCfg) do
    for _, timeRange in ipairs(cfg.available_time) do
      local timeParam1Secs = GetSecFromHHMMSS(timeRange.available_time_param1)
      local timeParam2Secs = GetSecFromHHMMSS(timeRange.available_time_param2)
      if curTimeSecs >= timeParam1Secs and curTimeSecs <= timeParam2Secs then
        return cfg.temp, curTimeSecs
      end
    end
  end
  Log.Warning("TemperatureUtils.GetTodTemp can not get TimeOfDay", curTimeSecs)
  return 5, curTimeSecs
end

function TemperatureUtils.GetAreaTempAndType()
  return _G.NRCModuleManager:DoCmd(AreaAndZoneModuleCmd.GetTemperature)
end

return TemperatureUtils
