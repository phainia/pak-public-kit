local NPCShopUIModuleEvent = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local NPCActionOpenShop = require("NewRoco.Modules.Core.NPC.Actions.NPCActionOpenShop")
local UMG_NPCShop_Temp_C = _G.NRCPanelBase:Extend("UMG_NPCShop_Temp_C")
_G.NPCShopUIModuleCmd = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleCmd")

function UMG_NPCShop_Temp_C:OnConstruct()
  self.uiData = {}
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1069, "UMG_NPCShop_Temp_C:OnConstruct")
  self.World = _G.UE4Helper.GetCurrentWorld()
  self.curTime = _G.ZoneServer:GetServerTime()
  self.realTime = self:GetRealTime()
  self.moneyTeampTop = {
    self.UMG_MoneyTemplatetop,
    self.UMG_MoneyTemplatetop_1,
    self.UMG_MoneyTemplatetop_2
  }
  self.moneyTeampSumCost = {
    self.UMG_MoneyTemplateSumCost,
    self.UMG_MoneyTemplateSumCost_1,
    self.UMG_MoneyTemplateSumCost_2
  }
  self:OnAddEventListener()
  self:BtnInit()
end

function UMG_NPCShop_Temp_C:OnDestruct()
  self.uiData = nil
end

function UMG_NPCShop_Temp_C:SetItemList(List)
  if List and #List > 0 then
    for i = 1, #List do
      List[i].callbackCaller = self
      List[i].callbackFunc = self.OnListItemSelected
      List[i].callbackFuncClcikBtn = self.OnClickBtnSetListItemSelected
    end
    self.ItemList:InitList(List)
    self.data:InitItemData(List)
  else
    self.ItemList:Clear()
  end
end

function UMG_NPCShop_Temp_C:OnActive(_param, param, param1, ...)
  self:Log("UMG_NPCShop_Temp_C:OnActive:", _param, param, param1)
  self:PlayAnimation(self.open)
  self.data = self.module:GetData("NPCShopUIModuleData")
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerCameraManager = player:GetUEController().playerCameraManager
  local camera1 = _G.NRCModuleManager:DoCmd(DialogueModuleCmd.GetUICamera)
  local cameraTransform = playerCameraManager:Abs_GetTransform()
  if camera1 then
    cameraTransform = camera1:Abs_GetTransform()
  end
  self.uiData.itemList1 = _param
  self.uiData.shopId = param
  self.uiData.CoinCost = self.data.sumCoinCost
  self.uiData.DiamondCost = self.data.sumDiamondCost
  self:updatePanelInfo()
  local dTime = self:GetRealTime() - self.realTime
  local svrTime = self.curTime + dTime
  local deltaTime = param1 - svrTime
  self.uiData.deltaTime = deltaTime
  local ShopConf = _G.DataConfigManager:GetShopConf(self.uiData.shopId)
  if self.uiData.deltaTime > 0 then
    self.TimeCountDown:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NPCShopUITimer = _G.TimerManager:CreateTimer(self, "NPCShopUITimer", deltaTime, self.updateTimeCountDown, self.timeOutGetStoreListReq, 1)
  else
    self.TimeCountDown:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if #_param >= 1 then
    self:OnItemClick(1)
  else
  end
  self.NRCText_shopName:SetText(ShopConf.shop_name)
  self.UMG_CaptureBackground:StartCapture()
  UE4Helper.SetEnableWorldRendering(false)
end

function UMG_NPCShop_Temp_C:Tick(MyGeometry, InDeltaTime)
end

function UMG_NPCShop_Temp_C:GetRealTime()
  local realTime = UE4.UGameplayStatics.GetAccurateRealTime(self.World)
  return realTime
end

function UMG_NPCShop_Temp_C:RefreshNPCShopMainPanel(_param, param, param1, ...)
  self.data = self.module:GetData("NPCShopUIModuleData")
  self.uiData = {}
  self.data.itemData = {}
  self.data.costInfo = {
    0,
    0,
    0
  }
  self.data.sumCoinCost = 0
  self.data.sumDiamondCost = 0
  self:OnActive(_param, param, param1, ...)
