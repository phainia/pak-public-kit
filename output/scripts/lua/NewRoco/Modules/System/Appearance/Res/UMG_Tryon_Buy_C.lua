local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local AppearanceModuleEnum = require("NewRoco.Modules.System.Appearance.AppearanceModuleEnum")
local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_Tryon_Buy_C = _G.NRCPanelBase:Extend("UMG_Tryon_Buy_C")
local TicketType = {}
TicketType.None = 0
TicketType.Package = 1
TicketType.Suit = 2
TicketType.FashionInSuit = 3
TicketType.FashionNotSuit = 4
TicketType.TailorSuit = 5

function UMG_Tryon_Buy_C:OnConstruct()
  self:SetChildViews(self.Video, self.CardPreview, self.CardPreview_1, self.CardPreview_2)
  self:AddButtonListener(self.Btn_Close.btnClose, self.OnClickCloseButton)
  self:AddButtonListener(self.Play.btnLevelUp, self.OnPlayButtonClicked)
  self:AddButtonListener(self.Pause.btnLevelUp, self.OnPauseButtonClicked)
  self:AddButtonListener(self.Appearance_Btn6.btnLevelUp, self.OnClickBuyButton)
  self:AddButtonListener(self.HotArea, self.OnClickCancelButton)
  self:AddButtonListener(self.btn_PikaPoint, self.OnClickPikaPoint)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  NRCEventCenter:RegisterEvent("UMG_Tryon_Buy_C", self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:RegisterEvent("UMG_Tryon_Buy_C", self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
  self.uiData = {}
  self.videoControl = false
  self.fashionLabelSortTable = {}
  if self.NRCText then
    self.NRCText:SetText(LuaText.fashion_extra_credit)
  end
  self.Appearance_Btn6.Title_1:SetText(LuaText.fashion_package)
end

function UMG_Tryon_Buy_C:OnDestruct()
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
end

function UMG_Tryon_Buy_C:OnPcClose()
  self:OnClickCancelButton()
end

function UMG_Tryon_Buy_C:OnPlayerDataUpdate()
  self:RefreshMoneyList()
  self:UpdateBuyButtonColor()
end

function UMG_Tryon_Buy_C:OnBagChange()
  self:RefreshMoneyList()
  self:UpdateBuyButtonColor()
end

function UMG_Tryon_Buy_C:RefreshMoneyList()
  if self.MoneyBtn:GetItemCount() > 0 then
    for i = 1, self.MoneyBtn:GetItemCount() do
      self.MoneyBtn:GetItemByIndex(i - 1):RefreshMoneyNum()
    end
  end
end

function UMG_Tryon_Buy_C:OnActive(shopId, itemData, bFashionPackage, goodsExpireTime)
  self.Video:SetAutoPlay(true)
  self:SetBtnVisibility(true)
  self.Video:OnActive()
  self:BindInputAction()
  self.Video:AddOnEndReached(self, self.MovieDone)
  self.Video:AddOnSeekCompleted(self, self.MovieSeekCompleted)
  self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Appearance_Btn6:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.uiData = {}
  self.uiData.ShopId = shopId
  self.uiData.ItemData = itemData
  self:InitMoneyButton()
  local shopConf = DataConfigManager:GetShopConf(shopId)
  if nil == shopConf then
    return
  end
  self.goodsExpireTime = goodsExpireTime
  self.bFashionPackage = bFashionPackage
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetPanelMoneyBtnVisibleFlag, "AppearanceTryOn", "UMG_Tryon_Buy_C")
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetPanelMoneyBtnVisibleFlag, "SeasonalCombinationBagShop", "UMG_Tryon_Buy_C")
  local GoodsOriginPrice = 0
  local GoodsRealPrice = 0
  local packageData = _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetGoodsSeverData, self.uiData.ShopId, itemData.shopLibId)
  if packageData then
    GoodsOriginPrice = packageData.origin_price.num
    GoodsRealPrice = packageData.real_price.num
  else
    Log.Warning("UMG_Tryon_Buy_C:OnActive", "packageData is nil", self.uiData.ShopId, itemData.shopLibId)
  end
  self.uiData.GoodsCostMoneyCount = GoodsRealPrice
  self:UpdateUI()
  self:PlayAnimation(self.In)
  _G.NRCAudioManager:PlaySound2DAuto(1251, "UMG_Tryon_Buy_C:OnActive")
