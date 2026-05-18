local UIUtils = require("NewRoco.Utils.UIUtils")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_ScrollPageController_C = _G.NRCPanelBase:Extend("UMG_ScrollPageController_C")

function UMG_ScrollPageController_C:OnConstruct()
  self.itemTotalNum = 0
  self.pageNum = 0
  self.curPage = 0
  if self.scrollView then
    self.scrollView.bUsePageController = true
  end
  self.CanScroll = true
  if self.LongPressDrag then
    self.IsLongPress = false
    self:InitLongPressTimeConfig()
    self.minDis = _G.DataConfigManager:GetPetGlobalConfig("box_drag_minimum_distance").num
    self.minDegrees = _G.DataConfigManager:GetPetGlobalConfig("team_drag_vertical_angel").num
    self.maxDisY = _G.DataConfigManager:GetPetGlobalConfig("vertical_swipe_distance_not_to_drag_pet").num
    self.maxDegrees = _G.DataConfigManager:GetPetGlobalConfig("swipe_angle_to_change_team").num
  end
  _G.NRCEventCenter:RegisterEvent("UMG_ScrollPageController_C", self, PetUIModuleEvent.OnPetPortableBagTouchEnded, self.OnPetPortableBagTouchEnded)
end

function UMG_ScrollPageController_C:InitEnableLongPressEvent()
  self.bEnableLongPressEvent = true
  self:InitLongPressTimeConfig()
end

function UMG_ScrollPageController_C:InitLongPressTimeConfig()
  if not self.LongPressTime then
    local pressTimeConf = _G.DataConfigManager:GetGlobalConfigByKeyType("drag_mode_press_time", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).num
    self.LongPressTime = self.LongPressTime or pressTimeConf and pressTimeConf / 1000 or 0.5
  end
end

function UMG_ScrollPageController_C:OnDestruct()
  self.pressPos = nil
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.OnPetPortableBagTouchEnded, self.OnPetPortableBagTouchEnded)
end

function UMG_ScrollPageController_C:SetCanScroll(CanScroll)
  self.CanScroll = CanScroll
end

function UMG_ScrollPageController_C:SetPageChangeHandler(_handler, _caller)
  self.callback = _G.MakeWeakFunctor(_caller, _handler)
end

function UMG_ScrollPageController_C:SetValidItemTotalNum(_validItemTotalNum, curPage)
  self.itemTotalNum = _validItemTotalNum or 0
  self.curPage = curPage or 0
  local itemNumPerPage = self:GetItemNumPerPage()
  if itemNumPerPage > 0 then
    self.pageNum = math.ceil(self.itemTotalNum / itemNumPerPage)
  else
    self.pageNum = 0
  end
end

function UMG_ScrollPageController_C:IsScrolling()
  if self.scrollingTimeLeft and self.scrollingTimeLeft > 0 then
    return true
  end
  return false
end

function UMG_ScrollPageController_C:GetTotalPageNum()
  return self.pageNum
end

function UMG_ScrollPageController_C:GetItemNumPerPage()
  return self.itemRowNumPerPage * self.itemColNumPerPage
end

function UMG_ScrollPageController_C:GetCurrentPage()
  return self.curPage
end

function UMG_ScrollPageController_C:ScrollToPage(_page, _animateTime, needAudio)
  if not self.scrollView then
    return false
  end
  if _page >= 0 and _page < self.pageNum and self.CanScroll then
    self:CancelAllDelay()
    if needAudio then
      _G.NRCAudioManager:PlaySound2DAuto(40006005, "UMG_ThisTag_C:OnActive")
    end
    self.curPage = _page
    self.scrollingTimeLeft = _animateTime or self.pageScrollTime
    local itemIndex = self.curPage * self:GetItemNumPerPage()
    if self.scrollView.Orientation == UE4.EOrientation.Orient_Horizontal then
      local ColIndex = math.floor(itemIndex / self.itemRowNumPerPage)
      self.desiredScrollOffset = self.scrollView:GetDesiredScrollOffsetByIndex(ColIndex)
    else
      local RowIndex = math.floor(itemIndex / self.itemColNumPerPage)
      self.desiredScrollOffset = self.scrollView:GetDesiredScrollOffsetByIndex(RowIndex)
    end
    return true
  end
  return false
