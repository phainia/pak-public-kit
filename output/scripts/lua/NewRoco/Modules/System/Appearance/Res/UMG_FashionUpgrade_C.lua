local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local UMG_FashionUpgrade_C = _G.NRCPanelBase:Extend("UMG_FashionUpgrade_C")

function UMG_FashionUpgrade_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
  self.data = self.module:GetData("AppearanceModuleData")
end

function UMG_FashionUpgrade_C:OnActive(showItemList)
  _G.NRCAudioManager:PlaySound2DAuto(1303, "UMG_FashionUpgrade_C:OnActive")
  Log.Dump(showItemList, 4, "UMG_FashionUpgrade_C:OnActive")
  self.showItemInfo = showItemList
  self:OnAddEventListener()
  self.curSelectIndex = 0
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.curUnlockIndex = 0
  self:DelayFrames(1, function()
    self:UpdatePanelInfo()
  end)
  self:SetCommonPopUpInfo(self.PopUp2)
  self.PopUp2:ShowOrHideBtnRight(false)
end

function UMG_FashionUpgrade_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancelBtnClicked
  CommonPopUpData.ClosePanelHandler = self.OnCancelBtnClicked
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_FashionUpgrade_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_FashionUpgrade_C:OnAddEventListener()
  self:AddButtonListener(self.Btn3.btnLevelUp, self.OnUpgradeBtnClicked)
  self:RegisterEvent(self, AppearanceModuleEvent.UpdateUpgradeMall, self.RefreshPanel)
end

function UMG_FashionUpgrade_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, AppearanceModuleEvent.UpdateUpgradeMall, self.RefreshPanel)
end

function UMG_FashionUpgrade_C:OnDestruct()
end

function UMG_FashionUpgrade_C:UpdatePanelInfo()
  self.data:SetHasItemList()
  self:SetBuyBtnState()
  self.NRCGridView_106:InitGridView(self.showItemInfo)
  for k, v in ipairs(self.showItemInfo) do
    if v.buy_num > 0 then
      self.curUnlockIndex = k
    end
  end
  local lvShowText = string.format("%d/%d", self.curUnlockIndex, #self.showItemInfo)
  self.SuitLvText:SetText(lvShowText)
  self:SetBtnVisible(false)
  self:SetSelect()
end

function UMG_FashionUpgrade_C:RefreshPanel(shopId, _rsp)
end

function UMG_FashionUpgrade_C:SetSelect()
  local selectIndex = 0
  if self.curUnlockIndex + 1 <= #self.showItemInfo then
    selectIndex = math.max(0, self.curUnlockIndex)
  else
    selectIndex = #self.showItemInfo - 1
  end
  self.showItemInfo[selectIndex + 1].skipClickSound = true
  self.NRCGridView_106:SelectItemByIndex(selectIndex)
end

function UMG_FashionUpgrade_C:OnCancelBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_FashionUpgrade_C:OnCancelBtnClicked")
  self:DoClose()
end

function UMG_FashionUpgrade_C:OnPcClose()
  self:OnCancelBtnClicked()
end

function UMG_FashionUpgrade_C:OnUpgradeBtnClicked()
  local selectInfo = self.showItemInfo[self.curSelectIndex]
  Log.Dump(selectInfo, 3, "UMG_FashionUpgrade_C:OnUpgradeBtnClicked")
  local buyItemTable = {}
  table.insert(buyItemTable, {
    shopLibId = selectInfo.goods_shop_id,
    selectedNum = 1
  })
  _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.MallBuyItemReq, 106, buyItemTable)
end

function UMG_FashionUpgrade_C:HasSuit(bOwned)
  if bOwned then
    self.Btn3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Btn3:SetClickAble(true)
    self.NotUpgradeable:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Btn3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NotUpgradeable:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Btn1:SetClickAble(false, true)
  end
end

