local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FreeHuggers_Item_C = Base:Extend("UMG_FreeHuggers_Item_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_FreeHuggers_Item_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_FreeHuggers_Item_C:OnAddEventListener()
  self:AddButtonListener(self.Button_Icon, self.OnShowRewardTips)
  self:AddButtonListener(self.Button_Get, self.OnGetReward)
end

function UMG_FreeHuggers_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.IsWaitGetRewardRsp = false
  self.RewardItemId = nil
  self.RewardItemType = nil
  self:ShowInfo()
  self:ShowReward()
  self:ShowRewardState()
  self:SetRedPoints()
end

function UMG_FreeHuggers_Item_C:ShowInfo()
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.petGroupData.petbase_id)
  if petBaseConf then
    self.NameText:SetText(petBaseConf.name)
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if modelConf and modelConf.big_icon then
      self.HeadIcon:SetIconPath(modelConf.big_icon)
      self.MaskLayer:SetPath(_G.NRCUtils:FormatConfIconPath(modelConf.big_icon, _G.UIIconPath.HeadIconPath))
    end
  end
end

function UMG_FreeHuggers_Item_C:OnItemSelected(_bSelected)
end

function UMG_FreeHuggers_Item_C:OnDeactive()
  self:RemoveButtonListener(self.Button_Icon, self.OnShowRewardTips)
  self:RemoveButtonListener(self.Button_Get, self.OnGetReward)
end

function UMG_FreeHuggers_Item_C:ShowReward()
  if not self.data.petGroupData.gt_share_form_id or 0 == self.data.petGroupData.gt_share_form_id then
    self.RewardId = self.data.petGroupData.instead_reward
  else
    local activityObject = NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstById, self.data.activityId)
    local hasCard = false
    local cardId = self.data.petGroupData.gt_share_form_id
    local playerCardData
    if activityObject and activityObject.PlayerCardData then
      playerCardData = activityObject.PlayerCardData
    end
    if playerCardData then
      for _, v in ipairs(playerCardData) do
        if v.id == cardId then
          hasCard = true
          break
        end
      end
    end
    if hasCard then
      local rewardId
      if activityObject and activityObject.returnActivityData and activityObject.returnActivityData.pet_collection_data then
        local petCollectData = activityObject.returnActivityData.pet_collection_data
        local collectPetRewardList = petCollectData.pet_rewards
        if collectPetRewardList then
          for _, v in ipairs(collectPetRewardList) do
            if v.pet_base_id == self.data.petGroupData.petbase_id then
              if 0 == v.reward_type then
                rewardId = self.data.petGroupData.gt_share_form_id
                break
              end
              rewardId = self.data.petGroupData.instead_reward
              break
            end
          end
        end
      end
      if rewardId then
        self.RewardId = rewardId
      else
        self.RewardId = self.data.petGroupData.instead_reward
      end
    else
      self.RewardId = self.data.petGroupData.gt_share_form_id
    end
  end
  local itemData
  if self.RewardId == self.data.petGroupData.instead_reward then
    local rewardConf = _G.DataConfigManager:GetRewardConf(self.RewardId)
    local rewardItem = rewardConf and rewardConf.RewardItem[1]
    if rewardItem then
      self.RewardItemId = rewardItem.Id
      self.RewardItemType = rewardItem.Type
      itemData = {
        itemType = self.RewardItemType,
        itemId = self.RewardItemId,
        itemNum = rewardItem.Count,
        bShowNum = true,
        bShowTip = true
      }
    end
  else
    self.RewardItemId = self.RewardId
    self.RewardItemType = _G.Enum.GoodsType.GT_SHARE_FORM
    itemData = {
      itemType = self.RewardItemType,
      itemId = self.RewardItemId,
      itemNum = 1,
      bShowNum = true,
      bShowTip = true
    }
  end
  self.ListItemIcon:OnItemUpdate(itemData, nil, 1)
end

