local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local MagicManualUtils = require("NewRoco.Modules.System.MagicManual.MagicManualUtils")
local UMG_Leve_ClearanceReward_C = _G.NRCPanelBase:Extend("UMG_Leve_ClearanceReward_C")

function UMG_Leve_ClearanceReward_C:OnConstruct()
  self:SetChildViews(self.PopUp)
  self.TabList = {
    {
      Text = LuaText.challenge_text_38,
      TabType = LevelSelectionEnum.RewardTab.StarReward
    },
    {
      Text = LuaText.challenge_text_39,
      TabType = LevelSelectionEnum.RewardTab.ClearanceReward
    }
  }
  self.ActivityType = nil
  self.challenge_data = nil
  self.ActivityData = nil
  self.SelectTabData = nil
  self.rewards = {}
  self:OnAddEventListener()
end

function UMG_Leve_ClearanceReward_C:OnDestruct()
end

function UMG_Leve_ClearanceReward_C:OnActive(ActivityType)
  self.ActivityType = ActivityType
  if ActivityType == ProtoEnum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
    self.NPCChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT)
    if self.NPCChallengeEventActivityObject and self.NPCChallengeEventActivityObject[1] then
      self.challenge_data = self.NPCChallengeEventActivityObject[1]:GetNpcChallengeData()
      self.ActivityData = self.NPCChallengeEventActivityObject[1]:GetNpcChallengeData()
      self.ActivityId = self.NPCChallengeEventActivityObject[1]:GetNpcActivityId()
    end
  elseif ActivityType == ProtoEnum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
    self.BossChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT)
    if self.BossChallengeEventActivityObject and self.BossChallengeEventActivityObject[1] then
      self.challenge_data = self.BossChallengeEventActivityObject[1]:GetBossChallengeData()
      self.ActivityData = self.BossChallengeEventActivityObject[1]:GetBossChallengeData()
      self.ActivityId = self.BossChallengeEventActivityObject[1]:GetBossActivityId()
    end
  end
  self:SetTabInfo()
  self:LoadAnimation(0)
  self:SetCommonPopUpInfo()
end

function UMG_Leve_ClearanceReward_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Leve_ClearanceReward_C:SetTabInfo()
  if self.ActivityId then
    for i, _ in ipairs(self.TabList) do
      _.ActivityId = self.ActivityId
    end
  end
  self.Tab:InitGridView(self.TabList)
  self.Tab:SelectItemByIndex(0)
end

function UMG_Leve_ClearanceReward_C:OnDeactive()
end

function UMG_Leve_ClearanceReward_C:OnAddEventListener()
  self:RegisterEvent(self, LevelSelectionModuleEvent.SelectTabEvent, self.OnSelectTabEvent)
  self:RegisterEvent(self, LevelSelectionModuleEvent.ReceiveAwardSucceed, self.OnReceiveAwardSucceed)
end

function UMG_Leve_ClearanceReward_C:OnSelectTabEvent(TabData)
  if self.SelectTabAudio then
    _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Leve_BattleSilhouette_C:OnClickCharacterButton")
  else
    self.SelectTabAudio = true
  end
  self.SelectTabData = TabData
  if TabData.TabType == LevelSelectionEnum.RewardTab.StarReward then
    self.rewards = self:GetStarReward()
    for i = 1, #self.rewards do
      self.rewards[i].ActivityId = self.ActivityId
    end
    self.DailyItems:InitList(self.rewards)
    for i, reward in ipairs(self.rewards) do
      local Item = self.DailyItems:GetItemByIndex(i - 1)
      if Item then
        local FinishStar
        if self.ActivityType == ProtoEnum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
          FinishStar = MagicManualUtils.GetFinishNPCChallengeEventSchedule(self.challenge_data, true)
        elseif self.ActivityType == ProtoEnum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
          FinishStar = MagicManualUtils.GetFinishBossChallengeEventSchedule(self.challenge_data, true)
        end
        Item:SetNPCChallengeEventInfo(FinishStar, self.ActivityData, self.ActivityType, self.ActivityId)
      end
    end
  elseif TabData.TabType == LevelSelectionEnum.RewardTab.ClearanceReward then
    self.rewards = self:GetClearanceReward()
    self.DailyItems:InitList(self.rewards)
    for i, reward in ipairs(self.rewards) do
      local Item = self.DailyItems:GetItemByIndex(i - 1)
      if Item then
        Item:SetBossChallengeEventInfo(self.ActivityType)
      end
    end
  end
end

function UMG_Leve_ClearanceReward_C:GetStarReward()
  local rewards = self.challenge_data.rewards
  table.sort(rewards, function(a, b)
    local SortA = a.star_required_num
    local SortB = b.star_required_num
    if a.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
      SortA = SortA + 99999999
    elseif a.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNFINISH then
      SortA = SortA + 999999
    elseif a.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
      SortA = SortA + 9999
    end
    if b.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
      SortB = SortB + 99999999
    elseif b.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNFINISH then
      SortB = SortB + 999999
    elseif b.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
      SortB = SortB + 9999
    end
    return SortA < SortB
  end)
  return rewards
end

function UMG_Leve_ClearanceReward_C:GetClearanceReward()
  local RewardList = {}
  if self.ActivityType == ProtoEnum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
    local modules = self.challenge_data.modules
    for i, module in ipairs(modules) do
      for j, level in ipairs(module.levels) do
        local NpcChallengeConf = _G.DataConfigManager:GetNpcChallengeConf(level.challenge_id)
        table.insert(RewardList, {
          reward_id = NpcChallengeConf.reward_pass,
          challenge_id = level.challenge_id,
          is_finish = level.is_finish
        })
      end
    end
  elseif self.ActivityType == ProtoEnum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
    local levels = self.challenge_data.levels
    for j, level in ipairs(levels) do
      local BossChallengeConf = _G.DataConfigManager:GetBossChallengeConf(level.challenge_id)
      table.insert(RewardList, {
        reward_id = BossChallengeConf.reward_pass,
        challenge_id = level.challenge_id,
        is_finish = level.is_finish
      })
    end
  end
  table.sort(RewardList, function(a, b)
    local SortA = a.challenge_id
    local SortB = b.challenge_id
    if a.is_finish then
      SortA = SortA + 999999
    elseif not a.is_finish then
      SortA = SortA + 9999
    end
    if b.is_finish then
      SortB = SortB + 999999
    elseif not b.is_finish then
      SortB = SortB + 9999
    end
    return SortA < SortB
  end)
  return RewardList
end

function UMG_Leve_ClearanceReward_C:OnReceiveAwardSucceed(star_required_num, ActivityType)
  if ActivityType == ProtoEnum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
    self.NPCChallengeEventActivityObject[1]:SetRewardState(star_required_num)
  elseif ActivityType == ProtoEnum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
    self.BossChallengeEventActivityObject[1]:SetRewardState(star_required_num)
  end
  for i, reward in ipairs(self.rewards) do
    if star_required_num == reward.star_required_num then
      reward.state = ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE
      local Item = self.DailyItems:GetItemByIndex(i - 1)
      if Item and self.SelectTabData.TabType == LevelSelectionEnum.RewardTab.StarReward then
        Item:UpdateReceiveAwardState(reward)
      end
    end
  end
end

function UMG_Leve_ClearanceReward_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Leve_ClearanceReward_C:OnCloseBtn()
  self:LoadAnimation(2)
end

return UMG_Leve_ClearanceReward_C
