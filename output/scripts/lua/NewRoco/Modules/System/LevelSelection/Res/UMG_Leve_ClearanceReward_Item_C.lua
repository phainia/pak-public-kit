local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Leve_ClearanceReward_Item_C = Base:Extend("UMG_Leve_ClearanceReward_Item_C")

function UMG_Leve_ClearanceReward_Item_C:OnConstruct()
end

function UMG_Leve_ClearanceReward_Item_C:OnDestruct()
end

function UMG_Leve_ClearanceReward_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.challenge_data = nil
  self.ActivityType = nil
  self.ActivityId = nil
  self.RewardList = nil
  self:SetInfo()
  self.ViewBtn.btnLevelUp.OnClicked:Add(self, self.OnReceiveAward)
end

function UMG_Leve_ClearanceReward_Item_C:SetInfo()
  local RewardList = {}
  local RewardConf = _G.DataConfigManager:GetRewardConf(self.data.reward_id)
  for i, reward in ipairs(RewardConf.RewardItem) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = reward.Type
    rewards.itemId = reward.Id
    rewards.itemNum = reward.Count
    rewards.bShowNum = true
    rewards.bShowTip = true
    rewards.bShowGetTag = self.data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE or self.data.is_finish
    table.insert(RewardList, rewards)
  end
  self.RewardList = RewardList
  self.FlowerSeed_ItemIist:InitGridView(RewardList)
end

function UMG_Leve_ClearanceReward_Item_C:SetNPCChallengeEventInfo(FinishStar, ActivityData, ActivityType, ActivityId)
  local data = self.data
  self.ActivityData = ActivityData
  self.ActivityType = ActivityType
  self.ActivityId = ActivityId
  self.Switcher_Titel:SetActiveWidgetIndex(0)
  self.Text_Content_1:SetText(data.star_required_num)
  self.ScheduleItem:SetWidgetIndex(1)
  self:SetChallengeEventInfo(FinishStar)
end

function UMG_Leve_ClearanceReward_Item_C:SetOnNewStateRemove()
end

function UMG_Leve_ClearanceReward_Item_C:UpdateReceiveAwardState(reward)
  self.data = reward
  if self.data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
    self.Switcher:SetActiveWidgetIndex(2)
    for i = 1, self.FlowerSeed_ItemIist:GetItemCount() do
      local item = self.FlowerSeed_ItemIist:GetItemByIndex(i - 1)
      item:SetAlreadyReceived(true)
    end
    self:PlayAnimation(self.Get)
  elseif self.data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
    self.Switcher:SetActiveWidgetIndex(0)
  elseif self.data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNFINISH then
    self.Switcher:SetActiveWidgetIndex(1)
  end
  self:SetOnNewStateRemove()
end

function UMG_Leve_ClearanceReward_Item_C:SetBossChallengeEventInfo(ActivityType)
  local data = self.data
  self.Switcher_Titel:SetActiveWidgetIndex(1)
  local NpcChallengeConf
  if ActivityType == ProtoEnum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
    NpcChallengeConf = _G.DataConfigManager:GetNpcChallengeConf(data.challenge_id)
  elseif ActivityType == ProtoEnum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
    NpcChallengeConf = _G.DataConfigManager:GetBossChallengeConf(data.challenge_id)
  end
  if NpcChallengeConf then
    self.Text_Content_2:SetText(NpcChallengeConf.topic)
  end
  if data.is_finish then
    self.Switcher:SetActiveWidgetIndex(2)
    for i = 1, self.FlowerSeed_ItemIist:GetItemCount() do
      local item = self.FlowerSeed_ItemIist:GetItemByIndex(i - 1)
      item:SetAlreadyReceived(true)
    end
    self:PlayAnimation(self.Get)
  else
    self.Switcher:SetActiveWidgetIndex(1)
    self.Quantity_1:SetText(LuaText.task_in_progress)
  end
end

function UMG_Leve_ClearanceReward_Item_C:SetChallengeEventInfo(FinishStar)
  local data = self.data
  if data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
    self.Switcher:SetActiveWidgetIndex(2)
    for i = 1, self.FlowerSeed_ItemIist:GetItemCount() do
      local item = self.FlowerSeed_ItemIist:GetItemByIndex(i - 1)
      item:SetAlreadyReceived(true)
    end
    self:PlayAnimation(self.Get)
  elseif data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
    self.ViewBtn:SetRedDotKey(373, self.data.ActivityId)
    self.Switcher:SetActiveWidgetIndex(0)
  elseif data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNFINISH then
    self.Switcher:SetActiveWidgetIndex(1)
  end
  self.Quantity_1:SetText(string.format("%d/%d", FinishStar, data.star_required_num))
end

function UMG_Leve_ClearanceReward_Item_C:OnItemSelected(_bSelected)
end

function UMG_Leve_ClearanceReward_Item_C:OnDeactive()
end

function UMG_Leve_ClearanceReward_Item_C:OnReceiveAward()
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.ReceiveAward, self.data.star_required_num, self.ActivityId, self.ActivityType, self.RewardList)
end

return UMG_Leve_ClearanceReward_Item_C
