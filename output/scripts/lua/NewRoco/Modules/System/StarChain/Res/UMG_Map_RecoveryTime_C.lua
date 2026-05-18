local StarChainModuleEvent = require("NewRoco.Modules.System.StarChain.StarChainModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local StarChainEnum = require("NewRoco.Modules.System.StarChain.StarChainEnum")
local UMG_Map_RecoveryTime_C = _G.NRCPanelBase:Extend("UMG_Map_RecoveryTime_C")

function UMG_Map_RecoveryTime_C:OnConstruct()
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
  self.ModuleData = self.module:GetData("StarChainModuleData")
  self.Path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/17.17'"
  self.stamina = _G.DataConfigManager:GetRoleGlobalConfig("star_top_limit").num
  self.next_recover_time = nil
  self.total_recover_time = nil
  self.IsSetNextRecoverTime = true
  self.OpenType = StarChainEnum.OpenType.Common
  self.IsCall = false
  self.IsClose = false
  self.SelectItemIndex = 1
  self.MallGoodsId = 20017
  self:OnAddEventListener()
  self.IsExChangeSuccess = true
  self:SetChildViews(self.PopUp4, self.PopUp1, self.PopUp2)
  self.touchLimitData = nil
end

function UMG_Map_RecoveryTime_C:OnDestruct()
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
end

function UMG_Map_RecoveryTime_C:OnAddEventListener()
  self:RegisterEvent(self, StarChainModuleEvent.StarChainChangeUpdateTimeEvent, self.StarChainChangeUpdateTime)
  self:RegisterEvent(self, StarChainModuleEvent.Tips_SelectItemChange, self.SelectItemChange)
  self:RegisterEvent(self, StarChainModuleEvent.Tips_PlayerDataChange, self.SetPanelInfo)
  NRCEventCenter:RegisterEvent("UMG_StarChain_C", self, BagModuleEvent.BagItemAdd, self.SetPanelInfo)
  NRCEventCenter:RegisterEvent("UMG_StarChain_C", self, BagModuleEvent.BagItemUpdate, self.SetPanelInfo)
end

function UMG_Map_RecoveryTime_C:OnActive(_data, _PlayIsMove, OpenType, IsCall, recoveryItemType, touchLimitData)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401011, "UMG_StarChain_C:OnClickBtn2_1")
  self.touchLimitData = touchLimitData
  self.data = _data
  self.recoveryItemType = recoveryItemType
  if OpenType then
    self.OpenType = OpenType
  end
  Log.Dump(OpenType, 6, "UMG_Map_RecoveryTime_Item_C:OnItemUpdate")
  self.PlayIsMove = _PlayIsMove
  self.IsCall = IsCall
  self.moneyInfo1 = {}
  self.moneyInfo2 = {}
  if self.OpenType == StarChainEnum.OpenType.Common then
    self.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
    local stamina = _G.DataConfigManager:GetRoleGlobalConfig("star_top_limit")
    local StaminaProportion = string.format("%s%s%s", StarNum, "/", stamina.num)
    self:SetCommonPopUpInfo(self.PopUp4)
    table.insert(self.moneyInfo1, {
      moneyType = _G.Enum.VisualItem.VI_STAR,
      sum = StaminaProportion,
      IsShowBuyIcon = false
    })
    self.MoneyBtn:InitGridView(self.moneyInfo1)
    if self.recoveryItemType and self.recoveryItemType == Enum.VisualItem.VI_STAR_DEBRIS then
      self.WidgetSwitcher_0:SetActiveWidgetIndex(2)
      local VisualItemConf = _G.DataConfigManager:GetVisualItemConf(Enum.VisualItem.VI_STAR_DEBRIS)
      local TitleText = VisualItemConf.displayName
      self:SetCommonPopUpInfo(self.PopUp2, TitleText)
      self.PopUp2:ShowOrHideBtnLeft(false)
      self.PopUp2:ShowOrHideBtnRight(false)
      self:ShowStarBones()
      self:StarDebrisRecoverTimeChange(self.data)
    else
      self:StarChainRecoverTimeChange(self.data)
    end
  elseif self.OpenType == StarChainEnum.OpenType.LegendaryBattle then
    self.WidgetSwitcher_0:SetActiveWidgetIndex(2)
    self:SetCommonPopUpInfo(self.PopUp2)
    local costItemId1 = _G.DataConfigManager:GetLegendaryGlobalConfig("beast_challenge_ticket_id").num
    local starNum1 = NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, costItemId1)
    if nil == starNum1 then
      starNum1 = 0
    else
      starNum1 = starNum1.num
    end
    table.insert(self.moneyInfo2, {
      moneyType = costItemId1,
      sum = starNum1,
      IsShowBuyIcon = false
    })
  end
  self.MoneyBtn2:InitGridView(self.moneyInfo2)
  self:SetPanelInfo()
  _G.NRCModuleManager:DoCmd(_G.TeamBattleModuleCmd.TempDisableTeamBattlePanel, false)
  UE4Helper.SetDesiredShowCursor(true, "UMG_Map_RecoveryTime_C")
  self:PlayInAnim()
  self:BindInputAction()
