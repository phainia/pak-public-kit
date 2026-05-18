local UMG_LoadingProgress_C = _G.NRCPanelBase:Extend("UMG_LoadingProgress_C")

function UMG_LoadingProgress_C:OnActive(percent, text)
end

function UMG_LoadingProgress_C:OnDeactive()
end

function UMG_LoadingProgress_C:OnAddEventListener()
end

function UMG_LoadingProgress_C:OnConstruct()
end

function UMG_LoadingProgress_C:OnDestruct()
end

function UMG_LoadingProgress_C:SetProgressPercent(percent)
  self.Progress:SetPercent(percent)
end

function UMG_LoadingProgress_C:SetLoadingText(text)
  self.Description:SetText(text)
end

return UMG_LoadingProgress_C