end

function UMG_NPCShop_Temp_C:OnDeactive()
  if self.NPCShopUITimer ~= nil then
    self.NPCShopUITimer:Clear()
    _G.TimerManager:RemoveTimer(self.NPCShopUITimer)
  end
end

function UMG_NPCShop_Temp_C:updatePanelInfo()
  self:updateListInfo(self.uiData.itemList1)
  self:ShowMoney()
end

function UMG_NPCShop_Temp_C:updateTimeCountDown()
  self.uiData.deltaTime = self.uiData.deltaTime - 1
  if self.uiData.deltaTime > 0 then
    local days = math.floor(self.uiData.deltaTime / 60 / 60 / 24)
    local hours = math.floor((self.uiData.deltaTime - days * 24 * 3600) / 3600)
    local minutes = math.floor((self.uiData.deltaTime - days * 24 * 3600 - hours * 3600) / 60)
    local seconds = self.uiData.deltaTime - days * 24 * 3600 - hours * 3600 - minutes * 60
    self.TimeCountDown:SetText(LuaText.umg_npcshop_temp_1 .. days .. LuaText.umg_npcshop_temp_2 .. hours .. LuaText.umg_npcshop_temp_3 .. minutes .. LuaText.umg_npcshop_temp_4 .. seconds .. LuaText.umg_npcshop_temp_5)
  else
    self.TimeCountDown:SetText("")
  end
end

function UMG_NPCShop_Temp_C:timeOutGetStoreListReq()
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.GetStoreListReq, self.uiData.shopId)
end

function UMG_NPCShop_Temp_C:refreshShopList()
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.GetStoreListReq, self.uiData.shopId)
end

function UMG_NPCShop_Temp_C:ShowMoney()
  local showType = _G.DataConfigManager:GetShopConf(self.uiData.shopId)
  local showTypeNum = #showType.shop_currency_show
  local ShowSumMoneyInfo = {}
  local ShowCostMoneyInfo = {}
  local sumMoneyNum, costMoneyNum
  for i = 1, showTypeNum do
    if showType.shop_currency_show[i].currency_type == _G.Enum.ShopCurrencyType.SCT_VITEM then
      sumMoneyNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(showType.shop_currency_show[i].param)
      if nil ~= sumMoneyNum then
        sumMoneyNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(showType.shop_currency_show[i].param)
      else
        sumMoneyNum = 0
      end
    else
      local sumCost = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, showType.shop_currency_show[i].param)
      if nil ~= sumCost then
        sumMoneyNum = sumCost.num
      else
        sumMoneyNum = 0
      end
    end
    costMoneyNum = self.data.costInfo[i]
    table.insert(ShowSumMoneyInfo, {
      currencyType = showType.shop_currency_show[i].currency_type,
      currencyId = showType.shop_currency_show[i].param,
      num = sumMoneyNum,
      showColor = 0,
      showbg = true,
      bigIcon = true
    })
    table.insert(ShowCostMoneyInfo, {
      currencyType = showType.shop_currency_show[i].currency_type,
      currencyId = showType.shop_currency_show[i].param,
      num = costMoneyNum,
      showColor = 0,
      bigIcon = true
    })
  end
  self:ShowTopMoney(ShowCostMoneyInfo, self.moneyTeampSumCost)
  self:ShowTopMoney(ShowSumMoneyInfo, self.moneyTeampTop)
  self:ShowSelectAllNum()
end

function UMG_NPCShop_Temp_C:updateListInfo(_items)
  self:Log("updateListInfo:", _items)
  local itemListCount = _items and #_items or 0
  self.curSelectedIndex = 1
  self:SetItemList(_items)
  if #_items > 0 then
  end
end

function UMG_NPCShop_Temp_C:OnListItemSelected(item, index)
  self.curSelectedIndex = index
  self:getCurSelectItem()
end

