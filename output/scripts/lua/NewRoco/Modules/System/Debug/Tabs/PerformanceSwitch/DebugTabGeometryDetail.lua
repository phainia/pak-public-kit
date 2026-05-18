local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabGeometryDetail = Base:Extend("DebugTabGeometryDetail")

function DebugTabGeometryDetail:Ctor()
  Base.Ctor(self)
end

local GroupName = "GeometryDetailQuality"

local function GetQualityLevelLabel(str, in_level)
  local level = UE4.UNRCQualityLibrary.GetGroupQualityLevel(GroupName)
  if level == in_level then
    return str .. "(\229\189\147\229\137\141)"
  else
    return str
  end
end

function DebugTabGeometryDetail:SetupTabs()
  self:Add(GetQualityLevelLabel("\228\189\142", 0), self.Low, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\228\184\173", 1), self.Medium, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\233\171\152", 2), self.High, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetQualityLevelLabel("\230\158\129\233\171\152", 3), self.Epic, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabGeometryDetail:Low()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel(GroupName, 0)
end

function DebugTabGeometryDetail:Medium()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel(GroupName, 1)
end

function DebugTabGeometryDetail:High()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel(GroupName, 2)
end

function DebugTabGeometryDetail:Epic()
  UE4.UNRCQualityLibrary.SetGroupQualityLevel(GroupName, 3)
end

return DebugTabGeometryDetail
