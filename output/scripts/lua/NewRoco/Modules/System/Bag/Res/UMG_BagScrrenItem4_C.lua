local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BagScrrenItem4_C = Base:Extend("UMG_BagScrrenItem3_C")

function UMG_BagScrrenItem4_C:OnConstruct()
end

function UMG_BagScrrenItem4_C:OnDestruct()
end

function UMG_BagScrrenItem4_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self.clickToggle = false
  if self.data.filter_icon then
    self.imageAttriIcon:SetPath(self.data.filter_icon)
    self.imageAttriIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Up:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.imageAttriIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Up:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.imageAttriIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Up:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Text:SetText(self.data.filter_desc)
  self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("E8E1D0FF"))
  self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
end

function UMG_BagScrrenItem4_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BagScrrenItem_C:OnItemSelected")
    self.clickToggle = not self.clickToggle
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.OnClickFilterItem, self.data.filter_type, _G.Enum[self.data.filter_enum_name][self.data.filter_enum_value], self.clickToggle)
    if self.clickToggle then
      self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("FFC65FFF"))
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("1E1F21FF"))
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1288, "UMG_PetDropDownListltem1_C:OnItemSelected")
    else
      self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("E8E1D0FF"))
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
    end
  end
end

function UMG_BagScrrenItem4_C:ResetBg()
  self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("E8E1D0FF"))
  self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
end

return UMG_BagScrrenItem4_C
