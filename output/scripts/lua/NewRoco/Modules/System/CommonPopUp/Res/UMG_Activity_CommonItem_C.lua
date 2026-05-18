local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_CommonItem_C = Base:Extend("UMG_Activity_CommonItem_C")

function UMG_Activity_CommonItem_C:OnConstruct()
  self.Bright:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_CommonItem_C:OnDestruct()
end

function UMG_Activity_CommonItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
end

function UMG_Activity_CommonItem_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self.Bright:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAnimation(self.Select)
    if self.data and type(self.data) == "table" and self.data.onSelectedCallback and self.data.onSelectedCaller then
      self.data.onSelectedCallback(self.data.onSelectedCaller, self.data, self.index)
    end
  else
    self.Bright:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimation(self.Select_not)
  end
end

function UMG_Activity_CommonItem_C:OnDeactive()
end

return UMG_Activity_CommonItem_C
