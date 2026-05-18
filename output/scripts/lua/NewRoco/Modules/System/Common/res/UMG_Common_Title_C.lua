local UMG_Common_Title_C = _G.NRCViewBase:Extend("UMG_Common_Title_C")

function UMG_Common_Title_C:OnActive()
end

function UMG_Common_Title_C:OnDeactive()
end

function UMG_Common_Title_C:OnAddEventListener()
end

function UMG_Common_Title_C:SetBaseInfo(_Title_bg, _Subtitle, _MainTitle)
  self:SetBg(_Title_bg)
  self:SetSubtitle(_Subtitle)
  self:Set_MainTitle(_MainTitle)
end

function UMG_Common_Title_C:SetBg(_Title_bg)
  if _Title_bg then
    self.Title_bg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Title_bg:SetPath(_Title_bg)
  else
    self.Title_bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Common_Title_C:SetSubtitle(_Subtitle)
  if _Subtitle then
    self.Subtitle:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Subtitle:SetText(_Subtitle)
  else
    self.Subtitle:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Common_Title_C:Set_MainTitle(_MainTitle)
  if _MainTitle then
    self.MainTitle:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MainTitle:SetText(_MainTitle)
  else
    self.MainTitle:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Common_Title_C
