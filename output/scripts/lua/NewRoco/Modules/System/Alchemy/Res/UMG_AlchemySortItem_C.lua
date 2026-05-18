local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AlchemySortItem_C = Base:Extend("UMG_AlchemySortItem_C")

function UMG_AlchemySortItem_C:OnConstruct()
end

function UMG_AlchemySortItem_C:OnDestruct()
end

function UMG_AlchemySortItem_C:OnItemUpdate(_data, datalist, index)
  self.conf = _data
  if self.conf == nil then
    return
  end
  self.NRCImage_146:SetPath(self.conf.filter_icon)
  self.SortText:SetText(self.conf.filter_desc)
  self.NRCSwitcher_48:SetActiveWidgetIndex(0)
  self.clickToggle = false
end

function UMG_AlchemySortItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_AlchemySortItem_C:OnItemSelected")
    self.clickToggle = not self.clickToggle
  end
  if self.clickToggle then
    self.NRCSwitcher_48:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_48:SetActiveWidgetIndex(0)
  end
end

function UMG_AlchemySortItem_C:OnDeactive()
end

return UMG_AlchemySortItem_C
