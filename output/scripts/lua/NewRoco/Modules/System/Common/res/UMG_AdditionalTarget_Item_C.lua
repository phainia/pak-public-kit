local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AdditionalTarget_Item_C = Base:Extend("UMG_AdditionalTarget_Item_C")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")

function UMG_AdditionalTarget_Item_C:OnConstruct()
  self.notFirstShow = false
  BattleEventCenter:Bind(self, BattleEvent.RefreshSilhouetteTaskState)
end

function UMG_AdditionalTarget_Item_C:OnDestruct()
  self:CancelDelay()
end

function UMG_AdditionalTarget_Item_C:OnItemUpdate(_data, datalist, index)
  if not self.notFirstShow then
    self.notFirstShow = true
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:CancelDelay()
    self.delayShowAnimId = _G.DelayManager:DelaySeconds((index - 1) * 0.05, self.DelayShowAnim, self)
  end
  self.data = _data
  self:SetPanelInfo()
end

function UMG_AdditionalTarget_Item_C:DelayShowAnim()
  if self and UE.UObject.IsValid(self) then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.In)
  end
  self.delayShowAnimId = nil
end

function UMG_AdditionalTarget_Item_C:CancelDelay()
  if self.delayShowAnimId then
    _G.DelayManager:CancelDelay(self.delayShowAnimId)
  end
  self.delayShowAnimId = nil
end

function UMG_AdditionalTarget_Item_C:OnBattleEvent(eventName, taskMap)
  local data = self.data
  if eventName == BattleEvent.RefreshSilhouetteTaskState then
    local newTaskInfo = taskMap[data.extra_reward_id]
    if newTaskInfo and data.extra_reward_status == ProtoEnum.BattleTaskState.BTS_UNKNOW then
      if newTaskInfo.task_state == ProtoEnum.BattleTaskState.BTS_SUCCESS then
        self.data.extra_reward_id = newTaskInfo.task_id
        self.data.extra_reward_status = newTaskInfo.task_state
        self:SetPanelInfo()
        self:PlayAnimation(self.Check)
      elseif newTaskInfo.task_state == ProtoEnum.BattleTaskState.BTS_FAIL then
        self.data.extra_reward_id = newTaskInfo.task_id
        self.data.extra_reward_status = newTaskInfo.task_state
      end
    end
  end
end

function UMG_AdditionalTarget_Item_C:SetPanelInfo()
  local data = self.data
  local LegendaryBattleAward = _G.DataConfigManager:GetLegendaryBattleAward(data.extra_reward_id)
  local Index = data.extra_reward_status
  if data.IsLeader then
    self.Switcher:SetActiveWidgetIndex(Index)
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Switcher_1:SetActiveWidgetIndex(Index)
    self.Switcher_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if LegendaryBattleAward and LegendaryBattleAward.text then
    self.Text_accomplish:SetText(LegendaryBattleAward.text)
    self.Text_underway:SetText(LegendaryBattleAward.text)
    self.Text_death:SetText(LegendaryBattleAward.text)
    self.Text_accomplish_1:SetText(LegendaryBattleAward.text)
    self.Text_underway_1:SetText(LegendaryBattleAward.text)
    self.Text_death_1:SetText(LegendaryBattleAward.text)
  else
    Log.Error("LegendaryBattleAward or LegendaryBattleAward.text\230\152\175\231\169\186\239\188\140id=", data.extra_reward_id, "\232\175\183\231\173\150\229\136\146\230\163\128\230\159\165\228\184\128\228\184\139\233\133\141\231\189\174LEGENDARY_BATTLE_AWARD\232\161\168")
  end
end

function UMG_AdditionalTarget_Item_C:PlayCheck()
  self:PlayAnimation(self.Check)
end

function UMG_AdditionalTarget_Item_C:OnItemSelected(_bSelected)
end

function UMG_AdditionalTarget_Item_C:OnDeactive()
end

function UMG_AdditionalTarget_Item_C:OnAnimationFinished(anim)
end

return UMG_AdditionalTarget_Item_C
