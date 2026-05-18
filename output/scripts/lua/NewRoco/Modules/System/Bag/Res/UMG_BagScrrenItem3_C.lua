local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BagScrrenItem3_C = Base:Extend("UMG_BagScrrenItem3_C")

function UMG_BagScrrenItem3_C:OnConstruct()
end

function UMG_BagScrrenItem3_C:OnDestruct()
end

function UMG_BagScrrenItem3_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self.clickToggle = false
  if self.data.filter_icon then
    self.imageAttriIcon:SetPath(self.data.filter_icon)
    self.imageAttriIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Up:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Canvas_AttriIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Up:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 1 == self.data.type then
    self.imageAttriIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Up:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.imageAttriIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Up:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.Text:SetText(self.data.filter_desc)
end

function UMG_BagScrrenItem3_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BagScrrenItem_C:OnItemSelected")
    self.clickToggle = not self.clickToggle
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.OnClickFilterItem, self.data.filter_type, _G.Enum[self.data.filter_enum_name][self.data.filter_enum_value], self.clickToggle)
    if self.clickToggle then
      self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FFC346FF"))
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1288, "UMG_PetDropDownListltem1_C:OnItemSelected")
    else
      self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FFFFFFFF"))
    end
  end
end

return UMG_BagScrrenItem3_C
