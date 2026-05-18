local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local EnvSystemModuleCmd = require("NewRoco.Modules.System.EnvSystem.EnvSystemModuleCmd")
local LinearTimeSetter = require("NewRoco.Modules.System.EnvSystem.LinearTimeSetter")
local Base = DebugTabBase
local DebugTabEnv = Base:Extend("DebugTabEnv")

function DebugTabEnv:SetupTabs()
end

function DebugTabEnv:GetTimeFromInput()
  local RawTime = self:GetInputString()
  local RawSecond = tonumber(RawTime)
  if nil ~= RawSecond then
    if RawSecond < 2400 then
      local time = math.floor(RawSecond / 100) * 3600 + RawSecond % 100 * 60
      return time
    else
      return RawSecond
    end
  end
  local TimeArrayList = string.Split(RawTime, ":")
  local TargetTime = 0
  for i, value in pairs(TimeArrayList) do
    if not string.IsNilOrEmpty(value) then
      local Time = tonumber(value) * 60 ^ (3 - i)
      TargetTime = TargetTime + Time
    end
  end
  return TargetTime
end

function DebugTabEnv:SetTimeDirect(Name, Panel)
  local Time = self:GetTimeFromInput()
  Log.Debug("SetTimeDirect", Time)
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, false)
  end
end

function DebugTabEnv:SetTime(Name, Panel)
  local Time = self:GetTimeFromInput()
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, true)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
end

function DebugTabEnv:LocalSetTime(Name, Panel)
  local Time = self:GetTimeFromInput()
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, true)
end

function DebugTabEnv:ChangeTimeScale(name, panel)
  local value = panel.InputBox:GetText()
  local scale = value and tonumber(value) or 0
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, scale)
end

function DebugTabEnv:LockMorning(name, panel)
  local Time = 15000
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabEnv:LockMorning1(name, panel)
  local Time = 17000
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabEnv:LockNoon(name, panel)
  local Time = 43200
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabEnv:LockAfternoon(name, panel)
  local Time = 68400
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabEnv:LockNight(name, panel)
  local Time = 0
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabEnv:LockLA(Name, Panel)
  local EnvSystemModule = _G.NRCModuleManager:GetModule("EnvSystemModule")
  EnvSystemModule.LockWeather = Enum.WeatherType.WT_SUNNY
  EnvSystemModule:OnChangeWeather(Enum.WeatherType.WT_SUNNY, true)
  self:LockNoon()
end

function DebugTabEnv:PrintTodTime(name, panel)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.PrintCurrentTime)
end

function DebugTabEnv:SwitchWeatherState(name, panel)
  local value = panel.InputBox:GetText()
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  EnvSys:SetWeatherStat(value, true, false)
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = 3
  req.gm_op_type = 2
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.param1 = value
  _G.ZoneServer:Send(_G.ProtoEnum.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req)
end

function DebugTabEnv:ShowWeatherState(name, panel)
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  local WeatherSystemValue = EnvSys:GetWeatherStat()
  local EnvModule = _G.NRCModuleManager:GetModule("EnvSystemModule")
  local LuaEnvValue = EnvModule and EnvModule.CurrentWeather or Enum.WeatherType.WT_NONE
  local AreaModule = _G.NRCModuleManager:GetModule("AreaAndZoneModule")
  local AreaEnvValue = AreaModule and AreaModule:GetZoneWeather() or Enum.WeatherType.WT_NONE
  self:Inspect({
    ["\229\144\142\229\143\176\228\184\139\229\143\145\231\154\132\229\164\169\230\176\148"] = table.getKeyName(Enum.WeatherType, AreaEnvValue),
    ["Lua\232\174\164\228\184\186\231\154\132\229\164\169\230\176\148"] = table.getKeyName(Enum.WeatherType, LuaEnvValue),
    ["\229\174\158\233\153\133\231\154\132\229\164\169\230\176\148"] = WeatherSystemValue,
    ["\229\189\147\229\137\141\231\154\132\229\140\186\229\159\159\229\136\151\232\161\168"] = AreaModule.zoneInfoArray:Items()
  }, "\229\164\169\230\176\148\231\179\187\231\187\159")
end

function DebugTabEnv:SetBloomState(name, panel)
  local value = panel.InputBox:GetText()
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  if "1" == value then
    EnvSys:SetBloomState(true)
    EnvSys:SetBloomSettings(2, 0, 10)
  else
    EnvSys:SetBloomState(false)
  end
end

function DebugTabEnv:SetBloomSettings(name, panel)
  local value = panel.InputBox:GetText()
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  local bloom = tonumber(value)
  if bloom then
    EnvSys:SetBloomSettings(bloom, 0, 3)
  end
end

function DebugTabEnv:StartAbnormal(Name, Panel)
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.UpdateAbnormal, true)
end

function DebugTabEnv:StopAbnormal(Name, Panel)
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.UpdateAbnormal, false)
end

return DebugTabEnv