function UMG_NPCShop_Temp_C:OnClickBtnSetListItemSelected(index)
  if self.curSelectedIndex ~= index then
  end
end

function UMG_NPCShop_Temp_C:getCurSelectItem()
  self:OnItemClick(self.curSelectedIndex)
end

function UMG_NPCShop_Temp_C:OnItemClick(index)
  local _itemId = self.uiData.itemList1[index].shopItemId
  self.uiData.itemList1[index].selectedState = true
  local goodsConf = _G.DataConfigManager:GetNormalShopConf(_itemId)
  if nil == goodsConf then
    return
  end
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(goodsConf.item_id)
  self.ItemName:SetText(goodsConf.goods_name)
  if bagItemConf.big_icon then
    self.HeadIcon:SetPath(bagItemConf.big_icon)
  end
  if self._itemId ~= _itemId then
    self.UMG_Common_BIconPar:CloseOpen()
    self._itemId = _itemId
  end
  local gainWayList = self:GetGaiWay(bagItemConf)
  self.ItemGainWay:InitGridView(gainWayList)
  self.ItemDesc:SetText(bagItemConf.description)
  self:getQuality(bagItemConf.item_quality)
  local itemData = NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, goodsConf.item_id)
  if nil ~= itemData then
    self.hasCount:SetText(itemData.num)
  else
    self.hasCount:SetText(0)
  end
end

function UMG_NPCShop_Temp_C:getQuality(quality)
  self.itemIconBG:SetVisibility(UE4.ESlateVisibility.Hidden)
  if 0 == quality then
    self.itemIconBG:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif 1 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_NPCShop_Temp_C:updateMoneyCost(_itemID, _selectedNum)
  self.data:ChangeItemNum(_itemID, _selectedNum, self.uiData.shopId)
end

function UMG_NPCShop_Temp_C:OnAddEventListener()
  self:AddButtonListener(self.Close.btnClose, self.OnCloseButtonClicked)
  self:AddButtonListener(self.UMG_Btn2.btnLevelUp, self.OnClearBtnClick)
  self:AddButtonListener(self.UMG_Btn3.btnLevelUp, self.OnBuyBtnClick)
  self:RegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_UI_REFRESH_MONEY_COST, self.updateMoneyCost)
  self:RegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_REFRESH_MAIN_PANEL, self.RefreshNPCShopMainPanel)
  self:RegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_GET_NPCACTION_OPENSHOP_INFO, self.OnNPCActionOpenShop)
  self:RegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_REFRESH_SUM_COST, self.OnRefreshSumCost)
  self:RegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_CLOSE, self.CloseNPCShop)
end

function UMG_NPCShop_Temp_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_UI_REFRESH_MONEY_COST)
  self:UnRegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_REFRESH_MAIN_PANEL)
  self:UnRegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_GET_NPCACTION_OPENSHOP_INFO)
  self:UnRegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_REFRESH_SUM_COST)
  self:UnRegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_CLOSE, self.CloseNPCShop)
end

function UMG_NPCShop_Temp_C:OnRefreshSumCost(cost)
  self:RefreshSumCost(cost)
  self:ShowMoney()
end

function UMG_NPCShop_Temp_C:OnNPCActionOpenShop(NPCActionInfo)
  self.uiData.npcaction = NPCActionInfo
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.GetStoreListReq, NPCActionInfo.Config.action_param1)
end

function UMG_NPCShop_Temp_C:OnCloseButtonClicked()
  UE4Helper.SetEnableWorldRendering(true)
  self:Log("UMG_NPCShop_Temp_C OnCloseButtonClicked")
  self:PlayAnimation(self.close_an)
end

function UMG_NPCShop_Temp_C:CloseNPCShop(shopId)
  if 101 ~= shopId and 102 ~= shopId then
    _G.DelayManager:DelaySeconds(1, function()
      self:ShopClose()
    end)
  end
end

function UMG_NPCShop_Temp_C:OnAnimationFinished(anim)
  self:Log("UMG_NPCShop_Temp_C OnAnimationFinished:", anim:GetName())
  if anim == self.close_an then
    self:ShopClose()
  end