end

function UMG_Map_RecoveryTime_C:ShowStarBones()
  local StarDebrisNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
  StarDebrisNum = StarDebrisNum or 0
  local staminaA = _G.DataConfigManager:GetRoleGlobalConfig("star_debris_top_limit")
  local StaminaProportionA = ""
  local ShowColor = UE4.UNRCStatics.HexToSlateColor("F4EEE1FF")
  if StarDebrisNum >= staminaA.num then
    ShowColor = UE4.UNRCStatics.HexToSlateColor("FFC65FFF")
    StaminaProportionA = string.format("%s", StarDebrisNum)
  elseif StarDebrisNum >= 0 and StarDebrisNum < staminaA.num then
    StaminaProportionA = string.format("%s", StarDebrisNum)
  end
  local MoneyList = {
    {
      moneyType = _G.Enum.VisualItem.VI_STAR_DEBRIS,
      sum = StaminaProportionA,
      IsShowBuyIcon = false,
      ShowColor = ShowColor,
      bCanClick = true
    }
  }
  self.moneyInfo2 = MoneyList
end

function UMG_Map_RecoveryTime_C:SetCommonPopUpInfo(PopUp, TitleText)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.Cancel
  CommonPopUpData.Btn_RightHandler = self.Confirm
  CommonPopUpData.ClosePanelHandler = self.Cancel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Map_RecoveryTime_C:SetPanelInfo(IsBPlaySound)
  if self.enableView then
    self:SetListInfo()
    local rewardsTable = self:SetRewards(self.data, IsBPlaySound)
    if self.OpenType == StarChainEnum.OpenType.Common then
      self.IconList:InitGridView(rewardsTable)
      self.IconList:SelectItemByIndex(self.SelectItemIndex - 1)
      self:UpdateStarChain()
      if self.recoveryItemType and self.recoveryItemType == Enum.VisualItem.VI_STAR_DEBRIS then
        local starDebris = {}
        local rewards = _G.NRCCommonItemIconData()
        rewards.itemType = _G.Enum.GoodsType.GT_VITEM
        rewards.itemId = Enum.VisualItem.VI_STAR_DEBRIS
        rewards.itemNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(Enum.VisualItem.VI_STAR_DEBRIS)
        rewards.bShowNum = true
        rewards.bShowTip = true
        rewards.IsDoCmd = true
        rewards.IsOnlyShowDebris = true
        table.insert(starDebris, rewards)
        self.IconList_2:InitGridView(starDebris)
      end
    elseif self.OpenType == StarChainEnum.OpenType.LegendaryBattle then
      self.IconList_2:InitGridView(rewardsTable)
      self.IconList_2:SelectItemByIndex(self.SelectItemIndex - 1)
      self:SetBaseInfo()
    end
  end
end

function UMG_Map_RecoveryTime_C:SetRewards(itemInfo, _IsBPlaySound)
  local rewardsTable = {}
  for k, v in ipairs(itemInfo) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = v.type
    rewards.itemId = v.ItemId
    rewards.itemNum = v.ItemNum
    rewards.bShowNum = true
    rewards.bShowTip = true
    rewards.IsDoCmd = true
    rewards.DoCmd = "StarChainModuleCmd.SelectItemChange"
    rewards.IsBPlaySound = _IsBPlaySound
    table.insert(rewardsTable, rewards)
  end
  return rewardsTable
