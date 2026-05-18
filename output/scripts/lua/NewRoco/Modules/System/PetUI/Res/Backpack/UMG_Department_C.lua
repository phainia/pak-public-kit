local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local BagModuleData = reload("NewRoco.Modules.System.Bag.BagModuleData")
local UMG_Department_C = Base:Extend("UMG_Department_C")

function UMG_Department_C:OnDestruct()
end

function UMG_Department_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  Log.Dump(self.uiData, 2, "UMG_BagItemTemplate_C:OnItemUpdate")
  self:Updatenum()
end

function UMG_Department_C:Updatenum()
  if self.uiData.Phase == nil then
    self.NRCSwitcher_26:SetActiveWidgetIndex(2)
  elseif self.uiData.Phase then
    if self.uiData.isDouble then
      self.NRCSwitcher_26:SetActiveWidgetIndex(3)
    else
      self.NRCSwitcher_26:SetActiveWidgetIndex(0)
    end
  elseif not self.uiData.Phase then
    if self.uiData.isDouble then
      self.NRCSwitcher_26:SetActiveWidgetIndex(4)
    else
      self.NRCSwitcher_26:SetActiveWidgetIndex(1)
    end
  end
  self.UMG_UIIcon:SetPath(self.uiData.icon)
end

return UMG_Department_C
