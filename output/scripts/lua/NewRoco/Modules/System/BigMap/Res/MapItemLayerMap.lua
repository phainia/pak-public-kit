local MapItemBase = require("NewRoco.Modules.System.BigMap.Res.MapItemBase")
local BigMapUtils = require("NewRoco/Modules/System/BigMap/BigMapUtils")
local MapItemLayerMap = MapItemBase:Extend("MapItemLayerMap")
MapItemLayerMap.ItemData = {}

function MapItemLayerMap:Ctor(parentView, layerList, templateList)
  MapItemBase.Ctor(self, parentView, layerList, templateList)
  self.iconList = {}
end

function MapItemLayerMap:Create(itemData)
  self:Refresh(itemData)
end

function MapItemLayerMap:Refresh(itemData)
  local iconData = itemData.iconData
  local imageData = itemData.imageInfo
  local imageWidget
  if self.iconList[imageData.layerMapId] then
    imageWidget = self.iconList[imageData.layerMapId]
  else
    self.iconList[imageData.layerMapId] = {}
    imageWidget = MapItemBase.CreateImageWidget(self, iconData, imageData)
    self.iconList[imageData.layerMapId] = imageWidget
  end
  if imageWidget then
    imageWidget:SetLayerMapImage(imageData.imagePath)
  end
end

function MapItemLayerMap:Get(layerId)
  return self.iconList[layerId]
end

function MapItemLayerMap:Destroy(layerId)
  local itemWidget = self.iconList[layerId]
  if itemWidget then
    itemWidget:RemoveFromParent()
    itemWidget:Destruct()
    table.removeKey(self.iconList, layerId)
  end
end

function MapItemLayerMap:SetLayerMapVisible(bVisible, layerId)
  if bVisible then
    self:SetAllLayerMapVisible(not bVisible)
    local layerMapConf = _G.DataConfigManager:GetLayeredWorldMapConf(layerId)
    local layerIds
    if layerMapConf then
      do
        local groupId = layerMapConf.map_layer_group
        if groupId > 0 then
          local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
          if bigMapModule then
            layerIds = bigMapModule.data.LayerGroupIdToLayerMapIds[groupId]
          end
        end
      end
    end
    for k, v in pairs(layerIds) do
      if v.area_func_id > 0 then
        local layerMapWidget = self.iconList[v.id]
        if layerMapWidget and UE4.UObject.IsValid(layerMapWidget) then
          layerMapWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  else
    local layerMapWidget = self.iconList[layerId]
    if layerMapWidget and UE4.UObject.IsValid(layerMapWidget) then
      layerMapWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self:SetAllLayerMapVisible(bVisible)
  end
end

function MapItemLayerMap:SetAllLayerMapVisible(bVisible)
  for k, v in pairs(self.iconList) do
    if bVisible then
      v:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      v:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function MapItemLayerMap:SetTopLayer(layerId)
  if self.iconList[layerId] and UE4.UObject.IsValid(self.iconList[layerId]) then
    self.iconList[layerId].Slot:SetZOrder(100)
    self.iconList[layerId]:SetMapOpacity(1)
  end
  local layerMapConf = _G.DataConfigManager:GetLayeredWorldMapConf(layerId)
  local layerIds
  if layerMapConf then
    local groupId = layerMapConf.map_layer_group
    if groupId > 0 then
      local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
      if bigMapModule then
        layerIds = bigMapModule.data.LayerGroupIdToLayerMapIds[groupId]
      end
    end
  end
  if layerIds then
    for k, v in pairs(layerIds) do
      local _id = v.id
      if _id > 0 and v.area_func_id > 0 and _id ~= layerId and self.iconList[_id] and UE4.UObject.IsValid(self.iconList[_id]) then
        self.iconList[_id].Slot:SetZOrder(10)
        self.iconList[_id]:SetMapOpacity(0.5)
      end
    end
  end
end

return MapItemLayerMap
