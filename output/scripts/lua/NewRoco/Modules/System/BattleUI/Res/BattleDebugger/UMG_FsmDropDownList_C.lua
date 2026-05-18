local UMG_FsmDropDownList_C = _G.NRCViewBase:Extend("UMG_FsmDropDownList_C")

function UMG_FsmDropDownList_C:OnConstruct()
  self.uidata = nil
  self.selectedIndex = -1
  self.bListVisible = false
  self:SetScrollVisible(self.bListVisible)
end

function UMG_FsmDropDownList_C:OnDestruct()
end

function UMG_FsmDropDownList_C:OnActive(data)
  self.uidata = nil
  self.bListVisible = false
  self:SetScrollVisible(self.bListVisible)
  self.uidata = data
  self:SetDropDownListInfo(data)
  self:OnAddEventListener()
end

function UMG_FsmDropDownList_C:OnDeactive()
end

function UMG_FsmDropDownList_C:OnAddEventListener()
  self:AddButtonListener(self.SelectButton, self.OnSelectedBtnClick)
end

function UMG_FsmDropDownList_C:OnSelectedBtnClick()
  if self.bListVisible == true then
    _G.NRCAudioManager:PlaySound2DAuto(1089, "UMG_BagDropDownList_C:OnSelectedBtnClick")
    self:SetScrollVisible(false)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1086, "UMG_BagDropDownList_C:OnSelectedBtnClick")
    self:SetScrollVisible(true)
  end
end

function UMG_FsmDropDownList_C:SetScrollVisible(visible)
  if visible then
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Visible)
    self.FrameBG:SetVisibility(UE4.ESlateVisibility.Visible)
    self.DownArrow:SetRenderTransformAngle(180)
    self.bListVisible = true
  else
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.FrameBG:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.DownArrow:SetRenderTransformAngle(0)
    self.bListVisible = false
  end
end

function UMG_FsmDropDownList_C:SetDropDownListInfo(data)
  self.CandidateListScroll:InitList(data)
end

return UMG_FsmDropDownList_C
