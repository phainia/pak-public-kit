local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local UMG_RandomStoreList_C = Base:Extend("UMG_RandomStoreList_C")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")

function UMG_RandomStoreList_C:OnConstruct()
  self.btnBuy:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:AddButtonListener(self.MagnificentMagic, self.OnClickMagnificentMagic)
  self.marqueeSpeed = 0.05
  self.startMarquee = false
  self.accumulateMoveWidth = 0.0
  self.bShouldEnableMarquee = false
  if self.ScrollBox_61 then
    self.ScrollBox_61:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.ScrollBox_61:SetScrollBarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ScrollBox_61:SetConsumeMouseWheel(UE4.EConsumeMouseWheel.Never)
  end
  _G.UpdateManager:Register(self)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.UpdateUI)
end

function UMG_RandomStoreList_C:OnDestruct()
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.UpdateUI)
  _G.UpdateManager:UnRegister(self)
  if self.DelayId then
    DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  if self.AnimDelayId then
    _G.DelayManager:CancelDelayById(self.AnimDelayId)
    self.AnimDelayId = nil
  end
end

function UMG_RandomStoreList_C:OnItemUpdate(_data, datalist, index)
  if self.CanvasPanel_0 then
    self.CanvasPanel_0:SetRenderOpacity(0)
  end
  self.Card:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.SuitName_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.SuitName_2:SetRenderOpacity(1)
  self.ReverseSide:SetVisibility(UE4.ESlateVisibility.Visible)
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.uiData = _data
  self.Index = index
  self:UpdateUI()
  self.DelayId = _G.DelayManager:DelaySeconds(0.05 * (self.Index - 1), function()
    self:PlayAnimation(self.In)
  end)
end

function UMG_RandomStoreList_C:OnActive()
  if self.Bg then
    self.Bg:SwitchToSetBrushFromMaterialInstanceMode(false)
    local Path = "Texture2D'/Game/NewRoco/Modules/System/Appearance/Raw/Monthly/Textures/img_xingxing1.img_xingxing1'"
    self.Bg:SetPath(Path)
  end
end

function UMG_RandomStoreList_C:OnDeactive()
end

function UMG_RandomStoreList_C:FindSGSuitId()
  local fashionGoodsConf = self.uiData and _G.DataConfigManager:GetNormalShopConf(self.uiData.shopItemId)
  local suitId = fashionGoodsConf and _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetSuitIdFromFashionId, fashionGoodsConf.item_id)
  return suitId
end

