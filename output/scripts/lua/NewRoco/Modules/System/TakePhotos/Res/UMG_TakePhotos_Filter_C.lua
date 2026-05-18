local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TakePhotos_Filter_C = Base:Extend("UMG_TakePhotos_Filter_C")

function UMG_TakePhotos_Filter_C:OnConstruct()
end

function UMG_TakePhotos_Filter_C:OnDestruct()
end

function UMG_TakePhotos_Filter_C:OnItemUpdate(_data, datalist, index)
  if (_data.FilterConf.filter_path or "") ~= "" then
    self.NoFilter:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.NoFilter:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  self.Image_Icon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Image_Icon:SetPath(_data.FilterConf.icon)
  self.Text_Title:SetText(_data.FilterConf.name or "")
  self.Index = index
  self.Data = _data
  self.Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function UMG_TakePhotos_Filter_C:OnItemSelected(_bSelected)
  if _bSelected then
    Log.Debug("\231\130\185\229\135\187\229\136\135\230\141\162\230\187\164\233\149\156\232\174\190\231\189\174", self.Data.FilterConf and self.Data.FilterConf.name)
    self.Data.OnClicked()
    self.Selected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

return UMG_TakePhotos_Filter_C
