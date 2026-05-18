local UMG_BattlePoint_C = _G.NRCViewBase:Extend("UMG_BattlePoint_C")

function UMG_BattlePoint_C:OnConstruct()
  self.bListVisible = false
  self:OnAddEventListener()
end

function UMG_BattlePoint_C:OnDestruct()
end

function UMG_BattlePoint_C:OnActive()
end

function UMG_BattlePoint_C:OnDeactive()
end

function UMG_BattlePoint_C:OnAddEventListener()
  self:AddButtonListener(self.SelectButton, self.OnClickSelectButton)
end

function UMG_BattlePoint_C:UpdateInfo(_Param)
  self.CandidateListScroll:InitList(_Param)
  self.CandidateListScroll:SelectItemByIndex(0)
  self:SetScrollVisible(self.bListVisible)
end

function UMG_BattlePoint_C:OnClickSelectButton()
  if self.bListVisible == true then
    _G.NRCAudioManager:PlaySound2DAuto(1089, "UMG_BagDropDownList_C:OnSelectedBtnClick")
    self:SetScrollVisible(false)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1086, "UMG_BagDropDownList_C:OnSelectedBtnClick")
    self:SetScrollVisible(true)
  end
end

function UMG_BattlePoint_C:SetScrollVisible(visible)
  if visible then
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.FrameBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.DownArrow:SetRenderTransformAngle(180)
    self.bListVisible = true
  else
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.FrameBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DownArrow:SetRenderTransformAngle(0)
    self.bListVisible = false
  end
end

function UMG_BattlePoint_C:SetText(_Text)
  self.TText:SetText(_Text)
end

return UMG_BattlePoint_C
