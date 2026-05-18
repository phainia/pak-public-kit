local MapItemBase = require("NewRoco.Modules.System.BigMap.Res.MapItemBase")
local MapItemCircle = MapItemBase:Extend("MapItemCircle")

function MapItemCircle:Ctor(parentView, layerList, iconTemplateList)
  MapItemBase.Ctor(self, parentView, layerList, iconTemplateList)
  self.iconList = {}
  self.itemDataList = {}
end

function MapItemCircle:Create(iconData, circleInfo)
  local showType = circleInfo.showType
  local typeId = circleInfo.typeId
  local extraId = circleInfo.extraId or typeId
  if self.iconList == nil then
    self.iconList = {}
  end
  if self.iconList[showType] == nil then
    self.iconList[showType] = {}
  end
  if self.iconList[showType][typeId] == nil then
    self.iconList[showType][typeId] = {}
  end
  if nil == self.itemDataList[showType] then
    self.itemDataList[showType] = {}
  end
  if nil == self.itemDataList[showType][typeId] then
    self.itemDataList[showType][typeId] = {}
  end
  if nil == self.itemDataList[showType][typeId][extraId] then
    self.itemDataList[showType][typeId][extraId] = iconData
  end
  local circleWidget = self.iconList[showType][typeId][extraId]
  if nil == circleWidget then
    local renderScale = 1.0
    circleWidget = MapItemBase.CreateWidget(self, iconData, renderScale)
    self.iconList[showType][typeId][extraId] = circleWidget
    self:Refresh(iconData, circleInfo)
  else
    self:Refresh(iconData, circleInfo)
  end
end

function MapItemCircle:Refresh(iconData, circleInfo)
  local showType = circleInfo.showType
  local typeId = circleInfo.typeId
  local extraId = circleInfo.extraId or typeId
  if self.iconList[showType] and self.iconList[showType][typeId] then
    local circleWidget = self.iconList[showType][typeId][extraId]
    if circleWidget and UE4.UObject.IsValid(circleWidget) then
      circleWidget:SetData(circleInfo)
      circleWidget:SetCircleRadius(circleInfo.circleRadius / 100, iconData.curMapImageScale)
      circleWidget:UpdateMapShowLevel(iconData.curMapSliderScale)
    end
  end
  if self.itemDataList[showType] and self.itemDataList[showType][typeId] then
    self.itemDataList[showType][typeId][extraId] = iconData
  end
end

function MapItemCircle:RefreshIconPos(pos, showType, typeId, extraId)
  if self.itemDataList[showType] and self.itemDataList[showType][typeId] and self.itemDataList[showType][typeId][extraId] then
    self.itemDataList[showType][typeId][extraId].iconImagePos = pos
  end
end

function MapItemCircle:Get(type, key, extraKey)
  if self.iconList[type] and self.iconList[type][key] then
    return self.iconList[type][key][extraKey]
  end
end

function MapItemCircle:GetData(type, key, extraKey)
  if self.itemDataList[type] and self.itemDataList[type][key] then
    return self.itemDataList[type][key][extraKey]
  end
end

function MapItemCircle:Destroy(type, key, extraKey)
  if self.iconList[type] and self.iconList[type][key] then
    local itemWidget = self.iconList[type][key][extraKey]
    if itemWidget and UE4.UObject.IsValid(itemWidget) then
      itemWidget:RemoveFromParent()
      itemWidget:Destruct()
      table.removeKey(self.iconList[type][key], extraKey)
      if table.isEmpty(self.iconList[type][key]) then
        table.removeKey(self.iconList[type], key)
      end
    end
  end
end

function MapItemCircle:ClearAll()
  if self.iconList then
    for type, iconList in pairs(self.iconList) do
      if iconList then
        for key, icons in pairs(iconList) do
          if icons then
            for extraKey, icon in pairs(icons) do
              if icon and UE4.UObject.IsValid(icon) then
                self:Destroy(type, key, extraKey)
              end
            end
          end
        end
      end
    end
  end
end

function MapItemCircle:UpdateIconScale(_scaleParam)
  for type, icons in pairs(self.iconList) do
    if icons then
      for key, icon in pairs(icons) do
        if not icon or UE4.UObject.IsValid(icon) then
        end
      end
    end
  end
end

function MapItemCircle:UpdateMapShowLevel(_sliderScale, _scale, _scaleRatio)
  for type, iconList in pairs(self.iconList) do
    if iconList then
      for key, icons in pairs(iconList) do
        if icons then
          for extraKey, icon in pairs(icons) do
            if icon and UE4.UObject.IsValid(icon) then
              icon:UpdateMapShowLevel(_sliderScale, _scale, _scaleRatio)
            end
          end
        end
      end
    end
  end
end

return MapItemCircle
