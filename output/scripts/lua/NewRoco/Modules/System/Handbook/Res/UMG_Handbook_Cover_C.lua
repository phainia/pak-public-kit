local UMG_Handbook_Cover_C = _G.NRCViewBase:Extend("UMG_Handbook_Cover_C")

function UMG_Handbook_Cover_C:OnActive(handbookInfoList, catchHandbookInfoList)
  if 0 == #handbookInfoList then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.Switcher:SetActiveWidgetIndex(0)
  end
  if 0 == #catchHandbookInfoList then
    self.Switcher_1:SetActiveWidgetIndex(1)
  else
    self.Switcher_1:SetActiveWidgetIndex(0)
  end
  self.List:InitGridView(handbookInfoList)
  self.List_1:InitGridView(catchHandbookInfoList)
end

function UMG_Handbook_Cover_C:OnAnimationFinished(anim)
end

function UMG_Handbook_Cover_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Handbook_Cover_C:OnSwitcherSwitcher_1(SwitcherIndex)
  self.Switcher_1:SetActiveWidgetIndex(SwitcherIndex)
end

return UMG_Handbook_Cover_C
