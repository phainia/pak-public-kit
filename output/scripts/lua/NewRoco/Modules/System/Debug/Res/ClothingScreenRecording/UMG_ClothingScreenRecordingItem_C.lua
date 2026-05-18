local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ClothingScreenRecordingItem_C = Base:Extend("UMG_ClothingScreenRecordingItem_C")

function UMG_ClothingScreenRecordingItem_C:OnConstruct()
end

function UMG_ClothingScreenRecordingItem_C:OnDestruct()
end

function UMG_ClothingScreenRecordingItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_ClothingScreenRecordingItem_C:SetInfo()
  local data = self.data
  self:IsSelect(data.IsSelect)
  self.SelectedName:SetText(data.Text)
  self.UnSelectedName:SetText(data.Text)
end

function UMG_ClothingScreenRecordingItem_C:IsSelect(_bSelected)
  if _bSelected then
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NotSelected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NotSelected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ClothingScreenRecordingItem_C:OnItemSelected(_bSelected)
  self:IsSelect(_bSelected)
  if self.data.Call then
    self.data.Call:SelectInfo(self.data.Type)
  end
end

function UMG_ClothingScreenRecordingItem_C:OnDeactive()
end

return UMG_ClothingScreenRecordingItem_C
