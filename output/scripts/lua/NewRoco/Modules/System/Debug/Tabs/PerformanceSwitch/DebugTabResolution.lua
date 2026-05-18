local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabResolution = Base:Extend("DebugTabResolution")

function DebugTabResolution:Ctor()
  Base.Ctor(self)
end

local function GetPCResolutionLabel(str, x, y)
  local cur_x, cur_y = UE4.UNRCQualityLibrary.GetPCResolution()
  if cur_x == x and cur_y == y then
    return str .. "(\229\189\147\229\137\141)"
  else
    return str
  end
end

local function GetQualityLevelLabel(str, in_level)
  if RocoEnv.IS_EDITOR or RocoEnv.PLATFORM == "PLATFORM_WINDOWS" then
    return str
  end
  local level = UE4.UNRCQualityLibrary.GetMobileResolutionQuality()
  if level == in_level then
    return str .. "(\229\189\147\229\137\141)"
  else
    return str
  end
end

local function GetVeryLowResolutionStatus()
  local value1 = UE4.UNRCStatics.GetConsoleVarFloat("r.Device.ScreenPercentage")
  local value2 = UE4.UNRCStatics.GetConsoleVarFloat("r.Device.ScreenPercentageScaleFactor")
  if value1 > 0 and value1 < 100 then
    return "\231\137\185\230\174\138\228\189\142\229\136\134\232\190\168\231\142\135(\229\188\128)"
  end
  if value2 > 0 and value2 < 1 then
    return "\231\137\185\230\174\138\228\189\142\229\136\134\232\190\168\231\142\135(\229\188\128)"
  end
  return "\231\137\185\230\174\138\228\189\142\229\136\134\232\190\168\231\142\135(\229\133\179)"
end