end

function UMG_ScrollPageController_C:OnTick(deltaTime)
  if not self.scrollView then
    return
  end
  if not self.scrollingTimeLeft or self.scrollingTimeLeft <= 0 then
    return
  end
  if not self.CanScroll then
    return
  end
  if deltaTime < self.scrollingTimeLeft then
    local curOffset = self.scrollView:GetScrollOffset()
    local distOffset = self.desiredScrollOffset - curOffset
    local targetOffset = curOffset + distOffset / self.scrollingTimeLeft * deltaTime
    self.scrollingTimeLeft = self.scrollingTimeLeft - deltaTime
    self.scrollView:SetScrollOffset(targetOffset)
    self.scrollView:SlateHandleWhenUserScrolled(targetOffset)
  else
    self.scrollingTimeLeft = 0
    self.scrollView:SetScrollOffset(self.desiredScrollOffset)
    self.scrollView:SlateHandleWhenUserScrolled(self.desiredScrollOffset)
    if self.callback then
      self.callback(self.curPage)
    end
  end
end

function UMG_ScrollPageController_C:GetLongPressMouseWheelItem(_MyGeometry, _TouchEvent)
  local LongPressEndItem, LongPressEndItemIndex = self:GetItemByTouchPos(_MyGeometry, _TouchEvent)
  if LongPressEndItem then
    if self.LastLongPressEndItem then
      if self.LastLongPressEndItem.index ~= LongPressEndItem.index then
        self.LastLongPressEndItem:LongDragSwitchToNormalMode()
        if LongPressEndItem.isEgg or LongPressEndItem.uiData ~= nil and LongPressEndItem.uiData.IsTravel then
          self.LastLongPressEndItem = nil
          self.LastLongPressEndItemIndex = nil
          return UE4.UWidgetBlueprintLibrary.Handled()
        end
        LongPressEndItem:SetDragMouseWheelMode()
        self.LastLongPressEndItem = LongPressEndItem
        self.LastLongPressEndItemIndex = LongPressEndItemIndex
      end
    else
      if LongPressEndItem.isEgg or LongPressEndItem.uiData and LongPressEndItem.uiData.IsTravel then
        return UE4.UWidgetBlueprintLibrary.Handled()
      end
      LongPressEndItem:SetDragMouseWheelMode()
      self.LastLongPressEndItem = LongPressEndItem
      self.LastLongPressEndItemIndex = LongPressEndItemIndex
    end
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_ScrollPageController_C:GetLongPressStartItem(_MyGeometry, _TouchEvent)
  self.LongPressItem, self.LongPressItemIndex = self:GetItemByTouchPos(_MyGeometry, _TouchEvent)
end

function UMG_ScrollPageController_C:GetLongPressEndItem(_MyGeometry, _TouchEvent)
  local LongPressEndItem, LongPressEndItemIndex = self:GetItemByTouchPos(_MyGeometry, _TouchEvent)
  if LongPressEndItem then
    if LongPressEndItem.isEgg or LongPressEndItem.uiData and LongPressEndItem.uiData.IsTravel then
      return
    end
    if LongPressEndItem.IsNilPet or not LongPressEndItem.hasPet then
      _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.PetBagDragSelectItem, LongPressEndItem._data, true, LongPressEndItemIndex)
    else
      _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.PetBagDragSelectItem, LongPressEndItem.uiData, true, LongPressEndItemIndex)
    end
  end
end