function UMG_FashionUpgrade_C:SetBuyBtnState()
  if self.showItemInfo and #self.showItemInfo > 0 then
    if self.showItemInfo[1].goods_id then
      if self.data.lvUpGoodsIdToSuitIdMap[self.showItemInfo[1].goods_id] then
        local curSuitId = self.data.lvUpGoodsIdToSuitIdMap[self.showItemInfo[1].goods_id]
        local owned = false
        if curSuitId and self.module:CheckHasSuit(curSuitId) then
          owned = true
        end
        local unlockShowText = ""
        if true == owned then
          if self.curUnlockIndex + 1 < self.curSelectIndex then
            self.Btn3:SetVisibility(UE4.ESlateVisibility.Collapsed)
            self.NotUpgradeable:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            self.Btn1:SetClickAble(false, true)
            self.Btn1.TitleCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            self.Btn1.img_suo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            unlockShowText = string.format(string.format(_G.DataConfigManager:GetLocalizationConf("fashion_suits_lvup_text1").msg), self.curSelectIndex - 1)
            self.Btn1:SetTitleTextAndIcon(nil, nil, nil, nil, unlockShowText, nil)
            self.Btn1:SetTitleTextColor("AF3D3EFF")
            self.Btn1:SetBtnText("\230\156\170\232\167\163\233\148\129")
          elseif self.curUnlockIndex >= self.curSelectIndex then
            self.Btn3:SetVisibility(UE4.ESlateVisibility.Collapsed)
            self.NotUpgradeable:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            self.Btn1:SetClickAble(false, true)
            self.Btn1.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
            self.Btn1.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
            self.Btn1:SetTitleTextAndIcon()
            self.Btn1:SetBtnText("\229\183\178\232\167\163\233\148\129")
          else
            self.Btn3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            self.Btn3:SetClickAble(true)
            self.Btn3:SetBtnText("\229\141\135\231\186\167")
            self.NotUpgradeable:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
        else
          self.Btn3:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.NotUpgradeable:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.Btn1:SetClickAble(false, true)
          unlockShowText = string.format(_G.DataConfigManager:GetLocalizationConf("fashion_suits_lvup_text2").msg)
          self.Btn1:SetTitleTextAndIcon(nil, nil, nil, nil, unlockShowText, nil)
          self.Btn1:SetTitleTextColor("AF3D3EFF")
          self.Btn1:SetBtnText("\230\156\170\232\167\163\233\148\129")
        end
      else
        Log.Error("\229\175\185\229\186\148suit\232\161\168\231\154\132\229\141\135\231\186\167\229\165\151\232\163\133\230\156\170\233\133\141\231\189\174", self.showItemInfo[1].goods_id)
      end
    else
      Log.Error("\229\177\149\231\164\186\231\137\169\229\147\129\230\178\161\230\156\137goods id")
    end
  else
    Log.Error("\229\189\147\229\137\141\229\177\149\231\164\186\231\154\132\230\151\182\232\163\133\228\184\186\231\169\186")
  end
end

function UMG_FashionUpgrade_C:SelectUpgradeItem(index)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.DetailPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.curSelectIndex = index
  local selectInfo = self.showItemInfo[index]
  self:SetBuyBtnState()
  if not selectInfo then
    return
  end
  if selectInfo.buy_num > 0 then
    self.AlreadyOwned_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.AlreadyOwned_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local fashionGoodsConf = _G.DataConfigManager:GetNormalShopConf(selectInfo.goods_id)
  if fashionGoodsConf.Type == _G.Enum.GoodsType.GT_SALON then
    local salonItemConf = _G.DataConfigManager:GetSalonItemConf(fashionGoodsConf.item_id)
    self.Icon:SetPath(salonItemConf.icon)
    self.Name:SetText(salonItemConf.name)
    self.Selected:SetPath(AppearanceUtils.GetPIKAQualityPath(salonItemConf.item_quality))
  elseif fashionGoodsConf.Type == _G.Enum.GoodsType.GT_FASHION then
    local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(fashionGoodsConf.item_id)
    self.Icon:SetPath(fashionItemConf.icon)
    self.Name:SetText(fashionItemConf.name)
    self.Selected:SetPath(AppearanceUtils.GetPIKAQualityPath(fashionItemConf.item_quality))
  elseif fashionGoodsConf.Type == _G.Enum.GoodsType.GT_FASHION_SUITS then
    local fashionSuitConf = _G.DataConfigManager:GetFashionSuitsConf(fashionGoodsConf.item_id)
    self.Icon:SetPath(fashionSuitConf.suits_icon)
    self.Name:SetText(fashionSuitConf.name)
    self.Selected:SetPath(AppearanceUtils.GetPIKAQualityPath(AppearanceUtils.GetSuitQuality(fashionSuitConf.suit_grade)))
  elseif fashionGoodsConf.Type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(fashionGoodsConf.item_id)
    self.Icon:SetPath(bagItemConf.big_icon)
    self.Name:SetText(bagItemConf.name)
    self.Selected:SetPath(AppearanceUtils.GetPIKAQualityPath(bagItemConf.item_quality))
  end
  local desc = string.format(string.format(_G.DataConfigManager:GetLocalizationConf("fashion_suits_lvup_text3").msg), index)
  self.desc:SetText(desc)
  local costIcon = NPCShopUtils:GetGoodsCurrencyIconByType(fashionGoodsConf.price_goods_type, fashionGoodsConf.price_goods_id)
  self.CostIcon:SetPath(costIcon)
  local costNum = fashionGoodsConf.origin_price
  local hasCostMoney = NPCShopUtils:GetGoodsCurrencyNumByType(fashionGoodsConf.price_goods_type, fashionGoodsConf.price_goods_id)
  if costNum > hasCostMoney then
    self.CostNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("AF3D3EFF"))
  end
  self.CostNum:SetText(costNum)
end

function UMG_FashionUpgrade_C:SetBtnVisible(bVisible)
  if bVisible then
    self.Btn3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NotUpgradeable:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Btn3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NotUpgradeable:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_FashionUpgrade_C
