local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LevelRewardList_C = Base:Extend("UMG_LevelRewardList_C")

function UMG_LevelRewardList_C:OnConstruct()
  self.Btn6:SetBtnText(LuaText.room_level_reward_button)
  self:AddButtonListener(self.Btn6.btnLevelUp, self.OnReqClaimReward)
end

function UMG_LevelRewardList_C:OnDestruct()
  self:RemoveButtonListener(self.Btn6.btnLevelUp)
end

function UMG_LevelRewardList_C:OnReqClaimReward()
  HomeIndoorSandbox.Server:ReqClaimHomeLevelReward(function(bSuccess, protoData)
    if bSuccess then
      _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, protoData.ret_info.goods_reward.rewards, "")
      self.Data.State.state = ProtoEnum.RewardState.RewardStateType.REWARD_STATE_TYPE_GOT
      self:OnItemUpdate(self.Data)
    end
  end, self.Data.Conf.id)
end

function UMG_LevelRewardList_C:OnItemUpdate(_data, datalist, index)
  self.Data = _data
  local Conf = _data.Conf
  local bCanExpandThisHomeLevel = _data.bCanExpandThisHomeLevel
  local State = self.Data.State.state
  self.NRCText_2:SetText(string.format(LuaText.home_level, tostring(Conf.id)))
  local RoomLevel = HomeIndoorSandbox.Server.WorldData.RoomLevel
  local bUnlocked = RoomLevel >= Conf.need_room_level
  if bUnlocked then
    self.NRCSwitcher_2:SetActiveWidgetIndex(0)
  else
    self.NRCSwitcher_2:SetActiveWidgetIndex(1)
  end
  self.NRCText_4:SetText(LuaText.room_level_reward_lock_tips)
  self.NRCText:SetText(LuaText.home_level_name)
  self.NRCText_7:SetText(LuaText.room_expend_tag)
  if bCanExpandThisHomeLevel then
    self.Expandable:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Expandable:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if State == ProtoEnum.RewardState.RewardStateType.REWARD_STATE_TYPE_GOT then
    self.NRCSwitcher_1:SetActiveWidgetIndex(3)
  elseif State == ProtoEnum.RewardState.RewardStateType.REWARD_STATE_TYPE_CAN_GET then
    self.NRCSwitcher_1:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_1:SetActiveWidgetIndex(2)
  end
  if State == ProtoEnum.RewardState.RewardStateType.REWARD_STATE_TYPE_GOT then
    if self.Mask2 then
      self.Mask2:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif self.Mask2 then
    self.Mask2:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local RewardConf = DataConfigManager:GetRewardConf(Conf.reward_id)
  local RewardItemList = {}
  if RewardConf then
    local Items = RewardConf.RewardItem
    if Items then
      local function GetQuality(Item)
        if Item.itemType == Enum.GoodsType.GT_VITEM then
          local VItem = DataConfigManager:GetVisualItemConf(Item.itemId)
          
          if VItem then
            return VItem.item_quality
          end
        elseif Item.itemType == Enum.GoodsType.GT_BAGITEM then
          local BagItem = DataConfigManager:GetBagItemConf(Item.itemId)
          if BagItem then
            return BagItem.item_quality
          end
        end
        return 0
      end
      
      for i, Item in ipairs(Items) do
        local Data = {
          itemType = Item.Type,
          itemId = Item.Id,
          itemNum = Item.Count,
          bShowNum = true,
          bShowGetTag = State == ProtoEnum.RewardState.RewardStateType.REWARD_STATE_TYPE_GOT,
          IsCanClick = true,
          itemQuantity = 1
        }
        Data.itemQuantity = GetQuality(Data)
        table.insert(RewardItemList, Data)
      end
    end
  end
  table.sort(RewardItemList, function(a, b)
    if a.itemQuantity ~= b.itemQuantity then
      return a.itemQuantity > b.itemQuantity
    end
    return a.itemId < b.itemId
  end)
  self.NRCGridView_127:InitGridView(RewardItemList)
end

function UMG_LevelRewardList_C:OnItemSelected(_bSelected)
end

function UMG_LevelRewardList_C:OnDeactive()
end

return UMG_LevelRewardList_C