end

function UMG_Tryon_Buy_C:OnDeactive()
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetPanelMoneyBtnVisibleFlag, "AppearanceTryOn", "UMG_Tryon_Buy_C", true)
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetPanelMoneyBtnVisibleFlag, "SeasonalCombinationBagShop", "UMG_Tryon_Buy_C", true)
  self:UnBindInputAction()
  self.Video:RemoveOnEndReached(self, self.MovieDone)
  self.Video:RemoveOnSeekCompleted(self, self.MovieSeekCompleted)
  self.Video:OnDeactive()
end

function UMG_Tryon_Buy_C:SetGoodsCostInfo(costNum, vitemType)
end

function UMG_Tryon_Buy_C:OnClickCancelButton()
  Log.Debug("UMG_Tryon_Buy_C:OnClickCancelButton")
  if self:IsAnimationPlaying(self.Cancel) or self:IsAnimationPlaying(self.In) then
    return
  end
  self:PlayAnimation(self.Cancel)
  self:UnBindInputAction()
  self.Appearance_Btn6:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_Tryon_Buy_C:OnClickCancelButton")
end

function UMG_Tryon_Buy_C:OnClickBuyButton()
  Log.Debug("UMG_Tryon_Buy_C:OnClickBuyButton \232\191\155\229\133\165OnClickBuyButton\229\135\189\230\149\176")
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_FASHION_BUY, true)
  if isBan then
    return
  end
  if self.uiData.ItemData == nil then
    return
  end
  local goodsShopConf = DataConfigManager:GetNormalShopConf(self.uiData.ItemData.shopLibId)
  if nil == goodsShopConf then
    return
  end
  local fashionGoodsConf = DataConfigManager:GetNormalShopConf(self.uiData.ItemData.shopLibId)
  if nil == fashionGoodsConf then
    return
  end
  local serverTimestamp = ActivityUtils.GetSvrTimestamp()
  Log.Debug("UMG_Tryon_Buy_C:OnClickBuyButton", self.goodsExpireTime, serverTimestamp, self.uiData.ItemData.shopLibId)
  if self.goodsExpireTime and 0 ~= self.goodsExpireTime and serverTimestamp >= self.goodsExpireTime then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.fashionmall_expired)
    self:OnClickCancelButton()
    _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.CloseAppearanceTryOn)
    return
  end
  local hasMoney = NPCShopUtils:GetGoodsCurrencyNum(self.uiData.ShopId, self.uiData.ItemData.shopLibId) or 0
  local CurrencyType, CurrencyId = NPCShopUtils:GetGoodsCurrencyTypeAndId(self.uiData.ShopId, self.uiData.ItemData.shopLibId)
  local costMoney = self.uiData.GoodsCostMoneyCount
  if hasMoney < costMoney then
    if CurrencyType == Enum.GoodsType.GT_VITEM then
      if CurrencyId == Enum.VisualItem.VI_COUPON then
        _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.JudgeBuyCouponGiftItem, costMoney)
      elseif CurrencyId == Enum.VisualItem.VI_DIAMOND then
        _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.JudgeBuyDiamondGiftItem, costMoney)
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.fashionmall_no_enough_currency)
      end
    elseif CurrencyType == Enum.GoodsType.GT_BAGITEM then
      local allExchangeConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.EXCHANGE_CONF):GetAllDatas()
      local NeedExchangeConf
      for _, ExchangeConf in pairs(allExchangeConf) do
        if ExchangeConf.get_item and #ExchangeConf.get_item > 0 and ExchangeConf.get_item[1].get_goods_id == CurrencyId then
          NeedExchangeConf = ExchangeConf
          break
        end
      end
      if NeedExchangeConf then
        local MaxiItemCount = costMoney - hasMoney
        _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdOpenExchangePanel, NeedExchangeConf, MaxiItemCount, MaxiItemCount)
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.fashionmall_no_enough_currency)
      end
    end
  else
    local allBuyActionData = {}
    table.insert(allBuyActionData, {
      goodsType = fashionGoodsConf.Type,
      goodsId = self.uiData.ItemData.shopLibId,
      num = 1
    })
    self.module.data.bIsBuyItem = true
    _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.BuyFashions, self.uiData.ShopId, allBuyActionData)
    self.Appearance_Btn6:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Tryon_Buy_C:OnClickBuyButton")
  end