function UMG_ScrollPageController_C:GetItemByTouchPos(_MyGeometry, _TouchEvent)
  local item
  local itemIndex = -1
  local screenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(_TouchEvent)
  local curPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(_MyGeometry, screenPos)
  local GeometrySize = UE4.USlateBlueprintLibrary.GetLocalSize(_MyGeometry)
  local itemWidth = GeometrySize.X / self.itemColNumPerPage
  local itemHeight = GeometrySize.Y / self.itemRowNumPerPage
  local clickCol = math.floor(curPos.X / itemWidth)
  local clickRow = math.floor(curPos.Y / itemHeight)
  local inClickArea = true
  local clickAreaWidthScale = self.clickAreaWidthScale or 1
  local clickAreaHeightScale = self.clickAreaHeightScale or 1
  if clickAreaWidthScale < 1 then
    local desireWidthMin = clickCol * itemWidth + (1 - clickAreaWidthScale) * itemWidth
    local desireWidthMax = clickCol * itemWidth + clickAreaWidthScale * itemWidth
    if desireWidthMin > curPos.X or desireWidthMax < curPos.X then
      inClickArea = false
    end
  end
  if inClickArea and clickAreaHeightScale < 1 then
    local desireHeightMin = clickRow * itemHeight + (1 - clickAreaHeightScale) * itemHeight
    local desireHeightMax = clickRow * itemHeight + clickAreaHeightScale * itemHeight
    if desireHeightMin > curPos.Y or desireHeightMax < curPos.Y then
      inClickArea = false
    end
  end
  if inClickArea then
    if self.itemRowNumPerPage > 1 then
      if self.scrollView.Orientation == UE4.EOrientation.Orient_Horizontal then
        itemIndex = (clickCol + self.curPage * self.itemColNumPerPage) * self.itemRowNumPerPage + clickRow
      else
        itemIndex = (clickRow + self.curPage * self.itemRowNumPerPage) * self.itemColNumPerPage + clickCol
      end
    else
      itemIndex = self.curPage * self:GetItemNumPerPage() + clickCol
    end
    if itemIndex >= 0 and itemIndex < self.itemTotalNum then
      item = self.scrollView:GetItemByIndex(itemIndex)
    else
      Log.InfoFormat("UMG_ScrollPageController_C: itemIndex=%d, totalNum=%d", itemIndex, self.itemTotalNum)
    end
  else
    Log.InfoFormat("UMG_ScrollPageController_C: not in clickArea. curPos=(%s,%s), click=(%s,%s)", tostring(curPos.X), tostring(curPos.Y), tostring(clickRow), tostring(clickCol))
  end
  return item, itemIndex
end

function UMG_ScrollPageController_C:LongPress()
  if self.LongPressItem and self.LongPressItem._data then
    if self.LongPressItem.ScrollType == UIUtils.ScrollPageItemType.PetWareHouseExchange then
      self.LongPressItem:LongPress()
    else
      self.LongPressItem:SwitchToChange()
      _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.SetPanelCanScroll, false, self.LongPressItem._data, self.LongPressItemIndex)
    end
  end
  self.bStartTouch = false
  self.pressPos = nil
end

function UMG_ScrollPageController_C:OnLongPressEvent(LongPressItem)
  Log.Debug("UMG_ScrollPageController_C:OnLongPressEvent", LongPressItem, self.LongPressItem)
  if LongPressItem ~= self.LongPressItem then
    return
  end
  Log.Debug("UMG_ScrollPageController_C:OnLongPressEvent", self.scrollView:GetSelectedIndex(), self.LongPressItemIndex + 1)
  self.LongPressItem.bLongPressEventTriggered = true
  self.LongPressItem:OnLongPressEvent()
  if self.scrollView:GetSelectedIndex() ~= self.LongPressItemIndex + 1 then
    self.scrollView:SelectItemByIndex(self.LongPressItemIndex)
  end
end

function UMG_ScrollPageController_C:CancelAllDelay()
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
end

