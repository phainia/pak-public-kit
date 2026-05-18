local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BagScrrenItem2_C = Base:Extend("UMG_BagScrrenItem2_C")

function UMG_BagScrrenItem2_C:OnConstruct()
end

function UMG_BagScrrenItem2_C:OnDestruct()
end

function UMG_BagScrrenItem2_C:OnItemUpdate(_data, datalist, index)
  self.conf = _data
  if self.conf == nil then
    return
  end
  self.TypeIcon:SetPath(self.conf.filter_icon)
  self.SortText:SetText(self.conf.filter_desc)
  self.Switcher:SetActiveWidgetIndex(1)
  self.clickToggle = false
end

function UMG_BagScrrenItem2_C:OnNotPlaySound()
  self.IsNotPlaySound = true
end

function UMG_BagScrrenItem2_C:OnItemSelected(_bSelected)
  if _bSelected then
    if not self.IsNotPlaySound then
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BagScrrenItem2_C:OnItemSelected")
    else
      self.IsNotPlaySound = false
    end
    self.clickToggle = not self.clickToggle
  end
  _G.NRCEventCenter:DispatchEvent(BagModuleEvent.OnClickFilterItem, self.conf.filter_type, _G.Enum[self.conf.filter_enum_name][self.conf.filter_enum_value], self.clickToggle)
  if self.clickToggle then
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  else
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
  self.Switcher:SetActiveWidgetIndex(self.clickToggle and 0 or 1)
end

function UMG_BagScrrenItem2_C:OnDeactive()
end

return UMG_BagScrrenItem2_C