function UMG_RandomStoreList_C:UpdateUI()
  if self.uiData == nil then
    return
  end
  local myUIData = self.uiData
  local fashionGoodsConf = _G.DataConfigManager:GetNormalShopConf(myUIData.shopItemId)
  local shopConf = _G.DataConfigManager:GetShopConf(myUIData.shopId)
  if nil == fashionGoodsConf or nil == shopConf then
    Log.Error("\232\161\168\230\149\176\230\141\174\228\184\141\229\173\152\229\156\168", myUIData.shopLibId, myUIData.shopId, myUIData.shopItemId)
    return
  end
  Log.Dump(self.uiData, 3, "UMG_RandomStoreList_C:UpdateUI ST_FASHION_RANDOM goodsShopData")
  self.uiData.ShopType = shopConf.shop_type
  local bShowDiscount = false
  if nil ~= self.uiData.origin_price_num then
    bShowDiscount = self.uiData.origin_price_num ~= self.uiData.real_price_num
  end
  if shopConf.shop_type == Enum.ShopType.ST_FASHION_RANDOM then
    if nil ~= self.uiData.origin_price_num then
      self.Money_2:SetText(self.uiData.origin_price_num)
    end
    if nil ~= self.uiData.real_price_num then
      self.SuitName_1:SetText(self.uiData.real_price_num)
    end
    self.Money_2:SetText(self.uiData.origin_price_num)
    self.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SuitName_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Money_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SuitName_1:SetText(self.uiData.real_price_num)
    self.CrossOut:SetVisibility(bShowDiscount and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.DiscountedPrice:SetVisibility(bShowDiscount and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  elseif shopConf.shop_type == Enum.ShopType.ST_FASHION_DISCOUNT then
  else
    Log.Error("\229\149\134\229\147\129\230\137\128\229\156\168\229\149\134\229\159\142id\231\154\132\229\164\132\231\144\134\230\156\170\229\174\154\228\185\137", myUIData.shopLibId, myUIData.shopId)
  end
  local icon = NPCShopUtils:GetGoodsCurrencyIconPath(myUIData.shopId, myUIData.shopItemId)
  self.Gold_Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if icon then
    self.Gold_Icon:SetPath(icon)
  end
  local name = ""
  local cardFaceBgImage = ""
  local cardFaceIcon = ""
  local bHasOwned = false
  local goodsType = fashionGoodsConf.Type
  local ItemPartType = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetItemPartType, goodsType, fashionGoodsConf.item_id)
  if self.NRCSwitcher_57 then
    self.NRCSwitcher_57:SetActiveWidgetIndex(0)
  end
  if self.SuitIcon then
    self.SuitIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if goodsType == _G.Enum.GoodsType.GT_FASHION_SUITS then
    local suitConf = _G.DataConfigManager:GetFashionSuitsConf(fashionGoodsConf.item_id)
    if suitConf and suitConf.suit_grade and suitConf.suits_icon_big then
      cardFaceBgImage = self:GetSuitBandBgPath(suitConf)
      cardFaceIcon = suitConf.suits_icon_big
      name = suitConf.name
      bHasOwned = self:HasOwnedEntireSuit(suitConf)
      self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if suitConf.suit_grade == Enum.SuitGrade.SG_BOND or suitConf.suit_grade == Enum.SuitGrade.SG_UNIBOND or shopConf.shop_type == Enum.ShopType.ST_FASHION_RANDOM then
        local petBaseId
        if type(suitConf.petbase_id) == "table" and #suitConf.petbase_id > 0 then
          petBaseId = suitConf.petbase_id[1]
        end
        local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
        if petBaseConf then
          self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          local IconPath = string.format("%s%d.%d", _G.UIIconPath.BigHeadIconPath, petBaseId, petBaseId)
          self.PetHeadIcon:SetPath(IconPath)
        end
      end
      if self.Select then
        self.Select:SetVisibility(UE4.ESlateVisibility.Visible)
      end
      if self.SuitIcon then
        self.SuitIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  elseif goodsType == _G.Enum.GoodsType.GT_CARD_SKIN then
    local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(fashionGoodsConf.item_id)
    if cardSkinConf and cardSkinConf.card_quality and cardSkinConf.skin_resource_path then
      cardFaceBgImage = string.format(UEPath.FMT_FASHION_SHOP_CARD_FACE, cardSkinConf.card_quality - 2, cardSkinConf.card_quality - 2)
      cardFaceIcon = string.format(UEPath.CARD_SKIN_PATH, cardSkinConf.skin_resource_path, cardSkinConf.skin_resource_path)
      name = cardSkinConf.skin_resource_name
      bHasOwned = _G.NRCModuleManager:DoCmd(FriendModuleCmd.HasCardSkin, cardSkinConf.id)
      self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif goodsType == _G.Enum.GoodsType.GT_FASHION then
    local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(fashionGoodsConf.item_id)
    if fashionItemConf and fashionItemConf.item_quality and fashionItemConf.icon then
      cardFaceBgImage = self:GetFashionItemBandBgPath(fashionItemConf)
      cardFaceIcon = fashionItemConf.icon
      name = fashionItemConf.name
      bHasOwned = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.CheckHasOwned, _G.Enum.GoodsType.GT_FASHION, fashionGoodsConf.item_id)
      self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if fashionItemConf.type == Enum.FashionLabelType.FLT_PENDANTA or fashionItemConf.type == Enum.FashionLabelType.FLT_WAND then
        self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Visible)
        local suitId = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetSuitIdFromFashionId, fashionGoodsConf.item_id)
        self:SetFashionSuitPetHeadIcon(suitId)
      end
    end
    if self.NRCSwitcher_57 then
      self.NRCSwitcher_57:SetActiveWidgetIndex(1)
    end
  else
    Log.Error("\230\156\170\229\164\132\231\144\134\231\177\187\229\158\139", goodsType, myUIData.shopLibId)
  end
  self:SetSuitIcon(ItemPartType)
  if goodsType == _G.Enum.GoodsType.GT_FASHION_SUITS then
    self.Select:SetVisibility(UE4.ESlateVisibility.Visible)
    local Color = "#2f2f2eFF"
    self.SuitIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(Color))
  else
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local Color = "#929086FF"
    self.SuitIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(Color))
  end
  self.bHasOwned = bHasOwned
  self.SuitName:SetText(name)
  self.SuitQualityColor:SetPath(cardFaceBgImage)
  self.Protagonist_7:SetPath(cardFaceIcon)
  self.LocalAreaIcon:SetPath(cardFaceIcon)
  if bHasOwned then
    self.AlreadyOwned_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Money_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Gold_Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DiscountedPrice:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.AlreadyOwned_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Money_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Gold_Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.DiscountedPrice:SetVisibility(bShowDiscount and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.uiData.bHadRevealed then
    self.ReverseSide:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SuitName_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_32:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.HorizontalBox:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:CheckIfTextTooLong()
  else
    self.ReverseSide:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SuitName_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_32:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HorizontalBox:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local hasMoney = NPCShopUtils:GetGoodsCurrencyNum(myUIData.shopId, myUIData.shopItemId) or 0
  local costMoney = self.uiData.real_price_num
  local ColorString
  if hasMoney >= costMoney then
    ColorString = "#F4EEE1FF"
  else
    ColorString = "#C7494AFF"
  end
  self.Money_2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(ColorString))