end

function UMG_Tryon_Buy_C:OnAnimationFinished(AnimationName)
  if AnimationName == self.Out or AnimationName == self.Cancel then
    if AnimationName == self.Out and self.CurrentTicketType ~= TicketType.TailorSuit then
      _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenFashionBuyResultPopUp)
    end
    self:DispatchEvent(AppearanceModuleEvent.OnTryOnBuyPanelClose)
    self:DoClose()
  elseif AnimationName == self.In and self.CurrentTicketType == TicketType.FashionInSuit then
    local widget = self.GridView_ClothingItem:GetItemByIndex(0)
    if widget and widget.StartPerform then
      widget:StartPerform()
    end
  end
end

function UMG_Tryon_Buy_C:OnBuySuccess()
  _G.NRCAudioManager:PlaySound2DAuto(40010011, "UMG_Tryon_Buy_C:OnBuySuccess")
  if self.uiData.ShopId ~= AppearanceModuleEnum.FashionMallShopId.RANDOM_FASHION then
    self.Img_Chuo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    _G.NRCAudioManager:PlaySound2DAuto(40006010, "UMG_Tryon_Buy_C:OnBuySuccess")
    _G.NRCAudioManager:PlaySound2DAuto(1253, "UMG_Tryon_Buy_C:OnBuySuccess")
    self:PlayAnimation(self.Out)
  else
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenFashionBuyResultPopUp)
    self:DoClose()
  end
end

function UMG_Tryon_Buy_C:OnBuyFail()
  self:OnClickCancelButton()
end

function UMG_Tryon_Buy_C:InitMoneyButton()
  local curShopId = 0
  if self.uiData == nil then
    return
  end
  if self.uiData.ShopId then
    curShopId = self.uiData.ShopId
  end
  local moneyInfo = {}
  local shopConf = _G.DataConfigManager:GetShopConf(curShopId)
  if shopConf and shopConf.goods then
    for idx, v in ipairs(shopConf.goods) do
      local bShowBuyIcon = false
      local costGoodType = v.goods_type
      local costGoodId = v.goods_id
      local ownNum = NPCShopUtils:GetGoodsCurrencyNumByType(costGoodType, costGoodId)
      if costGoodType == Enum.GoodsType.GT_VITEM then
        bShowBuyIcon = costGoodId == Enum.VisualItem.VI_COUPON or costGoodId == Enum.VisualItem.VI_DIAMOND or costGoodId == Enum.VisualItem.VI_PIKA_POINT
      end
      table.insert(moneyInfo, {
        currencyType = costGoodType,
        currencyId = v.goods_id,
        moneyType = costGoodType,
        sum = ownNum,
        IsShowBuyIcon = bShowBuyIcon
      })
    end
  end
  self.MoneyBtn:InitGridView(moneyInfo)
end

function UMG_Tryon_Buy_C:OnClickCloseButton()
  if self:IsAnimationPlaying(self.Cancel) or self:IsAnimationPlaying(self.In) then
    return
  end
  self:PlayAnimation(self.Cancel)
  self.Appearance_Btn6:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_Tryon_Buy_C:OnClickCloseButton")
end

