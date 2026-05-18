local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local TaskEnum = require("NewRoco.Modules.Core.Battle.Common.TaskEnum")
local TaskModuleEvent = reload("NewRoco.Modules.Core.Task.TaskModuleEvent")
local UMG_TaskItem_C = Base:Extend("UMG_TaskItem_C")
local DebugData = {"\239\188\159\239\188\159\239\188\159", "???"}
local ArrowUpDir = UE4.FVector2D(1, 1)
local ArrowDownDir = UE4.FVector2D(1, -1)

function UMG_TaskItem_C:OnConstruct()
end

function UMG_TaskItem_C:OnDestruct()
  if self.DelayId then
    DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  if self.Trackers then
    self.Trackers:RemoveEventListener(self, TaskModuleEvent.ON_UPDATE_TRACK, self.OnDistanceUpdate)
    self.Trackers = nil
  end
end

function UMG_TaskItem_C:OnItemUpdate(_data, datalist, index)
  self.Data = _data
  self.datalist = datalist
  self.index = index
  self:InitializedInfo()
  self:PlayIn()
  self:SetDistance()
  self:SetInfo()
end

function UMG_TaskItem_C:InitializedInfo()
  self.TaskIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TaskIconMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Finish:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Xiala:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_TaskItem_C:PlayIn()
  local OpenTask = _G.NRCModeManager:DoCmd(TaskModuleCmd.GetOpenTask)
  if OpenTask then
    local TaskConf = _G.DataConfigManager:GetTaskConf(OpenTask.id)
    if TaskConf.task_class == Enum.TaskClassType.TCT_JOURNEY then
      self.DelayId = _G.DelayManager:DelaySeconds(0.05 * (self.index - 1), function()
        self:PlayAnimation(self.Lvtu_in)
      end)
    elseif TaskConf.task_class == Enum.TaskClassType.TCT_MAIN then
      self.DelayId = _G.DelayManager:DelaySeconds(0.05 * (self.index - 1), function()
        self:PlayAnimation(self.Qitan_in)
      end)
    elseif TaskConf.task_class == Enum.TaskClassType.TCT_SUB then
      self.DelayId = _G.DelayManager:DelaySeconds(0.05 * (self.index - 1), function()
        self:PlayAnimation(self.Shiyi_in)
      end)
    end
  end
end

function UMG_TaskItem_C:SetDistance()
  local OpenTask = _G.NRCModeManager:DoCmd(TaskModuleCmd.GetOpenTask)
  if OpenTask then
    local TaskConf = _G.DataConfigManager:GetTaskConf(OpenTask.id)
    local TaskObject = _G.NRCModuleManager:DoCmd(TaskModuleCmd.GetTaskObjectByTaskId, OpenTask.id)
    if TaskObject and TaskObject.Config.task_class ~= Enum.TaskClassType.TCT_JOURNEY and not TaskObject:IsTrack() then
      if self.HorizontalBox_64 then
        self.HorizontalBox_64:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      return
    end
    local Distance, DirectionSign, Trackers = _G.NRCModuleManager:DoCmd(TaskModuleCmd.GetTaskDistanceByID, TaskConf.id, self.Data.pos)
    if Distance and Distance > 0 then
      self:SetDistanceText(DirectionSign, Distance)
    else
      if self.HorizontalBox_64 then
        self.HorizontalBox_64:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      self.Trackers = Trackers
      if self.Trackers then
        self.Trackers:AddEventListener(self, TaskModuleEvent.ON_UPDATE_TRACK, self.OnDistanceUpdate)
      end
    end
  end
end

function UMG_TaskItem_C:OnDistanceUpdate(TaskTrackInfo)
  local MinDistance = TaskTrackInfo and TaskTrackInfo.DistanceToPlayer or 0
  local DirectionSign = TaskTrackInfo and TaskTrackInfo.DirectionSign
  local Distance = math.round(MinDistance / 100)
  if Distance and Distance > 0 then
    self:SetDistanceText(DirectionSign, Distance)
  elseif self.HorizontalBox_64 then
    self.HorizontalBox_64:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Trackers then
    self.Trackers:RemoveEventListener(self, TaskModuleEvent.ON_UPDATE_TRACK, self.OnDistanceUpdate)
    self.Trackers = nil
  end
end

function UMG_TaskItem_C:SetDistanceText(DirectionSign, Distance)
  if self.HorizontalBox_64 then
    self.HorizontalBox_64:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if "" == DirectionSign then
    self.Arrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif "\226\150\178" == DirectionSign then
    self.Arrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Arrow:SetRenderScale(ArrowUpDir)
  elseif "\226\150\188" == DirectionSign then
    self.Arrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Arrow:SetRenderScale(ArrowDownDir)
  end
  local DistanceText = string.format(LuaText.umg_compitem_1, Distance)
  self.PosTips:SetText(DistanceText)
end

function UMG_TaskItem_C:SetInfo()
  local data = self.Data
  local Text
  local OpenTask = _G.NRCModeManager:DoCmd(TaskModuleCmd.GetOpenTask)
  if OpenTask then
    local TaskConf = _G.DataConfigManager:GetTaskConf(OpenTask.id)
    local TaskObject = _G.NRCModuleManager:DoCmd(TaskModuleCmd.GetTaskObjectByTaskId, TaskConf.id)
    Text = TaskObject:GetGoalDetail(self.Data.pos)
  end
  if data.IsFinish then
    if data.Type == TaskEnum.ContentType.Exist then
      self.TaskIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Finish:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.HorizontalBox_64:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Text:SetText(Text)
      self.TaskIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#AFAC9FFF"))
    else
      self.TaskIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Text:SetText(DebugData[1])
    end
  elseif data.IsShowExtraTask then
    self.TaskIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text:SetText(DebugData[2])
  else
    if data.Data >= data.Condition.count then
      self.Finish:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.HorizontalBox_64:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.TaskIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.TaskIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#AFAC9FFF"))
    else
      self.TaskIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.Text:SetText(Text)
  end
  if #self.datalist == self.index then
    self.Xiala:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_TaskItem_C:OnItemSelected(_bSelected)
end

function UMG_TaskItem_C:OnDeactive()
end

return UMG_TaskItem_C
