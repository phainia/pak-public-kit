local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local UMG_MinimapMain_C = _G.NRCPanelBase:Extend("UMG_MinimapMain_C")

function UMG_MinimapMain_C:OnConstruct()
  local sceneOffsetX = 254650.0
  local sceneOffsetY = 510000.0
  local sceneWidth = 307000.0
  local imageWidth = 4096
  local imageHeight = 4096
  local imageToScreenScale = imageWidth / sceneWidth
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  local bigMapNpcInfos = bigMapModule.data:GetNpcDatas()
  local bigMapNpcToAreaData = bigMapModule.data:GetNpcToAreaDatas()
  local iconScale = _G.DataConfigManager:GetGlobalConfigNumByKeyType("minimap_icon_percentage", _G.DataConfigManager.ConfigTableId.MAP_GLOBAL_CONFIG, 100) / 100
  local traceNpcCfgId = self:GetTraceNpcId()
  self.RealTime = self:GetRealTime()
  self.uiData = {
    sceneOffsetX = sceneOffsetX,
    sceneOffsetY = sceneOffsetY,
    imageToScreenScale = imageToScreenScale,
    sectorTexture = "Texture2D'/Game/ArtRes/Effects/Texture/Mask/Mask_BJ_011.Mask_BJ_011'",
    playerData = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER),
    npcInfos = bigMapNpcInfos,
    npcToAreasInfo = bigMapNpcToAreaData,
    playerPos = nil,
    playerImagePos = nil,
    iconScale = iconScale,
    traceNpcCfgId = traceNpcCfgId
  }
  self.curTickTime = 0.0
  self.maxTickTime = _G.DataConfigManager:GetWorldGlobalConfigByKey("world_map_info_sync_tick_interval").num or 15
  self.fogBlocks = {
    self.Fog1,
    self.Fog2,
    self.Fog3,
    self.Fog4,
    self.Fog5,
    self.Fog6,
    self.Fog7
  }
  self.uiItem = {
    taskIcons = {
      self.TaskIcon1,
      self.TaskIcon2,
      self.TaskIcon3,
      self.TaskIcon4,
      self.TaskIcon5
    },
    npcIcons = {},
    fogBlocks = self.fogBlocks
  }
  self:GetPlayerImagePos()
  self:OnShowStaticNpcIcon(self.uiData.npcInfos)
  if self:GetUnlockPortNum(self.uiData.npcInfos) > 0 then
    self:InitFogInfo()
    self:SetMinimapTransparent(false)
  else
    self:SetMinimapTransparent(true)
  end
end

function UMG_MinimapMain_C:OnDestruct()
end

function UMG_MinimapMain_C:OnActive()
end

function UMG_MinimapMain_C:OnDeactive()
end

function UMG_MinimapMain_C:GetNpcInfos()
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  local bigMapNpcInfos = bigMapModule.data:GetNpcDatas()
  self.uiData.npcInfos = bigMapNpcInfos
  return bigMapNpcInfos
end

function UMG_MinimapMain_C:SetCenterPos(posX, poxY)
end

function UMG_MinimapMain_C:OnShowStaticNpcIcon(npcInfos)
  if not npcInfos then
    return
  end
  for npcId, npcInfo in pairs(npcInfos) do
    local posX, posY = self:ScenePosToImagePos(npcInfo.npc_pos.x, npcInfo.npc_pos.y)
    self:CreateNpcIcon(npcId, posX, posY, npcInfo)
  end
end

function UMG_MinimapMain_C:CreateTaskIcon(posX, posY)
  local icon = self:CreateIconWidget(self.iconLayer2, self.iconTaskTemplate, posX, posY)
  icon:PlayTraceEffect(true)
  table.insert(self.uiItem.taskIcons, icon)
end

function UMG_MinimapMain_C:CreateIconWidget(iconLayer, iconTemplate, posX, posY)
  local iconWidget = UE4.UWidgetBlueprintLibrary.Create(self, iconTemplate)
  local iconScale = _G.DataConfigManager:GetGlobalConfigNumByKeyType("minimap_icon_percentage", _G.DataConfigManager.ConfigTableId.MAP_GLOBAL_CONFIG, 100) / 100
  iconWidget:SetRenderScale(UE4.FVector2D(iconScale, iconScale))
  if iconWidget then
    local iconSlot = iconLayer:AddChild(iconWidget)
    iconSlot:SetPosition(UE4.FVector2D(posX, posY))
    iconSlot:SetAnchors(UE4.FAnchors(0.5))
    iconSlot:SetAlignment(UE4.FVector2D(0.5, 0.5))
    iconSlot:SetAutoSize(true)
    return iconWidget
  end
