local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DeviceUtils = require("NewRoco.Modules.Core.App.DeviceUtils")
local DebugTabDetail = Base:Extend("DebugTabDetail")

function DebugTabDetail:Ctor()
  Base.Ctor(self)
end

local function GetIsDX12Label()
  local ans = UE4.UNRCQualityLibrary.IsPreferD3D12()
  if ans then
    return "\230\152\175\229\144\166dx12(\230\152\175)"
  else
    return "\230\152\175\229\144\166dx12(\229\144\166)"
  end
end

function DebugTabDetail:SetupTabs()
  self:Add("\232\176\131\232\175\149ProfileSelection", self.DebugProfileSelection, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\232\176\131\232\175\149ProfileSelection\228\184\141\229\144\171\232\174\190\229\164\135\229\144\141", self.DebugProfileSelectionNoDeviceModel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\232\183\179\232\191\135\230\156\186\229\158\139\233\153\144\229\136\182(\231\188\147\229\173\152)", self.SkipDeviceLimitAndCache, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\184\133\233\153\164\232\183\179\232\191\135\230\156\186\229\158\139\231\188\147\229\173\152", self.ClearSkipDeviceLimitCache, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("IsDeviceInCDN", self.IsDeviceInCDN, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\141\176CDN\233\133\141\231\189\174", self.LogDeviceListCDN, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\129\162\229\164\141\233\187\152\232\174\164\231\148\187\232\180\168\229\184\167\231\142\135\231\173\137", self.ResetAllToDefault, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add(GetIsDX12Label(), self.IsDX12, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\232\174\190\231\189\174dx12\229\144\175\229\138\168", self.SetPreferDX12, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\232\174\190\231\189\174dx11\229\144\175\229\138\168", self.SetPreferDX11, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\168\161\230\139\159\230\156\186\229\158\139\230\161\163\228\189\141(\231\188\147\229\173\152)", self.SimulateDeviceLevelCache, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\143\150\230\182\136\230\168\161\230\139\159\230\156\186\229\158\139\230\161\163\228\189\141", self.CloseSimulateDeviceLevel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\184\133\231\144\134PC\231\142\175\229\162\131\229\188\185\229\135\186\230\172\161\230\149\176", self.ClearPCEnvWarningTimes, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
end

function DebugTabDetail:ClearPCEnvWarningTimes(name, panel, InputText)
  UE4.UNRCPlatformStatics.SetPCEnvWarningHistory(0)
end

function DebugTabDetail:SimulateDeviceLevelCache(name, panel, InputText)
  local inputValue, inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  if 1 == #params then
    inputValue = tonumber(params[1])
    UE4.UNRCQualityLibrary.SetSimulateDeviceLevel(inputValue)
  end
end

function DebugTabDetail:CloseSimulateDeviceLevel()
  UE4.UNRCQualityLibrary.ClearSimulateDeviceLevel()
end

function DebugTabDetail:IsDX12()
  local ans = UE4.UNRCQualityLibrary.IsPreferD3D12()
  if ans then
    Log.PrintScreenMsgRed("DX12")
  else
    Log.PrintScreenMsgRed("DX11")
  end
end

function DebugTabDetail:SetPreferDX12()
  UE4.UNRCQualityLibrary.SetPreferD3D12(true)
end

function DebugTabDetail:SetPreferDX11()
  UE4.UNRCQualityLibrary.SetPreferD3D12(false)
end

function DebugTabDetail:ResetAllToDefault()
  UE4.UNRCQualityLibrary.ResetAllToDefault()
end

function DebugTabDetail:IsDeviceInCDN()
  local ans = DeviceUtils.IsDeviceInWhiteListCDN()
  if ans then
    Log.PrintScreenMsgRed("IsDeviceInWhiteListCDN true")
  else
    Log.PrintScreenMsgRed("IsDeviceInWhiteListCDN false")
  end
  ans = DeviceUtils.IsDeviceInBlackListCDN()
  if ans then
    Log.PrintScreenMsgRed("IsDeviceInBlackListCDN true")
  else
    Log.PrintScreenMsgRed("IsDeviceInBlackListCDN false")
  end
end

function DebugTabDetail:LogDeviceListCDN()
  local CDNList = UE4.UNRCQualityLibrary.GetServerCDNDeviceList(UE4.ENRCDeviceCDNType.All)
  for idx = 1, CDNList:Length() do
    local CDNItem = CDNList:Get(idx)
    Log.PrintScreenMsgRed(CDNItem)
  end
  UE4.UNRCQualityLibrary.WriteServerCDNDeviceListToLocal()
end

function DebugTabDetail:SkipDeviceLimit()
  DeviceUtils.bSkipDeviceLimit = true
end

function DebugTabDetail:SkipDeviceLimitAndCache()
  DeviceUtils.bSkipDeviceLimit = true
  UE4.UNRCQualityLibrary.SetSkipDeviceLimitCache()
end

function DebugTabDetail:ClearSkipDeviceLimitCache()
  UE4.UNRCQualityLibrary.ClearSkipDeviceLimitCache()
end

function DebugTabDetail:DebugProfileSelection()
  local detail = UE4.UNRCQualityLibrary.DebugProfileSelection()
  Log.PrintScreenMsgRed(detail)
end

function DebugTabDetail:DebugProfileSelectionNoDeviceModel()
  local detail = UE4.UNRCQualityLibrary.DebugProfileSelection(false)
  Log.PrintScreenMsgRed(detail)
end

function DebugTabDetail:PrintLuaInfo()
  Log.PrintScreenMsgRed("Lua ImageQuality:" .. DeviceUtils.ImageQuality)
  Log.PrintScreenMsgRed("Lua FrameQuality:" .. DeviceUtils.FrameQuality)
  Log.PrintScreenMsgRed("Lua MemoryQuality" .. DeviceUtils.MemoryQuality)
  Log.PrintScreenMsgRed("----------------")
  Log.PrintScreenMsgRed("Cpp ImageQuality:" .. UE4.UNRCQualityLibrary.GetImageQuality())
  Log.PrintScreenMsgRed("Cpp FrameQuality:" .. UE4.UNRCQualityLibrary.GetFrameQuality())
  Log.PrintScreenMsgRed("Cpp MemoryQuality" .. UE4.UNRCQualityLibrary.GetMemoryQuality())
end

function DebugTabDetail:PrintCurrentDeviceMemory()
  local MemoryNum = UE4.UNRCQualityLibrary.GetDeviceMemory()
  Log.PrintScreenMsgRed("\229\189\147\229\137\141\232\174\190\229\164\135\229\134\133\229\173\152:" .. MemoryNum .. "GB")
end

function DebugTabDetail:PrintCurrentQualitySettings()
  UE4.UNRCQualityLibrary.PrintCurrentQualitySettings()
end

function DebugTabDetail:PrintAllQualitySettings()
  UE4.UNRCQualityLibrary.PrintAllQualitySettings()
end

function DebugTabDetail:DebugCurrentDevice()
  local info = DeviceUtils.GetDeviceDetailInfo()
  Log.PrintScreenMsgRed(info)
end

function DebugTabDetail:DebugCurrentDeviceTGPA()
  local level = UE4.UNRCQualityLibrary.GetDeviceLevelTGPA()
  Log.PrintScreenMsgRed("\229\189\147\229\137\141\232\174\190\229\164\135\231\173\137\231\186\167:" .. level)
  local detail = UE4.UNRCQualityLibrary.GetDeviceDetail()
  Log.PrintScreenMsgRed(detail)
end

function DebugTabDetail:DebugCurrentDeviceUE()
  local level = UE4.UNRCQualityLibrary.GetDeviceLevelUE()
  Log.PrintScreenMsgRed("\229\189\147\229\137\141\232\174\190\229\164\135\231\173\137\231\186\167:" .. level)
  local detail = UE4.UNRCQualityLibrary.GetDeviceDetail()
  Log.PrintScreenMsgRed(detail)
end

function DebugTabDetail:QualityPanel()
end

return DebugTabDetail
