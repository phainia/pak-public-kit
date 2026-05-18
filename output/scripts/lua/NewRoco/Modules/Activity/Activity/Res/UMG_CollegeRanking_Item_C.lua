local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_CollegeRanking_Item_C = Base:Extend("UMG_CollegeRanking_Item_C")

function UMG_CollegeRanking_Item_C:OnConstruct()
end

function UMG_CollegeRanking_Item_C:OnDestruct()
end

function UMG_CollegeRanking_Item_C:OnItemUpdate(_data, datalist, index)
  self.rank:SetText(tostring(index))
  self.rankName:SetText(_data.name or "")
  self.score:SetText(_data.score or "")
  self.Switcher_BG:SetActiveWidgetIndex((index - 1) % 3)
end

function UMG_CollegeRanking_Item_C:OnItemSelected(_bSelected)
end

return UMG_CollegeRanking_Item_C