function UMG_FreeHuggers_Item_C:ShowRewardState()
  local collectData
  local activityObject = NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstById, self.data.activityId)
  if activityObject and activityObject.returnActivityData and activityObject.returnActivityData.pet_collection_data then
    collectData = activityObject.returnActivityData.pet_collection_data
  end
  if collectData then
    local hasCollectPet = collectData.collection_pet
    if hasCollectPet then
      local curPetBaseId = self.data.petGroupData.petbase_id
      if table.contains(hasCollectPet, curPetBaseId) then
        self.NRCSwitcher_BG:SetActiveWidgetIndex(1)
        local collectPetRewardList = collectData.pet_rewards
        if collectPetRewardList then
          local hasGetRewardPet = false
          for _, v in ipairs(collectPetRewardList) do
            if v.pet_base_id == curPetBaseId then
              hasGetRewardPet = true
              break
            end
          end
          if hasGetRewardPet then
            self.MaskLayer:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            self.Switcher:SetActiveWidgetIndex(2)
          else
            self.MaskLayer:SetVisibility(UE4.ESlateVisibility.Collapsed)
            self.Switcher:SetActiveWidgetIndex(1)
          end
        else
          self.MaskLayer:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.Switcher:SetActiveWidgetIndex(1)
        end
      else
        self.MaskLayer:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Switcher:SetActiveWidgetIndex(0)
        self.NRCSwitcher_BG:SetActiveWidgetIndex(0)
      end
    else
      self.MaskLayer:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Switcher:SetActiveWidgetIndex(0)
      self.NRCSwitcher_BG:SetActiveWidgetIndex(0)
    end
  end
end

function UMG_FreeHuggers_Item_C:SetRedPoints()
  local activityId = self.data.activityId
  local petBaseConfId = self.data.petGroupData.petbase_id
  self.redPointNew:SetupKey(ActivityEnum.RedPointKey.DetailReward, {
    activityId,
    activityId,
    petBaseConfId
  })
end

function UMG_FreeHuggers_Item_C:OnZoneActivityCommonRewardReq()
  self.IsWaitGetRewardRsp = true
  local req = _G.ProtoMessage:newZoneActivityCommonRewardsReq()
  local activity_id = self.data.activityId
  local activityConf = _G.DataConfigManager:GetActivityConf(activity_id)
  req.activity_id = activity_id
  req.activity_sub_id = activityConf.base_id[1]
  req.params = {
    self.data.petGroupData.petbase_id
  }
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_ACTIVITY_COMMON_REWARDS_REQ, req, self, self.OnZoneActivityCommonRewardRsp, true, true)
end

function UMG_FreeHuggers_Item_C:OnZoneActivityCommonRewardRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.NRCSwitcher_BG:SetActiveWidgetIndex(1)
    self.Switcher:SetActiveWidgetIndex(2)
    self.MaskLayer:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.RewardId == self.data.petGroupData.instead_reward then
      ActivityUtils.ShowRewardGetTips(self.RewardId)
    else
      local activityObject = NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstById, self.data.activityId)
      if activityObject and activityObject.PlayerCardData then
        local playerCardData = activityObject.PlayerCardData
        table.insert(playerCardData, {
          id = self.RewardId
        })
      end
    end
    self:UpdateActivityData()
  else
    local desc = _G.LuaText:GetErrorDesc(rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, desc, nil, nil, 1)
  end
  self.IsWaitGetRewardRsp = false
end

function UMG_FreeHuggers_Item_C:OnGetReward()
  if _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.CheckActivityExpired, self.data.activityId) then
    ActivityUtils.ShowActivityExpiredTips()
    return
  end
  if 1 == self.Switcher:GetActiveWidgetIndex() and not self.IsWaitGetRewardRsp then
    self:OnZoneActivityCommonRewardReq()
  end
end

function UMG_FreeHuggers_Item_C:OnShowRewardTips()
  if 1 == self.Switcher:GetActiveWidgetIndex() and not self.IsWaitGetRewardRsp then
    self:OnZoneActivityCommonRewardReq()
  elseif self.RewardItemType == _G.Enum.GoodsType.GT_SHARE_FORM then
    local params = {
      petBaseConfId = self.data.petGroupData.petbase_id,
      activityId = self.data.activityId
    }
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.RewardItemId, self.RewardItemType, false, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, params)
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.RewardItemId, self.RewardItemType, false)
  end
end

function UMG_FreeHuggers_Item_C:UpdateActivityData()
  local activityObject = NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstById, self.data.activityId)
  if activityObject and activityObject.returnActivityData and activityObject.returnActivityData.pet_collection_data then
    local petCollectData = activityObject.returnActivityData.pet_collection_data
    local rewardType = 0
    if self.RewardId == self.data.petGroupData.instead_reward then
      rewardType = 1
    end
    if not petCollectData.pet_rewards then
      petCollectData.pet_rewards = {}
    end
    table.insert(petCollectData.pet_rewards, {
      pet_base_id = self.data.petGroupData.petbase_id,
      reward_type = rewardType
    })
  end
end

return UMG_FreeHuggers_Item_C
