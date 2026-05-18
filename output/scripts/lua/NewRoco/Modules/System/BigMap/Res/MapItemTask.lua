local BigMapModuleEnum = require("NewRoco.Modules.System.BigMap.BigMapModuleEnum")
local MapItemBase = require("NewRoco.Modules.System.BigMap.Res.MapItemBase")
local MapItemTask = MapItemBase:Extend("MapItemTask")
MapItemTask.ItemData = {}

function MapItemTask:Ctor(parentView, layerList, iconTemplateList)
  MapItemBase.Ctor(self, parentView, layerList, iconTemplateList)
  self.iconList = {}
  self.itemData = {}
  self.allTaskIdList = {}
end

function MapItemTask:Create(iconData, taskInfo)
  self:Refresh(iconData, taskInfo)
  self:OnTravelStateChanged(self.bTravel)
end

function MapItemTask:Refresh(iconData, taskInfo)
  local itemWidget
  local taskId = taskInfo.taskId or 0
  local subTaskId = taskInfo.SubTaskId or taskId
  local goIndex = taskInfo.go_index or 1
  local renderScale = 1.0 / (iconData.curMapImageScale or 1)
  if iconData.layerIndex == nil then
    iconData.layerIndex = 6
  end
  iconData.ZOrder = 1
  if nil == self.iconList[taskId] then
    self.iconList[taskId] = {}
    self.itemData[taskId] = {}
  end
  if nil == self.iconList[taskId][subTaskId] then
    self.iconList[taskId][subTaskId] = {}
    self.itemData[taskId][subTaskId] = {}
  end
  self.itemData[taskId][subTaskId][goIndex] = {iconData = iconData, taskInfo = taskInfo}
  if self.iconList[taskId][subTaskId][goIndex] and UE4.UObject.IsValid(self.iconList[taskId][subTaskId][goIndex]) then
    itemWidget = self.iconList[taskId][subTaskId][goIndex]
  else
    self.iconList[taskId][subTaskId][goIndex] = {}
    itemWidget = MapItemBase.CreateWidget(self, iconData, renderScale)
    self.iconList[taskId][subTaskId][goIndex] = itemWidget
  end
  if self.iconList[taskId] and self.iconList[taskId][subTaskId] then
    local TaskMapTrack = NRCModuleManager:DoCmd(TaskModuleCmd.GetTrackTask)
    local traceTaskId = 0
    if TaskMapTrack then
      traceTaskId = TaskMapTrack.Config.id
    end
    for k, widget in pairs(self.iconList[taskId][subTaskId]) do
      if widget and UE4.UObject.IsValid(widget) then
        if traceTaskId == taskId then
          widget:PlayTraceEffect(true)
        else
          local bIsFlag = NRCModuleManager:DoCmd(BigMapModuleCmd.GetCurTraceAcceptableTask, taskId)
          widget:PlayTraceEffect(bIsFlag)
        end
        local taskConf = _G.DataConfigManager:GetTaskConf(taskId)
        widget:ShowDiffByTaskClass(taskConf, taskInfo.taskShowType)
        widget:SetRenderScale(UE4.FVector2D(renderScale, renderScale))
        local widgetData = widget:GetData()
        if nil == widgetData then
          widgetData = {}
          widget:SetData(widgetData)
        end
        widgetData.imagePosX = iconData.iconImagePos.x
        widgetData.imagePosY = iconData.iconImagePos.y
        widgetData.taskId = 0
        widget:SetMapLayerIconVisible(BigMapModuleEnum.CreatorPriority.TaskIcons)
      end
    end
  end
end

function MapItemTask:UpdateTraceEffect(taskId)
  if self.iconList and self.iconList[taskId] then
    local TaskMapTrack = NRCModuleManager:DoCmd(TaskModuleCmd.GetTrackTask)
    for k, widgetList in pairs(self.iconList[taskId]) do
      if widgetList then
        for go_index, TaskIcon in pairs(widgetList) do
          if TaskIcon and UE4.UObject.IsValid(TaskIcon) then
            if TaskMapTrack and TaskMapTrack.Config.id == taskId then
              TaskIcon:PlayTraceEffect(true)
            else
              TaskIcon:PlayTraceEffect(false)
            end
          end
        end
      end
    end
  end
end

function MapItemTask:UpdateShowTaskInfo(ShowTaskInfoList)
  local taskIdList = {}
  for k, v in pairs(ShowTaskInfoList) do
    local taskId = v.TaskConf.id
    taskIdList[taskId] = true
  end
  for taskId, _ in pairs(self.iconList) do
    if not taskIdList[taskId] then
      for k, widgetList in pairs(self.iconList[taskId]) do
        if widgetList then
          for go_index, TaskIcon in pairs(widgetList) do
            if TaskIcon and UE4.UObject.IsValid(TaskIcon) then
              TaskIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
            end
          end
        end
      end
    end
  end
end

function MapItemTask:Get(taskId, goIndex)
  for key, taskIcons in pairs(self.iconList) do
    for subTaskId, taskIcon in pairs(taskIcons) do
      if subTaskId == taskId then
        if goIndex and goIndex > 0 then
          if taskIcon[goIndex] then
            return taskIcon[goIndex]
          end
        else
          return taskIcon
        end
      end
    end
  end
  return nil
end

function MapItemTask:GetMap(taskId, subTaskId, goIndex)
  if self.iconList and self.iconList[taskId] and self.iconList[taskId][subTaskId] then
    return self.iconList[taskId][subTaskId][goIndex]
  end
end

