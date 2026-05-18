require("UnLuaEx")
local Base = require("NewRoco.UI.Widgets.BP_ScrollViewItemBase_C")
local BP_PageProgressBar_Item_C = Base:Extend("BP_PageProgressBar_Item_C")

function BP_PageProgressBar_Item_C:Construct()
  self:OnSelectionChange(false)
end

function BP_PageProgressBar_Item_C:OnSelectionChange(bSelected)
  if bSelected then
    self.Icon_Yellow:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Icon_Yellow:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

return BP_PageProgressBar_Item_C
