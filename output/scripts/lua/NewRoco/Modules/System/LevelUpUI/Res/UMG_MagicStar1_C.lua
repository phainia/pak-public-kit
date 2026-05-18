local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MagicStar1_C = Base:Extend("UMG_MagicStar1_C")

function UMG_MagicStar1_C:OnConstruct()
end

function UMG_MagicStar1_C:OnDestruct()
end

function UMG_MagicStar1_C:OnItemUpdate(_data, datalist, index)
  self.starNormal:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.starHide:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.star:SetVisibility(UE4.ESlateVisibility.Hidden)
  if _data.isEmpty then
    self.starHide:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif _data.isNormal then
    self.starNormal:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif _data.isStar then
    self.star:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_MagicStar1_C:OnItemSelected(_bSelected)
end

function UMG_MagicStar1_C:OnDeactive()
end

return UMG_MagicStar1_C
