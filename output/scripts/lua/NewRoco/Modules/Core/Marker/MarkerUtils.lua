local MarkerUtils = {}

function MarkerUtils.GetPoiIcon(POIClass)
  if 1 == POIClass or 4 == POIClass then
    return "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/Lobby/Frames/img_icon_jiemi_1_png.img_icon_jiemi_1_png'"
  elseif 2 == POIClass then
    return "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/Lobby/Frames/img_icon_jiemi_0_png.img_icon_jiemi_0_png'"
  else
    return ""
  end
end

function MarkerUtils.SetupPoiIcon(POIClass, icon)
  if not icon then
    return
  end
  if not POIClass then
    icon:SetVisibility(UE4.ESlateVisibility.Hidden)
    return
  end
  local Path = MarkerUtils.GetPoiIcon(POIClass)
  if string.IsNilOrEmpty(Path) then
    icon:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    icon:SetVisibility(UE4.ESlateVisibility.Visible)
    icon:SetPath(Path)
  end
end

return MarkerUtils
