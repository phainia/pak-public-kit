local UMG_PastActivity_Popup_C = _G.NRCViewBase:Extend("UMG_PastActivity_Popup_C")

function UMG_PastActivity_Popup_C:OnConstruct()
end

function UMG_PastActivity_Popup_C:OnDestruct()
end

function UMG_PastActivity_Popup_C:SetShinyTimes(timesStr)
  self.List:InitGridView(timesStr)
end

return UMG_PastActivity_Popup_C