end

function UMG_MinimapMain_C:CreateNpcIcon(npcId, posX, posY, npcInfo)
  if npcInfo then
    local iconLayer = self.iconLayer1
    local npcType = npcInfo.npcCfg.genre
    if npcType == _G.Enum.ClientNpcType.CNT_UNLOCKPORT then
      iconLayer = self.iconLayer2
    end
    local icon
    if self.uiItem.npcIcons[npcInfo.npc_refresh_id] == nil then
      icon = self:CreateIconWidget(iconLayer, self.iconNpcTemplate, -posX, -posY)
      icon:SetData(npcInfo)
      self.uiItem.npcIcons[npcInfo.npc_refresh_id] = icon
    else
      icon = self.uiItem.npcIcons[npcInfo.npc_refresh_id]
      icon:SetData(npcInfo)
    end
  end
end

function UMG_MinimapMain_C:PlayNpcTraceEffect(npcId, isplay)
  if npcId then
    local npcIcon = self.uiItem.npcIcons[npcId]
    if npcIcon then
      npcIcon:PlayTraceEffect(isplay)
      self:UpdateNpcTraceIcon(npcId, npcIcon, isplay)
    end
  end
end

function UMG_MinimapMain_C:ScenePosToImagePos(scenePosX, scenePosY)
  local x = -(scenePosX - self.uiData.sceneOffsetX) * self.uiData.imageToScreenScale
  local y = -(scenePosY - self.uiData.sceneOffsetY) * self.uiData.imageToScreenScale
  return math.ceil(x), math.ceil(y)
end

function UMG_MinimapMain_C:GetPlayerImagePos()
  if self.uiData.playerData == nil then
    return
  end
  local playerPos = self.uiData.playerData:GetActorLocation()
  local playerImagePosX, playerImagePosY = self:ScenePosToImagePos(playerPos.X, playerPos.Y)
  self.uiData.playerPos = playerPos
  self.uiData.playerImagePos = UE4.FVector2D(playerImagePosX, playerImagePosY)
end

