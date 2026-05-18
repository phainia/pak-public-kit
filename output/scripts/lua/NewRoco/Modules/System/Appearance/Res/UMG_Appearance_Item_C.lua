local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_Appearance_Item_C = Base:Extend("UMG_Appearance_Item_C")

function UMG_Appearance_Item_C:OnConstruct()
  self:AddEventListener()
end

function UMG_Appearance_Item_C:OnDestruct()
  self:RemoveEventListener()
end

function UMG_Appearance_Item_C:AddEventListener()
  self:AddButtonListener(self.Btn_Suit, self.OnBtnSuitClicked)
end

function UMG_Appearance_Item_C:RemoveEventListener()
end

function UMG_Appearance_Item_C:OnItemUpdate(_data, datalist, index)
  self.IsPlayAnim = true
  self.uiData = _data
  self.index = index
  self.bChoosed = false
  Log.Dump(_data, 3, "UMG_Appearance_Item_C:OnItemUpdate")
  self:UpdateItemInfo()
end

function UMG_Appearance_Item_C:UpdateItemInfo()
  local OpenAnim = self:SetRandomOpenAnim()
  self:PlayAnimation(OpenAnim)
  local FashionId = self.uiData.FashionId
  if 1 == #self.uiData.FashionGoodsId then
    self.Btn_Suit:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(FashionId[1])
    if fashionItemConf.icon then
      self.Icon:SetPath(fashionItemConf.icon)
    else
      self.Icon:SetPath("")
    end
    if self.uiData.bOwned == false and self.uiData.FashionGoodsId then
      self:SetSwitcher(0)
      local fashionGoodsConf = _G.DataConfigManager:GetNormalShopConf(self.uiData.FashionGoodsId[1])
      self.Money:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if fashionGoodsConf.price_goods_type == Enum.GoodsType.GT_VITEM then
        if fashionGoodsConf.price_goods_id == _G.Enum.VisualItem.VI_COIN then
          self.Gold_Icon:SetPath("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/100008.100008'")
          self:SetSwitcher(0)
          self.Money:SetText(fashionGoodsConf.origin_price)
        elseif fashionGoodsConf.price_goods_id == _G.Enum.VisualItem.VI_DIAMOND then
          self.Gold_Icon:SetPath("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/100649.100649'")
          self.Money:SetText(fashionGoodsConf.origin_price)
        elseif fashionGoodsConf.price_goods_id == _G.Enum.VisualItem.VI_PIKA_POINT then
          self.Gold_Icon:SetPath("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/100663.100663'")
          self.Money:SetText(fashionGoodsConf.origin_price)
        end
      end
    else
      self.Money:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:SetSwitcher(2)
    end
  else
    self.Btn_Suit:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Progress:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local fashionSuitConf = _G.DataConfigManager:GetFashionSuitsConf(self.uiData.SuitIndex)
    if fashionSuitConf.suits_icon then
      self.Icon:SetPath(fashionSuitConf.suits_icon)
    else
      self.Icon:SetPath("")
    end
    local moneySum = 0
    local hasnum = #self.uiData.FashionGoodsId
    for k, v in ipairs(self.uiData.FashionGoodsId) do
      local fashionGoodsConf = _G.DataConfigManager:GetNormalShopConf(v)
      local hasOwned = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.CheckHasOwned, _G.Enum.GoodsType.GT_FASHION, fashionGoodsConf.item_id)
      if not hasOwned then
        moneySum = moneySum + fashionGoodsConf.origin_price
        hasnum = hasnum - 1
      end
    end
    local ProgressText = tostring(hasnum) .. "/" .. tostring(#self.uiData.FashionGoodsId)
    if hasnum == #self.uiData.FashionGoodsId then
      self.Progress:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("272727FF"))
    else
      self.Progress:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("929086FF"))
    end
    self.Progress:SetText(ProgressText)
    if self.uiData.bOwned == false then
      self:SetSwitcher(0)
      local fashionGoodsConf = _G.DataConfigManager:GetNormalShopConf(self.uiData.FashionGoodsId[1])
      self.Money:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if fashionGoodsConf and fashionGoodsConf.price_goods_type == Enum.GoodsType.GT_VITEM then
        if fashionGoodsConf.price_goods_id == _G.Enum.VisualItem.VI_COIN then
          self.Gold_Icon:SetPath("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/100008.100008'")
          self.Money:SetText(moneySum)
        elseif fashionGoodsConf.price_goods_id == _G.Enum.VisualItem.VI_DIAMOND then
          self.Gold_Icon:SetPath("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/100649.100649'")
          self.Money:SetText(moneySum)
        end
      end
    else
      self.Money:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:SetSwitcher(2)
    end
  end
end

