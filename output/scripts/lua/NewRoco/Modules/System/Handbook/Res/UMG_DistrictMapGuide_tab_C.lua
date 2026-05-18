local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DistrictMapGuide_tab_C = Base:Extend("UMG_DistrictMapGuide_tab_C")

function UMG_DistrictMapGuide_tab_C:OnConstruct()
end

function UMG_DistrictMapGuide_tab_C:OnDestruct()
end

function UMG_DistrictMapGuide_tab_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Title:SetText(self.data.name)
end

function UMG_DistrictMapGuide_tab_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.Press)
    _G.NRCModuleManager:GetModule("HandbookModule"):DispatchEvent(HandbookModuleEvent.OnClickDistrictTabItemData, self.data.type)
  else
    self:PlayAnimation(self.Normal)
  end
end

function UMG_DistrictMapGuide_tab_C:OnDeactive()
end

return UMG_DistrictMapGuide_tab_C
