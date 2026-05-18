local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ArdourListItem_C = Base:Extend("UMG_ArdourListItem_C")

function UMG_ArdourListItem_C:OnConstruct()
end

function UMG_ArdourListItem_C:OnDestruct()
end

function UMG_ArdourListItem_C:OnItemUpdate(_data, datalist, index)
  self.isActive = _data.isActive
  self.quantity = _data.quantity or 0
  if self.isActive then
    self.DriveIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.DriveIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if 0 == self.quantity then
    self.QuantityText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.QuantityText:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.QuantityText:SetText(string.format("\195\151%d", self.quantity))
  end
end

function UMG_ArdourListItem_C:OnItemSelected(_bSelected)
end

function UMG_ArdourListItem_C:OnDeactive()
end

function UMG_ArdourListItem_C:UpdateData(data)
  if self.isActive == false then
    self.DriveIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAnimation(self.Get)
  end
end

function UMG_ArdourListItem_C:SetData(isActive, quantity)
  self.isActive = isActive
  self.quantity = quantity or 0
  if self.isActive then
    self.DriveIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.DriveIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if 0 == self.quantity then
    self.QuantityText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.QuantityText:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.QuantityText:SetText(string.format("\195\151%d", self.quantity))
  end
end

return UMG_ArdourListItem_C