end

function UMG_Map_RecoveryTime_C:SetBaseInfo()
  local costItemId = _G.DataConfigManager:GetLegendaryGlobalConfig("beast_challenge_ticket_id").num
  local itemConf = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, costItemId)
  local starNum = 0
  if nil == itemConf then
    starNum = 0
  else
    starNum = itemConf.num
  end
  if self.OpenType == StarChainEnum.OpenType.LegendaryBattle then
    self.PopUp1:SetTitleIconInfo()
  else
    self.PopUp1:SetTitleIconInfo(self.Path)
  end
  local BagItem = _G.DataConfigManager:GetBagItemConf(costItemId)
  self.PopUp1:SetDescInfo(string.format(LuaText.star_chain_module_text_2, BagItem.name))
  self.MoneyBtn2:GetItemByIndex(0):SetInfo(costItemId, starNum, not self.OpenType == StarChainEnum.OpenType.LegendaryBattle)
end

function UMG_Map_RecoveryTime_C:SetListInfo()
  self.data = {}
  local ConsumeItems = _G.DataConfigManager:GetRoleGlobalConfig("stamina_exchange_type1")
  local ConsumeItems_1 = _G.DataConfigManager:GetRoleGlobalConfig("stamina_exchange_type2")
  self.ItemId_1 = ConsumeItems.numList[1]
  self.ItemId_2 = ConsumeItems_1.numList[1]
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.ItemId_1)
  local VisualItemConf = _G.DataConfigManager:GetVisualItemConf(self.ItemId_2)
  self.BuyDiamondCount = nil
  self.RemainBuyDiamondCount = nil
  self.CostItemCount = nil
  self.ExchangeConf = nil
  self.StarItem = nil
  self.bagItemData = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, self.ItemId_1)
  if self.bagItemData then
    self.ItemNum_1 = self.bagItemData.num
  else
    self.ItemNum_1 = 0
  end
  self.ItemNum_2 = _G.DataModelMgr.PlayerDataModel:GetVItemCount(self.ItemId_2)
  if self.ItemNum_1 > 0 and self.OpenType == StarChainEnum.OpenType.Common then
    table.insert(self.data, {
      ItemId = self.ItemId_1,
      Icon = BagItemConf.icon,
      ItemType = _G.Enum.ExchangeUseType.EUT_STAR_USE_ITEM,
      ItemNum = self.ItemNum_1,
      type = _G.Enum.GoodsType.GT_BAGITEM
    })
  end
  table.insert(self.data, {
    ItemId = self.ItemId_2,
    Icon = VisualItemConf.bigIcon,
    ItemType = _G.Enum.ExchangeUseType.EUT_STAR_USE_DIAMOND,
    ItemNum = self.ItemNum_2,
    type = _G.Enum.GoodsType.GT_VITEM
  })
end

function UMG_Map_RecoveryTime_C:SelectItemChange(_index, uiData)
  if self.FirstSelectItem then
    self.FirstSelectItem = false
  elseif not uiData.IsBPlaySound then
    _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MagicManual_Task_Tads_C:SelectTaskType")
  end
  self.SelectItemIndex = _index
  self:SetPlaySound()
  self:SetSelectInfo()
end

function UMG_Map_RecoveryTime_C:SetPlaySound()
  local Count, List
  if self.OpenType == StarChainEnum.OpenType.Common then
    Count = self.IconList:GetItemCount()
    List = self.IconList
  elseif self.OpenType == StarChainEnum.OpenType.LegendaryBattle then
    Count = self.IconList_2:GetItemCount()
    List = self.IconList_2
  end
  for i = 1, Count do
    local Item = List:GetItemByIndex(i - 1)
    if Item then
      Item:SetPlaySound(false)
    end
  end
end

