local StarChainModuleEvent = require("NewRoco.Modules.System.StarChain.StarChainModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_StarChain_C = _G.NRCPanelBase:Extend("UMG_StarChain_C")

function UMG_StarChain_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_StarChain_C:OnDestruct()
  _G.NRCModuleManager:DoCmd(_G.TeamBattleModuleCmd.TempDisableTeamBattlePanel, true)
end

function UMG_StarChain_C:OnActive(_PlayIsMove)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1291, "UMG_StarChain_C:OnActive")
  self.PlayIsMove = _PlayIsMove
  self:SetBtnInfo()
  self:SetPanelInfo()
  _G.NRCModuleManager:DoCmd(_G.TeamBattleModuleCmd.TempDisableTeamBattlePanel, false)
  UE4Helper.SetDesiredShowCursor(true, "UMG_StarChain_C")
end

function UMG_StarChain_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_StarChain_C")
end

function UMG_StarChain_C:SetListInfo()
  self.data = {}
  self.ItemId_1 = 100653
  self.ItemId_2 = 3
  self.icon_1 = _G.DataConfigManager:GetBagItemConf(self.ItemId_1).icon
  self.icon_2 = _G.DataConfigManager:GetVisualItemConf(self.ItemId_2).bigIcon
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
  if self.ItemNum_1 > 0 then
    table.insert(self.data, {
      ItemId = self.ItemId_1,
      Icon = self.icon_1,
      ItemType = _G.Enum.ExchangeUseType.EUT_STAR_USE_ITEM,
      ItemNum = self.ItemNum_1
    })
  end
  table.insert(self.data, {
    ItemId = self.ItemId_2,
    Icon = self.icon_2,
    ItemType = _G.Enum.ExchangeUseType.EUT_STAR_USE_DIAMOND,
    ItemNum = self.ItemNum_2
  })
  self.SelectItemIndex = 1
end

function UMG_StarChain_C:OnAddEventListener()
  self:AddButtonListener(self.Btn2_1.btnLevelUp, self.OnClickBtn2_1)
  self:AddButtonListener(self.Btn3_1.btnLevelUp, self.OnClickBtn3_1)
  self:RegisterEvent(self, StarChainModuleEvent.Tips_SelectItemChange, self.SelectItemChange)
  self:RegisterEvent(self, StarChainModuleEvent.Tips_PlayerDataChange, self.SetPanelInfo)
  NRCEventCenter:RegisterEvent("UMG_StarChain_C", self, BagModuleEvent.BagItemAdd, self.SetPanelInfo)
  NRCEventCenter:RegisterEvent("UMG_StarChain_C", self, BagModuleEvent.BagItemUpdate, self.SetPanelInfo)
end

function UMG_StarChain_C:SetPanelInfo()
  if self.enableView then
    self:SetListInfo()
    self.List:InitGridView(self.data)
    self.List:SelectItemByIndex(self.SelectItemIndex - 1)
  end
end

function UMG_StarChain_C:OnClickBtn2_1()
  if self.PlayIsMove then
    local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    localPlayer.inputComponent:SetInputEnable(self, true)
    localPlayer.inputComponent:SetCameraControlEnable(self, true)
  end
  NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_StarChain_C:OnClickBtn2_1")
  self:OnClose()
end

function UMG_StarChain_C:OnClickBtn3_1()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local SelectItem = self.data[self.SelectItemIndex]
  if SelectItem.ItemType == _G.Enum.ExchangeUseType.EUT_STAR_USE_ITEM then
    if SelectItem.ItemNum > 0 then
      _G.NRCModuleManager:DoCmd(_G.StarChainModuleCmd.SendExchangeReq, self.StarItem.numList[1], 1, 1, localPlayer.serverData.base.actor_id, self.ExchangeConf.cost_item[1].cost_goods_id)
    else
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_starchain_1)
    end
  elseif SelectItem.ItemType == _G.Enum.ExchangeUseType.EUT_STAR_USE_DIAMOND then
    Log.Debug(SelectItem.ItemNum, self.CostItemCount, "UMG_StarChain_C:OnClickBtn3_1")
    if self.RemainBuyDiamondCount > 0 then
      if SelectItem.ItemNum >= self.CostItemCount then
        _G.DataModelMgr.PlayerDataModel:SetBuyDiamondCount(self.BuyDiamondCount + 1)
        _G.NRCModuleManager:DoCmd(_G.StarChainModuleCmd.SendExchangeReq, self.ExchangeConf.id, 1, 1, localPlayer.serverData.base.actor_id, self.ExchangeConf.cost_item[1].cost_goods_id)
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_starchain_2)
      end
    else
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_starchain_3)
    end
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_StarChain_C:OnClickBtn3_1")
end

function UMG_StarChain_C:SelectItemChange(_index)
  self.SelectItemIndex = _index
  self:SetSelectInfo()
end

function UMG_StarChain_C:SetSelectInfo()
  local RoleGloBalConfig, Text
  local SelectItem = self.data[self.SelectItemIndex]
  if SelectItem.ItemType == _G.Enum.ExchangeUseType.EUT_STAR_USE_ITEM then
    RoleGloBalConfig = _G.DataConfigManager:GetRoleGlobalConfig("star_buytext_item")
    self.StarItem = _G.DataConfigManager:GetRoleGlobalConfig("star_item")
    self.ExchangeConf = _G.DataConfigManager:GetExchangeConf(self.StarItem.numList[1])
    Text = string.format(RoleGloBalConfig.str, 12)
  elseif SelectItem.ItemType == _G.Enum.ExchangeUseType.EUT_STAR_USE_DIAMOND then
    RoleGloBalConfig = _G.DataConfigManager:GetRoleGlobalConfig("star_buytext_diamond")
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
  end
  self.Text_Describe_2:SetText(Text)
end

function UMG_StarChain_C:SetBtnInfo()
  self.Btn2_1:SetBtnText(LuaText.umg_starchain_4)
  self.Btn3_1:SetBtnText(LuaText.umg_starchain_5)
end

function UMG_StarChain_C:OnAnimFinished(anim)
  if anim == self.open then
  elseif anim == self.close then
  end
end

return UMG_StarChain_C