function UMG_Tryon_Buy_C:UpdateUI()
  self.Img_Chuo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if not (self.uiData and self.uiData.ShopId and self.uiData.ItemData) or not self.uiData.ItemData.shopLibId then
    return
  end
  local shopId = self.uiData.ShopId
  local shopLibId = self.uiData.ItemData.shopLibId
  local packageGoodsData = _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetGoodsSeverData, shopId, shopLibId)
  if not packageGoodsData then
    return
  end
  local normalShopConf = _G.DataConfigManager:GetNormalShopConf(shopLibId, true)
  if not (normalShopConf and normalShopConf.Type) or not normalShopConf.item_id then
    return
  end
  local goodsType = normalShopConf.Type
  local itemId = normalShopConf.item_id
  self.videoControl = false
  self.Appearance_Btn6.Title_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Appearance_Btn6:ResetButtonDiscountState()
  if goodsType == Enum.GoodsType.GT_FASHION_PACKAGE then
    self.CurrentTicketType = TicketType.Package
    self:UpdateUI_Package(shopId, shopLibId, itemId)
    self.Appearance_Btn6.Title_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif goodsType == Enum.GoodsType.GT_FASHION_SUITS then
    local shopConf = _G.DataConfigManager:GetShopConf(shopId)
    if not shopConf then
      Log.Error("\229\149\134\229\147\129\230\156\137\233\151\174\233\162\152\239\188\140\229\175\185\229\186\148\231\154\132\229\149\134\229\186\151id\230\137\190\228\184\141\229\136\176shopConf")
      return
    end
    if shopConf.shop_type == _G.Enum.ShopType.ST_FASHION_TAILOR then
      self.CurrentTicketType = TicketType.TailorSuit
      self:UpdateUI_TailorInSuit(shopId, shopLibId, itemId)
    else
      self.CurrentTicketType = TicketType.Suit
      self:UpdateUI_Suit(shopId, shopLibId, itemId)
    end
  elseif goodsType == Enum.GoodsType.GT_FASHION then
    local suitId = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetSuitIdFromFashionId, normalShopConf.item_id)
    if suitId then
      self.CurrentTicketType = TicketType.FashionInSuit
      self:UpdateUI_FashionInSuit(shopId, shopLibId, itemId, suitId)
    else
      self.CurrentTicketType = TicketType.FashionNotSuit
      self:UpdateUI_FashionNotSuit(shopId, shopLibId, itemId)
    end
  else
    Log.Error("UMG_Tryon_Buy_C:UpdateUI \230\156\170\229\174\154\228\185\137\231\177\187\229\158\139\229\164\132\231\144\134", shopId, shopLibId, goodsType, itemId)
  end
  local iconPath = NPCShopUtils:GetGoodsCurrencyIconPath(shopId, shopLibId)
  if not iconPath then
    Log.Warning("UMG_Tryon_Buy_C:UpdateUI", "iconPath not found", shopId, shopLibId)
    return
  end
  local vitemPrice = packageGoodsData.real_price.num
  self.PriceNum = vitemPrice
  self.Appearance_Btn6:SetAppearanceButtonContext(iconPath, vitemPrice, 0)
  self:UpdateBuyButtonColor()
end

function UMG_Tryon_Buy_C:UpdateUI_Package(shopId, shopLibId)
  self.NRCSwitcher_1:SetActiveWidgetIndex(0)
  local normalShopConf = _G.DataConfigManager:GetNormalShopConf(shopLibId)
  if nil == normalShopConf then
    return
  end
  local itemId = normalShopConf.item_id
  local fashionPackageConf = _G.DataConfigManager:GetFashionPackageConf(itemId)
  if not fashionPackageConf then
    return
  end
  local packageGoodsData = _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetGoodsSeverData, shopId, shopLibId)
  local PackageContentItemArray = {}
  if fashionPackageConf and packageGoodsData and normalShopConf and packageGoodsData.sub_goods then
    for idx, subGoodsData in ipairs(packageGoodsData.sub_goods) do
      local subGoodsId = subGoodsData and subGoodsData.goods_id
      local conf = _G.DataConfigManager:GetNormalShopConf(subGoodsId, true)
      if conf and conf.Type ~= Enum.GoodsType.GT_VITEM then
        local bIsFree = subGoodsData.is_gift
        local PackageContentItem = {
          ShopId = shopId,
          Id = conf.id,
          GoodsType = conf.Type,
          ItemId = conf.item_id,
          bIsFree = bIsFree,
          GoodsShopId = conf.id,
          packageGoodsId = shopLibId,
          CallbackCaller = self,
          CallbackFunc = self.OnClickItem
        }
        table.insert(PackageContentItemArray, PackageContentItem)
      end
    end
  end
  table.sort(PackageContentItemArray, function(a, b)
    local goodsTypeA = a.GoodsType or Enum.GoodsType.GT_NONE
    local goodsTypeB = b.GoodsType or Enum.GoodsType.GT_NONE
    if goodsTypeA == goodsTypeB and goodsTypeA == _G.Enum.GoodsType.GT_FASHION then
      local fashionItemConfA = _G.DataConfigManager:GetFashionItemConf(a and a.data and a.data.item_id, true)
      local fashionItemConfB = _G.DataConfigManager:GetFashionItemConf(b and b.data and b.data.item_id, true)
      local fashionTypeA = fashionItemConfA and fashionItemConfA.type or _G.Enum.FashionLabelType.FLT_BEGIN
      local fashionTypeB = fashionItemConfB and fashionItemConfB.type or _G.Enum.FashionLabelType.FLT_BEGIN
      return (AppearanceModuleEnum.Sort_fashionTypePriority[fashionTypeA] or math.maxinteger) < (AppearanceModuleEnum.Sort_fashionTypePriority[fashionTypeB] or math.maxinteger)
    elseif goodsTypeA and goodsTypeB then
      return (AppearanceModuleEnum.Sort_typeToPriority[goodsTypeA] or math.maxinteger) < (AppearanceModuleEnum.Sort_typeToPriority[goodsTypeB] or math.maxinteger)
    else
      return nil ~= goodsTypeA
    end
  end)
  self.NRCGridView_58:InitGridView(PackageContentItemArray)
  local packagePrice, packageFreePrice, bHadOwnEntirePackage, AvailablePikaPointInPackageContent = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CalcFashionPackagePrice, itemId, packageGoodsData.real_price, shopId, shopLibId)
  self.NumberText:SetText("x" .. AvailablePikaPointInPackageContent)
  self.Appearance_Btn6:SetDiscount(packageFreePrice)
  self.NRCImage_185:SetPath(fashionPackageConf.kv_receipt)
