local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabImageQuality = Base:Extend("DebugTabImageQuality")

function DebugTabImageQuality:Ctor()
  Base.Ctor(self)
end

local function GetQualityLevelLabel(str, in_level)
  local level = UE4.UNRCQualityLibrary.GetImageQuality()
  if level == in_level then
    return str .. "(\229\189\147\229\137\141)"
  else
    return str
  end
end

function DebugTabImageQuality:SetupTabs()
  self:Add(GetQualityLevelLabel("\228\189\142", 0), self.Low, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\228\184\173", 1), self.Medium, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\233\171\152", 2), self.High, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\230\158\129\233\171\152", 3), self.Epic, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\232\135\170\229\174\154\228\185\137", 4), self.Custom, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabImageQuality:Low()
  Log.Debug("DebugTabImageQuality:Low")
  UE4.UNRCQualityLibrary.SetImageQuality(UE4.ENRCImageQuality.Low)
end

function DebugTabImageQuality:Medium()
  Log.Debug("DebugTabImageQuality:Medium")
  UE4.UNRCQualityLibrary.SetImageQuality(UE4.ENRCImageQuality.Medium)
end

function DebugTabImageQuality:High()
  Log.Debug("DebugTabImageQuality:High")
  UE4.UNRCQualityLibrary.SetImageQuality(UE4.ENRCImageQuality.High)
end

function DebugTabImageQuality:Epic()
  Log.Debug("DebugTabImageQuality:Epic")
  UE4.UNRCQualityLibrary.SetImageQuality(UE4.ENRCImageQuality.Epic)
end

function DebugTabImageQuality:Custom()
  Log.Debug("DebugTabImageQuality:Custom")
  UE4.UNRCQualityLibrary.SetImageQuality(UE4.ENRCImageQuality.Custom)
end

function DebugTabImageQuality:HDR()
end

function DebugTabImageQuality:Ultra()
end

return DebugTabImageQuality
