local FurnitureTouchPlace = Class("FurnitureTouchPlace")

function FurnitureTouchPlace:Ctor(HomeMain)
  self.HomeMain = HomeMain
  self.TouchIdx = -1
end

function FurnitureTouchPlace:OnRocoTouchStartHandler(TouchIndex, Pos)
  self.SpawnStatus = nil
  if -1 == self.TouchIdx and self:IfPosInFurnitureListBounds(Pos.X, Pos.Y) then
    assert(nil == self.PreTouchWidgetItem)
    assert(nil == self.TouchWidgetItem)
    self.TouchIdx = TouchIndex
    self.TouchPos = Pos
    self.TouchStartPos = UE.FVector2D(Pos.X, Pos.Y)
    self:InternalStartTouch()
  end
end

function FurnitureTouchPlace:OnRocoTouchMoveHandler(TouchIndex, Pos)
  if self.TouchIdx == TouchIndex then
    self.TouchPos = Pos
    self:InternalTouchMove()
  end
end

function FurnitureTouchPlace:OnRocoTouchEndHandler(TouchIndex)
  if TouchIndex == self.TouchIdx then
    self.TouchIdx = -1
    self.PopupItemData = nil
    self.HoverPropsData = nil
    self.PreTouchWidgetItem = nil
    self.HomeMain.NRCImage_FlowHomeIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    HomeIndoorSandbox.World.Controller:TryUnSelectPropsByPressing()
    if self.TouchWidgetItem then
      self.TouchWidgetItem:UnSelectAnimation()
      self.TouchWidgetItem = nil
    end
    if self.SpawnStatus then
      HomeIndoorSandbox.HomeEditServ:DisplayTipsBySpawnStatus(self.SpawnStatus)
      self.SpawnStatus = nil
    end
  end
end

function FurnitureTouchPlace:InternalStartTouch()
end

function FurnitureTouchPlace:InternalCheckSelectItem(Item, locationY)
  local realSize = UE4.USlateBlueprintLibrary.GetAbsoluteSize(Item:GetCachedGeometry())
  local r = -realSize.Y / 8
  local d = locationY - self.TouchStartPos.Y
  if r > d then
    self.PopupItemData = Item.data
    self.TouchWidgetItem = Item
    self.HomeMain.NRCImage_FlowHomeIcon:SetVisibility(UE.ESlateVisibility.Visible)
    self.HomeMain.NRCImage_FlowHomeIcon:SetPath(Item.ItemImage.ImagePath.AssetPathName)
    self.TouchWidgetItem:SelectAnimation()
    _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_HomeItem_C:OnItemSelected")
    self.PreTouchWidgetItem = nil
    return true
  end
end

function FurnitureTouchPlace:InternalTouchMove()
  if not self.PopupItemData and self.HomeMain:InFurnitureMode() then
    if self.PreTouchWidgetItem and UE4.UObject.IsValid(self.PreTouchWidgetItem) then
      local locationX = self.TouchPos.X
      local locationY = self.TouchPos.Y
      local realSize = UE4.USlateBlueprintLibrary.GetAbsoluteSize(self.PreTouchWidgetItem:GetCachedGeometry())
      if math.abs(locationX - self.TouchStartPos.X) < realSize.X then
        self:InternalCheckSelectItem(self.PreTouchWidgetItem, locationY)
      end
      return
    end
    local FirstItemIndex = self.HomeMain.Furniture:GetFirstIndex()
    local LastItemIndex = self.HomeMain.Furniture:GetLastIndex()
    for i = FirstItemIndex, LastItemIndex do
      local Item = self.HomeMain.Furniture:GetItemByIndex(i)
      if Item then
        local locationX = self.TouchPos.X
        local locationY = self.TouchPos.Y
        local bInclude = self:IfPosInWidget(Item, locationX, locationY)
        if bInclude then
          self.PreTouchWidgetItem = Item
          self:InternalCheckSelectItem(self.PreTouchWidgetItem, locationY)
          break
        end
      end
    end
  end
  if self.HoverPropsData then
    self:TryMovePropsByPressing(self.TouchPos)
  elseif self.PopupItemData then
    local PixelPoint = self:InternalFollowPlaceIcon(self.TouchPos.X, self.TouchPos.Y)
    if not self:IfPosInFurnitureListBoundsCache(self.TouchPos.X, self.TouchPos.Y) and HomeIndoorSandbox.HomePropsServ:IsRoomEstablished(HomeIndoorSandbox.HomeEditServ.EditRoomId) then
      HomeIndoorSandbox.Module:ApplyFurnitureData(self.PopupItemData, PixelPoint)
    end
  end
end

