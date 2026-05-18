local UMG_CardPreview_C = _G.NRCPanelBase:Extend("UMG_CardPreview_C")

function UMG_CardPreview_C:OnConstruct()
  self.marqueeSpeed = 0.05
  self.startMarquee = false
  self.accumulateMoveWidth = 0.0
  self.bShouldEnableMarquee = false
  _G.UpdateManager:UnRegister(self)
end

function UMG_CardPreview_C:OnDestruct()
  if self.AnimDelayId then
    _G.DelayManager:CancelDelayById(self.AnimDelayId)
    self.AnimDelayId = nil
  end
end

function UMG_CardPreview_C:OnActive(goodsType, goodsId)
end

function UMG_CardPreview_C:OnDeactive()
end

function UMG_CardPreview_C:OnAddEventListener()
end

function UMG_CardPreview_C:SetData(goodsType, goodsId)
  if not goodsType or not goodsId then
    return
  end
  self.GoodsType = goodsType
  self.GoodsId = goodsId
  self:UpdateUI(goodsType, goodsId)
  if self.AnimDelayId then
    _G.DelayManager:CancelDelayById(self.AnimDelayId)
    self.AnimDelayId = nil
  end
  self.AnimDelayId = _G.DelayManager:DelayFrames(1, function()
    self:CheckIfTextTooLong()
  end)
end

function UMG_CardPreview_C:UpdateUI(goodsType, goodsId)
  local name = ""
  local cardFaceBgImage = ""
  local cardFaceIcon = ""
  local brandName = ""
  local bHasOwned = false
  local ItemPartType = _G.Enum.FashionLabelType.FLT_BEGIN
  if self.NRCSwitcher_57 then
    self.NRCSwitcher_57:SetActiveWidgetIndex(0)
  end
  if self.SuitIcon then
    self.SuitIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Select then
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local GorgeousMagicPetBaseId, bandType, BrandLogo
  if goodsType == _G.Enum.GoodsType.GT_FASHION_SUITS then
    local suitConf = _G.DataConfigManager:GetFashionSuitsConf(goodsId)
    if suitConf and suitConf.suit_grade and suitConf.suits_icon_big then
      bandType = suitConf.fashion_bond_band
      cardFaceBgImage = self:GetSuitBandBgPath(suitConf)
      cardFaceIcon = suitConf.suits_icon_big
      name = suitConf.name
      bHasOwned = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.HadOwnedEntireSuit, goodsId)
      ItemPartType = _G.Enum.FashionLabelType.FLT_SUIT
      self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CheckSGSuitId, goodsId) and type(suitConf.petbase_id) == "table" and #suitConf.petbase_id > 0 then
        GorgeousMagicPetBaseId = suitConf.petbase_id[1]
      end
    end
  elseif goodsType == _G.Enum.GoodsType.GT_FASHION then
    local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(goodsId)
    if fashionItemConf and fashionItemConf.item_quality and fashionItemConf.icon then
      local suitId = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetSuitIdFromFashionId, goodsId)
      if suitId then
        local suitConf = _G.DataConfigManager:GetFashionSuitsConf(suitId)
        if suitConf then
          bandType = suitConf.fashion_bond_band
        end
      else
        bandType = fashionItemConf.fashion_bond_band
      end
      cardFaceBgImage = self:FormatFashionItemBandBgPath(fashionItemConf.item_quality, bandType)
      cardFaceIcon = fashionItemConf.icon
      name = fashionItemConf.name
      bHasOwned = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.CheckHasOwned, _G.Enum.GoodsType.GT_FASHION, goodsId)
      ItemPartType = fashionItemConf.type
    end
    if self.NRCSwitcher_57 then
      self.NRCSwitcher_57:SetActiveWidgetIndex(1)
    end
  else
    Log.Error("UMG_CardPreview_C:UpdateUI \230\156\170\229\174\154\228\185\137\231\177\187\229\158\139\229\164\132\231\144\134", goodsType, goodsId)
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
  if bandType then
    local bondTabConf = _G.DataConfigManager:GetBondTabConf(bandType)
    brandName = bondTabConf and bondTabConf.band_name or ""
    BrandLogo = string.format(UEPath.FMT_BrandLogo, bandType, bandType)
  end
  self.SuitName:SetText(name)
  self.SuitQualityColor:SetPath(cardFaceBgImage)
  self.Protagonist_7:SetPath(cardFaceIcon)
  self.LocalAreaIcon:SetPath(cardFaceIcon)
  self.BrandNameText:SetText(brandName)
  self.BrandIcon:SetPath(BrandLogo)
  if GorgeousMagicPetBaseId then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(GorgeousMagicPetBaseId)
    if petBaseConf then
      self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local IconPath = string.format("%s%d.%d", _G.UIIconPath.BigHeadIconPath, GorgeousMagicPetBaseId, GorgeousMagicPetBaseId)
      self.PetHeadIcon:SetPath(IconPath)
    else
      self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_CardPreview_C:SetSuitIcon(ItemPartType)
  if ItemPartType ~= _G.Enum.FashionLabelType.FLT_BEGIN then
    local appearanceModule = NRCModuleManager:GetModule("AppearanceModule")
    local IconPath = appearanceModule.data:GetItemIconPathByItemType(ItemPartType)
    if nil ~= IconPath then
      self.SuitIcon:SetPath(IconPath)
    end
  end
end

function UMG_CardPreview_C:UpdateGorgeousMagicIconVisible()
  self.GorgeousMagic_Icon:SetVisibility(self.uiData.bHadRevealed and self:FindSGSuitId() and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
end

function UMG_CardPreview_C:FindSGSuitId()
  local fashionGoodsConf = self.uiData and _G.DataConfigManager:GetNormalShopConf(self.uiData.shopItemId)
  local suitId = fashionGoodsConf and _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetSuitIdFromFashionId, fashionGoodsConf.item_id)
  return suitId
end

function UMG_CardPreview_C:GetSuitBandBgPath(suitConf)
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

function UMG_CardPreview_C:FormatFashionItemBandBgPath(Quality, bond)
  if not Quality or not bond then
    Log.Error("UMG_CardPreview_C:FormatFashionItemBandBgPath invalid param", Quality, bond)
    return nil
  end
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

function UMG_CardPreview_C:CheckIfTextTooLong()
  local textComp = self.SuitName
  if not textComp or not UE.UObject.IsValid(textComp) then
    return
  end
  local textContent = textComp:GetText()
  self.bShouldEnableMarquee = self:CalculateTextWidth(textComp, textContent)
end

function UMG_CardPreview_C:CalculateTextWidth(textComp, textContent)
  local textWidth = textComp:GetDesiredSize().X
  local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ScrollBox_61)
  if Slot then
    local scrollBoxWidth = Slot:GetSize().x
    if textWidth >= scrollBoxWidth then
      textComp:SetText(string.format("%s    %s    ", textContent, textContent))
      _G.UpdateManager:Register(self)
      self.startMarquee = true
      return true
    end
  end
  return false
end

function UMG_CardPreview_C:OnTick(deltaTime)
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

function UMG_CardPreview_C:ShowBrandInfo(bShow)
  if bShow then
    self.CanvasPanel_110:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CanvasPanel_110:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_CardPreview_C
