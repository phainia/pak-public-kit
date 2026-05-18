local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PVPRankedMatchModuleUtils = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleUtils")
local PVPRankedMatchModuleEvent = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleEvent")
local UMG_PVP_FirstReward_Item_C = Base:Extend("UMG_PVP_FirstReward_Item_C")

function UMG_PVP_FirstReward_Item_C:OnConstruct()
  _G.NRCEventCenter:RegisterEvent("UMG_PVP_FirstReward_Item_C", self, PVPRankedMatchModuleEvent.UpdateSeasonStarReward, self.OnUpdateSeasonStarReward)
end

function UMG_PVP_FirstReward_Item_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.UpdateSeasonStarReward, self.OnUpdateSeasonStarReward)
end

function UMG_PVP_FirstReward_Item_C:EventUpdate()
end

function UMG_PVP_FirstReward_Item_C:UpdateSwitchState()
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

function UMG_PVP_FirstReward_Item_C:OnItemUpdate(_data, datalist, index)
  self:EventUpdate()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  _G.DelayManager:DelaySeconds((index - 1) * 0.033, function()
    self:ShowAnim()
  end)
  self.uiData = _data
  self.data = _G.NRCModuleManager:GetModule("PVPRankedMatchModule"):GetData("PVPRankedMatchModuleData")
  self.Btn3:SetRedDotExtraKey(297, {
    _data.id
  })
  self:UpdateSwitchState()
  self:InitRewards(_data.reward_id)
  local curRankConf = PVPRankedMatchModuleUtils.GetPvpRankConf(_data.id)
  self.Text_describe:SetText(curRankConf.name)
  self:AddListener()
end

function UMG_PVP_FirstReward_Item_C:ShowAnim()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
end

function UMG_PVP_FirstReward_Item_C:InitRewards(reward_id)
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
  end
  self.IconList:InitGridView(rewardsTable)
end

function UMG_PVP_FirstReward_Item_C:OnItemSelected(_bSelected)
end

function UMG_PVP_FirstReward_Item_C:OnDeactive()
end

function UMG_PVP_FirstReward_Item_C:TryReceivedAwards()
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.SendZoneGetPvpRankSeasonRewardReq)
end

function UMG_PVP_FirstReward_Item_C:AddListener()
  self.Btn3.btnLevelUp.OnClicked:Remove(self, self.TryReceivedAwards)
  self.Btn3.btnLevelUp.OnClicked:Add(self, self.TryReceivedAwards)
end

function UMG_PVP_FirstReward_Item_C:OnUpdateSeasonStarReward(NewRewardMap)
  if not self.uiData or not self.Switcher then
    return
  end
  local oneReward = NewRewardMap[self.uiData.id]
  if oneReward then
    if oneReward.available and oneReward.received then
      if 1 ~= self.Switcher:GetActiveWidgetIndex() then
        self:PlayAnimation(self.GetReward)
        if self.uiData.received == false then
          self.uiData.received = true
        end
      else
        self:UpdateSwitchState()
      end
      self:InitRewards(self.uiData.reward_id)
    end
    self.uiData = oneReward
  end
end

return UMG_PVP_FirstReward_Item_C
