local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_ElfCollection_Reward1_C = _G.NRCPanelBase:Extend("UMG_Activity_ElfCollection_Reward1_C")

function UMG_Activity_ElfCollection_Reward1_C:OnActive(data)
  self.IsClose = false
  self.Data = data
  self:ShowInfo()
  self:SetRedPoints()
  self:OnAddEventListener()
  self:LoadAnimation(0)
end

function UMG_Activity_ElfCollection_Reward1_C:OnDeactive()
  self:RemoveButtonListener(self.PopUp.btnClose.btnClose, self.OnClickCloseBtn)
  self:RemoveButtonListener(self.PopUp.FullScreen_Close, self.OnClickCloseBtn)
  self:RemoveButtonListener(self.CollectAllOThemBtn.btnLevelUp, self.OnBtnCollectRewardClick)
end

function UMG_Activity_ElfCollection_Reward1_C:SetRedPoints()
  local activity_id = self.Data.mainPanel:GetActivityId()
  self.CollectAllOThemBtn.RedDot:SetupKey(ActivityEnum.RedPointKey.DetailReward, {activity_id})
end

function UMG_Activity_ElfCollection_Reward1_C:OnAddEventListener()
  self:AddButtonListener(self.PopUp.btnClose.btnClose, self.OnClickCloseBtn)
  self:AddButtonListener(self.PopUp.FullScreen_Close, self.OnClickCloseBtn)
  self:AddButtonListener(self.CollectAllOThemBtn.btnLevelUp, self.OnBtnCollectRewardClick)
end

function UMG_Activity_ElfCollection_Reward1_C:ShowInfo()
  self.AlreadyReceivedBtn.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Text_quantity:SetText(string.format("%d/%d", self.Data.curNum, self.Data.maxNum))
  local rewardsTable = {}
  local rewardConf = _G.DataConfigManager:GetRewardConf(self.Data.rewardId)
  if rewardConf then
    local rewardsGroup = rewardConf.RewardItem
    if rewardsGroup then
      for _, _reward in ipairs(rewardsGroup) do
        local itemData = {}
        itemData.itemType = _reward.Type
        itemData.itemId = _reward.Id
        itemData.itemNum = _reward.Count
        itemData.bShowNum = true
        itemData.bShowTip = true
        table.insert(rewardsTable, itemData)
      end
    end
  end
  self.List:InitGridView(rewardsTable)
  local CanGetReward = self.Data.curNum == self.Data.maxNum
  local IsGetReward = self.Data.mainPanel.IsGetAward
  if CanGetReward then
    self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if IsGetReward then
      self:UpdateIsGetRewardItem(true)
      self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    else
      self:UpdateIsGetRewardItem(false)
      self.NRCSwitcher_0:SetActiveWidgetIndex(0)
    end
  else
    self:UpdateIsGetRewardItem(false)
    self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.PopUp.TitleText:SetText(LuaText.Activity_PetCollection_reward_name)
end

function UMG_Activity_ElfCollection_Reward1_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif anim == self:GetAnimByIndex(1) then
    self:LoadAnimation(1)
  elseif anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Activity_ElfCollection_Reward1_C:OnClickCloseBtn()
  if not self.IsClose then
    _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_Activity_ElfCollection_Reward1_C:OnClickCloseBtn")
    self.IsClose = true
    self:LoadAnimation(2)
  end
end

function UMG_Activity_ElfCollection_Reward1_C:OnBtnCollectRewardClick()
  if self.Data.mainPanel:CheckActivityExpired() then
    ActivityUtils.ShowActivityExpiredTips()
    return
  end
  if self.Data.curNum == self.Data.maxNum then
    local req = _G.ProtoMessage:newZoneReceivePlayerActivityDisposableRewardReq()
    local activity_id = self.Data.mainPanel:GetActivityId()
    local activityConf = _G.DataConfigManager:GetActivityConf(activity_id)
    req.activity_id = activity_id
    req.activity_stage_id = activityConf.base_id[1]
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_DISPOSABLE_REWARD_REQ, req, self, self.OnZoneGetPlayerActivityInfoRsp, true, true)
  end
end

function UMG_Activity_ElfCollection_Reward1_C:OnZoneGetPlayerActivityInfoRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    self:UpdateIsGetRewardItem(true)
    ActivityUtils.ShowRewardGetTips(self.Data.rewardId)
    self.Data.mainPanel.IsGetAward = true
  else
    local desc = _G.LuaText:GetErrorDesc(rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, desc, nil, nil, 1)
  end
end

function UMG_Activity_ElfCollection_Reward1_C:UpdateIsGetRewardItem(IsGetReward)
  for i = 1, self.List:GetItemCount() do
    local item = self.List:GetItemByIndex(i - 1)
    item:SetAlreadyReceived(IsGetReward)
  end
end

function UMG_Activity_ElfCollection_Reward1_C:ActivityExpiredClosePanel()
  ActivityUtils.ShowActivityExpiredTips()
  self:OnClickCloseBtn()
end

return UMG_Activity_ElfCollection_Reward1_C