end

function UMG_Tryon_Buy_C:UpdateUI_Suit(shopId, shopLibId, itemId)
  self.NRCSwitcher_1:SetActiveWidgetIndex(2)
  self.CardPreview_1:SetData(Enum.GoodsType.GT_FASHION_SUITS, itemId)
  local shopConf = _G.DataConfigManager:GetShopConf(shopId, true)
  local shopType = shopConf and shopConf.shop_type
  local packageGoodsData = _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetGoodsSeverData, shopId, shopLibId)
  local fashionItemDataArray = {}
  local moneyAmountHadOwned = 0
  if packageGoodsData and packageGoodsData.sub_goods then
    for idx, subGoodsData in ipairs(packageGoodsData.sub_goods) do
      local DontShow = shopType == Enum.ShopType.ST_FASHION_RANDOM and subGoodsData.is_gift
      if not DontShow then
        local subGoodsId = subGoodsData and subGoodsData.goods_id
        local conf = _G.DataConfigManager:GetNormalShopConf(subGoodsId, true)
        local bIsFree = subGoodsData.is_gift
        if conf and conf.Type == Enum.GoodsType.GT_FASHION then
          local bHasOwned = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.CheckHasOwned, _G.Enum.GoodsType.GT_FASHION, conf.item_id)
          if bHasOwned then
            moneyAmountHadOwned = moneyAmountHadOwned + subGoodsData.real_price.num
          end
          local PackageContentItem = {
            ShopId = shopId,
            Id = conf.id,
            GoodsType = conf.Type,
            ItemId = conf.item_id,
            bIsFree = bIsFree,
            GoodsShopId = conf.id,
            packageGoodsId = shopLibId,
            bHasOwned = bHasOwned
          }
          table.insert(fashionItemDataArray, PackageContentItem)
        end
      end
    end
  end
  table.sort(fashionItemDataArray, function(a, b)
    if a.bHasOwned ~= b.bHasOwned then
      return b.bHasOwned
    else
      local fashionItemConfA = _G.DataConfigManager:GetFashionItemConf(a.ItemId, true)
      local fashionItemConfB = _G.DataConfigManager:GetFashionItemConf(b.ItemId, true)
      local fashionItemTypeA = fashionItemConfA and fashionItemConfA.type
      local fashionItemTypeB = fashionItemConfB and fashionItemConfB.type
      return AppearanceUtils.GetFashionLabelSortPriority(fashionItemTypeA, self.fashionLabelSortTable) < AppearanceUtils.GetFashionLabelSortPriority(fashionItemTypeB, self.fashionLabelSortTable)
    end
  end)
  local extraPikaPoint = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CalcPikaPoint, shopId, shopLibId) or 0
  if extraPikaPoint > 0 then
    table.insert(fashionItemDataArray, 1, {
      ShopId = shopId,
      bFakeExtraPikaPoint = true,
      GoodsType = _G.Enum.GoodsType.GT_VITEM,
      ItemId = _G.ProtoEnum.VisualItem.VI_PIKA_POINT,
      vItemType = _G.ProtoEnum.VisualItem.VI_PIKA_POINT,
      vItemPrice = extraPikaPoint,
      bIsFree = true,
      CallbackCaller = self,
      CallbackFunc = self.OnClickItem
    })
  end
  self.NRCGridView:InitGridView(fashionItemDataArray)
  if shopType == Enum.ShopType.ST_FASHION_RANDOM and 0 ~= moneyAmountHadOwned then
    self.CostSumPanel_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.DeductionText:SetText("- " .. tostring(moneyAmountHadOwned))
  else
    self.CostSumPanel_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Tryon_Buy_C:UpdateUI_FashionInSuit(shopId, shopLibId, itemId, suitId)
  self.NRCSwitcher_1:SetActiveWidgetIndex(3)
  self.CardPreview_2:SetData(Enum.GoodsType.GT_FASHION_SUITS, suitId)
  local fashionSuitConf = _G.DataConfigManager:GetFashionSuitsConf(suitId, true)
  if not fashionSuitConf then
    return
  end
  local fashionItemDataArray = {}
  local ownedNum = 0
  for idx, fashionItemId in ipairs(fashionSuitConf.item_id) do
    local bHasOwned = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CheckHasOwned, _G.Enum.GoodsType.GT_FASHION, fashionItemId)
    local bPendingPurchase = fashionItemId == itemId
    local color = "ffffffff"
    local greyColor = "e1dcd0ff"
    if bHasOwned or bPendingPurchase then
      if fashionSuitConf.suit_grade == Enum.SuitGrade.SG_DAILY then
        color = "5fb5d5ff"
      elseif fashionSuitConf.suit_grade == Enum.SuitGrade.SG_UNIFORM or fashionSuitConf.suit_grade == Enum.SuitGrade.SG_UNIBOND then
        color = "9b73f8ff"
      elseif fashionSuitConf.suit_grade == Enum.SuitGrade.SG_BOND then
        color = "f8a955ff"
      end
    else
      color = greyColor
    end
    table.insert(fashionItemDataArray, {
      ItemId = fashionItemId,
      bPendingPurchase = bPendingPurchase,
      bHasOwned = bHasOwned,
      SuitId = suitId,
      Color = color,
      GreyColor = greyColor
    })
    if bHasOwned then
      ownedNum = ownedNum + 1
    end
    if fashionItemId == itemId then
      local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(fashionItemId, true)
      if fashionItemConf then
        self.NRCImage_10:SetPath(fashionItemConf.icon)
        self.ItemName:SetText(fashionItemConf.name)
      end
    end
  end
  table.sort(fashionItemDataArray, function(a, b)
    if a.bPendingPurchase or b.bPendingPurchase then
      return a.bPendingPurchase
    end
    if a.bHasOwned ~= b.bHasOwned then
      return a.bHasOwned
    else
      local fashionItemConfA = _G.DataConfigManager:GetFashionItemConf(a.ItemId, true)
      local fashionItemConfB = _G.DataConfigManager:GetFashionItemConf(b.ItemId, true)
      local fashionItemTypeA = fashionItemConfA and fashionItemConfA.type
      local fashionItemTypeB = fashionItemConfB and fashionItemConfB.type
      return AppearanceUtils.GetFashionLabelSortPriority(fashionItemTypeA, self.fashionLabelSortTable) < AppearanceUtils.GetFashionLabelSortPriority(fashionItemTypeB, self.fashionLabelSortTable)
    end
  end)
  self.GridView_ClothingItem:InitGridView(fashionItemDataArray)
  self.CollectionQuantityText:SetText(string.format("%d/%d", ownedNum, #fashionSuitConf.item_id))
end

function UMG_Tryon_Buy_C:UpdateUI_FashionNotSuit(shopId, shopLibId, itemId)
  self.NRCSwitcher_1:SetActiveWidgetIndex(1)
  self.videoControl = true
  self.CardPreview:SetData(Enum.GoodsType.GT_FASHION, itemId)
  local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(itemId, true)
  if not fashionItemConf then
    return
  end
  local fashionItemType = fashionItemConf.type
  if fashionItemType == Enum.FashionLabelType.FLT_PENDANTA then
    local bagCharmConf = _G.DataConfigManager:GetFashionBagcharmConf(itemId, true)
    if not bagCharmConf then
      return
    end
    self.ContentText:SetText(bagCharmConf.details_text)
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local gender = Enum.ESexValue.SEX_MALE
    if localPlayer then
      gender = localPlayer.gender
    end
    local videoPath
    if gender == Enum.ESexValue.SEX_MALE then
      videoPath = bagCharmConf.charm_video_male
    else
      videoPath = bagCharmConf.charm_video_female
    end
    self.Video:CloseMedia()
    local paramTable = {
      source = videoPath,
      needAutoPlay = true,
      isLoop = false
    }
    self.Video:OpenMediaPanelByParamTable(paramTable)
    if bagCharmConf.charm_kind == Enum.BagCharm.BGC_PETCHARM then
      self.NRCImage_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCImage_4:SetPath(UEPath.BagCharmShakeHandIcon)
    else
      self.NRCImage_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.TitleText:SetText(bagCharmConf.kind_name)
  elseif fashionItemType == Enum.FashionLabelType.FLT_WAND then
    local fashionWandConf = _G.DataConfigManager:GetFashionWandConf(itemId, true)
    if not fashionWandConf then
      return
    end
    self.ContentText:SetText(fashionWandConf.wand_tips_text)
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local gender = Enum.ESexValue.SEX_MALE
    if localPlayer then
      gender = localPlayer.gender
    end
    local videoPath
    if gender == Enum.ESexValue.SEX_MALE then
      videoPath = fashionWandConf.wand_video_male
    else
      videoPath = fashionWandConf.wand_video_female
    end
    self.Video:CloseMedia()
    local paramTable = {
      source = videoPath,
      needAutoPlay = true,
      isLoop = false
    }
    self.Video:OpenMediaPanelByParamTable(paramTable)
    if fashionWandConf.magic_icon then
      self.NRCImage_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCImage_4:SetPath(fashionWandConf.magic_icon)
    else
      self.NRCImage_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.TitleText:SetText(fashionWandConf.magic_name)
  else
    Log.Error("UMG_Tryon_Buy_C:UpdateUI_FashionNotSuit \230\156\170\229\174\154\228\185\137\231\177\187\229\158\139\229\164\132\231\144\134", shopId, shopLibId, itemId)
  end
end

function UMG_Tryon_Buy_C:UpdateUI_TailorInSuit(shopId, sgopLibId, itemId)
  self.NRCSwitcher_1:SetActiveWidgetIndex(4)
  self.CardPreview_3:SetData(_G.Enum.GoodsType.GT_FASHION_SUITS, itemId)
  local suitConf = _G.DataConfigManager:GetFashionSuitsConf(itemId)
  if suitConf then
    self.Describe_34:SetText(suitConf.flavor_text)
    local initList = {}
    local fashionOwned, fashionNotOwned = self.module.data:GetFashionOwnedBySuitId(itemId)
    local giftItemList = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetSuitGiftFashion, itemId)
    for k, v in ipairs(fashionOwned) do
      table.insert(initList, {
        itemId = v,
        bOwned = true,
        bIsGift = false,
        bIsInTailorShop = false
      })
    end
    for k, v in ipairs(fashionNotOwned) do
      table.insert(initList, {
        itemId = v,
        bOwned = false,
        bIsGift = false,
        bIsInTailorShop = false
      })
    end
    for k, v in ipairs(giftItemList) do
      local shopConf = _G.DataConfigManager:GetNormalShopConf(v)
      if shopConf then
        local bOwned = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CheckHasOwned, shopConf.Type, shopConf.item_id)
        table.insert(initList, {
          itemId = shopConf.item_id,
          bOwned = bOwned,
          bIsGift = true,
          bIsInTailorShop = false
        })
      end
    end
    self.GridView_ModelClothes:InitGridView(initList)
    local totalDiscount = 0
    local normalShopConf = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetNormalShopConfBySuitId, itemId)
    if normalShopConf then
      local goodsData = _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OnCmdGetGoodsSeverData, shopId, normalShopConf.id)
      if goodsData then
        totalDiscount = goodsData.origin_price.num - goodsData.real_price.num
      end
    end
    if 0 == totalDiscount then
      self.CostSumPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.DeductionText_1:SetText("0")
    else
      self.CostSumPanel_1:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.DeductionText_1:SetText(string.format("-%s", totalDiscount))
    end
  end
