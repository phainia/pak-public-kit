local TaskModuleEvent = reload("NewRoco.Modules.Core.Task.TaskModuleEvent")
local UMG_Envelope_C = _G.NRCPanelBase:Extend("UMG_Envelope_C")

function UMG_Envelope_C:OnConstruct()
  self.data = self.module:GetData("TaskModuleData")
  self:SetChildViews(self.UMG_Envelope1, self.UMG_Envelope1_2, self.UMG_Envelope1_1)
  self.EnvelopeList = {
    self.UMG_Envelope1,
    self.UMG_Envelope1_2
  }
  self.ReceiveBtn = {
    {
      Canvas = self.CanvasPanel_76,
      Text = self.Task,
      Animation = self.LeftBtn_In
    },
    {
      Canvas = self.CanvasPanel_2,
      Text = self.Task_1,
      Animation = self.RightBtn_In
    }
  }
  self.RandomSubTask = nil
  self.SelectTaskId = nil
end

function UMG_Envelope_C:OnDestruct()
  self.data:SetIsOpenTips(false)
end

function UMG_Envelope_C:OnActive(_RandomSubTask)
  self.RandomSubTask = _RandomSubTask
  self:SetPanelInfo()
  self:PlayAnimationByEnvelopeNum()
  self:OnAddEventListener()
end

function UMG_Envelope_C:SetPanelInfo()
  self:SetEnvelopeList()
end

function UMG_Envelope_C:SetReceiveBtnInfo()
  local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("sub_task_letter_source").msg
  for i, Receive in ipairs(self.ReceiveBtn) do
    local SubTaskConf = _G.DataConfigManager:GetSubTaskConf(self.RandomSubTask[i])
    Receive.Canvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local Text = string.format(LocalizationConf, SubTaskConf.task_source_des2)
    Receive.Text:SetText(Text)
  end
end

function UMG_Envelope_C:SetEnvelopeList()
  local Path
  local EnvelopeNum = #self.RandomSubTask
  if EnvelopeNum > 1 then
    for i, Envelope in ipairs(self.EnvelopeList) do
      Envelope:SetEnvelopeInfo(self.RandomSubTask[i])
      Path = self:GetPathById(self.RandomSubTask[i])
      self:SetImagePath(Path)
    end
    self:SetReceiveBtnInfo()
  else
    self.SelectTaskId = self.RandomSubTask[1]
    self.UMG_Envelope1_1:SetEnvelopeInfo(self.RandomSubTask[1])
    Path = self:GetPathById(self.RandomSubTask[1])
    self:SetImagePath(Path)
    self.UMG_Envelope1_1:SelectItem()
    local SubTaskConf = _G.DataConfigManager:GetSubTaskConf(self.RandomSubTask[1])
    local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("sub_task_letter_source").msg
    local Text = string.format(LocalizationConf, SubTaskConf.task_source_des2)
    self.Task_2:SetText(Text)
  end
end

function UMG_Envelope_C:GetPathById(TaskId)
  local SubTaskConf = _G.DataConfigManager:GetSubTaskConf(TaskId)
  local TaskTokenConf = _G.DataConfigManager:GetTaskTokenConf(SubTaskConf.token_reward_id)
  return TaskTokenConf.token__source
end

function UMG_Envelope_C:SetImagePath(Path)
  self.NRCImage_5:SetPath(Path)
  local request = NRCResourceManager:LoadResAsync(self, Path, -1, -1, nil, nil, nil)
  local DynamicMaterial = self.NRCImage:GetDynamicMaterial()
  DynamicMaterial:SetTextureParameterValue("Maintex", request)
  DynamicMaterial:SetTextureParameterValue("Mask_Texture", request)
end

function UMG_Envelope_C:PlayAnimationByEnvelopeNum()
  local EnvelopeNum = #self.RandomSubTask
  if EnvelopeNum > 1 then
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.In_2)
  else
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimation(self.In_1)
  end
end

function UMG_Envelope_C:OnDeactive()
end

function UMG_Envelope_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtn)
  self:AddButtonListener(self.Btn.btnLevelUp, self.OnConFirmReceiveLeft)
  self:AddButtonListener(self.Btn_1.btnLevelUp, self.OnConFirmReceiveRight)
  self:AddButtonListener(self.Btn_2.btnLevelUp, self.OnConfirmReceiveMiddle)
  self:RegisterEvent(self, TaskModuleEvent.EnvelopeSelect, self.OnEnvelopeSelect)
end

function UMG_Envelope_C:OnEnvelopeSelect(TaskId)
  self.SelectTaskId = TaskId
  for i, Envelope in ipairs(self.EnvelopeList) do
    if self.RandomSubTask[i] == TaskId then
      self.ReceiveBtn[i].Canvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:PlayAnimation(self.ReceiveBtn[i].Animation)
    else
      Envelope:PlayUnSelect()
      self.ReceiveBtn[i].Canvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Envelope_C:OnConFirmReceiveLeft()
  _G.NRCAudioManager:PlaySound2DAuto(1220002048, "UMG_Task_Gather_C:OnActive")
  self:PlayAnimation(self.Select_Left)
end

function UMG_Envelope_C:OnConFirmReceiveRight()
  _G.NRCAudioManager:PlaySound2DAuto(1220002048, "UMG_Task_Gather_C:OnActive")
  self:PlayAnimation(self.Select_Righ)
end

function UMG_Envelope_C:OnCloseBtn()
  self:PlayAnimation(self.Out_2)
end

function UMG_Envelope_C:OnConfirmReceiveMiddle()
  _G.NRCAudioManager:PlaySound2DAuto(1220002048, "UMG_Task_Gather_C:OnActive")
  self:PlayAnimation(self.Select_Middle)
end

function UMG_Envelope_C:OnAnimationFinished(Animation)
  if Animation == self.Select_Left or Animation == self.Select_Righ then
    _G.NRCModeManager:DoCmd(_G.TaskModuleCmd.OpenSubTask, self.SelectTaskId)
    self:DoClose()
  elseif Animation == self.Out_2 then
    _G.NRCModeManager:DoCmd(_G.TaskModuleCmd.CloseEnvelopePanel)
    self:DoClose()
  elseif Animation == self.Select_Middle then
    _G.NRCModeManager:DoCmd(_G.TaskModuleCmd.OpenSubTask, self.SelectTaskId)
    self:DoClose()
    _G.NRCAudioManager:PlaySound2DAuto(1220002047, "UMG_Task_Gather_C:OnActive")
  end
end

return UMG_Envelope_C
