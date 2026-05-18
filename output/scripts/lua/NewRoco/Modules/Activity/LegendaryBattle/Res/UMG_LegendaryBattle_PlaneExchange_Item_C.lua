local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LegendaryBattle_PlaneExchange_Item_C = Base:Extend("UMG_LegendaryBattle_PlaneExchange_Item_C")

function UMG_LegendaryBattle_PlaneExchange_Item_C:OnConstruct()
end

function UMG_LegendaryBattle_PlaneExchange_Item_C:OnDestruct()
end

function UMG_LegendaryBattle_PlaneExchange_Item_C:OnItemUpdate(_data, datalist, index)
  if true == _data then
    self.Number:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Number:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LegendaryBattle_PlaneExchange_Item_C:OnItemSelected(_bSelected)
end

function UMG_LegendaryBattle_PlaneExchange_Item_C:OnDeactive()
end

return UMG_LegendaryBattle_PlaneExchange_Item_C