end

function UMG_Tryon_Buy_C:OnClickItem(itemData, itemIndex)
  if not (itemData and itemData.GoodsType and itemData.ItemId) or not itemIndex then
    return
  end
  if itemData.GoodsType == Enum.GoodsType.GT_CARD_SKIN then
    local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(itemData.ItemId)
    if cardSkinConf then
      local playerGender = Enum.ESexValue.SEX_MALE
      local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
      if localPlayer then
        playerGender = localPlayer.gender
      end
      local context = {
        bIsNameCard = true,
        gender = playerGender,
        desc = _G.LuaText.popup_card_details,
        nameCardPanelBackground = string.format(_G.UEPath.CARD_COMMON_PATH, cardSkinConf.skin_resource_path, "Fram", cardSkinConf.skin_resource_path, "Fram")
      }
      _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenCardSkinDetailPanel, context)
    end
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, itemData.ItemId, itemData.GoodsType, false)
  end
end

function UMG_Tryon_Buy_C:MovieDone()
  self.Video:Seek(UE.UKismetMathLibrary.FromSeconds(0))
end

function UMG_Tryon_Buy_C:MovieSeekCompleted()
  self.Video:Pause()
  self:SetBtnVisibility(false)
end

function UMG_Tryon_Buy_C:OnPlayButtonClicked(bIgnoreUIPerform)
  if not bIgnoreUIPerform then
    _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MagnificentMagic_C:OnPlayButtonClicked")
  end
  self:SetBtnVisibility(true)
  self.Video:Play()
