local MagicManualUtils = require("NewRoco/Modules/System/MagicManual/MagicManualUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local MagicManualModuleEvent = require("NewRoco.Modules.System.MagicManual.MagicManualModuleEvent")
local UMG_DailySurvey_Item2_C = Base:Extend("UMG_DailySurvey_Item2_C")

function UMG_DailySurvey_Item2_C:OnConstruct()
  self:AddButtonListener(self.ViewBtn.btnLevelUp, self.OnItemButton)
  self:AddButtonListener(self.TraceBtn.btnLevelUp, self.OnTraceBtn)
end

function UMG_DailySurvey_Item2_C:OnDestruct()
end

function UMG_DailySurvey_Item2_C:SetBtnCanClick()
  self.TraceBtn.btnLevelUp:SetIsEnabled(true)
end

function UMG_DailySurvey_Item2_C:OnItemUpdate(arg, datalist, index)
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.CanClick = true
  self.conf = arg.conf
  if not self.conf then
    return
  end
  self.taskInfo = arg.taskInfo
  self.allAchieved = arg.allAchieved
  self.ClueSpecialNodeState = arg.ClueSpecialNodeState
  self:SwitchTaskState()
  self:ShowItemIcon()
end

function UMG_DailySurvey_Item2_C:SwitchTaskState()
  self.Bg_yellow:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.ClueSpecialNodeState == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#929086FF"))
    self.Switcher:SetActiveWidgetIndex(3)
    self.NRCSwitcher_30:SetActiveWidgetIndex(2)
    self.Quantity_1:SetText("\229\183\178\229\174\140\230\136\144")
    self.Quantity_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#929086FF"))
  elseif self.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    self.NRCSwitcher_30:SetActiveWidgetIndex(1)
    self.Bg_yellow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
    self.ViewBtn:SetRedDotKey(164)
    self.Switcher:SetActiveWidgetIndex(0)
  elseif self.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#929086FF"))
    self.NRCSwitcher_30:SetActiveWidgetIndex(0)
    self.Switcher:SetActiveWidgetIndex(3)
    self.Quantity_1:SetText("\229\183\178\229\174\140\230\136\144")
    self.Quantity_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#929086FF"))
  else
    self.NRCSwitcher_30:SetActiveWidgetIndex(1)
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
    self.go_guide = nil
    for i, v in pairs(self.conf.go_guide) do
      if v.type and v.type == Enum.TaskGoActionType.TGAT_UI and v.text then
        self.go_guide = v
      end
    end
    if self.go_guide and self.go_guide.type and self.go_guide.type == Enum.TaskGoActionType.TGAT_UI and self.go_guide.text then
      self.Switcher:SetActiveWidgetIndex(1)
    else
      self.Switcher:SetActiveWidgetIndex(2)
      self.Quantity_1:SetText("\232\191\155\232\161\140\228\184\173")
      self.Quantity_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
    end
  end
end

function UMG_DailySurvey_Item2_C:ShowItemIcon()
  local rewardConf
  if 0 ~= self.conf.Reward then
    rewardConf = _G.DataConfigManager:GetRewardConf(self.conf.Reward)
  end
  if rewardConf then
    local maxNum = self.conf.task_condition[1].count
    local curNum = self.taskInfo.task_target_list[1]
    self.RewardItem = rewardConf.RewardItem[1]
    local itemCount = rewardConf.RewardItem[1].Count
    self.NRCText:SetText(string.format("x%s", itemCount))
    self.Text_Content:SetText(self.conf.name)
    self.Text_Content_1:SetText(string.format("%s/%s", curNum, maxNum))
  end
end

function UMG_DailySurvey_Item2_C:OnItemButton()
  if self.taskInfo == nil then
    return
  end
  if self.taskInfo.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    if self.CanClick then
      self.CanClick = false
    else
      return
    end
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1198, "UMG_DailySurvey_Item2_C:OnItemButton")
    self.Bg_yellow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.GetAllPermanentReward)
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#929086FF"))
    self.Switcher:SetActiveWidgetIndex(3)
    self:PlayAnimation(self.Get)
  end
end

function UMG_DailySurvey_Item2_C:OnTraceBtn()
  MagicManualUtils.TaskTraceByGoGuide(self.go_guide)
  self.TraceBtn.btnLevelUp:SetIsEnabled(false)
end

function UMG_DailySurvey_Item2_C:OnItemSelected()
end

function UMG_DailySurvey_Item2_C:OnAnimationStarted(anim)
  if anim == self.In then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_DailySurvey_Item2_C:OnAnimationFinished(anim)
  if anim == self.In then
  end
end

function UMG_DailySurvey_Item2_C:OnDeactive()
end

return UMG_DailySurvey_Item2_C
