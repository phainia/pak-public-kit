local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugPerformanceUtils = require("NewRoco.Modules.System.Debug.Tabs.PerformanceSwitch.DebugPerformanceUtils")
local Base = DebugTabBase
local DebugTabEffects = Base:Extend("DebugTabEffects")

function DebugTabEffects:Ctor()
  Base.Ctor(self)
end

local GroupName = "EffectsQuality"

function DebugTabEffects:SetupTabs()
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "0", 0), self.L0, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "1", 1), self.L1, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "2", 2), self.L2, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "3", 3), self.L3, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "4", 4), self.L4, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "5", 5), self.L5, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(DebugPerformanceUtils.GetQualityLevelLabel(GroupName, "6", 6), self.L6, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabEffects:L0()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 0)
end

function DebugTabEffects:L1()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 1)
end

function DebugTabEffects:L2()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 2)
end

function DebugTabEffects:L3()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 3)
end

function DebugTabEffects:L4()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 4)
end

function DebugTabEffects:L5()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 5)
end

function DebugTabEffects:L6()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel_InteralLevel(GroupName, 6)
end

return DebugTabEffects
