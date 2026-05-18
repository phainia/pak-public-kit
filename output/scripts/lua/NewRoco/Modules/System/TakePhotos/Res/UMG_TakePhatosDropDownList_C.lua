local UMG_TakePhatosDropDownList_C = _G.NRCViewBase:Extend("UMG_TakePhatosDropDownList_C")

function UMG_TakePhatosDropDownList_C:OnConstruct()
  self.bOpened = false
  self.DropdownListOverlay:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function UMG_TakePhatosDropDownList_C:InitDataList(DataList)
  self.DataList = DataList
  self:RefreshList()
end

function UMG_TakePhatosDropDownList_C:RefreshList()
  for i, v in pairs(self.DataList) do
    if v.IsSelected() then
      self.TText:SetText(v.Name)
      break
    end
  end
  self.CandidateListScroll_1:InitGridView(self.DataList)
  self:RefreshOpenView(self.bOpened)
end

function UMG_TakePhatosDropDownList_C:ConditionUnExpand()
  if self.bOpened then
    self:Toggle()
  end
end

function UMG_TakePhatosDropDownList_C:NotifyUnExpandCheck()
  do
    local bOpened = self.bOpened
    if bOpened then
      if self.DelayEvalOpenFlag then
        self:CancelDelayByID(self.DelayEvalOpenFlag)
        self.DelayEvalOpenFlag = nil
      end
      self.DelayEvalOpenFlag = self:DelaySeconds(0.15, function()
        self.DelayEvalOpenFlag = nil
        if self.bOpened then
          self:Toggle()
        end
      end)
    end
  end
end

function UMG_TakePhatosDropDownList_C:Toggle()
  if self.DelayEvalOpenFlag then
    self:CancelDelayByID(self.DelayEvalOpenFlag)
    self.DelayEvalOpenFlag = nil
  end
  local bOpened = not self.bOpened
  self.bOpened = bOpened
  if bOpened then
    self:PlayAnimation(self.OpenDown)
  end
  self:RefreshOpenView(bOpened)
end

function UMG_TakePhatosDropDownList_C:RefreshOpenView(bOpened)
  if bOpened then
    self.DropdownListOverlay_1:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.DownArrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.DownArrow_up:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.DropdownListOverlay_1:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.DownArrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DownArrow_up:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

return UMG_TakePhatosDropDownList_C
