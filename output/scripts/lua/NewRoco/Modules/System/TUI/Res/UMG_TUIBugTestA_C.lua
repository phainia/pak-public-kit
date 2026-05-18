local UMG_TUIBugTestA_C = _G.NRCPanelBase:Extend("UMG_TUIBugTestA_C")

function UMG_TUIBugTestA_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_TUIBugTestA_C:OnDeactive()
end

function UMG_TUIBugTestA_C:OnAddEventListener()
  self:AddButtonListener(self.ChangeBtn, self.OnChange)
end

function UMG_TUIBugTestA_C:OnChange()
  if self.Bg.Visibility == UE4.ESlateVisibility.Hidden then
    self.Bg:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.Bg:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

return UMG_TUIBugTestA_C
