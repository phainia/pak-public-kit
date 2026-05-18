local UMG_FreeHuggers_C = _G.NRCPanelBase:Extend("UMG_FreeHuggers_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_FreeHuggers_C:OnActive(data)
  self.IsClose = false
  self.Data = data
  self.RewardItemId = nil
  self.RewardItemType = nil
  self.IsWaitGetRewardRsp = false
  self:OnAddEventListener()
  self:ShowInfo()
end

function UMG_FreeHuggers_C:OnDeactive()
  self:RemoveButtonListener(self.FullScreen_Close, self.OnClickCloseBtn)
  self:RemoveButtonListener(self.IconButton, self.OnGetFinalReward)
end

function UMG_FreeHuggers_C:OnAddEventListener()
  self:AddButtonListener(self.FullScreen_Close, self.OnClickCloseBtn)
  self:AddButtonListener(self.IconButton, self.OnGetFinalReward)
end

function UMG_FreeHuggers_C:ShowInfo()
  self.NRCText_13:SetText(LuaText.Activity_PetCollection_reward_name)
  self.TargetProgressText:SetText(string.format(LuaText.Activity_PetCollection_reward_task_des1, self.Data.curNum, self.Data.maxNum))
  local percent = self.Data.curNum * 1.0 / self.Data.maxNum * 1.0
  self.JinduProgressBar:SetPercent(percent)
  local RewardConf = _G.DataConfigManager:GetRewardConf(self.Data.rewardId)
  if RewardConf then
    local RewardItems = RewardConf.RewardItem
    if RewardItems then
      local rewardItemData = RewardItems[1]
      self.QuantityText:SetText(rewardItemData.Count)
      self.RewardItemId = rewardItemData.Id
      self.RewardItemType = rewardItemData.Type
      local bagItemConf = _G.DataConfigManager:GetBagItemConf(rewardItemData.Id)
      self:SetRewardItemQuality(bagItemConf.item_quality)
      if RewardConf.Icon then
        self.Icon:SetPath(RewardConf.Icon)
      else
        self.Icon:SetPath(bagItemConf.icon)
      end
    end
  end
  local petCollectData = {}
  for _, petGroupData in ipairs(self.Data.petGroup) do
    table.insert(petCollectData, {
      petGroupData = petGroupData,
      activityId = self.Data.activityId
    })
  end
  self.GridViewList:InitGridView(petCollectData)
  self:UpdateRewardState()
  self:SetRedPoints()
end

function UMG_FreeHuggers_C:SetRedPoints()
  local activityId = self.Data.activityId
  self.RedDot:SetupKey(ActivityEnum.RedPointKey.DetailReward, {
    activityId,
    activityId,
    0
  })
end

function UMG_FreeHuggers_C:SetRewardItemQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_FreeHuggers_C:OnClickCloseBtn()
  if not self.IsClose then
    _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_FreeHuggers_C:OnClickCloseBtn")
    self.IsClose = true
    self:DoClose()
  end
end

function UMG_FreeHuggers_C:OnGetFinalReward()
  if _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.CheckActivityExpired, self.Data.activityId) then
    ActivityUtils.ShowActivityExpiredTips()
    return
  end
  self:CheckCanGetFinalReward()
end

function UMG_FreeHuggers_C:UpdateRewardState()
  local hasGetReward = self:CheckHasGetReward()
  if hasGetReward then
    self.Completed:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Completed:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_FreeHuggers_C:CheckCanGetFinalReward()
  if self.IsWaitGetRewardRsp then
    return
  end
  local hasGetReward = self:CheckHasGetReward()
  if hasGetReward then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.RewardItemId, self.RewardItemType, false)
  elseif _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.CheckPetCollectIsFinish, self.Data.activityId) then
    self:OnZoneActivityCommonRewardReq()
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.RewardItemId, self.RewardItemType, false)
  end
end

function UMG_FreeHuggers_C:OnZoneActivityCommonRewardReq()
  self.IsWaitGetRewardRsp = true
  local req = _G.ProtoMessage:newZoneActivityCommonRewardsReq()
  local activity_id = self.Data.activityId
  local activityConf = _G.DataConfigManager:GetActivityConf(activity_id)
  req.activity_id = activity_id
  req.activity_sub_id = activityConf.base_id[1]
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_ACTIVITY_COMMON_REWARDS_REQ, req, self, self.OnZoneActivityCommonRewardRsp, true, true)
end

function UMG_FreeHuggers_C:OnZoneActivityCommonRewardRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self:UpdateActivityData()
    self:UpdateRewardState()
    ActivityUtils.ShowRewardGetTips(self.Data.rewardId)
  else
    local desc = _G.LuaText:GetErrorDesc(rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, desc, nil, nil, 1)
  end
  self.IsWaitGetRewardRsp = false
end

function UMG_FreeHuggers_C:UpdateActivityData()
  local activityObject = NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstById, self.Data.activityId)
  if activityObject and activityObject.returnActivityData and activityObject.returnActivityData.pet_collection_data then
    local petCollectData = activityObject.returnActivityData.pet_collection_data
    petCollectData.disposable_reward_taken_time = UE4.UNRCStatics.GetTimestampMS()
  end
end

function UMG_FreeHuggers_C:CheckHasGetReward()
  local activityObject = NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstById, self.Data.activityId)
  if activityObject and activityObject.returnActivityData and activityObject.returnActivityData.pet_collection_data then
    local petCollectData = activityObject.returnActivityData.pet_collection_data
    if petCollectData.disposable_reward_taken_time then
      return true
    end
  end
  return false
end

function UMG_FreeHuggers_C:ActivityExpiredClosePanel()
  ActivityUtils.ShowActivityExpiredTips()
  self:OnClickCloseBtn()
end

function UMG_FreeHuggers_C:OnPcClose()
  self:OnClickCloseBtn()
end

return UMG_FreeHuggers_C
