local UMG_DebugGrid_C = _G.NRCViewBase:Extend("UMG_DebugGrid_C")

function UMG_DebugGrid_C:OnActive()
  self.ShouldDrawGrid = false
end

function UMG_DebugGrid_C:ToggleGrid()
  if not self.ShouldDrawGrid then
    self.ShouldDrawGrid = true
  end
end

function UMG_DebugGrid_C:OnPaint(Context)
  if not self.ShouldDrawGrid then
    return
  end
  local MIN = 0
  local MAX = 6128
  local redColor = UE.FLinearColor(1.0, 0.0, 0.0, 1.0)
  for i = 0, 7 do
    UE.UWidgetBlueprintLibrary.DrawText(Context, "-Y10", UE4.FVector2D(403, 1149), redColor)
    UE.UWidgetBlueprintLibrary.DrawText(Context, "-Y10", UE4.FVector2D(1169, 1149), redColor)
    local Points = {}
    table.insert(Points, UE4.FVector2D(2 * i * 383, MIN))
    table.insert(Points, UE4.FVector2D(2 * i * 383, MAX))
    UE.UWidgetBlueprintLibrary.DrawLines(Context, Points, redColor, false, 1.0)
    Points = nil
    UE.UWidgetBlueprintLibrary.DrawText(Context, "-Y9", UE4.FVector2D(796 + (2 * i - 1) * 383, 383), redColor)
    local TempY = "-Y"
    TempY = TempY .. tostring(i + 10)
    UE.UWidgetBlueprintLibrary.DrawText(Context, TempY, UE4.FVector2D(403, 1532 + (2 * i - 1) * 383), redColor)
    local index = 10
    for j = 10, 26, 2 do
      local LocationText = "-Y" .. tostring(index)
      index = index + 1
      UE.UWidgetBlueprintLibrary.DrawText(Context, LocationText, UE4.FVector2D(1562 + (2 * i - 1) * 383, (j - 9) * 383 + 766), redColor)
    end
  end
  for i = 0, 7 do
    local Points = {}
    table.insert(Points, UE4.FVector2D(MIN, 2 * i * 383 - 20))
    table.insert(Points, UE4.FVector2D(MAX, 2 * i * 383 - 20))
    UE.UWidgetBlueprintLibrary.DrawLines(Context, Points, redColor, false, 1.0)
    Points = nil
    UE.UWidgetBlueprintLibrary.DrawText(Context, "X7", UE4.FVector2D(383, 1532 + (2 * i - 1) * 383), redColor)
    local TempX = "X"
    TempX = TempX .. tostring(i + 7)
    UE.UWidgetBlueprintLibrary.DrawText(Context, TempX, UE4.FVector2D((2 * i - 1) * 383 + 766, 383), redColor)
    local index = 8
    for j = 8, 20, 2 do
      local LocationText = "X" .. tostring(index)
      index = index + 1
      UE.UWidgetBlueprintLibrary.DrawText(Context, LocationText, UE4.FVector2D(766 + (j - 7) * 383, 1532 + (2 * i - 1) * 383), redColor)
    end
  end
end

return UMG_DebugGrid_C
