local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LegendaryBattle_SortItem_C = Base:Extend("UMG_LegendaryBattle_SortItem_C")

function UMG_LegendaryBattle_SortItem_C:OnConstruct()
end

function UMG_LegendaryBattle_SortItem_C:OnDestruct()
end

function UMG_LegendaryBattle_SortItem_C:OnItemUpdate(_data, datalist, index)
  Log.Dump(_data, 2, "UMG_LegendaryBattle_Sort_C:OnActive")
  self.SortText:SetText(_data.starNum)
end

function UMG_LegendaryBattle_SortItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Switcher:SetActiveWidgetIndex(0)
  else
    self.Switcher:SetActiveWidgetIndex(1)
  end
end

function UMG_LegendaryBattle_SortItem_C:OnDeactive()
end

return UMG_LegendaryBattle_SortItem_C