function UMG_ScrollPageController_C:HandlePressStart(_MyGeometry, _PointerEvent)
  local screenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(_PointerEvent)
  self.pressPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(_MyGeometry, screenPos)
  if self.LongPressItem and self.LongPressItem.OnLongPressEvent and self.LongPressItem.CanTriggerLongPress and self.LongPressItem:CanTriggerLongPress() then
    self:CancelAllDelay()
    self.LongPressItem.bLongPressEventTriggered = false
    local bSelected = self.scrollView:GetSelectedIndex() == self.LongPressItemIndex + 1
    self.LongPressItem:OnLongPressStartEvent(bSelected)
    self.DelayHandle = _G.DelayManager:DelaySeconds(self.LongPressTime or 0.5, self.OnLongPressEvent, self, self.LongPressItem)
    Log.Debug("UMG_ScrollPageController_C:HandlePressStart Delay LongPressEvent")
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_ScrollPageController_C:HandlePressMove(_MyGeometry, _PointerEvent)
  if not self.CanScroll then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  if self.scrollingTimeLeft and self.scrollingTimeLeft > 0 then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  if self.pressPos and self.scrollView then
    local screenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(_PointerEvent)
    local curPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(_MyGeometry, screenPos)
    local pressMoveOffset = 0
    if self.scrollView.Orientation == UE4.EOrientation.Orient_Horizontal then
      pressMoveOffset = curPos.X - self.pressPos.X
    else
      pressMoveOffset = curPos.Y - self.pressPos.Y
    end
    if math.abs(pressMoveOffset) > self.touchScrollSensitivity then
      local pageToScroll = pressMoveOffset > 0 and self.curPage - 1 or self.curPage + 1
      if self.bCyclicScrolling then
        if pageToScroll < 0 then
          pageToScroll = self.pageNum - 1
        elseif pageToScroll >= self.pageNum then
          pageToScroll = 0
        end
        self.bPauseScroll = true
      end
      self:ScrollToPage(pageToScroll)
    end
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_ScrollPageController_C:HandleMouseWheel(_MyGeometry, _PointerEvent)
  if self.scrollingTimeLeft and self.scrollingTimeLeft > 0 then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  do
    local wheelDelta = UE4.UKismetInputLibrary.PointerEvent_GetWheelDelta(_PointerEvent)
    if math.abs(wheelDelta) > 0 then
      local pageToScroll = wheelDelta > 0 and self.curPage - 1 or self.curPage + 1
      if self.bCyclicScrolling then
        if pageToScroll < 0 then
          pageToScroll = self.pageNum - 1
        elseif pageToScroll >= self.pageNum then
          pageToScroll = 0
        end
      end
      self:ScrollToPage(pageToScroll)
    end
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_ScrollPageController_C:HandlePressEnd(_MyGeometry, _PointerEvent)
  if self.scrollingTimeLeft and self.scrollingTimeLeft > 0 then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  if self.LongPressItem and self.LongPressItem.bLongPressEventTriggered then
    self.LongPressItem.bLongPressEventTriggered = false
    self.LongPressItem:OnLongPressEndEvent()
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  local prePos = self.pressPos
  if prePos and self.scrollView then
    local screenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(_PointerEvent)
    local curPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(_MyGeometry, screenPos)
    if math.abs(curPos.X - prePos.X) <= self.touchScrollSensitivity and math.abs(curPos.Y - prePos.Y) <= self.touchScrollSensitivity then
      local GeometrySize = UE4.USlateBlueprintLibrary.GetLocalSize(_MyGeometry)
      local itemWidth = GeometrySize.X / self.itemColNumPerPage
      local itemHeight = GeometrySize.Y / self.itemRowNumPerPage
      local clickCol = math.floor(curPos.X / itemWidth)
      local clickRow = math.floor(curPos.Y / itemHeight)
      local inClickArea = true
      local clickAreaWidthScale = self.clickAreaWidthScale or 1
      local clickAreaHeightScale = self.clickAreaHeightScale or 1
      if clickAreaWidthScale < 1 then
        local desireWidthMin = clickCol * itemWidth + (1 - clickAreaWidthScale) * itemWidth
        local desireWidthMax = clickCol * itemWidth + clickAreaWidthScale * itemWidth
        if desireWidthMin > curPos.X or desireWidthMax < curPos.X then
          inClickArea = false
        end
      end
      if inClickArea and clickAreaHeightScale < 1 then
        local desireHeightMin = clickRow * itemHeight + (1 - clickAreaHeightScale) * itemHeight
        local desireHeightMax = clickRow * itemHeight + clickAreaHeightScale * itemHeight
        if desireHeightMin > curPos.Y or desireHeightMax < curPos.Y then
          inClickArea = false
        end
      end
      if inClickArea then
        local itemIndex = -1
        if self.itemRowNumPerPage > 1 then
          if self.scrollView.Orientation == UE4.EOrientation.Orient_Horizontal then
            itemIndex = (clickCol + self.curPage * self.itemColNumPerPage) * self.itemRowNumPerPage + clickRow
          else
            itemIndex = (clickRow + self.curPage * self.itemRowNumPerPage) * self.itemColNumPerPage + clickCol
          end
        else
          itemIndex = self.curPage * self:GetItemNumPerPage() + clickCol
        end
        if itemIndex >= 0 and itemIndex < self.itemTotalNum then
          self.scrollView:SelectItemByIndex(itemIndex)
        else
          Log.InfoFormat("UMG_ScrollPageController_C: itemIndex=%d, totalNum=%d", itemIndex, self.itemTotalNum)
        end
      else
        Log.InfoFormat("UMG_ScrollPageController_C: not in clickArea. curPos=(%s,%s), click=(%s,%s)", tostring(curPos.X), tostring(curPos.Y), tostring(clickRow), tostring(clickCol))
      end
    else
      Log.InfoFormat("UMG_ScrollPageController_C: curPos=(%s,%s), pressPos=(%s,%s)", tostring(curPos.X), tostring(curPos.Y), tostring(prePos.X), tostring(prePos.Y))
    end
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_ScrollPageController_C:OnMouseButtonDown(_MyGeometry, _MouseEvent)
  if self.isDestruct then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  return self:HandlePressStart(_MyGeometry, _MouseEvent)
