local MapItemBase = require("NewRoco.Modules.System.BigMap.Res.MapItemBase")
local MapItemAreaName = MapItemBase:Extend("MapItemAreaName")
MapItemAreaName.ItemData = {}

function MapItemAreaName:Ctor(parentView, layerList, iconTemplateList)
  MapItemBase.Ctor(self, parentView, layerList, iconTemplateList)
  self.iconList = {}
  self.treasureIconList = {}
end

function MapItemAreaName:Create(itemData)
  self:Refresh(itemData)
end

function MapItemAreaName:Refresh(itemData)
  local areaId = itemData.areaInfo.config.name_area_id
  local iconWidget
  local iconData = itemData.iconData
  local renderScale = 1.0 / (itemData.iconData.curMapImageScale or 1)
  if self.iconList[areaId] then
    iconWidget = self.iconList[areaId]
  else
    self.iconList[areaId] = {}
    if itemData.areaInfo.bActivity then
      iconWidget = MapItemBase.CreateWidget(self, itemData.iconData, renderScale)
    else
      iconWidget = MapItemBase.CreateWidget(self, itemData.iconData)
    end
    self.iconList[areaId] = iconWidget
    if iconWidget and iconWidget.SetMapAreaData then
      table.insert(self.treasureIconList, areaId)
    end
  end
  if iconWidget then
    if iconWidget.RefreshGatherInfo then
      iconWidget:SetData(itemData.areaInfo)
      iconWidget:UpdateMapShowLevel(iconData.curMapSliderScale, iconData.scale, iconData.curMapSliderScale)
      iconWidget:RefreshGatherInfo()
      iconWidget.Slot:SetZOrder(-1)
    elseif iconWidget.SetMapAreaData then
      local worldMapConf = itemData.areaInfo.config
      if worldMapConf then
        iconWidget:SetMapAreaData({}, worldMapConf)
        iconWidget:UpdateMapShowLevel(iconData.curMapSliderScale)
        if worldMapConf.icon_priority then
          iconWidget.Slot:SetZOrder(worldMapConf.icon_priority)
        else
          iconWidget.Slot:SetZOrder(0)
        end
        local scale = 1.0 / iconData.curMapImageScale
        local scaleParam = UE4.FVector2D(scale, scale)
        self:UpdateIconScale(scaleParam)
      end
    end
  end
end

function MapItemAreaName:ClearTreasureIcon(iconList)
  local removeList = {}
  local removeIndexList = {}
  for i, areaID in pairs(self.treasureIconList or {}) do
    local isShow = false
    for _, _areaID in pairs(iconList or {}) do
      if areaID == _areaID then
        isShow = true
        break
      end
    end
    if not isShow then
      table.insert(removeList, areaID)
      table.insert(removeIndexList, i)
    end
  end
  for _, areaID in pairs(removeList or {}) do
    self:Destroy(areaID)
  end
  table.sort(removeIndexList, function(a, b)
    return b < a
  end)
  for _, index in pairs(removeIndexList or {}) do
    table.remove(self.treasureIconList, index)
  end
end

function MapItemAreaName:Get(areaId)
  return self.iconList[areaId]
end

function MapItemAreaName:Destroy(areaId)
  local itemWidget = self.iconList[areaId]
  if itemWidget and UE4.UObject.IsValid(itemWidget) then
    itemWidget:RemoveFromParent()
    itemWidget:Destruct()
    table.removeKey(self.iconList, areaId)
  end
end

function MapItemAreaName:UpdateIconScale(_scaleParam)
  for k, v in pairs(self.iconList) do
    if v and UE4.UObject.IsValid(v) and v.SetMapAreaData then
      v:SetRenderScale(_scaleParam)
      local npcFunctionIcon = v
      if npcFunctionIcon.Scope and npcFunctionIcon.Scope:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
        local standardScale = UE4.FVector2D(1 / (_scaleParam.X * 3.2), 1 / (_scaleParam.Y * 3.2))
        if v.IconRadius then
          local ModifiedScale = UE4.FVector2D(v.IconRadius / 10000 * standardScale.X, v.IconRadius / 10000 * standardScale.Y)
          npcFunctionIcon.Scope:SetRenderScale(ModifiedScale)
        else
          npcFunctionIcon.Scope:SetRenderScale(standardScale)
        end
      end
    end
  end
end

function MapItemAreaName:RefreshAllAreaGatherInfo()
  for k, v in pairs(self.iconList) do
    if v and UE4.UObject.IsValid(v) and v.RefreshGatherInfo then
      v:RefreshGatherInfo()
    end
  end
end

function MapItemAreaName:RefreshAreaGatherInfo(areaId)
  local itemWidget = self.iconList[areaId]
  if itemWidget and UE4.UObject.IsValid(itemWidget) and itemWidget.RefreshGatherInfo then
    itemWidget:RefreshGatherInfo()
  end
end

return MapItemAreaName
