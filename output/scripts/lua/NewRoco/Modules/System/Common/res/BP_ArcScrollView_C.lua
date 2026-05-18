local LuaMathUtils = require("NewRoco.Utils.LuaMathUtils")
local Base = require("NewRoco.TUI.BP_NRCScrollView_C")
local BP_ArcScrollView_C = Base:Extend("BP_ArcScrollView_C")

function BP_ArcScrollView_C:Construct()
  Base.Construct(self)
  self.isFirstTick = true
  self.AutoSnapWaitTime = 0.2
  self.autoSnapCountdownTime = self.AutoSnapWaitTime
  self.HideItemPercentageThreshold = 0.4
  self.MouseWheelDataMultiplier = 1
  self.normalizeMouseWheelData = false
  self.onlyConsumeFirstMouseWheelScroll = false
  self.EnablePageNation = false
  self.isMouseWheelForPagination = false
  self.mouseWheelEndRestTimeForPagination = 0
  self.maxMouseWheelEndRestTime = 0.2
  self.PageItemCount = 1
  self.currentPageIndex = 0
  self.wheelDataThisFrame = 0
  self.wheelDataLastFrame = 0
  self.isInitializing = false
  Log.Debug("BP_ArcScrollView_C:Construct")
end

function BP_ArcScrollView_C:InitList(_itemDatas, bForceNoCreate)
  self.isInitializing = true
  Base.InitList(self, _itemDatas, bForceNoCreate)
  self:BindLuaCallback({
    self,
    self.HandleUserScroll
  })
  if self.EnablePageNation then
    self.maxPageIndex = math.ceil(self:GetMaxScrollOffset() / (self:GetItemSize().Y * self.PageItemCount)) - 1
    if self.maxPageIndex < 0 then
      self.maxPageIndex = 1
    end
  end
  self:UpdateVisibleItemPositionInCurvePath()
  self.isInitializing = false
end

function BP_ArcScrollView_C:OnTick(deltaTime)
  if self.EnablePageNation then
    if 0 ~= self.wheelDataThisFrame then
      if not self.isMouseWheelForPagination then
        self:HandleStartScrollForPagination()
      end
      self.mouseWheelEndRestTimeForPagination = self.maxMouseWheelEndRestTime
      self.isMouseWheelForPagination = true
    elseif self.isMouseWheelForPagination and self.mouseWheelEndRestTimeForPagination < 0 then
      self:HandleEndScrollForPagination()
    end
    self.mouseWheelEndRestTimeForPagination = self.mouseWheelEndRestTimeForPagination - deltaTime
  end
  if self:HandleUserPress() then
    self.targetWheelScrollOffset = nil
    self.autoSnapCountdownTime = self.AutoSnapWaitTime
  elseif self:HandleMouseWheelMovement(deltaTime) then
    self.autoSnapCountdownTime = self.AutoSnapWaitTime
  elseif self:HandleAutoSnap(deltaTime) then
  end
  self.HandlingUserScrollingCurrentFrame = self._handlingUserScrolling
  self._handlingUserScrolling = false
  self.autoSnapCountdownTime = self.autoSnapCountdownTime - deltaTime
  self.wheelDataLastFrame = self.wheelDataThisFrame
  self.wheelDataThisFrame = 0
end

function BP_ArcScrollView_C:HandleUserScroll(offset)
  self:SetScrollOffset(offset)
  self:UpdateVisibleItemPositionInCurvePath()
  if not self.isInitializing then
    self._handlingUserScrolling = true
  end
end

function BP_ArcScrollView_C:OnMouseWheel(MyGeometry, InTouchEvent)
  local wheelData = UE4.UKismetInputLibrary.PointerEvent_GetWheelDelta(InTouchEvent)
  if self.onlyConsumeFirstMouseWheelScroll and self.targetWheelScrollOffset ~= nil or self._handlingUserScrolling then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  self.wheelDataThisFrame = wheelData
  self:ScrollWithWheelData(wheelData)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function BP_ArcScrollView_C:ScrollWithWheelData(wheelData)
  local scrollOffset = self:GetScrollOffset()
  if self.normalizeMouseWheelData and 0 ~= wheelData then
    wheelData = wheelData / math.abs(wheelData)
  end
  wheelData = wheelData * self.MouseWheelDataMultiplier
  if not self.EnablePageNation then
    local targetWheelScrollOffset
    if self.targetWheelScrollOffset ~= nil then
      targetWheelScrollOffset = self.targetWheelScrollOffset - wheelData * self:GetItemSize().Y
    else
      targetWheelScrollOffset = scrollOffset - wheelData * self:GetItemSize().Y
    end
    self:SetTargetWheelScrollOffset(targetWheelScrollOffset)
  else
  end
end

