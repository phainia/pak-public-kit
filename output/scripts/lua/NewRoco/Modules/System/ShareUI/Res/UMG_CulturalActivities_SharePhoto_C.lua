local UMG_CulturalActivities_SharePhoto_C = _G.NRCPanelBase:Extend("UMG_CulturalActivities_SharePhoto_C")

function UMG_CulturalActivities_SharePhoto_C:OnActive(data)
  self.data = data
  local playerInfo = _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.GetPlayerInfo)
  self.PhotoSub.TextName:SetText(playerInfo.name)
  self.PhotoSub.NRCText_Uid:SetText(playerInfo.uin)
  if playerInfo.headPath and playerInfo.headPath ~= "" then
    self.PhotoSub.HeadPortrait:SetPath(playerInfo.headPath)
  end
  local titleText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_Phone_title").str
  local sendText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_Phone_send").str
  local messageText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_Phone_message").str
  self.PhotoSub.NRCText_0:SetText(titleText)
  self.PhotoSub.Text_Title:SetText(sendText)
  self.PhotoSub.Text_Title_1:SetText(messageText)
  local shareTitleText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_MiddlePage_Subtitle").str
  local shareDesText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_MiddlePage_des").str
  self.PhotoSub.TitleText:SetText(shareTitleText)
  self.PhotoSub.NRCText_2:SetText(shareDesText)
  local awardId = _G.DataConfigManager:GetActivityGlobalConfig("SIM_MiddlePage_PreviewReward").numList[1]
  local items = _G.DataConfigManager:GetRewardConf(awardId).RewardItem
  local rewardsTable = {}
  for k, v in ipairs(items) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = v.Type
    rewards.itemId = v.Id
    rewards.itemNum = v.Count
    rewards.bShowNum = true
    rewards.bShowTip = true
    table.insert(rewardsTable, rewards)
  end
  self.PhotoSub.Award:InitGridView(rewardsTable)
  self.PhotoSub:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

return UMG_CulturalActivities_SharePhoto_C