function UMG_MinimapMain_C:Tick(MyGeometry, InDeltaTime)
  self.curTickTime = self.curTickTime + InDeltaTime
  if self.curTickTime > self.maxTickTime then
    self.curTickTime = 0
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.SendTickWorldMapInfoSyncReq)
  end
  local playerCameraManager = self:GetOwningPlayerCameraManager()
  local playerAng = playerCameraManager:K2_GetActorRotation().Yaw + 135
  local playerDir = self.uiData.playerData:GetActorRotation().Yaw + 90
  self:GetPlayerImagePos()
  self.heroIcon:SetRenderTransformAngle(playerDir or 0)
  local mapPosX, mapPosY = self:ScenePosToImagePos(self.uiData.playerImagePos.X, self.uiData.playerImagePos.Y)
  local mapPos = UE4.FVector2D(self.uiData.playerImagePos.X, self.uiData.playerImagePos.Y)
  self.mapLayer0.Slot:SetPosition(mapPos)
  self.mapLayer.Slot:SetPosition(mapPos)
  self.Sector:SetRenderTransformAngle(playerAng or 0)
  if self:GetTraceNpcId() and self:GetTraceNpcId() == self.uiData.traceNpcCfgId then
    for npcId, npcInfo in pairs(self.uiData.npcInfos) do
      if self.uiData.traceNpcCfgId == npcInfo.npcCfg.id then
        self:PlayNpcTraceEffect(npcInfo.npc_refresh_id, true)
      end
    end
  else
    for k, v in pairs(self.uiItem.npcIcons) do
      self:PlayNpcTraceEffect(k, false)
    end
  end
  self.uiData.traceNpcCfgId = self:GetTraceNpcId()
  local TaskModule = _G.NRCModuleManager:GetModule("TaskModule")
  if TaskModule then
    local TaskMap = _G.NRCModuleManager:DoCmd(TaskModuleCmd.GetTaskMap)
    local traceCount = 0
    local taskClass = 0
    if TaskMap then
      for _, to in pairs(TaskMap) do
        if to.Trackers then
          for _, tracker in ipairs(to.Trackers) do
            if tracker.Valid then
              traceCount = traceCount + 1
              local taskPosX, taskPosY = self:ScenePosToImagePos(tracker.Position.X, tracker.Position.Y)
              if tracker.TaskConfig.task_class == _G.Enum.TaskClassType.TCT_MAIN then
                taskClass = _G.Enum.TaskClassType.TCT_MAIN
              elseif tracker.TaskConfig.task_class == _G.Enum.TaskClassType.TCT_SUB then
                taskClass = _G.Enum.TaskClassType.TCT_SUB
              end
              self:UpdateTaskTraceIcon(-taskPosX, -taskPosY, self.uiItem.taskIcons[traceCount])
            end
          end
        end
      end
      for i = 1, 5 do
        local icon = self.uiItem.taskIcons[i]
        icon:ShowDiffByTaskClass(taskClass)
        if i < traceCount + 1 then
          icon:SetVisibility(UE4.ESlateVisibility.Visible)
          icon:PlayTraceEffect(true)
          icon:SetRenderScale(UE4.FVector2D(self.uiData.iconScale, self.uiData.iconScale))
        else
          icon:SetVisibility(UE4.ESlateVisibility.Hidden)
        end
      end
    end
  end
  local deltaTime = self:GetRealTime() - self.RealTime
  if deltaTime > 1 then
    local curTime = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime) / 3600
    local isDay = curTime and curTime > 8.0 and curTime < 18.0
    if isDay then
      self.NightMask:SetVisibility(UE4.ESlateVisibility.Hidden)
    else
      self.NightMask:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    self.RealTime = self:GetRealTime()
    self:SetAreaFogTime(isDay)
  end
end

function UMG_MinimapMain_C:GetRealTime()
  local RealTime = UE4.UGameplayStatics.GetAccurateRealTime(self.World)
  return RealTime
end

function UMG_MinimapMain_C:CheckPosition(targetPos)
  local distance = self:distSqr2D(-self.uiData.playerImagePos, targetPos)
  if distance > 6400.0 then
    return false
  else
    return true
  end
end

function UMG_MinimapMain_C:distSqr2D(a, b)
  if not a or not b then
    return math.maxinteger
  end
  local X = (a.X or a.x) - (b.X or b.x)
  local Y = (a.Y or a.y) - (b.Y or b.y)
  return X * X + Y * Y
end

function UMG_MinimapMain_C:GetTraceNpcId()
  local bigMapModule = NRCModuleManager:GetModule("BigMapModule")
  if nil == bigMapModule then
    return
  end
  local traceNpcId = bigMapModule:GetTraceNpcId()
  if self.curTraceNpcEntityId ~= traceNpcId then
    self.curTraceNpcConfigId = -1
    self.curTraceNpcEntityId = traceNpcId
    local npcData = bigMapModule:GetTraceNpcData()
    if npcData and npcData.npcCfg then
      self.curTraceNpcConfigId = npcData.npcCfg.id or -1
    end
  end
  return self.curTraceNpcConfigId
end

function UMG_MinimapMain_C:UpdateNpcTraceIcon(_npcId, traceIcon, isplay)
  if not traceIcon then
    return
  end
  self:GetNpcInfos()
  for npcId, npcInfo in pairs(self.uiData.npcInfos) do
    if _npcId == npcInfo.npc_refresh_id then
      local posX, posY = self:ScenePosToImagePos(npcInfo.npc_pos.x, npcInfo.npc_pos.y)
      if self:CheckPosition(UE4.FVector2D(-posX, -posY)) then
      else
        local vector0 = UE4.FVector2D(0, 0)
        vector0.X = -posX + self.uiData.playerImagePos.X
        vector0.Y = -posY + self.uiData.playerImagePos.Y
        local vector = vector0:Normalize()
        if traceIcon then
          if isplay then
            traceIcon.Slot:SetPosition(-self.uiData.playerImagePos + vector0 * 62)
          else
            traceIcon.Slot:SetPosition(UE4.FVector2D(-posX, -posY))
          end
        end
      end
    end
  end