end

function UMG_ScrollPageController_C:OnMouseButtonUp(_MyGeometry, _MouseEvent)
  if self.isDestruct then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  return self:HandlePressEnd(_MyGeometry, _MouseEvent)
end

function UMG_ScrollPageController_C:OnMouseWheel(_MyGeometry, _MouseEvent)
  if self.isDestruct then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  if RocoEnv.PLATFORM_WINDOWS then
    return self:HandleMouseWheel(_MyGeometry, _MouseEvent)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_ScrollPageController_C:OnTouchStarted(_MyGeometry, _TouchEvent)
  self.bStartTouch = false
  self.bPauseScroll = false
  if self.isDestruct then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  self:CancelAllDelay()
  if self.LongPressDrag then
    self:GetLongPressStartItem(_MyGeometry, _TouchEvent)
    if self.LongPressItem and (not (not self.LongPressItem.isEgg and not self.LongPressItem.IsNilPet and self.LongPressItem.hasPet and self.LongPressItem.clickable) or self.LongPressItem.uiData and self.LongPressItem.uiData.IsTravel) then
    else
      self.bStartTouch = true
      self.DelayHandle = _G.DelayManager:DelaySeconds(self.LongPressTime or 0.5, self.LongPress, self)
    end
  end
  if self.bEnableLongPressEvent then
    self:GetLongPressStartItem(_MyGeometry, _TouchEvent)
  end
  return self:HandlePressStart(_MyGeometry, _TouchEvent)
end

