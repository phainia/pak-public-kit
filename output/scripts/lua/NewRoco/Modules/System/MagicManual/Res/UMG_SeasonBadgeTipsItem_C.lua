local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SeasonBadgeTipsItem_C = Base:Extend("UMG_SeasonBadgeTipsItem_C")

function UMG_SeasonBadgeTipsItem_C:OnConstruct()
end

function UMG_SeasonBadgeTipsItem_C:OnDestruct()
end

function UMG_SeasonBadgeTipsItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local starList = {}
  for i = 1, 5 do
    local level = self.data.level_num
    local data = -1
    if i <= level - 1 then
      data = 1
    end
    table.insert(starList, {IsShow = data})
  end
  self.ProbabilityStarRating:InitGridView(starList)
  self.BadgeIcon:SetPath(self.data.badge_icon)
  self.ProbabilityText:SetText(self.data.badge_type_text)
end

function UMG_SeasonBadgeTipsItem_C:OnItemSelected(_bSelected)
end

function UMG_SeasonBadgeTipsItem_C:OnDeactive()
end

return UMG_SeasonBadgeTipsItem_C