function UMG_Map_RecoveryTime_C:SetSelectInfo()
  local RoleGloBalConfig, Text
  local SelectItem = self.data[self.SelectItemIndex]
  if SelectItem.ItemType == _G.Enum.ExchangeUseType.EUT_STAR_USE_ITEM then
    RoleGloBalConfig = _G.DataConfigManager:GetRoleGlobalConfig("stamina_exchange_text1")
    self.StarItem = _G.DataConfigManager:GetRoleGlobalConfig("star_item")
    Text = string.format(RoleGloBalConfig.str, 12)
    self.CostItemCount = 1
    self.ExchangeConf = _G.DataConfigManager:GetExchangeConf(self.StarItem.numList[1])
  elseif SelectItem.ItemType == _G.Enum.ExchangeUseType.EUT_STAR_USE_DIAMOND then
    if self.OpenType == StarChainEnum.OpenType.Common then
      RoleGloBalConfig = _G.DataConfigManager:GetRoleGlobalConfig("stamina_exchange_text2")
      self.BuyDiamondCount = _G.DataModelMgr.PlayerDataModel:GetBuyDiamondCount()
      local StarPrice = _G.DataConfigManager:GetRoleGlobalConfig("star_price")
      local BuyTimesPerday = _G.DataConfigManager:GetRoleGlobalConfig("star_buytimes_perday")
      self.RemainBuyDiamondCount = BuyTimesPerday.num - self.BuyDiamondCount
      if self.BuyDiamondCount >= 0 and self.BuyDiamondCount < BuyTimesPerday.num then
        self.ExchangeConf = _G.DataConfigManager:GetExchangeConf(StarPrice.numList[self.BuyDiamondCount + 1])
        self.CostItemCount = self.ExchangeConf.cost_item[1].cost_goods_num
        Text = string.format(RoleGloBalConfig.str, self.CostItemCount, self.ExchangeConf.get_item[1].get_goods_num, self.RemainBuyDiamondCount)
      else
        RoleGloBalConfig = _G.DataConfigManager:GetRoleGlobalConfig("star_buytext_diamond_notimes")
        Text = RoleGloBalConfig.str
      end
    elseif self.OpenType == StarChainEnum.OpenType.LegendaryBattle then
      local LegendaryGlobalConf = _G.DataConfigManager:GetLegendaryGlobalConfig("legendary_ticket_exchange")
      self.ExchangeConf = _G.DataConfigManager:GetExchangeConf(LegendaryGlobalConf.num)
      Text = string.format(LegendaryGlobalConf.str, self.ExchangeConf.cost_item[1].cost_goods_num, self.ExchangeConf.get_item[1].get_goods_num)
      self.Text_Describe_3:SetText(Text)
      self.CostItemCount = self.ExchangeConf.cost_item[1].cost_goods_num
      self.BuyDiamondCount = _G.DataModelMgr.PlayerDataModel:GetBuyDiamondCount()
      local BuyTimesPerday = _G.DataConfigManager:GetRoleGlobalConfig("star_buytimes_perday")
      self.RemainBuyDiamondCount = BuyTimesPerday.num - self.BuyDiamondCount
    end
  end
  if self.OpenType == StarChainEnum.OpenType.Common then
    if self.recoveryItemType and self.recoveryItemType == Enum.VisualItem.VI_STAR_DEBRIS then
      local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
      local StarLimit = _G.DataConfigManager:GetRoleGlobalConfig("star_top_limit").num
      local StarDebrisNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
      StarDebrisNum = StarDebrisNum or 0
      local StarDebrisLimit = _G.DataConfigManager:GetRoleGlobalConfig("star_debris_top_limit").num
      if StarNum >= StarLimit then
        if StarDebrisNum >= StarDebrisLimit then
          local VisualItemConf = _G.DataConfigManager:GetVisualItemConf(self.recoveryItemType)
          local text = string.format(LuaText.star_chain_module_text_3, VisualItemConf.displayName)
          self.PopUp2:SetDescInfo(text)
        else
          self.PopUp2:SetDescInfo(LuaText.star_chain_module_text_4)
        end
      else
        self.PopUp2:SetDescInfo(LuaText.star_chain_module_text_5)
      end
      local text = _G.DataConfigManager:GetGlobalConfigByKeyType("star_debris_rule_description", _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG).str
      self.Text_Describe_3:SetText(text)
    else
      self.Text_Describe_2:SetText(Text)
    end
  elseif self.OpenType == StarChainEnum.OpenType.LegendaryBattle then
    self.Text_Describe_3:SetText(Text)
  end
