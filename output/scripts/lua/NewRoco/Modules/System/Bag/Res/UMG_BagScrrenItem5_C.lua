local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BagScrrenItem5_C = Base:Extend("UMG_BagScrrenItem5_C")

function UMG_BagScrrenItem5_C:OnConstruct()
end

function UMG_BagScrrenItem5_C:OnDestruct()
end

function UMG_BagScrrenItem5_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self.clickToggle = false
  if _data.filter_icon then
    self.ShiNeng:SetPath(_data.filter_icon)
    self.ShiNeng:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ShiNeng:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Text:SetText(_data.filter_desc)
end

function UMG_BagScrrenItem5_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.clickToggle = not self.clickToggle
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.OnClickFilterItem, self.data.filter_type, _G.Enum[self.data.filter_enum_name][self.data.filter_enum_value], self.clickToggle)
    if self.clickToggle == true then
      self.SelectSwitcher:SetActiveWidgetIndex(1)
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1288, "UMG_PetDropDownListltem1_C:OnItemSelected")
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
    else
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401015, "UMG_PetDropDownListltem1_C:OnItemSelected")
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
      self.SelectSwitcher:SetActiveWidgetIndex(0)
    end
  end
end

function UMG_BagScrrenItem5_C:OnDeactive()
end

return UMG_BagScrrenItem5_C
