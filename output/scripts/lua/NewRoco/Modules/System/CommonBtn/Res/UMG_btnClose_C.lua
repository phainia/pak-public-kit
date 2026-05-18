local UMG_btnClose_C = _G.NRCPanelBase:Extend("UMG_btnClose_C")

function UMG_btnClose_C:OnActive()
end

function UMG_btnClose_C:OnDeactive()
end

function UMG_btnClose_C:SetStyle(index)
  self.NRCSwitcher_1:SetActiveWidgetIndex(index)
end

function UMG_btnClose_C:OnAddEventListener()
end

return UMG_btnClose_C