function BP_ArcScrollView_C:SetTargetWheelScrollOffset(newOffset)
  self.targetWheelScrollOffset = newOffset
  self.targetWheelScrollOffset = math.max(0, self.targetWheelScrollOffset)
  local maxScrollOffset = math.max(0, self:GetMaxScrollOffset())
  self.targetWheelScrollOffset = math.floor(self.targetWheelScrollOffset + 0.5)
  self.targetWheelScrollOffset = math.min(maxScrollOffset, self.targetWheelScrollOffset)
  self._handlingUserScrolling = false
end

function BP_ArcScrollView_C:HandleUserPress()
  if self._handlingUserScrolling or self:GetScrollBoxHandleScrollingState() then
    self.targetWheelScrollOffset = nil
    return true
  end
  return false
end

function BP_ArcScrollView_C:HandleMouseWheelMovement(deltaTime)
  if self.targetWheelScrollOffset then
    local scrollOffset = self:GetScrollOffset()
    if math.abs(scrollOffset - self.targetWheelScrollOffset) > 1 then
      local newOffsetOffset = LuaMathUtils.FInterpTo(scrollOffset, self.targetWheelScrollOffset, deltaTime, 5)
      if math.abs(newOffsetOffset - self.targetWheelScrollOffset) <= 1 then
        newOffsetOffset = self.targetWheelScrollOffset
        self.targetWheelScrollOffset = nil
      end
      self:SetScrollOffset(newOffsetOffset)
      self.OnUserScrolled:Broadcast(newOffsetOffset)
    else
      local newOffsetOffset = self.targetWheelScrollOffset
      self:SetScrollOffset(newOffsetOffset)
      self.OnUserScrolled:Broadcast(newOffsetOffset)
      self.targetWheelScrollOffset = nil
    end
    return true
  end
  return false
end

function BP_ArcScrollView_C:HandleAutoSnap(deltaTime)
  if self.autoSnapCountdownTime <= 0 then
    self.autoSnapCountdownTime = 0
    local scrollOffset = self:GetScrollOffset()
    local snapMultiplier = 1
    if self.EnablePageNation then
      snapMultiplier = self.PageItemCount
    end
    local snapScrollOffset = math.floor(scrollOffset / (self:GetItemSize().Y * snapMultiplier) + 0.5) * self:GetItemSize().Y * snapMultiplier
    if snapScrollOffset > self:GetMaxScrollOffset() then
      snapScrollOffset = (math.floor(scrollOffset / (self:GetItemSize().Y * snapMultiplier) + 0.5) - 1) * self:GetItemSize().Y * snapMultiplier
    end
    if math.abs(scrollOffset - snapScrollOffset) > 1 then
      local newOffsetOffset = LuaMathUtils.FInterpTo(scrollOffset, snapScrollOffset, deltaTime, 5)
      if math.abs(newOffsetOffset - snapScrollOffset) <= 1 then
        newOffsetOffset = snapScrollOffset
      end
      self:SetScrollOffset(newOffsetOffset)
      self.OnUserScrolled:Broadcast(newOffsetOffset)
      return true
    elseif 0 ~= math.abs(scrollOffset - snapScrollOffset) then
      local newOffsetOffset = snapScrollOffset
      self:SetScrollOffset(newOffsetOffset)
      self.OnUserScrolled:Broadcast(newOffsetOffset)
      return true
    end
    return false
  end
  return false
end

function BP_ArcScrollView_C:ScrollToLastPage()
  if not self.EnablePageNation then
    return
  end
  local newPageIndex = self.currentPageIndex - 1
  if newPageIndex < 0 then
    newPageIndex = 0
  end
  if newPageIndex > self.maxPageIndex then
    newPageIndex = self.maxPageIndex
  end
  local targetWheelScrollOffset = newPageIndex * self:GetItemSize().Y * self.PageItemCount
  self:SetTargetWheelScrollOffset(targetWheelScrollOffset)
  self.currentPageIndex = newPageIndex
end

function BP_ArcScrollView_C:ScrollToNextPage()
  if not self.EnablePageNation then
    return
  end
  local newPageIndex = self.currentPageIndex + 1
  if newPageIndex < 0 then
    newPageIndex = 0
  end
  if newPageIndex > self.maxPageIndex then
    newPageIndex = self.maxPageIndex
  end
  local targetWheelScrollOffset = newPageIndex * self:GetItemSize().Y * self.PageItemCount
  self:SetTargetWheelScrollOffset(targetWheelScrollOffset)
  self.currentPageIndex = newPageIndex
end

function BP_ArcScrollView_C:HandleStartScrollForPagination()
  if self.wheelDataThisFrame > 0 then
    self:ScrollToLastPage()
  elseif self.wheelDataThisFrame < 0 then
    self:ScrollToNextPage()
  end
end

function BP_ArcScrollView_C:HandleEndScrollForPagination()
  self.isMouseWheelForPagination = false
  self.mouseWheelEndRestTimeForPagination = 0
end

function BP_ArcScrollView_C:RefreshPageIndexWithOffset()
  local offset = self:GetScrollOffset()
  self.currentPageIndex = math.round(offset / (self:GetItemSize().Y * self.PageItemCount))
end

return BP_ArcScrollView_C
