local NPCShopUIModuleEvent = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local AppearanceModuleEnum = require("NewRoco.Modules.System.Appearance.AppearanceModuleEnum")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local UMG_NPCShopConfirmTicket_C = _G.NRCViewBase:Extend("UMG_NPCShopConfirmTicket_C")

function UMG_NPCShopConfirmTicket_C:OnConstruct()
  self.uiData = {}
end

function UMG_NPCShopConfirmTicket_C:OnDestruct()
end

function UMG_NPCShopConfirmTicket_C:OnActive(_param, _param1, _param2)
  if _param.isTryOnShop then
    Log.Error("\228\187\152\232\180\185\230\151\182\232\163\133\229\186\151\229\176\143\231\165\168\229\183\178\231\187\143\229\156\168UMG_Tryon_Buy_C\228\184\138\229\164\132\231\144\134\228\186\134\239\188\140\228\184\141\233\156\128\232\166\129\229\156\168UMG_NPCShopConfirmTicket_C\228\184\138\229\164\132\231\144\134")
  else
    self.ListSwitcher:SetActiveWidgetIndex(0)
    if _param1 then
      local NPCShopUIModule = _G.NRCModuleManager:GetModule("NPCShopUIModule")
      self.module = NPCShopUIModule
      self.data = self.module:GetData("NPCShopUIModuleData")
      self.uiData = _param
      self.uiData.itemList1 = _param.itemList1
      self.uiData.itemData = _param1
      local showItem = {}
      self.TotalCostGoodType = Enum.GoodsType.GT_NONE
      self.TotalCostGoodId = nil
      self.TotalCostGoodNum = 0
      for i = 1, #self.uiData.itemList1 do
        if self.uiData.itemList1[i].selectedNum > 0 then
          table.insert(showItem, self.uiData.itemList1[i])
          self.TotalCostGoodType, self.TotalCostGoodId = NPCShopUtils:GetGoodsCurrencyTypeAndId(self.uiData.itemList1[i].npcShopId, self.uiData.itemList1[i].shopItemId)
          self.TotalCostGoodNum = self.TotalCostGoodNum + self.uiData.itemList1[i].selectedNum * self.uiData.itemList1[i].priceNum
        end
      end
      self:SetDatas(showItem)
      self:UpdateCostInfo()
      local ShopConf = _G.DataConfigManager:GetShopConf(self.uiData.shopId)
      self.NRCText_shopName:SetText(ShopConf.shop_name)
      self.NRCText_location:SetText(ShopConf.shop_location)
      if ShopConf.checkout_icon then
        self.Img_Chuo:SetPath(ShopConf.checkout_icon)
      end
    elseif _param.IsTailorShop then
      self.uiData = _param
      self.uiData.itemList1 = _param.itemList1
      self:SetDatas(self.uiData.itemList1)
      self:UpdateCostInfo()
      local ShopConf = _G.DataConfigManager:GetShopConf(_param.shopId)
      self.NRCText_shopName:SetText(ShopConf.shop_name)
      self.NRCText_location:SetText(ShopConf.shop_location)
      if ShopConf.checkout_icon then
        self.Img_Chuo:SetPath(ShopConf.checkout_icon)
      end
    else
      self.uiData = _param[1]
      self.uiData.itemList1 = _param[1].itemList1
      self:SetDatas(self.uiData.itemList1)
      self:UpdateCostInfo()
      local ShopConf = _G.DataConfigManager:GetShopConf(101)
      self.NRCText_shopName:SetText(ShopConf.shop_name)
      self.NRCText_location:SetText(ShopConf.shop_location)
      if ShopConf.checkout_icon then
        self.Img_Chuo:SetPath(ShopConf.checkout_icon)
      end
    end
    local time = self:GetRealTime()
    self.NRCText_time:SetText(time)
    self.Img_Chuo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:OnAddEventListener()
end

function UMG_NPCShopConfirmTicket_C:OnDeactive()
end

function UMG_NPCShopConfirmTicket_C:SetDatas(List)
  if List and #List > 0 then
    self.ItemList:InitList(List)
  else
    self.ItemList:Clear()
  end