end

function UMG_Tryon_Buy_C:OnPauseButtonClicked(bIgnoreUIPerform)
  if not bIgnoreUIPerform then
    _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MagnificentMagic_C:OnPauseButtonClicked")
  end
  self:SetBtnVisibility(false)
  self.Video:Pause()
end

function UMG_Tryon_Buy_C:OnVideoPlayOrPause()
  if not self.videoControl then
    return
  end
  if self.Video.MediaPlayer:IsPlaying() then
    self:OnPauseButtonClicked()
  else
    self:OnPlayButtonClicked()
  end
end

function UMG_Tryon_Buy_C:SetBtnVisibility(bPlay)
  if bPlay then
    self.Pause:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Play:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Pause:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Play:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Tryon_Buy_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_TryOnBuy")
  if mappingContext then
    mappingContext:BindAction("IA_ToggleVideoPlayState", self, "OnVideoPlayOrPause", UE.ETriggerEvent.Triggered)
  end
end

function UMG_Tryon_Buy_C:UnBindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_TryOnBuy")
  if mappingContext then
    mappingContext:UnBindAction("IA_ToggleVideoPlayState")
  end
end

function UMG_Tryon_Buy_C:UpdateBuyButtonColor()
  if not (self.uiData and self.uiData.ItemData) or not self.PriceNum then
    return
  end
  local hasCostMoney = NPCShopUtils:GetGoodsCurrencyNum(self.uiData.ShopId, self.uiData.ItemData.shopLibId) or 0
  if hasCostMoney >= self.PriceNum then
    self.Appearance_Btn6:SetQuantityTextColor("050505FF")
  else
    self.Appearance_Btn6:SetQuantityTextColor("C7494AFF")
  end
end

function UMG_Tryon_Buy_C:OnClickPikaPoint()
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, Enum.VisualItem.VI_PIKA_POINT, Enum.GoodsType.GT_VITEM)
end

function UMG_Tryon_Buy_C:OnFoldCollapsed()
  if self.videoControl then
    self:OnPauseButtonClicked(true)
  end
end

function UMG_Tryon_Buy_C:OnUnDoFoldCollapsed()
  if self.videoControl then
    self:OnPlayButtonClicked(true)
  end
end

return UMG_Tryon_Buy_C
