local UMG_BallList_C = _G.NRCPanelBase:Extend("UMG_BallList_C")

function UMG_BallList_C:OnConstruct()
  self.InitSelectIndex = nil
  self.ScrollPageController:SetPageChangeHandler(self.ListScrollToPage, self)
end

function UMG_BallList_C:OnDisable()
  self:CancelDelayId()
end

function UMG_BallList_C:OnDestruct()
  self:CancelDelayId()
end

function UMG_BallList_C:ClosePanel()
  if self:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_BallList_C:SetListInfo(type)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanPress = true
  local isPCMode = UE4Helper.IsPCMode()
  if not isPCMode then
    self.NRCSwitcher_33:SetActiveWidgetIndex(0)
  else
    self.PCKey:SetScrollMode()
    self.NRCSwitcher_33:SetActiveWidgetIndex(1)
  end
  local itemList = {}
  local itemListFull = {}
  if type == ProtoEnum.BagItemType.BI_PET_BALL then
    itemList = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetEquipBallList)
    for _, item in ipairs(itemList) do
      if item and item.idx == nil then
        item.idx = 999
      end
      table.insert(itemListFull, item)
    end
    local resultList = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBallNormalSortList, itemListFull)
    if #resultList > 6 and 0 ~= #resultList % 6 then
      local addNum = 6 - #resultList % 6
      for i = 1, addNum do
        table.insert(resultList, {isEmpty = true})
      end
    end
    self.BallList:InitList(resultList)
    self.ScrollPageController:SetValidItemTotalNum(#resultList)
    self.InitSelectIndex = nil
    local equipItem = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetCurEquipItemInfo)
    for index, item in ipairs(resultList) do
      if item and equipItem and item.gid == equipItem.gid then
        self.InitSelectIndex = index
        break
      end
    end
    if self.InitSelectIndex then
      local function cb()
        if self.InitSelectIndex then
          local curPageIndex = math.ceil(self.InitSelectIndex / 6) - 1
          
          self.ScrollPageController:ScrollToPage(curPageIndex, 0.05)
          self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
        self:CancelDelayId()
      end
      
      self.delayId = _G.DelayManager:DelaySeconds(0.1, cb)
    end
  end
end

function UMG_BallList_C:ScrollNextPage(wheelData)
  local curPageIndex = self.ScrollPageController:GetCurrentPage()
  local maxPageCount = self.ScrollPageController:GetTotalPageNum() - 1
  if -1 == wheelData then
    if curPageIndex < maxPageCount then
      curPageIndex = curPageIndex + 1
    else
      curPageIndex = 0
    end
  elseif 1 == wheelData then
    if curPageIndex > 0 then
      curPageIndex = curPageIndex - 1
    else
      curPageIndex = maxPageCount
    end
  end
  self.ScrollPageController:ScrollToPage(curPageIndex, 0.2)
end

function UMG_BallList_C:OnPCSelectPet0(action_type, index)
  if 0 == action_type then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
    if self.CanPress then
      self.CanPress = false
      for i = 1, 6 do
        if index == i then
          local curPageIndex = self.ScrollPageController:GetCurrentPage()
          local selectIndex = curPageIndex * 6 + i
          local item = self.BallList:GetItemByIndex(selectIndex - 1)
          if item and not item.uiData.isEmpty then
            if not item.MyAbilityErrorCode then
              self.BallList:SelectItemByIndex(selectIndex - 1)
            else
              self.BallList:OnItemClicked()
            end
          end
        end
      end
    end
  else
    self.CanPress = true
  end
end

function UMG_BallList_C:ListScrollToPage(pageIndex)
  if self.InitSelectIndex then
    local item = self.BallList:GetItemByIndex(self.InitSelectIndex - 1)
    self.BallList:OnChildItemClick(item, self.InitSelectIndex - 1)
    self.InitSelectIndex = nil
  end
  for i = 1, 6 do
    local selectIndex = pageIndex * 6 + i
    local item = self.BallList:GetItemByIndex(selectIndex - 1)
    if item and not item.uiData.isEmpty then
      item:PCKeySetting(i)
    end
  end
end

function UMG_BallList_C:CancelDelayId()
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
end

return UMG_BallList_C