end

function UMG_Map_RecoveryTime_C:StarChainRecoverTimeChange(_rsp)
  if self.enableView then
    self.next_recover_time = _rsp.next_recover_time
    self.total_recover_time = _rsp.total_recover_time
  end
  self.stamina = _G.DataConfigManager:GetRoleGlobalConfig("star_top_limit").num
  self.StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
end

function UMG_Map_RecoveryTime_C:StarDebrisRecoverTimeChange(_rsp)
  if self.enableView then
    self.next_recover_time = _rsp.recover_time
    self.isRecover = _rsp.is_recover
  end
  self.stamina = _G.DataConfigManager:GetRoleGlobalConfig("star_debris_top_limit").num
  self.StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
end

function UMG_Map_RecoveryTime_C:UpdateStarChain()
  if self.enableView then
    local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
    local stamina = _G.DataConfigManager:GetRoleGlobalConfig("star_top_limit")
    local StaminaProportion = string.format("%s%s%s", StarNum, "/", stamina.num)
    if self.recoveryItemType == Enum.VisualItem.VI_STAR_DEBRIS then
      self:SendZoneGetStarDebrisInfoReq()
    end
    self.MoneyBtn:GetItemByIndex(0):SetInfo(_G.Enum.VisualItem.VI_STAR, StaminaProportion, false)
  end
end

function UMG_Map_RecoveryTime_C:StarChainChangeUpdateTime(_num)
  if self.enableView and self.OpenType == StarChainEnum.OpenType.Common then
    self.num = _num
    self:DelaySeconds(0.1, self.StarChainChangeUpdateTimeCall, self)
    self.MoneyBtn:GetItemByIndex(0):SetVisibility(UE4.ESlateVisibility.Visible)
    self.MoneyBtn:GetItemByIndex(0).AddBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
    local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
    local stamina = _G.DataConfigManager:GetRoleGlobalConfig("star_top_limit")
    local StaminaProportion = string.format("%s%s%s", StarNum, "/", stamina.num)
    self.MoneyBtn:GetItemByIndex(0):SetInfo(_G.Enum.VisualItem.VI_STAR, StaminaProportion, false)
  end
end

function UMG_Map_RecoveryTime_C:StarChainChangeUpdateTimeCall()
  self.StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
  if self.StarNum >= self.stamina then
    self.next_recover_time = 0
    self.total_recover_time = 0
  else
    local RoleGlobalConf = _G.DataConfigManager:GetRoleGlobalConfig("star_recover_time")
    self.total_recover_time = self.total_recover_time - RoleGlobalConf.num * self.num
  end
end