end

function UMG_NPCShop_Temp_C:ShopClose()
  self.data.itemData = {}
  self.data.costInfo = {
    0,
    0,
    0
  }
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_NPCShop_Temp_C:OnCloseButtonClicked")
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerCameraManager = player:GetUEController().playerCameraManager
  UE4Helper.SetEnableWorldRendering(true)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_npcshop_temp_6)
  if self.data.NPCActionOpenShop ~= nil then
    self.data.NPCActionOpenShop:Finish()
  end
  self:DoClose()
end

function UMG_NPCShop_Temp_C:OnClearBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_NPCShop_Temp_C:OnClearBtnClick")
  for i = 1, #self.uiData.itemList1 do
    self.uiData.itemList1[i].selectedNum = 0
  end
  self.data.itemData = {}
  self.data.costInfo = {
    0,
    0,
    0
  }
  self:updatePanelInfo()
  self:RefreshSumCost(self.data.costInfo)
  self.data.sumCoinCost = 0
  self.data.sumDiamondCost = 0
  self.uiData.CoinCost = 0
  self.uiData.DiamondCost = 0
end

function UMG_NPCShop_Temp_C:RefreshSumCost(cost)
  for i = 1, #self.uiData.itemList1 do
    for j = 1, 3 do
      self.uiData.itemList1[i].showMoneyCost[j] = cost[j]
    end
  end
  local count = self.ItemList:GetItemCount()
  for i = 1, count do
  end
end

function UMG_NPCShop_Temp_C:OnBuyBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_NPCShop_Temp_C:OnBuyBtnClick")
  local buyItemCnt = 0
  for i = 1, #self.data.itemData do
    if 0 == self.data.itemData[i].itemNum then
    else
      buyItemCnt = buyItemCnt + 1
    end
  end
  if buyItemCnt > 0 then
    _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopConfirm, self.uiData, self.data)
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_npcshop_temp_7)
  end
end

function UMG_NPCShop_Temp_C:OnTitleBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1005, "UMG_NPCShop_Temp_C:OnTitleBtnClick")
end

function UMG_NPCShop_Temp_C:ShowSelectAllNum()
  local itemCnt = #self.data.itemData
  local num = 0
  if self.data.itemData then
    for i = 1, itemCnt do
      num = num + self.data.itemData[i].itemNum
    end
  end
  if num > 0 then
    self.NRCText_allnum:SetText(num)
    self.CanvasPanelBuyNum:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.CanvasPanelBuyNum:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_NPCShop_Temp_C:GetGaiWay(bagItemInfo)
  local real_acquire_struct = {}
  for i = 1, #bagItemInfo.acquire_struct do
    if bagItemInfo.acquire_struct[i].acquire_way_text == nil then
      goto lbl_40
    elseif 0 == bagItemInfo.acquire_struct[i].behavior_id then
      table.insert(real_acquire_struct, 1, {
        acquire_struct = bagItemInfo.acquire_struct[i]
      })
    else
      table.insert(real_acquire_struct, {
        acquire_struct = bagItemInfo.acquire_struct[i]
      })
    end
    ::lbl_40::
  end
  return real_acquire_struct
end

function UMG_NPCShop_Temp_C:ShowTopMoney(datas, umgs)
  for i = 1, #umgs do
    if i > #datas then
      umgs[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      umgs[i]:OnItemUpdate(datas[i])
      umgs[i]:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
end

function UMG_NPCShop_Temp_C:BtnInit()
  self.UMG_Btn2:SetBtnText(LuaText.umg_npcshop_temp_8)
  self.UMG_Btn3:SetBtnText(LuaText.umg_npcshop_temp_9)
  self.UMG_Btn2:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/ui_combtn_cancel_png.ui_combtn_cancel_png'")
  self.UMG_Btn3:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/ui_combtn_sure_png.ui_combtn_sure_png'")
end

return UMG_NPCShop_Temp_C