end

function UMG_NPCShopConfirmTicket_C:OnAddEventListener()
  self:AddButtonListener(self.TitleButton, self.OnBtnTitleClick)
  self:RegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_UI_BUY_ITEM_INFO, self.SetDatas)
end

function UMG_NPCShopConfirmTicket_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_UI_BUY_ITEM_INFO)
end

function UMG_NPCShopConfirmTicket_C:UpdateCostInfo()
  self:ShowMoney()
end

function UMG_NPCShopConfirmTicket_C:ShowMoney()
  local showType = _G.DataConfigManager:GetShopConf(self.uiData.shopId)
  local ShowCostMoneyInfo = {}
  if 101 == self.uiData.shopId and showType.goods then
    for i = 1, #showType.goods do
      table.insert(ShowCostMoneyInfo, {
        currencyType = showType.goods[i].goods_type,
        currencyId = showType.goods[i].goods_id,
        num = self.uiData.sumCost[i],
        showColor = 1
      })
    end
  elseif self.uiData.IsTailorShop then
    if self.uiData.itemList1 and #self.uiData.itemList1 > 0 then
      for idx, itemData in ipairs(self.uiData.itemList1) do
        if itemData.selectedNum > 0 then
          local costGoodType, costGoodId = NPCShopUtils:GetGoodsCurrencyTypeAndId(itemData.shopLibId, itemData.shopItemId)
          if costGoodType and costGoodId then
            table.insert(ShowCostMoneyInfo, {
              currencyType = costGoodType,
              currencyId = costGoodId,
              num = itemData.priceNum,
              showColor = 1
            })
            break
          end
        end
      end
    end
  elseif self.TotalCostGoodType and self.TotalCostGoodId and self.TotalCostGoodNum then
    table.insert(ShowCostMoneyInfo, {
      currencyType = self.TotalCostGoodType,
      currencyId = self.TotalCostGoodId,
      num = self.TotalCostGoodNum,
      showColor = 1
    })
  end
  self.CostMoney:InitGridView(ShowCostMoneyInfo)
end

function UMG_NPCShopConfirmTicket_C:OnBtnCancelClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_NPCShopConfirm_C:OnBtnCancelClick")
  NRCModuleManager:GetModule("NPCShopUIModule"):DispatchEvent(NPCShopUIModuleEvent.NPCSHOP_Cancel)
  NRCModuleManager:GetModule("AppearanceModule"):DispatchEvent(AppearanceModuleEvent.TailorShopCancelBuy)
end

function UMG_NPCShopConfirmTicket_C:OnBtnBuyClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_NPCShopConfirm_C:OnBtnBuyClick")
  self.CanvasPanelBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.CanvasPanelPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:Buy()
  self.panel.bIfNeedAppCloseConfirm = true
end

function UMG_NPCShopConfirmTicket_C:Buy()
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.MallBuyItemReq, self.uiData.shopId, self.uiData.itemList1)
end

function UMG_NPCShopConfirmTicket_C:OnBtnTitleClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1005, "UMG_NPCShopConfirm_C:OnBtnTitleClick")
end

function UMG_NPCShopConfirmTicket_C:PlayAnimationClose()
  self.Img_Chuo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.uiData.shopId ~= AppearanceModuleEnum.FashionMallShopId.RANDOM_FASHION then
    self:PlayAnimation(self.Close)
  end
end

function UMG_NPCShopConfirmTicket_C:OnAnimationFinished(anim)
  if anim == self.Close and not self.uiData.isTryOnShop then
    if self.panel then
      local shopId = self.uiData.shopId
      if 101 == shopId or 102 == shopId then
        self.panel.BuyBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.panel.CancelBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self.panel:PlayAnimation(self.panel.close)
    else
      self:DoClose()
    end
  end
end

function UMG_NPCShopConfirmTicket_C:GetRealTime()
  local sertime = _G.ZoneServer:GetServerTime()
  local strTime = os.date("%m.%d %H:%M:%S", math.floor(sertime / 1000))
  return strTime
end

return UMG_NPCShopConfirmTicket_C