function UMG_ScrollPageController_C:OnTouchMoved(_MyGeometry, _MouseEvent)
  if self.isDestruct then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  local angleDegrees
  if self.pressPos and not self:IsScrolling() and self.scrollView and not self.bPauseScroll and self.minDegrees and self.minDis and self.maxDisY then
    local screenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(_MouseEvent)
    local curPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(_MyGeometry, screenPos)
    local pressMoveOffsetX = 0
    local pressMoveOffsetY = 0
    pressMoveOffsetX = math.abs(curPos.X - self.pressPos.X)
    pressMoveOffsetY = math.abs(curPos.Y - self.pressPos.Y)
    if pressMoveOffsetY > 0.001 then
      local angle = math.atan(pressMoveOffsetX / pressMoveOffsetY)
      if angle then
        angleDegrees = math.deg(angle)
      end
    end
    if angleDegrees and angleDegrees > self.minDegrees and pressMoveOffsetX > self.minDis then
      if self.bStartTouch and self.LongPressDrag then
        self:LongPress()
        self:CancelAllDelay()
      end
    elseif pressMoveOffsetY > self.maxDisY then
      self.bStartTouch = false
      self:CancelAllDelay()
    end
  elseif not self.bEnableLongPressEvent then
    self.bStartTouch = false
    self:CancelAllDelay()
  end
  if self.IsLongPress and self.LongPressDrag then
    return self:GetLongPressMouseWheelItem(_MyGeometry, _MouseEvent)
  end
  if self.CanScroll and not self.bPauseScroll then
    if angleDegrees and self.LongPressDrag and self.maxDegrees then
      if angleDegrees < self.maxDegrees then
        return self:HandlePressMove(_MyGeometry, _MouseEvent)
      end
    else
      return self:HandlePressMove(_MyGeometry, _MouseEvent)
    end
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_ScrollPageController_C:OnTouchEnded(_MyGeometry, _TouchEvent)
  if self.isDestruct then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  self.bStartTouch = false
  self.bPauseScroll = false
  self:CancelAllDelay()
  if self.LongPressDrag and self.IsLongPress then
    self:GetLongPressEndItem(_MyGeometry, _TouchEvent)
    _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.SetPanelCanScroll, true)
    self.LastLongPressEndItem = nil
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  return self:HandlePressEnd(_MyGeometry, _TouchEvent)
end

function UMG_ScrollPageController_C:OnPetPortableBagTouchEnded()
  self:CancelAllDelay()
  if self.LongPressDrag and self.IsLongPress then
    if self.LastLongPressEndItem and self.LastLongPressEndItemIndex then
      if self.LastLongPressEndItem.isEgg or self.LastLongPressEndItem.uiData and self.LastLongPressEndItem.uiData.IsTravel then
        return
      end
      if self.LastLongPressEndItem.IsNilPet or not self.LastLongPressEndItem.hasPet then
        _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.PetBagDragSelectItem, self.LastLongPressEndItem._data, true, self.LastLongPressEndItemIndex)
      else
        _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.PetBagDragSelectItem, self.LastLongPressEndItem.uiData, true, self.LastLongPressEndItemIndex)
      end
    end
    self.LastLongPressEndItemIndex = nil
    self.LastLongPressEndItem = nil
  end
end

function UMG_ScrollPageController_C:OnMouseEnter(_MyGeometry, _MouseEvent)
  if self.isDestruct then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  if RocoEnv.PLATFORM_WINDOWS and self.scrollView and self.CanScroll then
    self.scrollView:SetScrollBarForceVisible(true)
  end
end

function UMG_ScrollPageController_C:OnMouseLeave(_MouseEvent)
  if self.isDestruct then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  if self.LongPressDrag and self.IsLongPress and self.LastLongPressEndItem then
    self.LastLongPressEndItem:LongDragSwitchToNormalMode()
    self.LastLongPressEndItem = nil
  end
  if RocoEnv.PLATFORM_WINDOWS and self.scrollView then
    self.scrollView:SetScrollBarForceVisible(false)
  end
end

return UMG_ScrollPageController_C