end

function UMG_RandomStoreList_C:SetSuitIcon(ItemPartType)
  if ItemPartType ~= _G.Enum.FashionLabelType.FLT_BEGIN then
    local appearanceModule = NRCModuleManager:GetModule("AppearanceModule")
    local IconPath = appearanceModule.data:GetItemIconPathByItemType(ItemPartType)
    if nil ~= IconPath then
      self.SuitIcon:SetPath(IconPath)
    end
  end
end

function UMG_RandomStoreList_C:RevealCard()
  Log.Debug("UMG_RandomStoreList_C:RevealCard")
  _G.NRCAudioManager:PlaySound2DAuto(1220002026, "UMG_RandomStoreList_C:RevealCard")
  self.uiData.bHadRevealed = true
  self.ReverseSide:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SuitName_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_32:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.HorizontalBox:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local bShowDiscount = false
  if self.uiData.origin_price_num ~= nil then
    bShowDiscount = self.uiData.origin_price_num ~= self.uiData.real_price_num
  end
  if self.uiData.ShopType == Enum.ShopType.ST_FASHION_RANDOM then
    self.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SuitName_1:SetVisibility(bShowDiscount and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.CrossOut:SetVisibility(bShowDiscount and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.DiscountedPrice:SetVisibility(bShowDiscount and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  elseif self.uiData.ShopType == Enum.ShopType.ST_FASHION_DISCOUNT then
    self.SuitName_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.DiscountedPrice:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:PlayAnimation(self.Unlock)
  _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.AddCardHadRevealed, self.uiData.shopId, self.Index)
end

function UMG_RandomStoreList_C:HasOwnedEntireSuit(suitConf)
  local suitFashionIds = suitConf.item_id
  local appearanceModule = NRCModuleManager:GetModule("AppearanceModule")
  if suitFashionIds and #suitFashionIds > 0 then
    for k, v in ipairs(suitFashionIds) do
      local hasOwned = appearanceModule:OnCmdCheckHasOwned(_G.Enum.GoodsType.GT_FASHION, v)
      if not hasOwned then
        return false
      end
    end
  end
  return true
end

function UMG_RandomStoreList_C:OnItemSelected(bSelected)
  if not bSelected then
    return
  end
  local fashionGoodsConf = _G.DataConfigManager:GetNormalShopConf(self.uiData.shopItemId)
  if not fashionGoodsConf then
    return
  end
  local goodsType = fashionGoodsConf.Type
  if not self.uiData.bHadRevealed then
    _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_RandomStoreList_C:OnItemSelected")
    self:RevealCard()
    return
  end
  if self.bHasOwned then
    local itemId = fashionGoodsConf.item_id
    if goodsType == Enum.GoodsType.GT_CARD_SKIN then
      local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(itemId)
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
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, itemId, goodsType, false)
    end
  else
    self:OnClickBuy()
  end
end

function UMG_RandomStoreList_C:OnClickBuy()
  if self:CheckIfHasPanel("FashionBuyResultPopUp") then
    return
  end
  if self:CheckIfHasPanel("ShopCollectProgress") then
    return
  end
  if self.uiData == nil then
    return
  end
  if self.bHasOwned then
    local text = _G.DataConfigManager:GetLocalizationConf("fashion_shop_own_tips").msg
    if nil == text then
      text = "has owned"
    end
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, text)
    return
  end
  local fashionGoodsConf = _G.DataConfigManager:GetNormalShopConf(self.uiData.shopItemId)
  if nil == fashionGoodsConf then
    return
  end
  local hasMoney = NPCShopUtils:GetGoodsCurrencyNum(self.uiData.shopId, self.uiData.shopItemId) or 0
  local costMoney = self.uiData.real_price_num
  local CurrencyType, CurrencyId = NPCShopUtils:GetGoodsCurrencyTypeAndId(self.uiData.shopId, self.uiData.shopItemId)
  if not CurrencyType or not CurrencyId then
    Log.Warning("NPCShopUtils:GetGoodsCurrencyTypeAndId", "CurrencyType or CurrencyId not found", self.uiData.shopId, self.uiData.shopItemId)
    return
  end
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenFashionShopConfirm, self.uiData.shopId, {
    shopLibId = self.uiData.shopLibId,
    price_type = CurrencyId,
    price_num = self.uiData.real_price_num
  }, false, self.uiData.goodsExpireTime)
