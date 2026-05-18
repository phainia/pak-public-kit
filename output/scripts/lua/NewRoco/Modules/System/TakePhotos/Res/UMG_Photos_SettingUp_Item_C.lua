local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Photos_SettingUp_Item_C = Base:Extend("UMG_Photos_SettingUp_Item_C")

function UMG_Photos_SettingUp_Item_C:OnConstruct()
  self.Switcher:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Select:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.NotSelectedColor = UE4.UNRCStatics.HexToSlateColor("C3C1B4FF")
  self.SelectedColor = UE4.UNRCStatics.HexToSlateColor("FF8E1DFF")
end

function UMG_Photos_SettingUp_Item_C:OnDestruct()
end

function UMG_Photos_SettingUp_Item_C:OnItemUpdate(_data, datalist, index)
  self._data = _data
  self.NRCText_Name:SetText(_data.name or "")
end

function UMG_Photos_SettingUp_Item_C:OnItemSelected(_bSelected)
  if _bSelected and self._data and self._data.OnSelectDelegate then
    _bSelected = self._data.OnSelectDelegate(self._data)
  end
  if _bSelected then
    self.Switcher:SetActiveWidgetIndex(1)
    self.NRCText_Name:SetColorAndOpacity(self.SelectedColor)
  else
    self.Switcher:SetActiveWidgetIndex(0)
    self.NRCText_Name:SetColorAndOpacity(self.NotSelectedColor)
  end
end

function UMG_Photos_SettingUp_Item_C:OnDeactive()
end

return UMG_Photos_SettingUp_Item_C