function UMG_Appearance_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Selected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.bChoosed then
      for i = 1, #self.uiData.FashionId do
        local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(self.uiData.FashionId[i])
        if fashionItemConf.type ~= _G.Enum.FashionLabelType.FLT_WAND then
          self:PlayAnimation(self.change1_unselect)
          self:StopAnimation(self.change1_Loop)
          _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearance, self.uiData.FashionId[i], self.uiData.FashionGoodsId, false)
          self.bChoosed = false
        end
        if fashionItemConf.type == _G.Enum.FashionLabelType.FLT_BAGS then
          local TempAppearData = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetTempAppearOrBeautyData, _G.Enum.GoodsType.GT_FASHION)
          if TempAppearData and #TempAppearData > 0 then
            for i, j in ipairs(TempAppearData) do
              if j.FashionType == _G.Enum.FashionLabelType.FLT_PENDANTA then
                _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearance, j.FashionId, j.FashionGoodsId, false)
                local tips = _G.DataConfigManager:GetLocalizationConf("fashion_bag_pendanta_remind2").msg
                _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tips)
                break
              end
            end
          end
          self.bChoosed = false
        end
      end
    else
      _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearConfirmBtnClickable, false)
      local TempAppearData = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetTempAppearOrBeautyData, _G.Enum.GoodsType.GT_FASHION)
      local tempTable = {}
      local TopsAndButtoms = {}
      local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(self.uiData.FashionId[1])
      if (fashionItemConf.type == _G.Enum.FashionLabelType.FLT_TOPS or fashionItemConf.type == _G.Enum.FashionLabelType.FLT_BOTTOMS) and TempAppearData and #TempAppearData > 0 then
        for i, j in ipairs(TempAppearData) do
          if j.FashionType == _G.Enum.FashionLabelType.FLT_DRESSES then
            _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearance, j.FashionId, j.FashionGoodsId, false)
          end
        end
      end
      if fashionItemConf.type == _G.Enum.FashionLabelType.FLT_DRESSES and TempAppearData and #TempAppearData > 0 then
        for i, j in ipairs(TempAppearData) do
          if j.FashionType == _G.Enum.FashionLabelType.FLT_TOPS then
            table.insert(TopsAndButtoms, j)
          elseif j.FashionType == _G.Enum.FashionLabelType.FLT_BOTTOMS then
            table.insert(TopsAndButtoms, j)
          end
        end
        for a, b in ipairs(TopsAndButtoms) do
          _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearance, b.FashionId, b.FashionGoodsId, false)
        end
      end
      if fashionItemConf.type == _G.Enum.FashionLabelType.FLT_PENDANTA then
        local hasBag = false
        if TempAppearData and #TempAppearData > 0 then
          for i, j in ipairs(TempAppearData) do
            if j.FashionType == _G.Enum.FashionLabelType.FLT_BAGS then
              hasBag = true
              break
            end
          end
        end
        if not hasBag then
          local tips = _G.DataConfigManager:GetLocalizationConf("fashion_bag_pendanta_remind1").msg
          _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tips)
          return
        end
      end
      if #self.uiData.FashionId > 1 and TempAppearData and #TempAppearData > 0 then
        for k, v in ipairs(TempAppearData) do
          local fashionType = _G.DataConfigManager:GetFashionItemConf(v.FashionId)
          local hasFashion = false
          for i = 1, #self.uiData.FashionId do
            local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(self.uiData.FashionId[i])
            if fashionItemConf.type == fashionType then
              hasFashion = true
            end
          end
          if false == hasFashion then
            table.insert(tempTable, v)
          end
        end
      end
      for k, v in ipairs(tempTable) do
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearance, v.FashionId, v.FashionGoodsId, false)
      end
      self:PlayAnimation(self.change1_Loop, 0, 9999)
      self:PlayAnimation(self.change1)
      local IsFirstPlay = false
      for i = 1, #self.uiData.FashionId do
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearance, self.uiData.FashionId[i], self.uiData.FashionGoodsId, true)
        if self.IsPlayAnim then
          if #self.uiData.FashionId > 1 and not IsFirstPlay then
            _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.PlayAvatarAnim, true)
            IsFirstPlay = true
          end
          if #self.uiData.FashionId <= 1 and not IsFirstPlay then
            _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.PlayAvatarAnim, false, self.uiData.FashionId[i])
          end
        else
          self.IsPlayAnim = true
        end
        self.bChoosed = true
      end
    end
    _G.NRCAudioManager:PlaySound2DAuto(1072, "UMG_Appearance_Item_C:OnItemSelected")
  else
    self:PlayAnimation(self.change1_unselect)
    self:StopAnimation(self.change1_Loop)
    self.bChoosed = false
    self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Appearance_Item_C:SelectedAppearance()
  self.IsPlayAnim = false
end

function UMG_Appearance_Item_C:OnBtnSuitClicked()
  _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.OpenAppearanceSuitDetailsPanel, self.uiData.SuitIndex)
end

function UMG_Appearance_Item_C:OnDeactive()
end

function UMG_Appearance_Item_C:CheckIsChoosed(curAppearChooseInfo)
  if nil == curAppearChooseInfo then
  elseif #curAppearChooseInfo > 0 then
    for i = 1, #curAppearChooseInfo do
      if curAppearChooseInfo[i].FashionId == self.uiData.FashionId[1] then
        self.bChoosed = true
        return
      else
        self.bChoosed = false
      end
    end
  end
end

function UMG_Appearance_Item_C:SetSwitcher(type)
  self.Switcher:SetActiveWidgetIndex(type)
end

function UMG_Appearance_Item_C:SetRandomOpenAnim()
  local animations = {
    self.open_1,
    self.open_2,
    self.open_3
  }
  local randomIndex = math.random(#animations)
  return animations[randomIndex]
end

return UMG_Appearance_Item_C
