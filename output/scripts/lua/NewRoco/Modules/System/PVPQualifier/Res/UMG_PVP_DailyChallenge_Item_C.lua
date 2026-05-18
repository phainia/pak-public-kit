local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PVP_DailyChallenge_Item_C = Base:Extend("UMG_PVP_DailyChallenge_Item_C")
local PVPRankedMatchModuleEvent = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleEvent")

function UMG_PVP_DailyChallenge_Item_C:OnConstruct()
  self:AddListener()
end

function UMG_PVP_DailyChallenge_Item_C:OnDestruct()
  self:CancelDelay()
  self:RemoveListener()
end

function UMG_PVP_DailyChallenge_Item_C:OnItemUpdate(_data, datalist, index)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:CancelDelay()
  self.delayShowAnimId = _G.DelayManager:DelaySeconds((index - 1) * 0.05, self.DelayShowAnim, self)
  self.uiData = _data
  self:UpdateRewardState()
  self.Array:SetText(string.format("%02d", index))
  self:InitRewards(_data.reward_id)
  local str = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character4").str
  local WeekTaskConf = _G.DataConfigManager:GetPvpRankWeekTaskConf(_data.id)
  if WeekTaskConf then
    self.Text_describe:SetText(string.format(str, tonumber(WeekTaskConf.num)))
  end
  self.Btn3:SetRedDotExtraKey(295, {
    _data.id
  })
end

function UMG_PVP_DailyChallenge_Item_C:DelayShowAnim()
  if self and UE4.UObject.IsValid(self) then
    self:ShowAnim()
  end
  self.delayShowAnimId = nil
end

function UMG_PVP_DailyChallenge_Item_C:CancelDelay()
  if self.delayShowAnimId then
    _G.DelayManager:CancelDelay(self.delayShowAnimId)
  end
  self.delayShowAnimId = nil
end

function UMG_PVP_DailyChallenge_Item_C:InitRewards(reward_id)
  local rewardsTable = {}
  local rewardConf = _G.DataConfigManager:GetRewardConf(reward_id)
  if rewardConf then
    for k, v in ipairs(rewardConf.RewardItem) do
      local rewards = _G.NRCCommonItemIconData()
      rewards.itemType = v.Type
      rewards.itemId = v.Id
      rewards.itemNum = v.Count
      rewards.bShowNum = true
      rewards.bShowTip = true
      rewards.bShowGetTag = self.uiData.received
      table.insert(rewardsTable, rewards)
    end
  else
    Log.Error("\229\165\150\229\138\177id\231\154\132\229\173\151\230\174\181RewardItem\233\133\141\231\189\174\228\184\186\231\169\186=", _data.reward_id, "\232\175\183\231\173\150\229\136\146\230\163\128\230\159\165\228\184\128\228\184\139\233\133\141\231\189\174REWARD_CONF\232\161\168")
  end
  self.IconList:InitGridView(rewardsTable)
end

function UMG_PVP_DailyChallenge_Item_C:ReceiveWeekTaskReward()
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.SendZoneGetPvpRankWeekTaskRewardReq, self.uiData)
end

function UMG_PVP_DailyChallenge_Item_C:OnItemSelected(_bSelected)
end

function UMG_PVP_DailyChallenge_Item_C:OnDeactive()
end

function UMG_PVP_DailyChallenge_Item_C:OnLogin()
end

function UMG_PVP_DailyChallenge_Item_C:OnAnimationFinished(anim)
end

function UMG_PVP_DailyChallenge_Item_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_PVP_DailyChallenge_Item_C:AddListener()
  _G.NRCEventCenter:RegisterEvent("UMG_PVP_DailyChallenge_Item_C", self, PVPRankedMatchModuleEvent.UpdateWeekReward, self.OnUpdateWeekReward)
  self:AddButtonListener(self.Btn3.btnLevelUp, self.ReceiveWeekTaskReward)
end

function UMG_PVP_DailyChallenge_Item_C:RemoveListener()
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.UpdateWeekReward, self.OnUpdateWeekReward)
end

function UMG_PVP_DailyChallenge_Item_C:UpdateRewardState()
  if self.uiData.available then
    if self.uiData.received then
      self.Switcher:SetActiveWidgetIndex(1)
    else
      self.Switcher:SetActiveWidgetIndex(2)
    end
  else
    self.Switcher:SetActiveWidgetIndex(0)
  end
end

function UMG_PVP_DailyChallenge_Item_C:OnUpdateWeekReward(NewRewardMap)
  if not self.uiData then
    return
  end
  local oneReward = NewRewardMap[self.uiData.id]
  if oneReward then
    if self.uiData.available and not self.uiData.received then
      if oneReward.available and oneReward.received then
        self:PlayAnimation(self.Get)
      end
      self.uiData = oneReward
      self:InitRewards(self.uiData.reward_id)
    end
    self.uiData = oneReward
  end
end

function UMG_PVP_DailyChallenge_Item_C:ShowAnim()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.In)
end

return UMG_PVP_DailyChallenge_Item_C
