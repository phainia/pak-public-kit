local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local EnvSystemModuleCmd = require("NewRoco.Modules.System.EnvSystem.EnvSystemModuleCmd")
local LinearTimeSetter = require("NewRoco.Modules.System.EnvSystem.LinearTimeSetter")
local LockWeatherReason = require("NewRoco.Modules.System.EnvSystem.LockWeatherReason")
local Base = DebugTabBase
local DebugTabLightTOD = Base:Extend("DebugTabLightTOD")

function DebugTabLightTOD:SetupTabs()
  self:Add("\230\152\190\231\164\186Bloom\229\143\130\230\149\176", self.ShowBloomParam, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "ShowBloomParam")
  self:Add("\233\148\129\229\174\154\229\164\169\230\176\148(\229\174\162\230\136\183\231\171\175)", self.LockWeatherClient, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "LockWeatherClient")
  self:Add("\228\184\128\233\148\174\233\148\129\229\174\154\230\184\133\230\153\168(\229\174\162\230\136\183\231\171\175)", self.LockMorningClient, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "LockMorningClient")
  self:Add("\228\184\128\233\148\174\233\148\129\229\174\154\230\173\163\229\141\136(\229\174\162\230\136\183\231\171\175)", self.LockNoonClient, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "LockNoonClient")
  self:Add("\228\184\128\233\148\174\233\148\129\229\174\154\229\130\141\230\153\154(\229\174\162\230\136\183\231\171\175)", self.LockAfternoonClient, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "LockAfternoonClient")
  self:Add("\228\184\128\233\148\174\233\148\129\229\174\154\229\164\156\230\153\154(\229\174\162\230\136\183\231\171\175)", self.LockNightClient, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "LockNightClient")
  self:Add("\232\167\163\233\153\164\230\151\182\233\151\180\233\148\129\229\174\154(\229\174\162\230\136\183\231\171\175)", self.UnlockTimeClient, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "UnlockTimeClient")
end

function DebugTabLightTOD:GetTimeFromInput()
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

function DebugTabLightTOD:SetTimeDirect(Name, Panel)
  local Time = self:GetTimeFromInput()
  Log.Debug("SetTimeDirect", Time)
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, false)
  end
end

function DebugTabLightTOD:SetTime(Name, Panel)
  local Time = self:GetTimeFromInput()
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, true)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
end

function DebugTabLightTOD:LocalSetTime(Name, Panel)
  local Time = self:GetTimeFromInput()
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, true)
end

function DebugTabLightTOD:ChangeTimeScale(name, panel, id)
  if panel then
    local value = panel.InputBox:GetText()
    local scale = value and tonumber(value) or 0
    NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, scale)
  elseif id then
    NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, id)
  end
end

function DebugTabLightTOD:LockMorning(name, panel)
  local Time = 15000
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabLightTOD:LockMorning1(name, panel)
  local Time = 17000
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabLightTOD:LockNoon(name, panel)
  local Time = 43200
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabLightTOD:LockAfternoon(name, panel)
  local Time = 68400
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabLightTOD:LockNight(name, panel)
  local Time = 0
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabLightTOD:LockLA(Name, Panel)
  local EnvSystemModule = _G.NRCModuleManager:GetModule("EnvSystemModule")
  EnvSystemModule:OnLockWeather(Enum.WeatherType.WT_SUNNY, LockWeatherReason.GM)
  self:LockNoon()
end

function DebugTabLightTOD:LockWeatherClient(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  value = value and tonumber(value) or _G.Enum.WeatherType.WT_NONE
  local EnvSystemModule = _G.NRCModuleManager:GetModule("EnvSystemModule")
  EnvSystemModule:OnLockWeather(value, LockWeatherReason.GM)
end

function DebugTabLightTOD:PrintTodTime(name, panel)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.PrintCurrentTime)
end

function DebugTabLightTOD:SwitchWeatherState(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = 3
  req.gm_op_type = 2
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.param1 = value
  _G.ZoneServer:Send(_G.ProtoEnum.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req)
end

function DebugTabLightTOD:ShowWeatherState(name, panel)
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

function DebugTabLightTOD:StartAbnormal(Name, Panel)
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.UpdateAbnormal, true)
end

function DebugTabLightTOD:StopAbnormal(Name, Panel)
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.UpdateAbnormal, false)
end

function DebugTabLightTOD:SetBloomState(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  if "1" == value then
    EnvSys:SetBloomState(true)
    EnvSys:SetBloomSettings(2, 0, 10)
  else
    EnvSys:SetBloomState(false)
  end
end

function DebugTabLightTOD:SetBloomSettings(name, panel, id)
  if panel then
    local Instance = UE.UNRCPlatformGameInstance.GetInstance()
    local EnvSys = Instance and Instance:GetWorldSubSystem()
    local params = string.Split(panel.InputBox:GetText(), ";")
    local bloom = tonumber(params[1]) or 2
    local BloomThreshold = tonumber(params[2]) or 0
    local ChangeInterval = tonumber(params[3]) or 0.1
    if bloom then
      EnvSys:SetBloomSettings(bloom, BloomThreshold, ChangeInterval)
    end
  elseif id then
    local value = id
    local Instance = UE.UNRCPlatformGameInstance.GetInstance()
    local EnvSys = Instance and Instance:GetWorldSubSystem()
    local bloom = value
    if bloom then
      EnvSys:SetBloomSettings(bloom, 0, 3)
    end
  end
end

function DebugTabLightTOD:ShowBloomParam()
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  if EnvSys then
    local BloomIntensity, BloomThreshold, ChangeInterval = EnvSys:GetBloomSettings()
    local BloomTint3, BloomTint4, BloomTint5, TintInterval = EnvSys:GetBloomAdditionalSettings()
    local info = string.format("BloomParam BloomIntensity:%s BloomThreshold:%s ChangeInterval:%s BloomTint3:%s BloomTint4:%s BloomTint5:%s TintInterval:%s", BloomIntensity, BloomThreshold, ChangeInterval, BloomTint3, BloomTint4, BloomTint5, TintInterval)
    UE4Helper.PrintScreenMsg(info)
  end
end

function DebugTabLightTOD:LockMorningClient()
  self:LockTimeClient(4.166666666666667)
end

function DebugTabLightTOD:LockNoonClient()
  self:LockTimeClient(12.0)
end

function DebugTabLightTOD:LockAfternoonClient()
  self:LockTimeClient(19.0)
end

function DebugTabLightTOD:LockNightClient()
  self:LockTimeClient(0)
end

function DebugTabLightTOD:LockTimeClient(time)
  if not time then
    return
  end
  if not self.timeSession then
    self.timeSession = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.RegisterTime, time)
  else
    self.timeSession:UpdateTime(time)
  end
end

function DebugTabLightTOD:UnlockTimeClient()
  if self.timeSession then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ReleaseTime, self.timeSession)
  end
  self.timeSession = nil
end

return DebugTabLightTOD
