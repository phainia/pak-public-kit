local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DebugDropGmDownListltem_2_C = Base:Extend("UMG_DebugDropGmDownListltem_2_C")

function UMG_DebugDropGmDownListltem_2_C:OnConstruct()
end

function UMG_DebugDropGmDownListltem_2_C:OnDestruct()
end

function UMG_DebugDropGmDownListltem_2_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.TText:SetText(_data.Name)
end

function UMG_DebugDropGmDownListltem_2_C:OnItemSelected(_bSelected)
  if self.data.IsMultiSelect then
    if _bSelected then
      local IsAdd = false
      if self.Select:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
        self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
        IsAdd = false
      else
        self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        IsAdd = true
      end
      self.data.handler(self.data.Call, self.data.Name, IsAdd)
    end
  elseif _bSelected then
    if self.Select:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
      self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.data.handler(self.data.Call, nil)
    else
      self.data.handler(self.data.Call, self.data.Name)
      self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_DebugDropGmDownListltem_2_C:OnDeactive()
end

return UMG_DebugDropGmDownListltem_2_C
