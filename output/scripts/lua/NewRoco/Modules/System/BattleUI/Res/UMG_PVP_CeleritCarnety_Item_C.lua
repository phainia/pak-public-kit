local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PVP_CeleritCarnety_Item_C = Base:Extend("UMG_PVP_CeleritCarnety_Item_C")

function UMG_PVP_CeleritCarnety_Item_C:OnConstruct()
end

function UMG_PVP_CeleritCarnety_Item_C:OnDestruct()
end

function UMG_PVP_CeleritCarnety_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local eventConf
  if _data.ActiveType == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
    eventConf = _G.DataConfigManager:GetNpcChallengeConf(_data.id)
  elseif _data.ActiveType == Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
    eventConf = _G.DataConfigManager:GetBossChallengeConf(_data.id)
  end
  if not eventConf then
    return
  end
  self.Text_describe:SetText(eventConf.topic)
  self:SetInfo(eventConf.reward_pass)
  self.Switcher:SetActiveWidgetIndex(1)
end

function UMG_PVP_CeleritCarnety_Item_C:SetInfo(RewardId)
  local RewardList = {}
  local RewardConf = _G.DataConfigManager:GetRewardConf(RewardId)
  for i, reward in ipairs(RewardConf.RewardItem) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = reward.Type
    rewards.itemId = reward.Id
    rewards.itemNum = reward.Count
    rewards.bShowNum = true
    rewards.bShowTip = true
    table.insert(RewardList, rewards)
  end
  self.IconList:InitGridView(RewardList)
end

function UMG_PVP_CeleritCarnety_Item_C:OnItemSelected(_bSelected)
end

function UMG_PVP_CeleritCarnety_Item_C:OnDeactive()
end

return UMG_PVP_CeleritCarnety_Item_C
