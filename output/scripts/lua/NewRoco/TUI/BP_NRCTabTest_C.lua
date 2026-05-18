local BP_NRCTabTest_C = _G.NRCPanelBase:Extend("BP_NRCTabTest_C")

function BP_NRCTabTest_C:OnConstruct()
  local activewidget = self.BP_NRCTab:GetActiveWidget()
  if activewidget then
    activewidget:OnActive()
  end
  self:AddListener()
end

function BP_NRCTabTest_C:OnDestruct()
  self:RemoveListener()
end

function BP_NRCTabTest_C:OnActive()
end

function BP_NRCTabTest_C:OnDeactive()
end

function BP_NRCTabTest_C:AddListener()
end

function BP_NRCTabTest_C:SetDropDownListItemNum(index)
  self.UMG_Tab1Template:SetDropDownListItemNum(index)
end

function BP_NRCTabTest_C:OnTabChangeCallback(index)
  local activewidget = self.BP_NRCTab:GetActiveWidget()
  activewidget:OnActive()
end

function BP_NRCTabTest_C:RemoveListener()
  self.BP_NRCTab:OnDestruct()
end

return BP_NRCTabTest_C
