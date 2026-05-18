local MapItemBase = require("NewRoco.Modules.System.BigMap.Res.MapItemBase")
local BigMapModuleEnum = require("NewRoco.Modules.System.BigMap.BigMapModuleEnum")
local BigMapUtils = require("NewRoco/Modules/System/BigMap/BigMapUtils")
local MapItemNPC = MapItemBase:Extend("MapItemNPC")
MapItemNPC.ItemData = {}

function MapItemNPC:Ctor(parentView, layerList, iconTemplateList)
  MapItemBase.Ctor(self, parentView, layerList, iconTemplateList)
  self.iconList = {}
  self.iconPool = {}
  self.itemData = {}
  self.templateList = {}
  self.iconPoolRef = {}
  self.allEntryIdList = {}
end

function MapItemNPC:Create(itemData)
  local entryId = itemData.npcInfo.entry_id
  if nil == entryId or 0 == entryId then
    Log.Error("MapItemNPC:Create, entryId is nil or 0")
    return
  end
  local templateIndex = self:GetIconTemplate(itemData)
  local iconData = itemData.iconData
  iconData.iconTemplateIndex = templateIndex
  if nil == iconData.layerIndex or iconData.layerIndex <= 0 then
    iconData.layerIndex = BigMapUtils.GetNpcIconLayer(itemData.npcInfo)
  end
  iconData.ZOrder = self:GetZOrder(itemData.npcInfo.world_map_cfg_id)
  itemData.iconData = iconData
  if nil == self.iconList then
    self.iconList = {}
  end
  if self.iconList[entryId] then
    if (self.itemData and self.itemData[entryId] and self.itemData[entryId].iconData.layerIndex) ~= (itemData and itemData.iconData and itemData.iconData.layerIndex) then
      self:Recycle(entryId)
      local renderScale = 1.0 / (iconData.curMapImageScale or 1)
      local Widget = self:GetItemFromPool(templateIndex)
      MapItemBase.WidgetAddToViewPort(self, Widget, iconData, renderScale)
      Widget:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.iconList[entryId] = Widget
    end
    self:Refresh(itemData)
  else
    self.iconList[entryId] = {}
    local renderScale = 1.0 / (iconData.curMapImageScale or 1)
    local Widget = self:GetItemFromPool(templateIndex)
    if nil == Widget or not UE4.UObject.IsValid(Widget) then
      Widget = MapItemBase.CreateWidget(self, iconData, renderScale)
    else
      MapItemBase.WidgetAddToViewPort(self, Widget, iconData, renderScale)
      Widget:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.iconList[entryId] = Widget
    self:Refresh(itemData)
  end
  self.templateList[entryId] = templateIndex
end

function MapItemNPC:Refresh(itemData)
  local entryId = itemData.npcInfo.entry_id
  if nil == entryId or 0 == entryId then
    Log.Error("MapItemNPC:Create, entryId is nil or 0")
    return
  end
  if nil == self.iconList then
    Log.Error("MapItemNPC:Refresh, iconList is nil")
    return
  end
  if self.iconList[entryId] then
    local iconData = itemData.iconData
    local _npcInfo = itemData.npcInfo
    iconData.ZOrder = self:GetZOrder(_npcInfo.world_map_cfg_id)
    local itemWidget = self.iconList[entryId]
    local worldMapConf = _G.DataConfigManager:GetWorldMapConf(_npcInfo.world_map_cfg_id)
    if itemWidget and UE4.UObject.IsValid(itemWidget) then
      self.itemData[entryId] = itemData
      itemWidget:SetData(_npcInfo, worldMapConf)
      itemWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if iconData.bTracing and iconData.bTracing == true then
        itemWidget:PlayTraceEffect(true)
      else
        itemWidget:PlayTraceEffect(false)
      end
      itemWidget:UpdateMapShowLevel(iconData.curMapSliderScale)
      itemWidget:SetShowTime(_npcInfo)
      itemWidget:SetMapLayerIconVisible(BigMapModuleEnum.CreatorPriority.NpcIcons)
      itemWidget:SetPetOwnerVisible()
      if itemWidget.mapLayerId == iconData.curShowLayerId then
        itemWidget:SetLayerMapIcon(true)
      else
        itemWidget:SetLayerMapIcon(false)
      end
      if self.bTravel and self.travelInfo and #self.travelInfo > 0 then
        itemWidget:ShowTravel(_npcInfo)
      else
        itemWidget:ShowTravel(nil)
      end
      if _npcInfo.npcCfg and _npcInfo.npcCfg.genre == _G.Enum.ClientNpcType.CNT_HOME_NPC then
        itemWidget.Slot:SetPosition(UE4.FVector2D(itemData.iconData.iconImagePos.x, itemData.iconData.iconImagePos.y))
      end
    end
  end