end

function UMG_RandomStoreList_C:OnClickMagnificentMagic()
  if self.uiData.shopItemId > 0 then
    local fashionGoodsConf = self.uiData and _G.DataConfigManager:GetNormalShopConf(self.uiData.shopItemId)
    local goodsType = fashionGoodsConf.Type
    local suitId = 0
    if goodsType == _G.Enum.GoodsType.GT_FASHION_SUITS then
      suitId = fashionGoodsConf.item_id
    end
    if goodsType == _G.Enum.GoodsType.GT_FASHION then
      suitId = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetSuitIdFromFashionId, fashionGoodsConf.item_id)
      local SuitItemConf = _G.DataConfigManager:GetFashionItemConf(fashionGoodsConf.item_id)
      if not SuitItemConf then
        return
      end
      if SuitItemConf.type == Enum.FashionLabelType.FLT_PENDANTA or SuitItemConf.type == Enum.FashionLabelType.FLT_WAND then
        return
      end
    end
    self:SendTLogMagicInteractionAction(suitId)
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenMagicVideoDetailsPanel, Enum.GoodsType.GT_FASHION_SUITS, suitId, {
      shopId = self.uiData.shopId
    })
  end
end

function UMG_RandomStoreList_C:SendTLogMagicInteractionAction(suitId)
  if not suitId then
    return
  end
  Log.Debug("UMG_RandomStoreList_C:SendTLogMagicInteractionAction", suitId)
  local key = "FashionMagicInteractionLog"
  local roleDataStr = _G.GEMPostManager:GetRoleDataForTLog()
  local value = string.format("%s|%s|%d|%d", key, roleDataStr, suitId, 0)
  _G.GEMPostManager:SendNRCTLog(key, value)
end

function UMG_RandomStoreList_C:SetFashionSuitPetHeadIcon(suitId)
  local suitConf = _G.DataConfigManager:GetFashionSuitsConf(suitId)
  if not suitConf then
    Log.Error("\230\137\190\228\184\141\229\136\176\229\165\151\232\163\133\233\133\141\231\189\174:", suitId)
    return
  end
  if suitConf.petbase_id and #suitConf.petbase_id > 0 then
    local petid = suitConf.petbase_id[1]
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(suitConf.petbase_id[1])
    local IconPath = string.format("%s%d.%d", _G.UIIconPath.BigHeadIconPath, petid, petid)
    if IconPath then
      if self.PetHeadIcon then
        self.PetHeadIcon:SetPath(IconPath)
        Log.Debug("\232\174\190\231\189\174\229\165\151\232\163\133\229\174\160\231\137\169\229\164\180\229\131\143:", suitConf.name, petBaseConf.name, IconPath)
      else
        Log.Warning("PetHeadIcon\231\187\132\228\187\182\228\184\141\229\173\152\229\156\168")
      end
    else
      Log.Error("\230\137\190\228\184\141\229\136\176petbase\233\133\141\231\189\174:", suitConf.petbase_id[1])
    end
  else
    Log.Debug("\229\165\151\232\163\133\230\178\161\230\156\137\229\175\185\229\186\148\231\154\132petbase_id:", suitId)
  end
end

function UMG_RandomStoreList_C:CheckIfTextTooLong()
  local textComp = self.SuitName
  if not textComp or not UE.UObject.IsValid(textComp) then
    return
  end
  local textContent = textComp:GetText()
  self.bShouldEnableMarquee = self:CalculateTextWidth(textComp, textContent)
end

function UMG_RandomStoreList_C:CalculateTextWidth(textComp, textContent)
  local textWidth = textComp:GetDesiredSize().X
  local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ScrollBox_61)
  if Slot then
    local scrollBoxWidth = Slot:GetSize().x
    if textWidth >= scrollBoxWidth then
      textComp:SetText(string.format("%s    %s    ", textContent, textContent))
      self.AnimDelayId = _G.DelayManager:DelayFrames(1, function()
        self.startMarquee = true
      end)
      return true
    end
  end
  return false