function UMG_Map_RecoveryTime_C:OnTick(deltaTime)
  if self.recoveryItemType and self.recoveryItemType == Enum.VisualItem.VI_STAR_DEBRIS then
    local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
    local StarLimit = _G.DataConfigManager:GetRoleGlobalConfig("star_top_limit").num
    local StarDebrisNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
    StarDebrisNum = StarDebrisNum or 0
    local StarDebrisLimit = _G.DataConfigManager:GetRoleGlobalConfig("star_debris_top_limit").num
    local recoverTimeEach = _G.DataConfigManager:GetRoleGlobalConfig("star_debris_recover").numList[1]
    if self.isRecover then
      if StarDebrisNum < StarDebrisLimit then
        if self.next_recover_time > 0 then
          local recoverTime = recoverTimeEach - self.next_recover_time
          local Text = self:secondsToTime(recoverTime)
          self.PopUp2:SetDescInfo(string.format("%s<span color=\"#d56c1f\">%s</>", LuaText.star_chain_module_text_4, Text))
          self.next_recover_time = self.next_recover_time + deltaTime
          if self.next_recover_time <= 0 then
            self.StarNum = self.StarNum + 1
            local RoleGlobalConf = _G.DataConfigManager:GetRoleGlobalConfig("star_debris_recover")
            if self.StarNum >= self.stamina then
              self.next_recover_time = 0
            else
              self.next_recover_time = RoleGlobalConf.num
            end
          end
        else
          local VisualItemConf = _G.DataConfigManager:GetVisualItemConf(self.recoveryItemType)
          local text = string.format(LuaText.star_chain_module_text_3, VisualItemConf.displayName)
          self.PopUp2:SetDescInfo(string.format("%s %s", text, "24:00:00"))
          self:SendZoneGetStarDebrisInfoReq()
        end
      end
    elseif self.next_recover_time > 0 then
      if StarDebrisNum >= StarDebrisLimit then
        local VisualItemConf = _G.DataConfigManager:GetVisualItemConf(self.recoveryItemType)
        local text = string.format(LuaText.star_chain_module_text_3, VisualItemConf.displayName)
        self.PopUp2:SetDescInfo(text)
      else
        local recoverTime = 86400 - self.next_recover_time
        local Text = self:secondsToTime(recoverTime)
        self.PopUp2:SetDescInfo(string.format("%s %s", LuaText.star_chain_module_text_5, Text))
      end
    else
      local VisualItemConf = _G.DataConfigManager:GetVisualItemConf(self.recoveryItemType)
      local text = string.format(LuaText.star_chain_module_text_3, VisualItemConf.displayName)
      self.PopUp2:SetDescInfo(string.format("%s %s", LuaText.star_chain_module_text_5, "24:00:00"))
      self:SendZoneGetStarDebrisInfoReq()
    end
  elseif self.next_recover_time and self.total_recover_time then
    if 0 == self.next_recover_time and self.StarNum >= self.stamina then
      self.Time:SetText(string.format("%s:%s:%s", "00", "00", "00"))
    else
      local Text = self:secondsToTime(self.next_recover_time)
      self.Time:SetText(Text)
      self.next_recover_time = self.next_recover_time - deltaTime
      if self.next_recover_time <= 0 then
        self.StarNum = self.StarNum + 1
        local RoleGlobalConf = _G.DataConfigManager:GetRoleGlobalConfig("star_recover_time")
        if self.StarNum >= self.stamina then
          self.next_recover_time = 0
        else
          self.next_recover_time = RoleGlobalConf.num
        end
      end
    end
    if 0 == self.total_recover_time and self.StarNum >= self.stamina then
      self.PopUp4:SetDescInfo("")
      self.NRCSwitcher_0:SetActiveWidgetIndex(1)
      self.Time_1:SetText(string.format("%s:%s:%s", "00", "00", "00"))
    else
      local Text = self:secondsToTime(self.total_recover_time)
      self.PopUp4:SetDescInfo("")
      self.Time_1:SetText(Text)
      self.total_recover_time = self.total_recover_time - deltaTime
      if self.total_recover_time <= 0 then
        self.total_recover_time = 0
      end
    end
  end
end

function UMG_Map_RecoveryTime_C:SendZoneGetStarDebrisInfoReq()
  local curTimestamp = _G.UpdateManager.Timestamp or 0
  local preSendTimestamp = self.StarDebrisInfoReqTime or 0
  if curTimestamp > 0 and curTimestamp < preSendTimestamp + 1 then
    return
  end
  self.StarDebrisInfoReqTime = curTimestamp
  local req = _G.ProtoMessage:newZoneGetStarDebrisInfoReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_STAR_DEBRIS_INFO_REQ, req, self, self.OnStarDebrisRecoverTime)
end

function UMG_Map_RecoveryTime_C:OnStarDebrisRecoverTime(rsp)
  self.StarDebrisInfoReqTime = 0
  if 0 == rsp.ret_info.ret_code then
    self:StarDebrisRecoverTimeChange(rsp)
  end
end

