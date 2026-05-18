local UMG_BagDropDownList_C = _G.NRCPanelBase:Extend("UMG_BagDropDownList_C")

function UMG_BagDropDownList_C:OnConstruct()
  self.uidata = nil
  self.selectedIndex = -1
  self.bListVisible = false
  self:SetScrollVisible(self.bListVisible)
  self:OnAddEventListener()
end

function UMG_BagDropDownList_C:OnDestruct()
end

function UMG_BagDropDownList_C:OnActive(data)
  self.uidata = nil
  self.bListVisible = false
  self:SetScrollVisible(self.bListVisible)
  self.uidata = data
  self:SetDropDownListInfo(data)
end

function UMG_BagDropDownList_C:OnDeactive()
end

function UMG_BagDropDownList_C:OnAddEventListener()
  self:AddButtonListener(self.SelectButton, self.OnSelectedBtnClick)
end

function UMG_BagDropDownList_C:OnRemoveEventListener()
end

function UMG_BagDropDownList_C:OnSelectedBtnClick()
  if self.bListVisible == true then
    _G.NRCAudioManager:PlaySound2DAuto(1089, "UMG_BagDropDownList_C:OnSelectedBtnClick")
    self:SetScrollVisible(false)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1086, "UMG_BagDropDownList_C:OnSelectedBtnClick")
    self:SetScrollVisible(true)
  end
end

function UMG_BagDropDownList_C:SetScrollVisible(visible)
  if visible then
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Background:SetVisibility(UE4.ESlateVisibility.Visible)
    self.DownArrow:SetVisibility(UE4.ESlateVisibility.Visible)
    self.DownArrow_up:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.bListVisible = true
  else
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Background:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.DownArrow:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.DownArrow_up:SetVisibility(UE4.ESlateVisibility.Visible)
    self.bListVisible = false
  end
end

function UMG_BagDropDownList_C:SetDropDownListInfo(data)
  self.CandidateListScroll:InitList(data)
  local index = self:GetSelectedIndex()
  self.CandidateListScroll:SelectItemByIndex(index)
end

function UMG_BagDropDownList_C:SetSelectedIndex(index)
  self.selectedIndex = index
end

function UMG_BagDropDownList_C:GetSelectedIndex()
  return self.selectedIndex
end

function UMG_BagDropDownList_C:SetArrowBG(path)
  self.DownArrow:SetPath(path)
end

function UMG_BagDropDownList_C:SetScrollBG(path)
end

function UMG_BagDropDownList_C:SelectItem(sortType)
  self:SetScrollVisible(false)
  self:SetSelectedIndex(sortType)
  local selected = {}
  table.insert(selected, sortType)
  self.ShowSelectedItem:InitGridView(selected)
end

function UMG_BagDropDownList_C:PlayAnimationInfo()
  self:PlayAnimation(self.In)
end

return UMG_BagDropDownList_C
