local UMG_SellPlants_C = _G.NRCPanelBase:Extend("UMG_SellPlants_C")

function UMG_SellPlants_C:OnConstruct()
  self:SetChildViews(self.Small_PopUp3)
  self.IncomeText1:SetText(LuaText.plant_sell_confirm_bottom_text)
  self.uiData = {}
end

function UMG_SellPlants_C:OnDestruct()
end

function UMG_SellPlants_C:OnActive(shopId, itemDataArray, priceType, priceSum)
  self.uiData = {}
  if not (shopId and itemDataArray and priceType) or not priceSum then
    return
  end
  self:InitPopUpData()
  self.uiData.shopId = shopId
  self.uiData.itemDataArray = itemDataArray
  self.uiData.priceType = priceType
  self.uiData.priceSum = priceSum
  local rewardsTable = {}
  for k, v in ipairs(itemDataArray) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = _G.Enum.GoodsType.GT_BAGITEM
    rewards.itemId = v.itemId
    rewards.itemNum = v.selectedNum
    rewards.bShowNum = true
    rewards.bShowTip = true
    table.insert(rewardsTable, rewards)
  end
  self.View_Item:InitList(rewardsTable)
  local vItemConf = _G.DataConfigManager:GetVisualItemConf(self.uiData.priceType, true)
  if vItemConf then
    self.CurrencyIcon:SetPath(vItemConf.iconPath)
  end
  self.IncomeText:SetText(self.uiData.priceSum)
  self:LoadAnimation(0)
end

function UMG_SellPlants_C:OnDeactive()
end

function UMG_SellPlants_C:InitPopUpData()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = LuaText.plant_sell_confirm_title
  CommonPopUpData.Call = self
  CommonPopUpData.PopUpType = 1
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  CommonPopUpData.Btn_LeftHandler = self.OnClickCancelButton
  CommonPopUpData.Btn_RightHandler = self.OnClickConfirmButton
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.Small_PopUp3:SetPanelInfo(CommonPopUpData)
end

function UMG_SellPlants_C:ClosePanel()
  self:LoadAnimation(2)
end

function UMG_SellPlants_C:OnClickCancelButton()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_SellPlants_C:OnClickConfirmButton")
  self.Small_PopUp3:OnBtnClose()
end

function UMG_SellPlants_C:OnClickConfirmButton()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_SellPlants_C:OnClickConfirmButton")
  self:PreProcessSellingItem()
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.MallBuyItemReq, self.uiData.shopId, self.uiData.itemDataArray)
  self.Small_PopUp3:OnBtnClose()
end

function UMG_SellPlants_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(0) then
    local loopAnim = self:GetAnimByIndex(1)
    self:PlayAnimation(loopAnim, 0, 99999)
  elseif Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_SellPlants_C:PreProcessSellingItem()
  local shopConf = _G.DataConfigManager:GetShopConf(self.uiData.shopId, true)
  if not (shopConf and self.uiData) or not self.uiData.itemDataArray then
    return
  end
  local purchaseLimit = shopConf.purchase_limit
  if nil == purchaseLimit or 0 == purchaseLimit then
    local config = _G.DataConfigManager:GetPaymentGlobalConfig("buy_num_limit")
    if config and config.num then
      purchaseLimit = config.num
    end
  end
  if not purchaseLimit then
    return
  end
  local bReachLimit = false
  for idx, item in ipairs(self.uiData.itemDataArray) do
    if purchaseLimit < item.selectedNum then
      item.selectedNum = purchaseLimit
      bReachLimit = true
    end
  end
  if bReachLimit then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.home_plant_sell_over_limit, tostring(purchaseLimit)), nil, nil, 1)
  end
end

return UMG_SellPlants_C
