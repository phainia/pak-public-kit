local UMG_PetSort_C = _G.NRCPanelBase:Extend("UMG_PetSort_C")

function UMG_PetSort_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_PetSort_C:OnActive(curSortRuleId, skillSortReverse)
  self.curSortRuleId = curSortRuleId
  self.skillSortReverse = skillSortReverse
  self:SetCommonPopUpInfo(self.PopUp3)
  local skillSequenceConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.SKILL_SEQUENCE_CONF):GetAllDatas()
  if skillSequenceConf then
    self.SortList:InitGridView(skillSequenceConf)
  end
  if curSortRuleId then
    for i = 1, self.SortList:GetItemCount() do
      local item = self.SortList:GetItemByIndex(i - 1)
      if item.data.id == curSortRuleId then
        item:OnNotPlaySound()
        self.SortList:SelectItemByIndex(i - 1)
        break
      end
    end
  end
  self.SortList2:InitGridView({
    {
      sequence_desc = LuaText.skill_sort_text_3,
      skillSortReverse = false
    },
    {
      sequence_desc = LuaText.skill_sort_text_4,
      skillSortReverse = true
    }
  })
  local selectIndex = skillSortReverse and 1 or 0
  local selectItem = self.SortList2:GetItemByIndex(selectIndex)
  if selectItem then
    selectItem:OnNotPlaySound()
    self.SortList2:SelectItemByIndex(selectIndex)
  end
  self:LoadAnimation(0)
end

function UMG_PetSort_C:OnDeactive()
end

function UMG_PetSort_C:OnAddEventListener()
end

function UMG_PetSort_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnLeftBtnClick
  CommonPopUpData.Btn_RightHandler = self.OnRightBtnClick
  CommonPopUpData.ClosePanelHandler = self.OnLeftBtnClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_PetSort_C:OnLeftBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_PetSort_C:OnRightBtnClick")
  self:LoadAnimation(2)
  self.PopUp3:LoadAnimation(2)
end

function UMG_PetSort_C:OnRightBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_PetSort_C:OnRightBtnClick")
  local bChange = false
  local SortRuleId = self.curSortRuleId
  local oldSkillSortReverse = self.skillSortReverse
  local curSkillSortReverse
  for i = 1, self.SortList:GetItemCount() do
    local item = self.SortList:GetItemByIndex(i - 1)
    if item.CurSelected == true and self.curSortRuleId ~= item.data.id then
      SortRuleId = item.data.id
      bChange = true
    end
  end
  local item = self.SortList2:GetItemByIndex(0)
  if item then
    curSkillSortReverse = not item.CurSelected
  end
  if bChange or curSkillSortReverse ~= oldSkillSortReverse then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnPetSkillSortRuleChange, SortRuleId, curSkillSortReverse)
    _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OnPetSkillSortRuleChange, SortRuleId, curSkillSortReverse)
  end
  self:LoadAnimation(2)
  self.PopUp3:LoadAnimation(2)
end

function UMG_PetSort_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_PetSort_C