function DebugTabResolution:SetupTabs()
  self:Add("\230\137\147\229\141\176MobileResolution", self.PrintMobileResolution, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("UI1080L1", 0), self.UI1080L1, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("UI1080L2", 1), self.UI1080L2, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("UI1080L3", 2), self.UI1080L3, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("UI1080L4", 3), self.UI1080L4, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("UI720L1", 5), self.UI720L1, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("UI720L2", 6), self.UI720L2, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("UI720L3", 7), self.UI720L3, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetVeryLowResolutionStatus(), self.Empty, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetPCResolutionLabel("PC 3600x1620", 3600, 1620), self.R36001620, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetPCResolutionLabel("PC 2520x1134", 2520, 1134), self.R25201134, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetPCResolutionLabel("PC 2400x1080", 2400, 1080), self.R24001080, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetPCResolutionLabel("PC 1600x720", 1600, 720), self.R1600720, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetPCResolutionLabel("PC 800x360", 800, 360), self.R800360, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\174\190\231\189\174BorderX", self.SetNRCBlackBorderX, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\174\190\231\189\174BorderY", self.SetNRCBlackBorderY, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\174\190\231\189\174BorderRatioX", self.SetNRCBlackBorderRatioX, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\174\190\231\189\174BorderRatioY", self.SetNRCBlackBorderRatioY, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabResolution:Empty(name, panel)
end

function DebugTabResolution:SetNRCBlackBorderX(name, panel)
  if panel then
    local value
    local inputText = panel.InputBox:GetText()
    if nil == inputText then
      inputText = ""
    end
    local params = {}
    for w in string.gmatch(inputText, "%S+") do
      table.insert(params, w)
    end
    if 1 == #params then
      value = tonumber(params[1])
    end
    Log.Debug("DebugTabResolution:SetNRCBlackBorderX", value)
    if nil ~= value then
      UE4.UNRCStatics.ExecConsoleCommand("g.GNRCBorderHorizontalRatio -1")
      UE4.UNRCStatics.ExecConsoleCommand("g.GNRCBorderVerticalRatio -1")
      UE4.UNRCStatics.ExecConsoleCommand(string.format("g.GNRCBlackBorderX %d", value))
    end
  end
end

function DebugTabResolution:SetNRCBlackBorderY(name, panel)
  if panel then
    local value
    local inputText = panel.InputBox:GetText()
    if nil == inputText then
      inputText = ""
    end
    local params = {}
    for w in string.gmatch(inputText, "%S+") do
      table.insert(params, w)
    end
    if 1 == #params then
      value = tonumber(params[1])
    end
    Log.Debug("DebugTabResolution:SetNRCBlackBorderY", value)
    if nil ~= value then
      UE4.UNRCStatics.ExecConsoleCommand("g.GNRCBorderHorizontalRatio -1")
      UE4.UNRCStatics.ExecConsoleCommand("g.GNRCBorderVerticalRatio -1")
      UE4.UNRCStatics.ExecConsoleCommand(string.format("g.GNRCBlackBorderY %d", value))
    end
  end
end

function DebugTabResolution:SetNRCBlackBorderRatioX(name, panel)
  if panel then
    local value
    local inputText = panel.InputBox:GetText()
    if nil == inputText then
      inputText = ""
    end
    local params = {}
    for w in string.gmatch(inputText, "%S+") do
      table.insert(params, w)
    end
    if 1 == #params then
      value = tonumber(params[1])
    end
    Log.Debug("DebugTabResolution:SetNRCBlackBorderRatioX", value)
    if nil ~= value then
      UE4.UNRCStatics.ExecConsoleCommand(string.format("g.GNRCBorderHorizontalRatio %f", value))
    end
  end
end

function DebugTabResolution:SetNRCBlackBorderRatioY(name, panel)
  if panel then
    local value
    local inputText = panel.InputBox:GetText()
    if nil == inputText then
      inputText = ""
    end
    local params = {}
    for w in string.gmatch(inputText, "%S+") do
      table.insert(params, w)
    end
    if 1 == #params then
      value = tonumber(params[1])
    end
    Log.Debug("DebugTabResolution:SetNRCBlackBorderRatioY", value)
    if nil ~= value then
      UE4.UNRCStatics.ExecConsoleCommand(string.format("g.GNRCBorderVerticalRatio %f", value))
    end
  end
end

function DebugTabResolution:PrintDeviceAndVarInfo()
  local screenResolution = UE4.UNRCStatics.GetGameUserSettings():GetScreenResolution()
  local systemResolution = UE4.UNRCStatics.GetGSystemResolution()
  local desktopResolution = UE4.UNRCStatics.GetGameUserSettings():GetDesktopResolution()
  UE4Helper.PrintScreenMsgRed(string.format("ScreenResolution:%d,%d", screenResolution.X, screenResolution.Y))
  UE4Helper.PrintScreenMsgRed(string.format("GSystemResolution:%d,%d", systemResolution.X, systemResolution.Y))
  UE4Helper.PrintScreenMsgRed(string.format("DesktopResolution:%d,%d", desktopResolution.X, desktopResolution.Y))
  local ScreenPercentage, ContentScale, sgResolutionQuality = UE4.UNRCQualityLibrary.GetResolutionVarValues()
  UE4Helper.PrintScreenMsgRed(string.format("ScreenPercentage:%f ContentScale:%f sgResolutionQuality:%f", ScreenPercentage, ContentScale, sgResolutionQuality))
end

function DebugTabResolution:PrintMobileResolution()
  local x, y = UE4.UNRCQualityLibrary.GetMobileResolution()
  UE4Helper.PrintScreenMsgRed(string.format("MobileResolution:%d,%d", x, y))
end

function DebugTabResolution:PrintFrameBufferSize()
  local x, y = UE4.UNRCQualityLibrary.GetFrameBufferSize()
  UE4Helper.PrintScreenMsgRed(string.format("FrameBufferSize:%d,%d", x, y))
end

function DebugTabResolution:UI1080L4(name, panel)
  UE4.UNRCQualityLibrary.SetMobileResolutionQuality(UE4.ENRCMobileResolutionQuality.UI1080L4)
end

function DebugTabResolution:UI1080L3(name, panel)
  UE4.UNRCQualityLibrary.SetMobileResolutionQuality(UE4.ENRCMobileResolutionQuality.UI1080L3)
end

function DebugTabResolution:UI1080L2(name, panel)
  UE4.UNRCQualityLibrary.SetMobileResolutionQuality(UE4.ENRCMobileResolutionQuality.UI1080L2)
end

function DebugTabResolution:UI1080L1(name, panel)
  UE4.UNRCQualityLibrary.SetMobileResolutionQuality(UE4.ENRCMobileResolutionQuality.UI1080L1)
end

function DebugTabResolution:UI720L3(name, panel)
  UE4.UNRCQualityLibrary.SetMobileResolutionQuality(UE4.ENRCMobileResolutionQuality.UI720L3)
end

function DebugTabResolution:UI720L2(name, panel)
  UE4.UNRCQualityLibrary.SetMobileResolutionQuality(UE4.ENRCMobileResolutionQuality.UI720L2)
end

function DebugTabResolution:UI720L1(name, panel)
  UE4.UNRCQualityLibrary.SetMobileResolutionQuality(UE4.ENRCMobileResolutionQuality.UI720L1)
end

function DebugTabResolution:ContentScale3(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("r.Mobilecontentscalefactor 3")
end

function DebugTabResolution:ContentScale2(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("r.Mobilecontentscalefactor 2")
end

function DebugTabResolution:ContentScale1p5(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("r.Mobilecontentscalefactor 1.5")
end

function DebugTabResolution:ContentScale1(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("r.Mobilecontentscalefactor 1")
end

function DebugTabResolution:ContentScale0p67(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("r.Mobilecontentscalefactor 0.67")
end

function DebugTabResolution:ContentScale0p5(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("r.Mobilecontentscalefactor 0.5")
end

function DebugTabResolution:ScreenPercentage150(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("r.ScreenPercentage 150")
end

function DebugTabResolution:ScreenPercentage100(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("r.ScreenPercentage 100")
end

function DebugTabResolution:ScreenPercentage67(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("r.ScreenPercentage 67")
end

function DebugTabResolution:ScreenPercentage50(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("r.ScreenPercentage 50")
end

function DebugTabResolution:R36001620()
  UE4.UNRCQualityLibrary.SetPCResolution(3600, 1620)
end

function DebugTabResolution:R25201134()
  UE4.UNRCQualityLibrary.SetPCResolution(2520, 1134)
end

function DebugTabResolution:R24001080()
  UE4.UNRCQualityLibrary.SetPCResolution(2400, 1080)
end

function DebugTabResolution:R1600720()
  UE4.UNRCQualityLibrary.SetPCResolution(1600, 720)
end

function DebugTabResolution:R800360()
  UE4.UNRCQualityLibrary.SetPCResolution(800, 360)
end

return DebugTabResolution