function UMG_Map_RecoveryTime_C:secondsToTime(ts)
  local seconds = math.floor(math.fmod(ts, 60))
  local min = math.floor(ts / 60)
  local hour = math.floor(min / 60)
  local str
  if tonumber(seconds) >= 0 and tonumber(seconds) < 60 and tonumber(min - hour * 60) >= 0 and tonumber(min - hour * 60) < 60 then
    str = string.format("%02d:%02d:%02d", hour, min - hour * 60, seconds)
  else
    Log.Error(ts, seconds, hour, tonumber(seconds) >= 0 and tonumber(seconds) < 60, tonumber(min - hour * 60) >= 0, "\230\151\182\233\151\180\230\141\162\231\174\151\230\156\137\233\151\174\233\162\152\232\175\183\230\163\128\230\159\165")
  end
  return str
end

function UMG_Map_RecoveryTime_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_Map_RecoveryTime_C")
end

function UMG_Map_RecoveryTime_C:Cancel()
  if self.PlayIsMove then
    local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    localPlayer.inputComponent:SetInputEnable(self, true)
    localPlayer.inputComponent:SetCameraControlEnable(self, true)
  end
  if self.IsCall then
    local SourceReturnFlag = _G.NRCModuleManager:DoCmd(_G.StarChainModuleCmd.GetShopSourceReturnFlag)
    local SourceReturnFunc, call = _G.NRCModuleManager:DoCmd(_G.StarChainModuleCmd.GetShopSourceReturnFunc)
    if SourceReturnFlag then
      if call then
        SourceReturnFunc(call)
      else
        SourceReturnFunc()
      end
      _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdSetShopSourceReturnFlag, false)
    end
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401002, "UMG_StarChain_C:OnClickBtn2_1")
  self:PlayOutAnim()
  _G.NRCModeManager:DoCmd(BigMapModuleCmd.SetSliderVisible)
end

function UMG_Map_RecoveryTime_C:BuyDiamond()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  _G.DataModelMgr.PlayerDataModel:SetBuyDiamondCount((self.BuyDiamondCount or 0) + 1)
  local goods_Id = self.ExchangeConf and self.ExchangeConf.cost_item[1].cost_goods_id
  if goods_Id then
    _G.NRCModuleManager:DoCmd(_G.StarChainModuleCmd.SendExchangeReq, self.ExchangeConf.id, 1, 1, localPlayer.serverData.base.actor_id, goods_Id)
  else
    Log.Warning("goods_Id\228\184\186\231\169\186,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
  end
end

function UMG_Map_RecoveryTime_C:Confirm()
  local Limit = _G.DataConfigManager:GetRoleGlobalConfig("star_top_limit").num
  local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
  if self.OpenType == StarChainEnum.OpenType.Common and Limit <= StarNum then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.no_more_star)
    return
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local SelectItem = self.data[self.SelectItemIndex]
  if SelectItem.ItemType == _G.Enum.ExchangeUseType.EUT_STAR_USE_ITEM then
    if SelectItem.ItemNum > 0 then
      if self.OpenType == StarChainEnum.OpenType.Common then
        _G.NRCModuleManager:DoCmd(StarChainModuleCmd.OpenUseItemPanel, SelectItem)
      else
        _G.NRCModuleManager:DoCmd(_G.StarChainModuleCmd.SendExchangeReq, self.StarItem.numList[1], 1, 1, localPlayer.serverData.base.actor_id, self.ExchangeConf.cost_item[1].cost_goods_id)
      end
    else
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_starchain_1)
    end
  elseif SelectItem.ItemType == _G.Enum.ExchangeUseType.EUT_STAR_USE_DIAMOND then
    if self.OpenType == StarChainEnum.OpenType.Common then
      if self.RemainBuyDiamondCount > 0 then
        if SelectItem.ItemNum >= self.CostItemCount then
          local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
          local Context = string.format(LuaText.star_buytext_diamond_confirm, self.CostItemCount)
          local Ctx = DialogContext()
          Ctx:SetTitle(LuaText.TIPS)
          Ctx:SetContent(Context)
          Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
          Ctx:SetCallbackOkOnly(self, self.BuyDiamond)
          Ctx:SetClickAnywhereClose(true)
          Ctx:SetCloseOnCancel(true)
          Ctx:SetButtonText(LuaText.umg_dialog_2, LuaText.umg_dialog_1)
          _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
        else
          self:SecondBuyTips()
        end
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_starchain_3)
      end
    elseif self.OpenType == StarChainEnum.OpenType.LegendaryBattle then
      if SelectItem.ItemNum >= self.CostItemCount then
        if self.ExchangeConf.use_type == Enum.ExchangeUseType.EUT_LEGENDARY_TICKET and self.ExchangeConf.unlock_type == Enum.ExchangeFormulaUnlockType.EFUT_ROLE_LEVEL then
          local PlayerLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
          if PlayerLevel < self.ExchangeConf.unlock_data then
            _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_2049)
            UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401001, "UMG_StarChain_C:OnClickBtn3_1")
            return
          end
        end
        _G.NRCModuleManager:DoCmd(_G.StarChainModuleCmd.SendExchangeReq, self.ExchangeConf.id, 1, 1, localPlayer.serverData.base.actor_id, self.ExchangeConf.cost_item[1].cost_goods_id)
      else
        self:SecondBuyTips()
      end
    end
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401001, "UMG_StarChain_C:OnClickBtn3_1")
end

