local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Delegate = require("Utils.Delegate")
local UMG_PetBagList_C = _G.NRCPanelBase:Extend("UMG_PetBagList_C")

function UMG_PetBagList_C:OnConstruct()
  self.itemSize = {0, 0}
  self.OnGuidanceReleased = Delegate()
  _G.NRCEventCenter:RegisterEvent("UMG_PetBagList_C", self, PetUIModuleEvent.OnPetPortableBagTouchEnded, self.OnPetPortableBagTouchEnded)
end

function UMG_PetBagList_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent, OnPetPortableBagTouchEnded, self.OnPetPortableBagTouchEnded)
end

function UMG_PetBagList_C:HasInit()
  return self.itemSize and self.ScrollOffset
end

function UMG_PetBagList_C:SetInfo(itemSize, ScrollOffset)
  if itemSize then
    self.itemSize = itemSize
  end
  self.IsLongPress = false
  self.ScrollOffset = ScrollOffset
end

function UMG_PetBagList_C:GetLongPressEndItem(_MyGeometry, _TouchEvent)
  local LongPressEndItem, LongPressEndItemIndex = self:GetItemByTouchPos(_MyGeometry, _TouchEvent)
  if LongPressEndItem and (LongPressEndItem.uiData or LongPressEndItem.IsNilPet) then
    if LongPressEndItem.isEgg or LongPressEndItem.uiData and LongPressEndItem.uiData.IsTravel then
      return
    end
    if LongPressEndItem.bFiltering then
      return
    end
    _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.PetBagDragSelectItem, LongPressEndItem.uiData or {gid = "IsNil", isInBackPack = true}, false, LongPressEndItemIndex)
  end
end

function UMG_PetBagList_C:GetLongPressMouseWheelItem(_MyGeometry, _TouchEvent)
  local LongPressEndItem, LongPressEndItemIndex = self:GetItemByTouchPos(_MyGeometry, _TouchEvent)
  if LongPressEndItem then
    if self.LastLongPressEndItem then
      if self.LastLongPressEndItem.pos ~= LongPressEndItem.pos and not LongPressEndItem.bFiltering then
        if LongPressEndItem.isEgg or LongPressEndItem.uiData and LongPressEndItem.uiData.IsTravel then
          return
        end
        self.LastLongPressEndItem:LongDragSwitchToNormalMode()
        LongPressEndItem:SetDragMouseWheelMode()
        self.LastLongPressEndItem = LongPressEndItem
        self.LastLongPressEndItemIndex = LongPressEndItemIndex
      end
    else
      if LongPressEndItem.isEgg or LongPressEndItem.uiData and LongPressEndItem.uiData.IsTravel or LongPressEndItem.bFiltering then
        return
      end
      LongPressEndItem:SetDragMouseWheelMode()
      self.LastLongPressEndItem = LongPressEndItem
      self.LastLongPressEndItemIndex = LongPressEndItemIndex
    end
  end
end

function UMG_PetBagList_C:GetItemByTouchPos(_MyGeometry, _TouchEvent)
  local screenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(_TouchEvent)
  local curPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(_MyGeometry, screenPos)
  if 0 == self.itemSize.X or 0 == self.itemSize.Y then
    return
  end
  local AllRow = curPos.Y + self.ScrollOffset
  local AllCol = curPos.X
  local clickCol = math.floor(AllCol / self.itemSize.X)
  local clickRow = math.floor(AllRow / self.itemSize.Y)
  if clickCol >= self.Col then
    return nil, nil
  end
  local index = clickRow * self.Col + clickCol
  local item = self.ScrollView:GetItemByIndex(index)
  return item, index
end

function UMG_PetBagList_C:OnTouchEnded(_MyGeometry, _TouchEvent)
  if self.IsLongPress then
    self:GetLongPressEndItem(_MyGeometry, _TouchEvent)
  else
    self:OnItemSelectByPos(_MyGeometry, _TouchEvent)
    self.TouchStartIndex = nil
  end
  _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.SetPanelCanScroll, true)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_PetBagList_C:OnPetPortableBagTouchEnded()
  if self.IsLongPress and self.LastLongPressEndItem and self.LastLongPressEndItemIndex and self.LastLongPressEndItem and (self.LastLongPressEndItem.uiData or self.LastLongPressEndItem.IsNilPet) then
    if self.LastLongPressEndItem.isEgg or self.LastLongPressEndItem.uiData and self.LastLongPressEndItem.uiData.IsTravel then
      return
    end
    if self.LastLongPressEndItem.bFiltering then
      return
    end
    _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.PetBagDragSelectItem, self.LastLongPressEndItem.uiData or {gid = "IsNil", isInBackPack = true}, false, self.LastLongPressEndItemIndex)
  end
  self.LastLongPressEndItemIndex = nil
  self.LastLongPressEndItem = nil
end

function UMG_PetBagList_C:OnTouchStarted(_MyGeometry, _TouchEvent)
  self.TouchStartIndex = self:OnItemSelectByPos(_MyGeometry, _TouchEvent, true)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_PetBagList_C:OnItemSelectByPos(_MyGeometry, _TouchEvent, NoSelect)
  local screenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(_TouchEvent)
  local curPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(_MyGeometry, screenPos)
  if 0 == self.itemSize.X or 0 == self.itemSize.Y or self.itemSize.X == nil or self.itemSize.Y == nil then
    return
  end
  local AllRow = curPos.Y + (self.ScrollOffset or 0)
  local AllCol = curPos.X
  local clickCol = math.floor(AllCol / self.itemSize.X)
  local clickRow = math.floor(AllRow / self.itemSize.Y)
  local index = math.floor(clickRow * self.Col + clickCol)
  if NoSelect then
    return index
  end
  if self.TouchStartIndex == index then
    local item = self.ScrollView:GetItemByIndex(index)
    if item and item.IsNilPet then
      item.clickable = true
    end
    if item and item.uiData and (item.uiData.IsTravel or item.uiData.IsInHome or item.uiData.IsInGuard) then
      return
    end
    if item and item.bFiltering then
      return
    end
    self.ScrollView:SelectItemByIndex(index)
  end
end

function UMG_PetBagList_C:OnTouchMoved(_MyGeometry, _TouchEvent)
  if self.IsLongPress then
    self:GetLongPressMouseWheelItem(_MyGeometry, _TouchEvent)
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_PetBagList_C:OnMouseLeave(_MyGeometry, _TouchEvent)
  if self.IsLongPress and self.LastLongPressEndItem then
    self.LastLongPressEndItem:LongDragSwitchToNormalMode()
    self.LastLongPressEndItem = nil
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_PetBagList_C:OnAddEventListener()
end

function UMG_PetBagList_C:OnMouseButtonReleased()
  if self.OnGuidanceReleased then
    self.OnGuidanceReleased:Invoke(self)
  end
end

return UMG_PetBagList_C