function FurnitureTouchPlace:OnPostCreateItem(PropsData, Status)
  self.SpawnStatus = Status
  if not self.PopupItemData then
    return
  end
  if PropsData then
    self.PopupItemData = nil
    self.HoverPropsData = PropsData
    self.HomeMain.NRCImage_FlowHomeIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    HomeIndoorSandbox.World.Controller:TrySelectPropsByPressing(self.TouchIdx, PropsData)
  end
end

function FurnitureTouchPlace:InternalFollowPlaceIcon(locationX, locationY)
  local PixelPoint, NewViewportPoint = self:AdjustTouchPos(locationX, locationY)
  local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.HomeMain.NRCImage_FlowHomeIcon)
  Slot:SetPosition(NewViewportPoint)
  return PixelPoint
end

function FurnitureTouchPlace:IfPosInWidget(Box, ScreenX, ScreenY)
  local TouchScreenPoint = UE.FVector2D(ScreenX, ScreenY)
  local TouchAreaGeo = Box:GetCachedGeometry()
  return UE4.USlateBlueprintLibrary.IsUnderLocation(TouchAreaGeo, TouchScreenPoint)
end

function FurnitureTouchPlace:AdjustTouchPos(locationX, locationY)
  local BorderWidth = UE4.USlateBlueprintLibrary.GetNRCBorderWidth()
  local BorderHeight = UE4.USlateBlueprintLibrary.GetNRCBorderHeight()
  local ScreenPoint = UE.FVector2D(locationX - BorderWidth, locationY - BorderHeight)
  local AbsolutePoint = UE.FVector2D(0, 0)
  UE4.USlateBlueprintLibrary.ScreenToWidgetAbsoluteConsiderBorder(_G.UE4Helper.GetCurrentWorld(), ScreenPoint, AbsolutePoint, true)
  local PixelPoint = UE.FVector2D(0, 0)
  local NewViewportPoint = UE.FVector2D(0, 0)
  UE4.USlateBlueprintLibrary.AbsoluteToViewport(_G.UE4Helper.GetCurrentWorld(), AbsolutePoint, PixelPoint, NewViewportPoint)
  local ViewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
  if BorderWidth > 0 then
    PixelPoint.X = PixelPoint.X / ViewportSize.X * (ViewportSize.X - 2 * BorderWidth) + BorderWidth
  end
  if BorderHeight > 0 then
    PixelPoint.Y = PixelPoint.Y / ViewportSize.Y * (ViewportSize.Y - 2 * BorderHeight) + BorderHeight
  end
  return PixelPoint, NewViewportPoint
end

function FurnitureTouchPlace:TryMovePropsByPressing(TouchPos)
  local PixelPoint, NewViewportPoint = self:AdjustTouchPos(TouchPos.X, TouchPos.Y)
  local Pos = PixelPoint
  HomeIndoorSandbox.World.Controller:TryMovePropsByPressing(Pos)
end

if _G.RocoEnv.IS_EDITOR then
  function FurnitureTouchPlace:IfPosInWidget(Box, X, Y)
    local TouchAreaGeo = Box:GetPaintSpaceGeometry()
    
    local absoluteSize = UE4.USlateBlueprintLibrary.GetAbsoluteSize(TouchAreaGeo)
    local viewportScale = UE4.UWidgetLayoutLibrary.GetViewportScale(Box)
    local realSize = UE4.FVector2D(absoluteSize.X, absoluteSize.Y) / viewportScale
    local topLeft = UE4.UNRCStatics.GetWidgetViewportPosition(Box)
    local ViewportPos = UE.FVector2D(0, 0)
    UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), UE.FVector2D(X, Y), ViewportPos)
    if ViewportPos.X < topLeft.X then
      return false
    end
    if ViewportPos.X > topLeft.X + realSize.X then
      return false
    end
    if ViewportPos.Y < topLeft.Y then
      return false
    end
    if ViewportPos.Y > topLeft.Y + realSize.Y then
      return false
    end
    return true
  end
  
  function FurnitureTouchPlace:InternalFollowPlaceIcon(locationX, locationY)
    local ViewportPos = UE.FVector2D(0, 0)
    UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), UE.FVector2D(locationX, locationY), ViewportPos)
    local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.HomeMain.NRCImage_FlowHomeIcon)
    Slot:SetPosition(ViewportPos)
    return self.TouchPos
  end
  
  function FurnitureTouchPlace:TryMovePropsByPressing(TouchPos)
    HomeIndoorSandbox.World.Controller:TryMovePropsByPressing(TouchPos)
  end
end

function FurnitureTouchPlace:IfPosInFurnitureListBounds(X, Y)
  local Box = self.HomeMain.EditFurniture
  return self:IfPosInWidget(Box, X, Y)
end

function FurnitureTouchPlace:IfPosInFurnitureListBoundsCache(X, Y)
  return self:IfPosInFurnitureListBounds(X, Y)
end

return FurnitureTouchPlace
