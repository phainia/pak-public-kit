local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugPerformanceUtils = require("NewRoco.Modules.System.Debug.Tabs.PerformanceSwitch.DebugPerformanceUtils")
local Base = DebugTabBase
local DebugTabTexture = Base:Extend("DebugTabTexture")

function DebugTabTexture:Ctor()
  Base.Ctor(self)
end

local GroupName = "TextureQuality"

function DebugTabTexture:SetupTabs()
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "0", 0), self.L0, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "1", 1), self.L1, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "2", 2), self.L2, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "3", 3), self.L3, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "4", 4), self.L4, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "5", 5), self.L5, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "6", 6), self.L6, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabTexture:L0()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 0)
end

function DebugTabTexture:L1()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 1)
end

function DebugTabTexture:L2()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 2)
end

function DebugTabTexture:L3()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 3)
end

function DebugTabTexture:L4()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 4)
end

function DebugTabTexture:L5()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 5)
end

function DebugTabTexture:L6()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 6)
end

return DebugTabTexture
