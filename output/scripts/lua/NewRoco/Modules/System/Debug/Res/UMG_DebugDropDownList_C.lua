local UMG_DebugDropDownList_C = _G.NRCPanelBase:Extend("UMG_DebugDropDownList_C")

function UMG_DebugDropDownList_C:OnConstruct()
  self.uidata = nil
  self.selectedIndex = -1
  self.bListVisible = false
  self:SetScrollVisible(self.bListVisible)
  self:OnAddEventListener()
end

function UMG_DebugDropDownList_C:OnDestruct()
end

function UMG_DebugDropDownList_C:OnActive(data)
  self.uidata = nil
  self.bListVisible = false
  self:SetScrollVisible(self.bListVisible)
  self.uidata = data
  self:SetDropDownListInfo(data)
end

function UMG_DebugDropDownList_C:OnDeactive()
end

function UMG_DebugDropDownList_C:OnAddEventListener()
  self:AddButtonListener(self.SelectButton, self.OnSelectedBtnClick)
end

function UMG_DebugDropDownList_C:OnRemoveEventListener()
end

function UMG_DebugDropDownList_C:OnSelectedBtnClick()
  if self.bListVisible == true then
    _G.NRCAudioManager:PlaySound2DAuto(1089, "UMG_BagDropDownList_C:OnSelectedBtnClick")
    self:SetScrollVisible(false)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1086, "UMG_BagDropDownList_C:OnSelectedBtnClick")
    self.DebugInfoMainCtrl(self.owner, self.InputName)
    self:SetScrollVisible(true)
  end
end

function UMG_DebugDropDownList_C:SetScrollVisible(visible)
  if visible then
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Visible)
    self.FrameBG:SetVisibility(UE4.ESlateVisibility.Visible)
    self.DownArrow:SetRenderTransformAngle(180)
    self.bListVisible = true
  else
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.FrameBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DownArrow:SetRenderTransformAngle(0)
    self.bListVisible = false
  end
end

function UMG_DebugDropDownList_C:SetDropDownListInfo(data)
  self.CandidateListScroll:InitList(data)
end

function UMG_DebugDropDownList_C:setDebugInfoMainCtrl(_DebugInfoMainCtrl, _InputName, owner)
  self.DebugInfoMainCtrl = _DebugInfoMainCtrl
  self.InputName = _InputName
  self.owner = owner
end

function UMG_DebugDropDownList_C:SetSelectedIndex(index)
  self.selectedIndex = index
end

function UMG_DebugDropDownList_C:GetSelectedIndex()
  return self.selectedIndex
end

function UMG_DebugDropDownList_C:SetArrowBG(path)
  self.DownArrow:SetPath(path)
end

function UMG_DebugDropDownList_C:SetScrollBG(path)
end

function UMG_DebugDropDownList_C:SelectItem(sortType)
  self:SetScrollVisible(false)
  self:SetSelectedIndex(sortType)
  local selected = {}
  table.insert(selected, sortType)
  self.ShowSelectedItem:InitGridView(selected)
end

return UMG_DebugDropDownList_C
