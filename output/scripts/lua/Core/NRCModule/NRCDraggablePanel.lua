local NRCDraggablePanel = _G.NRCPanelBase:Extend("NRCDraggablePanel")

function NRCDraggablePanel:OnConstruct()
  self.isDragging = false
  self.dragOffset = UE4.FVector2D(0, 0)
  self.lastMousePosition = UE4.FVector2D(0, 0)
  self.enableDrag = true
  self.dragAreaWidget = nil
  self.isConstrainToViewport = true
  self.dragThreshold = 1
  self.cachedViewportSize = nil
  self.cachedPanelSize = nil
end

function NRCDraggablePanel:OnActive(...)
  if self.enableDrag then
    self:SetupDragArea()
  end
end

function NRCDraggablePanel:SetDraggable(enable)
  self.enableDrag = enable
end

function NRCDraggablePanel:SetConstrainToViewport(constrain)
  self.isConstrainToViewport = constrain
end

function NRCDraggablePanel:SetDragArea(widget)
  self.dragAreaWidget = widget
  self:SetupDragArea()
end

function NRCDraggablePanel:SetupDragArea()
end

function NRCDraggablePanel:ConstrainToViewport(position)
  local viewportSize = self.cachedViewportSize
  local panelSize = self.cachedPanelSize
  local clampedPosition = UE4.FVector2D(position.X, position.Y)
  if clampedPosition.X < 0 then
    clampedPosition.X = 0
  elseif clampedPosition.X + panelSize.X > viewportSize.X then
    clampedPosition.X = viewportSize.X - panelSize.X
  end
  if clampedPosition.Y < 0 then
    clampedPosition.Y = 0
  elseif clampedPosition.Y + panelSize.Y > viewportSize.Y then
    clampedPosition.Y = viewportSize.Y - panelSize.Y
  end
  return clampedPosition
end

function NRCDraggablePanel:OnMouseButtonDown(MyGeometry, MouseEvent)
  if not self.enableDrag then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  local mousePosition = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  if self.dragAreaWidget then
    local dragAreaGeometry = self.dragAreaWidget:GetCachedGeometry()
    if not UE4.USlateBlueprintLibrary.IsUnderLocation(dragAreaGeometry, mousePosition) then
      return UE4.UWidgetBlueprintLibrary.Unhandled()
    end
  end
  local mouseViewportPosition = UE4.UWidgetLayoutLibrary.GetMousePositionOnViewport(UE4Helper.GetCurrentWorld())
  local widgetViewportPosition = UE4.UNRCStatics.GetWidgetViewportPosition(self)
  self.dragOffset = mouseViewportPosition - widgetViewportPosition
  self.cachedViewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
  self.cachedPanelSize = self:GetDesiredSize()
  self.isDragging = true
  self.lastMousePosition = mousePosition
  self:OnDragBegin(widgetViewportPosition)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function NRCDraggablePanel:OnMouseMove(MyGeometry, MouseEvent)
  if not self.isDragging then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  local mousePosition = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  local offsetMousePosition = mousePosition - self.lastMousePosition
  if math.abs(offsetMousePosition.X) < self.dragThreshold and math.abs(offsetMousePosition.Y) < self.dragThreshold then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  self.lastMousePosition = mousePosition
  local mouseViewportPosition = UE4.UWidgetLayoutLibrary.GetMousePositionOnViewport(UE4Helper.GetCurrentWorld())
  local targetViewportPosition = mouseViewportPosition - self.dragOffset
  if self.isConstrainToViewport then
    targetViewportPosition = self:ConstrainToViewport(targetViewportPosition)
  end
  self:SetPositionInViewport(targetViewportPosition, false)
  self:OnDraging(targetViewportPosition)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function NRCDraggablePanel:OnMouseButtonUp(MyGeometry, MouseEvent)
  if not self.isDragging then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  self.isDragging = false
  self.cachedViewportSize = nil
  self.cachedPanelSize = nil
  local widgetViewportPosition = UE4.UNRCStatics.GetWidgetViewportPosition(self)
  self:OnDragEnd(widgetViewportPosition)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function NRCDraggablePanel:OnDragBegin(ViewportPosition)
end

function NRCDraggablePanel:OnDraging(ViewportPosition)
end

function NRCDraggablePanel:OnDragEnd(ViewportPosition)
end

return NRCDraggablePanel
