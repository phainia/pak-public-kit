local UMG_TaskSummary_GroupPhoto_1_C = _G.NRCViewBase:Extend("UMG_TaskSummary_GroupPhoto_1_C")

function UMG_TaskSummary_GroupPhoto_1_C:OnConstruct()
  self.TODData = {
    [Enum.TimeOfDay.TOD_DAWN] = {
      {StartTime = 4, EndTime = 8}
    },
    [Enum.TimeOfDay.TOD_DAY] = {
      {StartTime = 8, EndTime = 16}
    },
    [Enum.TimeOfDay.TOD_TWILIGHT] = {
      {StartTime = 16, EndTime = 20}
    },
    [Enum.TimeOfDay.TOD_EVENING] = {
      {StartTime = 20, EndTime = 24},
      {StartTime = 0, EndTime = 4}
    }
  }
  self.customData = nil
  self.tip = nil
  self:SetChildViews(self.UMG_TaskPhoto)
  self:OnAddEventListener()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_TaskSummary_GroupPhoto_1_C:OnDestruct()
end

function UMG_TaskSummary_GroupPhoto_1_C:OnActive()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local curModule = self.module
  self.tipsDisplayController = curModule and curModule.getTaskSummaryTipsController
  if self.tipsDisplayController then
    self.tipsDisplayController:BindView(self)
    self.tipsDisplayController:GetExecutor():StartTipDispatchStateListener()
  end
end

function UMG_TaskSummary_GroupPhoto_1_C:OnDeactive()
  if self.tipsDisplayController then
    self.tipsDisplayController:UnBindView()
  end
end

function UMG_TaskSummary_GroupPhoto_1_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseRenamePanel, self.OnClickbtnCloseRenamePanel)
  self:AddButtonListener(self.OpenBtn, self.OnOpenBtn)
end

function UMG_TaskSummary_GroupPhoto_1_C:OnPlayTips(tip)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.customData = tip.customData
  self.tip = tip
  self:SetTaskPhotoInfo()
  self:SetPanelInfo()
end

function UMG_TaskSummary_GroupPhoto_1_C:SetTaskPhotoInfo()
  self.UMG_TaskPhoto:SetPlayerData(self.customData, "panel")
  self.UMG_TaskPhoto:SetpanelName("TaskMainPanel")
  self.UMG_TaskPhoto:SetPlayerPath()
end

function UMG_TaskSummary_GroupPhoto_1_C:SetPanelInfo()
  local TaskSummaryConf = _G.DataConfigManager:GetTaskSummary(self.customData.summary_id)
  if not TaskSummaryConf then
    Log.ErrorFormat("Invalid summary_id(%s).", self.customData.summary_id)
    return
  end
  local nowTime = os.date("*t", self.customData.tod)
  local Index = 0
  for i, Tod in pairs(self.TODData) do
    for j, _Tod in ipairs(Tod) do
      if nowTime.hour >= _Tod.StartTime and nowTime.hour < _Tod.EndTime then
        Index = i
      end
    end
  end
  local BgPath = TaskSummaryConf.res_conf[1].bg_res
  local TodTime = tonumber(TaskSummaryConf.light_conf[1].light_para[1])
  for i, TaskSummary in ipairs(TaskSummaryConf.res_conf) do
    if self:FindPath(TaskSummary.tod, Index) and self:FindPath(TaskSummary.weather, self.customData.weather2) then
      BgPath = TaskSummary.bg_res
      break
    end
  end
  for i, TaskSummary in ipairs(TaskSummaryConf.light_conf) do
    if self:FindPath(TaskSummary.tod_pc, Index) and self:FindPath(TaskSummary.weather_pc, self.customData.weather2) then
      TodTime = tonumber(TaskSummary.light_para[1])
      break
    end
  end
  Log.Debug(BgPath, TodTime, Index, self.customData.summary_id, "UMG_TaskSummary_GroupPhoto_C:SetPanelInfo")
  self.Text_Title:SetText(TaskSummaryConf.task_name)
  self.PanelBg:SetPath(BgPath)
  local date = os.date("%Y.%m.%d", self.customData.tod)
  self.Text_Time:SetText(date)
end

function UMG_TaskSummary_GroupPhoto_1_C:FindPath(Conf, Param)
  for i, _ in ipairs(Conf) do
    if Param == _ then
      return true
    end
  end
end

function UMG_TaskSummary_GroupPhoto_1_C:OnAllTipsFinished()
  self:ClosePanel()
end

function UMG_TaskSummary_GroupPhoto_1_C:OnOpenBtn()
  _G.NRCAudioManager:PlaySound2DAuto(40002016, "UMG_MagicManual_Task_Tads_C:SelectTaskType")
  _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.OpenTaskPhoto, self.tip)
end

function UMG_TaskSummary_GroupPhoto_1_C:OnClickbtnCloseRenamePanel()
  if self.tipsDisplayController then
    self.tipsDisplayController:GetExecutor():ConsumeNextTip()
  else
    self:DoClose()
  end
end

function UMG_TaskSummary_GroupPhoto_1_C:ClosePanel()
  self:DoClose()
end

function UMG_TaskSummary_GroupPhoto_1_C:OnAnimationFinished(Anim)
  if Anim == self.Disappear then
    self:DoClose()
  end
end

return UMG_TaskSummary_GroupPhoto_1_C
