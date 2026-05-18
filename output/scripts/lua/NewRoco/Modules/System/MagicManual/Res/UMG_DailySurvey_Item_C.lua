local MagicManualModuleEvent = reload("NewRoco.Modules.System.MagicManual.MagicManualModuleEvent")
local UMG_DailySurvey_Item_C = _G.NRCPanelBase:Extend("UMG_DailySurvey_Item_C")

function UMG_DailySurvey_Item_C:OnConstruct()
  _G.UpdateManager:UnRegister(self)
  self:AddButtonListener(self.Button_27, self.OnClickButton_27)
end

function UMG_DailySurvey_Item_C:OnDestruct()
  _G.UpdateManager:UnRegister(self)
end

function UMG_DailySurvey_Item_C:OnActive(arg)
  self.conf = arg.conf
  self.num = arg.num
  self.taskInfo = arg.taskInfo
  self.rewardConf = _G.DataConfigManager:GetRewardConf(self.conf.Reward)
  self.NRCText_22:SetText(self.num)
  self.canReceive = self.taskInfo.state >= _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT
  if self.taskInfo.state >= _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self:PlayAnimation(self.Normal)
    self.NRCImage_43:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Right_di:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    self.Right_di:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCImage_43:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimation(self.Waiting_to_receive)
  else
    self.NRCImage_43:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimation(self.Normal)
    self.Right_di:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.Switcher:SetActiveWidgetIndex(self.canReceive and 0 or 1)
  self.NrcRedPoint:SetupKey(164, {
    self.conf.id
  })
  self.DeltaTimer = 0
end

function UMG_DailySurvey_Item_C:OnTick(InDeltaTime)
  self.DeltaTimer = self.DeltaTimer + InDeltaTime
  if self.FirstRed then
    if self.DeltaTimer >= 3 then
      if self.NrcRedPoint and self.NrcRedPoint:IsRed() then
        local red = self.NrcRedPoint.RedPointNode:GetChildAt(0)
        if red then
          red:PlayAnimation(red.Loop)
        end
      end
      self.DeltaTimer = 0
      self.FirstRed = false
    end
  elseif self.DeltaTimer >= 8 then
    if self.NrcRedPoint and self.NrcRedPoint:IsRed() then
      local red = self.NrcRedPoint.RedPointNode:GetChildAt(0)
      if red then
        red:PlayAnimation(red.Loop)
      end
    end
    self.DeltaTimer = 0
  end
end

function UMG_DailySurvey_Item_C:CancelTick()
  self.FirstRed = false
  self.DeltaTimer = 0
  _G.UpdateManager:UnRegister(self)
end

function UMG_DailySurvey_Item_C:GetRewardAnim()
  if self.NrcRedPoint:IsRed() then
    self.NrcRedPoint:PlayAnimation(self.NrcRedPoint.Out)
    self.NRCImage_43:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Get)
    self.FirstRed = false
    self.DeltaTimer = 0
    _G.UpdateManager:UnRegister(self)
  end
end

function UMG_DailySurvey_Item_C:OnClickButton_27()
  _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.SetClueRewardIndex, self.num)
  if self.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    if self.rewardConf then
      local rewardList = {}
      for i = 1, #self.rewardConf.RewardItem do
        local item = self.rewardConf.RewardItem[i]
        table.insert(rewardList, {
          Id = item.Id,
          Count = item.Count,
          Type = item.Type,
          state = self.taskInfo.state
        })
      end
      _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.ShowClueRewardTips, self.num, rewardList)
    end
  elseif self.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    self.NRCImage_43:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Get)
    _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.GetAllClueReward)
  elseif self.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN then
    self:PlayAnimation(self.Select_offthestocks)
    if self.rewardConf then
      local rewardList = {}
      if self.isSpecial then
        local eggShow = _G.DataConfigManager:GetDailyGlobalConfig(8).numList
        table.insert(rewardList, {
          Id = eggShow[1],
          Count = eggShow[2],
          Type = _G.Enum.GoodsType.GT_BAGITEM
        })
      end
      for i = 1, #self.rewardConf.RewardItem do
        local item = self.rewardConf.RewardItem[i]
        table.insert(rewardList, {
          Id = item.Id,
          Count = item.Count,
          Type = item.Type,
          state = self.taskInfo.state
        })
      end
      _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.ShowClueRewardTips, self.num, rewardList)
    end
  end
end

function UMG_DailySurvey_Item_C:OnAnimationFinished(anim)
  if anim == self.In and self.NrcRedPoint:IsRed() then
    _G.UpdateManager:Register(self)
    self.FirstRed = true
    self.DeltaTimer = 0
    self.NrcRedPoint:PlayAnimation(self.NrcRedPoint.In)
  end
end

function UMG_DailySurvey_Item_C:PlayAnimIn(DelayTime)
  if self:IsAnimationPlaying(self.In) or self:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
    return
  end
  if 0 == DelayTime then
    self:PlayAnimation(self.In)
  else
    self:DelaySeconds(DelayTime, function()
      self:PlayAnimation(self.In)
    end)
  end
end

function UMG_DailySurvey_Item_C:OnAnimationStarted(anim)
  if anim == self.In then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_DailySurvey_Item_C:OnDeactive()
end

return UMG_DailySurvey_Item_C