end

function UMG_RandomStoreList_C:OnTick(deltaTime)
  if self.bShouldEnableMarquee and self.startMarquee then
    local slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ScrollBox_61)
    if not slot then
      return
    end
    local scrollBoxWidth = slot:GetSize().x
    local contentWidth = self.SuitName:GetDesiredSize().X
    local ScollEnd = self.ScrollBox_61:GetScrollOffsetOfEnd()
    local totalScrollEnd = ScollEnd + scrollBoxWidth
    self.marqueeProgress = (self.marqueeProgress or 0) + (self.marqueeSpeed or 50) * deltaTime * totalScrollEnd
    local half = totalScrollEnd * 0.5
    if half < self.marqueeProgress then
      self.marqueeProgress = self.marqueeProgress - half
    end
    self.marqueeProgress = math.min(self.marqueeProgress, half)
    self.ScrollBox_61:SetScrollOffset(self.marqueeProgress)
  end
end

function UMG_RandomStoreList_C:OnAnimationFinished(Anim)
  Log.Debug("UMG_RandomStoreList_C:OnAnimationFinished", Anim)
  if Anim == self.Unlock then
    self:CheckIfTextTooLong()
  end
  if Anim == self.In and self.uiData.bHadRevealed then
    self:CheckIfTextTooLong()
  end
end

function UMG_RandomStoreList_C:GetSuitBandBgPath(suitConf)
  if not suitConf then
    Log.Error("\230\137\190\228\184\141\229\136\176suitConf\233\133\141\231\189\174:", suitConf.item_id)
    return nil
  end
  local suitQuality = suitConf.suit_grade
  local Quality = 3
  if suitQuality == Enum.SuitGrade.SG_DAILY then
    Quality = 3
  elseif suitQuality == Enum.SuitGrade.SG_UNIFORM or suitQuality == Enum.SuitGrade.SG_UNIBOND then
    Quality = 4
  elseif suitQuality == Enum.SuitGrade.SG_BOND then
    Quality = 5
  end
  local bond = suitConf.fashion_bond_band
  local Path = self:FormatFashionItemBandBgPath(Quality, bond)
  return Path
end

function UMG_RandomStoreList_C:FormatFashionItemBandBgPath(Quality, bond)
  local globalConf = _G.DataConfigManager:GetGlobalConfig("random_shop_band_bg_source")
  if not globalConf then
    Log.Error("\230\137\190\228\184\141\229\136\176globalConf\233\133\141\231\189\174:", "random_shop_band_bg_source")
    return nil
  end
  local bandBgSource = globalConf.str
  if not bandBgSource then
    Log.Error("\230\137\190\228\184\141\229\136\176bandBgSource\233\133\141\231\189\174:", "random_shop_band_bg_source")
    return nil
  end
  local Path = string.format(bandBgSource, Quality, bond, Quality, bond)
  return Path
end

function UMG_RandomStoreList_C:GetFashionItemBandBgPath(fashionItemConf)
  if not fashionItemConf then
    Log.Error("\230\137\190\228\184\141\229\136\176fashionItemConf\233\133\141\231\189\174:", fashionItemConf.item_id)
    return nil
  end
  local Quality = fashionItemConf.item_quality
  local bond = 1
  if fashionItemConf.suits_id ~= nil then
    local suitConf = _G.DataConfigManager:GetFashionSuitsConf(tonumber(fashionItemConf.suits_id))
    if suitConf then
      bond = suitConf.fashion_bond_band
    else
      Log.Error("\230\137\190\228\184\141\229\136\176suitConf\233\133\141\231\189\174:", fashionItemConf.suits_id)
      return nil
    end
  else
    bond = fashionItemConf.fashion_bond_band
  end
  local Path = self:FormatFashionItemBandBgPath(Quality, bond)
  return Path
end

function UMG_RandomStoreList_C:CheckIfHasPanel(panelName)
  local AppearanceModule = _G.NRCModuleManager:GetModule("AppearanceModule")
  if nil == AppearanceModule then
    return false
  end
  local bHasPanel = AppearanceModule:HasPanel(panelName)
  if bHasPanel then
    Log.Info("UMG_RandomStoreList_C: has panel ", panelName)
    return true
  end
  local IsOpening = AppearanceModule:IsPanelInOpening(panelName)
  if IsOpening then
    Log.Info("UMG_RandomStoreList_C:isopening panel ", panelName)
    return true
  end
  return false
end

return UMG_RandomStoreList_C
