local UMG_CulturalActivities_Share_C = _G.NRCPanelBase:Extend("UMG_CulturalActivities_Share_C")
local ShareUIModuleEvent = reload("NewRoco.Modules.System.ShareUI.ShareUIModuleEvent")

function UMG_CulturalActivities_Share_C:OnConstruct()
  self.CanShare = true
  self:OnAddEventListener()
end

function UMG_CulturalActivities_Share_C:OnActive()
  self.CanShare = true
  local titleText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_Phone_title").str
  local sendText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_Phone_send").str
  local messageText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_Phone_message").str
  self.NRCText_0:SetText(titleText)
  self.Text_Title:SetText(sendText)
  self.Text_Title_1:SetText(messageText)
  local shareTitleText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_MiddlePage_Subtitle").str
  local shareDesText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_MiddlePage_des").str
  self.TitleText:SetText(shareTitleText)
  self.NRCText_2:SetText(shareDesText)
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
  self.Award:InitGridView(rewardsTable)
  self.shareBaseId = _G.Enum.ShareButtonType.SBT_ACTIVITY_SIM
  _G.NRCModuleManager:DoCmd(_G.ShareUIModuleCmd.CheckRewardStateEntrance, self.shareBaseId)
end

function UMG_CulturalActivities_Share_C:OnDeactive()
  self:RemoveButtonListener(self.CloseBtn.btnClose, self.ClosePanel)
  self:RemoveButtonListener(self.BtnShare.btnLevelUp, self.OnShare)
  _G.NRCEventCenter:UnRegisterEvent(self, ShareUIModuleEvent.SHOW_ENTRANCE_REWARD, self.CheckShowShareReward)
  self:CancelShareDelayId()
  self.ShareUIReward:CancelShareDelayId()
end

function UMG_CulturalActivities_Share_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.ClosePanel)
  self:AddButtonListener(self.BtnShare.btnLevelUp, self.OnShare)
  _G.NRCEventCenter:RegisterEvent(self.name, self, ShareUIModuleEvent.SHOW_ENTRANCE_REWARD, self.CheckShowShareReward)
end

function UMG_CulturalActivities_Share_C:ClosePanel()
  self:OnClose()
end

function UMG_CulturalActivities_Share_C:OnPcClose()
  self:OnClose()
end

function UMG_CulturalActivities_Share_C:OnShare()
  if self.CanShare then
    self.CanShare = false
    
    local function cb()
      local shareBaseId = _G.Enum.ShareButtonType.SBT_ACTIVITY_SIM
      local index = 1
      if RocoEnv.PLATFORM_WINDOWS or RocoEnv.PLATFORM_OPENHARMONY then
        index = 2
      end
      local sharePartId = _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.GetSharePartIdByShareBaseId, shareBaseId, index)
      if sharePartId then
        local data = {shareBaseId = shareBaseId, sharePartId = sharePartId}
        _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.OpenShareUIPanel, data)
      end
    end
    
    self.ShareCallBack = cb
    self:OnClose()
  end
end

function UMG_CulturalActivities_Share_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    if self.ShareCallBack then
      self.ShareCallBack()
      self.ShareCallBack = nil
      self.CanShare = true
    end
    self:DoClose()
  end
end

function UMG_CulturalActivities_Share_C:CheckShowShareReward(data)
  if data.shareBaseId == self.shareBaseId and 0 == data.rewardGetState then
    local function cb()
      self.ShareUIReward:Init({
        shareBaseId = data.shareBaseId,
        
        isUpAnim = false
      })
    end
    
    self.shareDelayId = _G.DelayManager:DelayFrames(1, cb, self)
  end
end

function UMG_CulturalActivities_Share_C:CancelShareDelayId()
  if self.shareDelayId then
    _G.DelayManager:CancelDelayById(self.shareDelayId)
    self.shareDelayId = nil
  end
end

return UMG_CulturalActivities_Share_C
