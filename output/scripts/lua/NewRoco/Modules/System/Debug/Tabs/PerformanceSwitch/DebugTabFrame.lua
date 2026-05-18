local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabFrame = Base:Extend("DebugTabFrame")

function DebugTabFrame:Ctor()
  Base.Ctor(self)
end

local function GetQualityLevelLabel(str, in_level)
  local level = UE4.UNRCQualityLibrary.GetFrameQuality()
  if UE4.UNRCQualityLibrary.IsWindowsMode() and level <= 5 then
    level = level + 1
  end
  if level == in_level then
    return str .. "(\229\189\147\229\137\141)"
  else
    return str
  end
end

function DebugTabFrame:SetupTabs()
  self:Add(GetQualityLevelLabel("\228\189\142", 0), self.Low, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\228\184\173", 1), self.Medium, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\233\171\152", 2), self.High, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\232\182\133\233\171\152", 3), self.Super, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\230\158\129\233\171\152", 4), self.Ultra, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\230\158\129\232\135\180", 5), self.Epic, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\230\151\160\233\153\144\229\136\182", 6), self.Unlimit, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabFrame:Low()
  Log.Debug("DebugTabFrame:Low")
  UE4.UNRCQualityLibrary.SetFrameQuality(UE4.ENRCFrameQuality.Low)
end

function DebugTabFrame:Medium()
  Log.Debug("DebugTabFrame:Medium")
  UE4.UNRCQualityLibrary.SetFrameQuality(UE4.ENRCFrameQuality.Medium)
end

function DebugTabFrame:High()
  Log.Debug("DebugTabFrame:High")
  UE4.UNRCQualityLibrary.SetFrameQuality(UE4.ENRCFrameQuality.High)
end

function DebugTabFrame:Super()
  Log.Debug("DebugTabFrame:Super")
  UE4.UNRCQualityLibrary.SetFrameQuality(UE4.ENRCFrameQuality.Super)
end

function DebugTabFrame:Ultra()
  Log.Debug("DebugTabFrame:Ultra")
  UE4.UNRCQualityLibrary.SetFrameQuality(UE4.ENRCFrameQuality.Ultra)
end

function DebugTabFrame:Epic()
  Log.Debug("DebugTabFrame:Epic")
  UE4.UNRCQualityLibrary.SetFrameQuality(UE4.ENRCFrameQuality.Epic)
end

function DebugTabFrame:Unlimit()
  Log.Debug("DebugTabFrame:Unlimit")
  UE4.UNRCQualityLibrary.SetFrameQuality(UE4.ENRCFrameQuality.Unlimit)
end

return DebugTabFrame