function UMG_Map_RecoveryTime_C:SecondBuyTips()
  self.ModuleData:SetIsOpenBuyDiamondGiftItem(true)
  self.ModuleData:SetIsCall(self.IsCall)
  _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.JudgeBuyCouponGiftItem, self.CostItemCount)
end

function UMG_Map_RecoveryTime_C:SetVisibilityInfo(_IsVisibility)
  if _IsVisibility then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Map_RecoveryTime_C:PlayInAnim()
  local switcherIndex = self.WidgetSwitcher_0:GetActiveWidgetIndex()
  if 0 == switcherIndex then
    self:LoadAnimation(0)
  elseif 1 == switcherIndex then
    self:LoadAnimation(3)
  elseif 2 == switcherIndex then
    self:LoadAnimation(6)
  end
end

function UMG_Map_RecoveryTime_C:PlayLoopAnim()
  local switcherIndex = self.WidgetSwitcher_0:GetActiveWidgetIndex()
  if 0 == switcherIndex then
    self:LoadAnimation(1)
  elseif 1 == switcherIndex then
    self:LoadAnimation(4)
  elseif 2 == switcherIndex then
    self:LoadAnimation(7)
  end
  if self.touchLimitData then
    local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, self.touchLimitData.panel).MONEYTIMECLICK
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, self.touchLimitData.module, self.touchLimitData.panel, touchReasonType)
  end
end

function UMG_Map_RecoveryTime_C:PlayOutAnim()
  local switcherIndex = self.WidgetSwitcher_0:GetActiveWidgetIndex()
  if 0 == switcherIndex then
    self:LoadAnimation(2)
  elseif 1 == switcherIndex then
    self:LoadAnimation(5)
  elseif 2 == switcherIndex then
    self:LoadAnimation(8)
  end
end

function UMG_Map_RecoveryTime_C:PanelClose()
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ModuleData:SetIsOpenBuyDiamondGiftItem(false)
  self.ModuleData:SetIsCall(nil)
  _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.ShowOrHideMoneyBtn, false)
  _G.NRCModuleManager:DoCmd(StarChainModuleCmd.ShowOrHideMoneyBtn, false)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowOrHideMoneyBtn, false)
  _G.NRCModuleManager:DoCmd(ShopModuleCmd.EnableOrDisableShopOnPopUpOpen, true)
  self:DoClose()
end

function UMG_Map_RecoveryTime_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) or Anim == self:GetAnimByIndex(5) or Anim == self:GetAnimByIndex(8) then
    self:PanelClose()
  elseif Anim == self:GetAnimByIndex(0) or Anim == self:GetAnimByIndex(3) or Anim == self:GetAnimByIndex(6) then
    self:PlayLoopAnim()
  end
end

function UMG_Map_RecoveryTime_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_MapRecoveryTime")
  if mappingContext then
    mappingContext:BindAction("IA_CloseMapRecoveryTime", self, "OnPcClose2")
  end
end

function UMG_Map_RecoveryTime_C:OnPcClose2()
  self:Cancel()
end

return UMG_Map_RecoveryTime_C
