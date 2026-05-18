local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LeveIUpList2_C = Base:Extend("UMG_LeveIUpList2_C")

function UMG_LeveIUpList2_C:OnConstruct()
end

function UMG_LeveIUpList2_C:OnDestruct()
end

function UMG_LeveIUpList2_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Icon:SetPath(_data.icon)
  self.Content:SetText(_data.Description)
  self.Content:SetVisibility(UE4.ESlateVisibility.Visible)
  if _data.value then
    self.ContentTupo:SetText(_data.value)
    self.ContentTupo:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ContentTupo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LeveIUpList2_C:OnItemSelected(_bSelected)
end

function UMG_LeveIUpList2_C:OnDeactive()
end

return UMG_LeveIUpList2_C
