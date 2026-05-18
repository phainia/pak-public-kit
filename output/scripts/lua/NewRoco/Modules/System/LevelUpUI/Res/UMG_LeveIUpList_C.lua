local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LeveIUpList_C = Base:Extend("UMG_LeveIUpList_C")

function UMG_LeveIUpList_C:OnConstruct()
end

function UMG_LeveIUpList_C:OnDestruct()
end

function UMG_LeveIUpList_C:OnItemUpdate(_data, datalist, index)
  if _data.isUpdateTaskDes then
    self.CanvasPanel_25:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if _data.isLocked then
      self.Lock:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Open:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Open:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self.Content:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ContentTupo:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ContentTupo:SetText(_data.content)
    self.ContentTupo_1:SetText(_data.value)
    self.StarImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_25:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Open:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Content:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ContentTupo:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ContentTupo_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Content:SetText(_data.content)
    if _data.value then
      self.ClassText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ClassText:SetText(_data.value)
      self.Arrows:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.ClassText:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Arrows:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.StarImage:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if _data.icon then
    self.StarImage:SetPath(_data.icon)
  end
end

function UMG_LeveIUpList_C:OnItemSelected(_bSelected)
end

function UMG_LeveIUpList_C:OnDeactive()
end

return UMG_LeveIUpList_C
