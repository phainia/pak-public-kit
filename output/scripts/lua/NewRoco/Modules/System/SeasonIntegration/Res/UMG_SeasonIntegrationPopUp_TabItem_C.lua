local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SeasonIntegrationPopUp_TabItem_C = Base:Extend("UMG_SeasonIntegrationPopUp_TabItem_C")
local SeasonIntegrationModuleEvent = require("NewRoco.Modules.System.SeasonIntegration.SeasonIntegrationModuleEvent")

function UMG_SeasonIntegrationPopUp_TabItem_C:OnConstruct()
end

function UMG_SeasonIntegrationPopUp_TabItem_C:OnDestruct()
end

function UMG_SeasonIntegrationPopUp_TabItem_C:OnAnimationFinished(anim)
  if anim == self.change1 then
    self:PlayAnimation(self.select_loop)
  end
end

function UMG_SeasonIntegrationPopUp_TabItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.TabIcon:SetPath(self.data.page_icon)
  self.TabIcon_Select:SetPath(self.data.page_icon_select)
  self.TabText:SetText(self.data.page_name)
  if index > 1 then
    self:PlayAnimation(self.Open)
  end
end

function UMG_SeasonIntegrationPopUp_TabItem_C:OnItemSelected(_bSelected)
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_SeasonIntegrationPopUp_TabItem_C:OnItemSelected")
  self:StopAllAnimations()
  self:PlayAnimation(_bSelected and self.change1 or self.change2)
  if self.data and _bSelected then
    local module = _G.NRCModuleManager:GetModule("SeasonIntegrationModule")
    if module then
      module:DispatchEvent(SeasonIntegrationModuleEvent.OnSeasonPopUpTabSelect, self:GetGuidanceCustomListIndex())
    end
  end
end

function UMG_SeasonIntegrationPopUp_TabItem_C:OnDeactive()
end

return UMG_SeasonIntegrationPopUp_TabItem_C