function MapItemTask:SetIconPosNew(taskId, subTaskId, goIndex, showPos)
  local iconWidget = self:GetMap(taskId, subTaskId, goIndex)
  if iconWidget and UE4.UObject.IsValid(iconWidget) then
    if iconWidget.Slot then
      iconWidget.Slot:SetPosition(showPos)
    end
  else
    self:SetIconPos(BigMapModuleEnum.CreatorPriority.TaskIcons, subTaskId, showPos, goIndex)
  end
end

function MapItemTask:GetAllTaskIcon()
  return self.iconList
end

function MapItemTask:GetItemData(taskId, subTaskId, goIndex)
  if self.itemData[taskId] and self.itemData[taskId][subTaskId] then
    return self.itemData[taskId][subTaskId][goIndex]
  end
end

function MapItemTask:GetAllTaskId()
  table.clear(self.allTaskIdList)
  for taskId, taskIcons in pairs(self.iconList) do
    for subTaskId, taskIcon in pairs(taskIcons) do
      if self.allTaskIdList[subTaskId] == nil then
        self.allTaskIdList[subTaskId] = {}
      end
      if taskIcon then
        for goIndex, task in pairs(taskIcon) do
          table.insert(self.allTaskIdList[subTaskId], goIndex)
        end
      end
    end
  end
  return self.allTaskIdList
end

function MapItemTask:Destroy(taskId, subTaskId, goIndex)
  if self.iconList and self.iconList[taskId] and self.iconList[taskId][subTaskId] then
    local taskIcon = self.iconList[taskId][subTaskId][goIndex]
    if taskIcon and UE4.UObject.IsValid(taskIcon) then
      taskIcon:RemoveFromParent()
      taskIcon:Destruct()
      table.removeKey(self.iconList[taskId][subTaskId], goIndex)
    end
  end
end

function MapItemTask:DestroyById(taskId, subTaskId, goIndex)
  if self.iconList and self.iconList[taskId] and self.iconList[taskId][subTaskId] then
    local taskIcons = self.iconList[taskId][subTaskId]
    for _goIndex, taskIcon in pairs(taskIcons) do
      if taskIcon and UE4.UObject.IsValid(taskIcon) then
        taskIcon:RemoveFromParent()
        taskIcon:Destruct()
        self.iconList[taskId][subTaskId][goIndex] = nil
      end
    end
    self.iconList[taskId][subTaskId] = nil
  end
end

function MapItemTask:DestroyBySubTaskId(subTaskId, goIndex)
  if self.iconList then
    for taskId, taskIcons in pairs(self.iconList) do
      if taskIcons then
        for _subTaskId, taskIcon in pairs(taskIcons) do
          for _goIndex, _taskIcon in pairs(taskIcon) do
            if _subTaskId == subTaskId and _goIndex == goIndex and _taskIcon and UE4.UObject.IsValid(_taskIcon) then
              _taskIcon:RemoveFromParent()
              _taskIcon:Destruct()
              table.removeKey(self.iconList[taskId][subTaskId], goIndex)
              if table.isNil(self.iconList[taskId][subTaskId]) then
                table.removeKey(self.iconList[taskId], subTaskId)
              end
              if table.isNil(self.iconList[taskId]) then
                table.removeKey(self.iconList, taskId)
              end
              break
            end
          end
        end
      end
    end
  end
end

function MapItemTask:DestroyAll()
  MapItemBase.DestroyAll(self)
  if self.iconList then
    for taskId, taskIconList in pairs(self.iconList) do
      for subTaskId, taskIcons in pairs(taskIconList) do
        for goIndex, taskIcon in pairs(taskIcons) do
          self:Destroy(taskId, subTaskId, goIndex)
        end
      end
    end
    self.iconList = nil
  end
end

function MapItemTask:ClearAll()
  if self.iconList then
    for taskId, taskIconList in pairs(self.iconList) do
      for subTaskId, taskIcons in pairs(taskIconList) do
        for goIndex, taskIcon in pairs(taskIcons) do
          self:Destroy(taskId, subTaskId, goIndex)
        end
      end
    end
    self.iconList = {}
  end
end

function MapItemTask:UpdateIconScale(_scaleParam)
  for k, v in pairs(self.iconList) do
    if v then
      for key, val in pairs(v) do
        for goIndex, taskIcon in pairs(val) do
          if taskIcon and UE4.UObject.IsValid(taskIcon) then
            taskIcon:SetRenderScale(_scaleParam)
          end
        end
      end
    end
  end
end

function MapItemTask:UpdateIconScaleByParam(taskId, subTaskId, goIndex, _scaleParam)
  if self.iconList[taskId] and self.iconList[taskId][subTaskId] then
    local icon = self.iconList[taskId][subTaskId][goIndex]
    if icon and UE4.UObject.IsValid(icon) then
      icon:SetRenderScale(_scaleParam)
    end
  end
end

function MapItemTask:OnTravelStateChanged(bTravel)
  MapItemBase.OnTravelStateChanged(self, bTravel)
  for taskId, taskList in pairs(self.iconList) do
    if taskList then
      for subTaskId, taskIcons in pairs(taskList) do
        for goIndex, taskIcon in ipairs(taskIcons) do
          if taskIcon and UE4.UObject.IsValid(taskIcon) then
            if bTravel then
              taskIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
            else
              taskIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            end
          end
        end
      end
    end
  end
end

function MapItemTask:SetIconLayer(taskId, subTaskId, goIndex, layerIndex)
  self:Destroy(taskId, subTaskId, goIndex)
  local itemData = self.itemData[taskId][subTaskId][goIndex]
  if itemData then
    itemData.iconData.layerIndex = layerIndex
    self:Create(itemData.iconData, itemData.taskInfo)
  end
end

return MapItemTask
