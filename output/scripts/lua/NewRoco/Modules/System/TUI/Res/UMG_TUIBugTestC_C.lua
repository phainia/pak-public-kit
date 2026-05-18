local UMG_TUIBugTestC_C = _G.NRCPanelBase:Extend("UMG_TUIBugTestC_C")

function UMG_TUIBugTestC_C:OnConstruct()
end

function UMG_TUIBugTestC_C:OnAddEventListener()
end

function UMG_TUIBugTestC_C:OnActive()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_TUIBugTestC_C:OnEnable()
  self.UMG_TUIBugTestA:OnChange()
end

function UMG_TUIBugTestC_C:OnDeactive()
end

function UMG_TUIBugTestC_C:OnAddEventListener()
end

return UMG_TUIBugTestC_C
