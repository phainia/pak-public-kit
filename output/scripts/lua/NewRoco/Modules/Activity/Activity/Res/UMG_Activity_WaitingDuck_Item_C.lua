local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local PVPRankedMatchModuleUtils = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleUtils")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local UMG_Activity_WaitingDuck_Item_C = Base:Extend("UMG_Activity_WaitingDuck_Item_C")

function UMG_Activity_WaitingDuck_Item_C:OnConstruct()
  Base.OnConstruct(self)
  self.Switcher:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:AddButtonListener(self.Button_Item, self.OpenItemInfo)
end

function UMG_Activity_WaitingDuck_Item_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveAllButtonListener()
end

function UMG_Activity_WaitingDuck_Item_C:OnItemUpdate(_data, datalist, index)
  Base.OnItemUpdate(self, _data, datalist, index)
  if index > 2 then
    local Slot = self.NRCImage_59.Slot
    if Slot then
      Slot:SetSize(UE4.FVector2D(494, Slot:GetSize().Y))
    end
  end
  local itemData = _data.customData
  self.Text_Title:SetText(itemData.part_name)
  self.Switcher:SetActiveWidgetIndex(index - 1)
  self.redPointNew:SetupKey(ActivityEnum.RedPointKey.DetailReward, {
    self.itemData.parent.activityInst:GetActivityId(),
    itemData.id
  })
  local goods = itemData.reward_group[1]
  local goodsType = goods.goods_type
  if goodsType == Enum.GoodsType.GT_BAGITEM then
    local Conf = _G.DataConfigManager:GetBagItemConf(goods.goods_id)
    self.icon:SetPath(Conf.icon)
    self:SetQuality(Conf.item_quality)
  elseif goodsType == Enum.GoodsType.GT_CARD_LABEL then
    local Conf = _G.DataConfigManager:GetCardLabelConf(goods.goods_id)
    self.icon:SetPath(Conf.label_icon)
    self:SetQuality(Conf.card_quality)
  elseif goodsType == Enum.GoodsType.GT_REWARD then
    local Conf = _G.DataConfigManager:GetRewardConf(goods.goods_id)
    self.icon:SetPath(Conf.Icon)
  end
  self.txtLV:SetText("\195\151" .. goods.goods_count)
  self:UpdateState()
end

function UMG_Activity_WaitingDuck_Item_C:UpdateState()
  local Type = self.itemData.customData.condition_group[1].condition_enum
  if Type == Enum.RequiredType.ACTRT_LOGIN_DAY_TOTAL then
    self:UpdateLoginDays()
  elseif Type == Enum.RequiredType.ACTRT_PVP_RANK then
    self:UpdatePVPRank()
  elseif Type == Enum.RequiredType.ACTRT_HANDBOOK_NUM then
    self:UpdateHandbookNum()
  end
end

function UMG_Activity_WaitingDuck_Item_C:UpdateLoginDays()
  local module = NRCModuleManager:GetModule("ActivityModule")
  local LoginDays = module:GetLoginDays()
  local TargetLoginDays = self.itemData.customData.condition_group[1].condition_param
  self.Text_quantity:SetText(string.format("%d/%d", LoginDays, TargetLoginDays))
end

function UMG_Activity_WaitingDuck_Item_C:UpdatePVPRank()
  local CurRankName = PVPRankedMatchModuleUtils.GetCurRankName()
  if string.IsNilOrEmpty(CurRankName) then
    CurRankName = "---"
  end
  local TargetRankStar = self.itemData.customData.condition_group[1].condition_param
  local TargetRankName = PVPRankedMatchModuleUtils.GetPvpRankConf(TargetRankStar).name
  CurRankName = string.gsub(CurRankName, "<[^>]+>", "")
  TargetRankName = string.gsub(TargetRankName, "<[^>]+>", "")
  self.Text_quantity:SetText(CurRankName .. "/" .. TargetRankName)
end

function UMG_Activity_WaitingDuck_Item_C:UpdateHandbookNum()
  local Count = _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.GetAreaHandbookInfo, Enum.AreaHandbookType.AHT_KINGDOM).collect_coll_num
  local TargetCount = self.itemData.customData.condition_group[1].condition_param
  self.Text_quantity:SetText(string.format("%d/%d", Count or 0, TargetCount))
end

function UMG_Activity_WaitingDuck_Item_C:RefreshState(_data)
  if nil == _data then
    Log.Error("UMG_Activity_WaitingDuck_Item_C:RefreshState _data is nil")
    return
  end
  local activity_part_id = self.itemData.customData.id
  for i, data in pairs(_data) do
    if data.activity_part_id == activity_part_id then
      self:UpdateState()
      self:SetCurState(data.state)
      break
    end
  end
end

function UMG_Activity_WaitingDuck_Item_C:SetCurState(State)
  self.ActivityState = State
  if State == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNFINISH then
    self.Text_hint:SetText(_G.DataConfigManager:GetLocalizationConf("task_in_progress").msg)
    self.Text_hint:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F5EEE1FF"))
    self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif State == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
    self.Text_hint:SetText("\231\130\185\229\135\187\233\162\134\229\143\150")
    self.Text_hint:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F5EEE1FF"))
    self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif State == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
    self.Text_hint:SetText(_G.DataConfigManager:GetLocalizationConf("activity_checkin_tip3").msg)
    self.Text_hint:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F9C15DFF"))
    self.Switcher:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end

function UMG_Activity_WaitingDuck_Item_C:OnItemSelected(_bSelected)
  Base.OnItemSelected(self, _bSelected)
  if _bSelected and self.itemData.customData.reward_award_way == Enum.RewardReceiveType.ARRT_NONE and self.ActivityState == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
    local req = _G.ProtoMessage:newZoneReceivePlayerActivityConditionRewardReq()
    req.activity_id = self.itemData.parent.activityInst:GetActivityId()
    req.activity_part_id = self.itemData.customData.id
    ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_CONDITION_REWARD_REQ, req, self, self.OnZoneReceivePlayerActivityConditionRewardRsp)
  end
end

function UMG_Activity_WaitingDuck_Item_C:OnZoneReceivePlayerActivityConditionRewardRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    local itemData = self.itemData.customData.reward_group[1]
    local rewardsList = {}
    local rewards = {}
    rewards.id = itemData.goods_id
    rewards.type = itemData.goods_type
    rewards.num = itemData.goods_count
    table.insert(rewardsList, rewards)
    _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, rewardsList, "")
    self:SetCurState(ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE)
  end
end

function UMG_Activity_WaitingDuck_Item_C:OpenItemInfo()
  local RewardItem = self.itemData.customData.reward_group[1]
  local GoodsID = RewardItem.goods_id
  local GoodsType = RewardItem.goods_type
  if GoodsType == Enum.GoodsType.GT_REWARD then
    local Conf = _G.DataConfigManager:GetRewardConf(GoodsID)
    GoodsID = Conf.RewardItem[1].Id
    GoodsType = Conf.RewardItem[1].Type
  end
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, GoodsID, GoodsType)
end

function UMG_Activity_WaitingDuck_Item_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

return UMG_Activity_WaitingDuck_Item_C