end

function MapItemNPC:GetIconLayer(_npcInfo)
  if nil == _npcInfo then
    Log.Error("MapItemNPC:GetIconLayer, npcInfo is nil")
    return nil
  end
  local layerIndex = 1
  local worldMapCfg = _G.DataConfigManager:GetWorldMapConf(_npcInfo.world_map_cfg_id)
  if nil == worldMapCfg then
    return nil
  end
  if _npcInfo.status == _G.ProtoEnum.LockStatus.ENUM.LOCKED then
    if 1 == worldMapCfg.lock_element_show_top then
      layerIndex = 2
    end
  else
    if 1 == worldMapCfg.unlock_element_show_top then
      layerIndex = 2
    end
    if _npcInfo.status == _G.ProtoEnum.LockStatus.ENUM.DUNGEON_FINISH then
      layerIndex = 2
    end
  end
  if _npcInfo.npcCfg and _npcInfo.npcCfg.genre == Enum.ClientNpcType.CNT_CAMP then
    layerIndex = 2
  end
  return layerIndex
end

function MapItemNPC:GetIconTemplate(itemData)
  if itemData.npcInfo == nil then
    Log.Error("MapItemNPC:GetIconTemplate, npcInfo is nil")
    return nil
  end
  local _npcInfo = itemData.npcInfo
  local iconTemplateIndex = 1
  local worldMapCfg = _G.DataConfigManager:GetWorldMapConf(_npcInfo.world_map_cfg_id)
  if _npcInfo.npcCfg then
    if _npcInfo.npcCfg.genre == Enum.ClientNpcType.CNT_PETBOSS or _npcInfo.npcCfg.genre == Enum.ClientNpcType.CNT_LEGENDARY_SPIRIT then
      if worldMapCfg and worldMapCfg.map_show_type == Enum.MapIconShowType.MAP_HANDBOOK_TRACK then
        iconTemplateIndex = 3
      else
        iconTemplateIndex = 1
      end
    elseif _npcInfo.npcCfg.genre == Enum.ClientNpcType.CNT_CAMP or _npcInfo.npcCfg.genre == Enum.ClientNpcType.CNT_TELEPORT or _npcInfo.npcCfg.genre == Enum.ClientNpcType.CNT_FLOWER_SEED or worldMapCfg.map_tips_show_type == Enum.MapTipsShowType.MAP_TIPS_OWL_SANCTUARY or worldMapCfg.map_show_type == Enum.MapIconShowType.MAP_ACTIVITY_AREA then
      iconTemplateIndex = 2
    elseif _npcInfo.npcCfg.genre == Enum.ClientNpcType.CNT_HOME_NPC then
      iconTemplateIndex = 1
    else
      local isShowCathPet = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.IsShowCatchPet, _npcInfo.npc_refresh_id)
      if worldMapCfg.map_func_icon_group and worldMapCfg.map_func_icon_group == _G.Enum.MapFuncIconGroup.MFIG_NPCFUNCTION or isShowCathPet then
        iconTemplateIndex = 2
      elseif worldMapCfg.map_tips_show_type and worldMapCfg.map_tips_show_type == _G.ProtoEnum.MapTipsShowType.MAP_TIPS_DUNGEON then
        iconTemplateIndex = 2
      else
        iconTemplateIndex = 3
      end
    end
  end
  return iconTemplateIndex
end

function MapItemNPC:GetZOrder(worldMapCfgId)
  local worldMapCfg = _G.DataConfigManager:GetWorldMapConf(worldMapCfgId)
  if worldMapCfg then
    if worldMapCfg.map_tips_show_type == Enum.MapTipsShowType.MAP_TIPS_CAMP then
      return -1
    elseif worldMapCfg.icon_priority then
      return worldMapCfg.icon_priority
    else
      return 0
    end
  end
  return 0
end

function MapItemNPC:Get(entryId)
  return self.iconList[entryId]
end

function MapItemNPC:GetItemData(entryId)
  return self.itemData[entryId]
end

function MapItemNPC:GetAllEntryId()
  table.clear(self.allEntryIdList)
  for k, v in pairs(self.iconList) do
    table.insert(self.allEntryIdList, k)
  end
  return self.allEntryIdList
end

