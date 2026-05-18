local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Buff_Item_C = Base:Extend("UMG_Buff_Item_C")

function UMG_Buff_Item_C:OnConstruct()
end

function UMG_Buff_Item_C:OnDestruct()
end

function UMG_Buff_Item_C:OnItemUpdate(_data, datalist, index)
  self.Description:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Description:SetText(_data.Description)
  self.Icon:SetPath(_data.Icon)
end

function UMG_Buff_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.Description:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
      self.Description:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Description:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.Description:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Buff_Item_C:OnDeactive()
end

return UMG_Buff_Item_C