end

function UMG_MinimapMain_C:UpdateTaskTraceIcon(targetPosX, targetPosY, traceIcon)
  if nil == traceIcon then
    return
  end
  if self:CheckPosition(UE4.FVector2D(targetPosX, targetPosY)) then
    traceIcon.Slot:SetPosition(UE4.FVector2D(targetPosX, targetPosY))
  else
    local vector0 = UE4.FVector2D(0, 0)
    vector0.X = targetPosX + self.uiData.playerImagePos.X
    vector0.Y = targetPosY + self.uiData.playerImagePos.Y
    local vector = vector0:Normalize()
    traceIcon.Slot:SetPosition(-self.uiData.playerImagePos + vector0 * 68)
  end
end

function UMG_MinimapMain_C:InitFogInfo()
  if self.uiData.npcInfos == nil or nil == self.uiData.npcToAreasInfo then
    return
  end
  self:InitFogTexture()
  for npcId, npcInfo in pairs(self.uiData.npcInfos) do
    local areaFogInfo = self.uiData.npcToAreasInfo[npcInfo.npc_refresh_id]
    if areaFogInfo then
      if npcInfo.unlocked then
        self:SetAreaFogInfo(self.uiItem.fogBlocks[areaFogInfo.imageIndex], 1.0, areaFogInfo.scaleParam, 1.0)
      else
        self:SetAreaFogInfo(self.uiItem.fogBlocks[areaFogInfo.imageIndex], 0.0, areaFogInfo.scaleParam, 0.0)
      end
    end
  end
end

function UMG_MinimapMain_C:GetUnlockPortNum(_npcInfos)
  local unlockPortNum = 0
  for npcId, npcinfo in pairs(_npcInfos) do
    if npcinfo.unlocked == true and npcinfo.npcCfg.genre == _G.Enum.ClientNpcType.CNT_UNLOCKPORT then
      unlockPortNum = unlockPortNum + 1
    end
  end
  return unlockPortNum
end

function UMG_MinimapMain_C:UpdateNpcInfo(npcInfos)
  self.uiData.npcInfos = npcInfos
  if self:GetUnlockPortNum(npcInfos) > 0 then
    self:InitFogInfo()
  else
  end
  local uiItem = self.uiItem
  if uiItem.npcIcons then
    for _, npcWidget in pairs(uiItem.npcIcons) do
      npcWidget:RemoveFromParent()
    end
  end
  uiItem.npcIcons = {}
  if not npcInfos then
    return
  end
end

function UMG_MinimapMain_C:UpdateMinimapChangeEntriesInfo(_entryInfos)
  _G.Log.Debug("UMG_MinimapMain_C:UpdateMinimapChangeEntriesInfo1")
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if nil == bigMapModule then
    return
  end
  _G.Log.Debug("UMG_MinimapMain_C:UpdateMinimapChangeEntriesInfo2")
  bigMapModule:UpdateMapEntries(_entryInfos)
  self:GetNpcInfos()
  self:UpdateNpcInfo(self.uiData.npcInfos)
  if self:GetUnlockPortNum(self.uiData.npcInfos) > 0 then
    _G.Log.Debug("UMG_MinimapMain_C:UpdateMinimapChangeEntriesInfo3")
  end
end

function UMG_MinimapMain_C:SetMinimapTransparent(bool)
  if bool then
    self.mapLayer0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.fogLayer0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.fogLayer:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.mapLayer0:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.fogLayer0:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.fogLayer:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end

function UMG_MinimapMain_C:UpdateMinimapDeleteEntriesInfo(_EntryId)
  for i = 1, #_EntryId do
    table.removeKey(self.uiData.npcInfos, _EntryId[i])
  end
  self:UpdateNpcInfo(self.uiData.npcInfos)
end

function UMG_MinimapMain_C:OnRelogin()
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if nil == bigMapModule then
    return
  end
  bigMapModule.data.bReceivedSyncBeginRsp = false
  bigMapModule:OnCmdSendGetWorldMapInfosReq()
  bigMapModule:OnCmdSendTickWorldMapInfoSyncReq()
end

return UMG_MinimapMain_C