function MapItemNPC:Destroy(entryId)
  local itemWidget = self.iconList[entryId]
  if itemWidget and UE4.UObject.IsValid(itemWidget) then
    itemWidget:RemoveFromParent()
    itemWidget:Destruct()
    table.removeKey(self.iconList, entryId)
  end
end

function MapItemNPC:Recycle(entryId)
  local iconWidget = self.iconList[entryId]
  if iconWidget and UE4.UObject.IsValid(iconWidget) then
    iconWidget:RemoveFromParent()
    table.removeKey(self.iconList, entryId)
    local templateIndex = self.templateList[entryId]
    if templateIndex and templateIndex > 0 then
      if self.iconPool[templateIndex] == nil then
        self.iconPool[templateIndex] = {}
      end
      if nil == self.iconPoolRef[templateIndex] then
        self.iconPoolRef[templateIndex] = {}
      end
      table.insert(self.iconPool[templateIndex], iconWidget)
      table.insert(self.iconPoolRef[templateIndex], UnLua.Ref(iconWidget))
    end
  end
end

function MapItemNPC:GetItemFromPool(templateIndex)
  if self.iconPool[templateIndex] and #self.iconPool[templateIndex] > 0 then
    if self.iconPoolRef[templateIndex] and #self.iconPoolRef[templateIndex] > 0 then
      table.remove(self.iconPoolRef[templateIndex], 1)
    end
    return table.remove(self.iconPool[templateIndex], 1)
  end
  return nil
end

function MapItemNPC:OnTravelStateChanged(bTravel)
  MapItemBase.OnTravelStateChanged(self, bTravel)
  for k, v in pairs(self.iconList) do
    if v and UE.UObject.IsValid(v) then
      local worldMapCfg
      if bTravel then
        if v.uiData and v.uiData.world_map_cfg_id then
          worldMapCfg = _G.DataConfigManager:GetWorldMapConf(v.uiData.world_map_cfg_id)
        end
        if worldMapCfg and worldMapCfg.map_tips_show_type ~= Enum.MapTipsShowType.MAP_TIPS_CAMP then
          self:SetItemVisibility(false, BigMapModuleEnum.CreatorPriority.NpcIcons, k)
        else
          v:ShowTravel(v.uiData)
          if nil == _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetTravelInfo, v.uiData.npc_refresh_id) and UE4.UObject.IsValid(v.Travel_DuringJourney) then
            v.Travel_DuringJourney:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
        end
      else
        self:SetItemVisibility(true, BigMapModuleEnum.CreatorPriority.NpcIcons, k)
        if UE4.UObject.IsValid(v.Travel_DuringJourney) then
          v.Travel_DuringJourney:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
  end
end

function MapItemNPC:UpdateIconScale(_scaleParam)
  for k, v in pairs(self.iconList) do
    if v and UE4.UObject.IsValid(v) then
      v:SetRenderScale(_scaleParam)
    end
  end
end

function MapItemNPC:UpdateIconScaleByEntryId(entryId, _scaleParam)
  local icon = self:Get(entryId)
  if icon and UE4.UObject.IsValid(icon) then
    icon:SetRenderScale(_scaleParam)
  end
end

function MapItemNPC:UpdateMapShowLevel(_sliderScale, _scale, _scaleRatio)
  if self.iconList then
    for k, v in pairs(self.iconList) do
      if self.bTravel then
        if v.uiData and v.uiData.world_map_cfg_id then
          local worldMapCfg = _G.DataConfigManager:GetWorldMapConf(v.uiData.world_map_cfg_id)
          if worldMapCfg and worldMapCfg.map_tips_show_type == Enum.MapTipsShowType.MAP_TIPS_CAMP and v and v.UpdateMapShowLevel then
            v:UpdateMapShowLevel(_sliderScale, _scale, _scaleRatio)
          end
        end
      elseif v and v.UpdateMapShowLevel then
        v:UpdateMapShowLevel(_sliderScale, _scale, _scaleRatio)
      end
    end
  end
end

function MapItemNPC:SetTraceEffect(bTracing, entryId)
  if self.iconList then
    local widget = self.iconList[entryId]
    if widget and UE4.UObject.IsValid(widget) then
      widget:PlayTraceEffect(bTracing)
    end
  end
end

function MapItemNPC:SetIconLayer(entryId, layerIndex)
  self:Recycle(entryId)
  local itemData = self.itemData[entryId]
  if itemData then
    itemData.iconData.layerIndex = layerIndex
    self:Create(self.itemData[entryId])
  end
end

return MapItemNPC
