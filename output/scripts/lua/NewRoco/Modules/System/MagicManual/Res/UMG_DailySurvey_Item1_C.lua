local MagicManualModuleEvent = require("NewRoco.Modules.System.MagicManual.MagicManualModuleEvent")
local UMG_DailySurvey_Item1_C = _G.NRCPanelBase:Extend("UMG_DailySurvey_Item1_C")

function UMG_DailySurvey_Item1_C:OnConstruct()
  self:AddButtonListener(self.Button_24, self.OnClickButton_24)
end

function UMG_DailySurvey_Item1_C:OnDestruct()
end

function UMG_DailySurvey_Item1_C:OnActive(taskInfo, ClueSpecialNodeState)
  self.IsReceive = false
  self.ClueSpecialNodeState = ClueSpecialNodeState
  self.taskInfo = taskInfo.taskInfo
  self.conf = taskInfo.conf
  self.num = taskInfo.num
  self.rewardConf = _G.DataConfigManager:GetRewardConf(self.conf.Reward)
  local RewardItem = self.rewardConf.RewardItem[1]
  self.RewardItem = RewardItem
  self.NRCText:SetText(string.format("x%s", RewardItem.Count))
  self:SwitchTaskState()
end

function UMG_DailySurvey_Item1_C:SwitchTaskState()
  self.ParticleSystemWidget2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ParticleSystemWidget2:SetActivate(false)
  if self.ClueSpecialNodeState == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#929086FF"))
    self.NRCSwitcher_30:SetActiveWidgetIndex(2)
  elseif self.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    self.NRCSwitcher_30:SetActiveWidgetIndex(1)
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
    self.ParticleSystemWidget2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ParticleSystemWidget2:SetActivate(true)
  elseif self.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#929086FF"))
    self.NRCSwitcher_30:SetActiveWidgetIndex(0)
  else
    self.NRCSwitcher_30:SetActiveWidgetIndex(1)
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  end
end

function UMG_DailySurvey_Item1_C:OnClickButton_24()
  if self.taskInfo and self.taskInfo.state and self.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    if self.IsReceive == true then
      return
    end
    self.NRCSwitcher_30:SetActiveWidgetIndex(0)
    _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.GetAllPermanentReward)
    self.IsReceive = true
  end
end

function UMG_DailySurvey_Item1_C:OnAnimationFinished(anim)
  if anim == self.Select_Unlocked then
  elseif anim == self.Select__AlreadyReceived and self.IsReceive then
    self.IsReceive = false
    _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.GetAllPermanentReward)
  end
end

function UMG_DailySurvey_Item1_C:OnDeactive()
end

return UMG_DailySurvey_Item1_C
