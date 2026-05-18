local AlchemyUtils = require("NewRoco.Modules.System.Alchemy.AlchemyUtils")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_Alchemy_VitalityPanel_C = _G.NRCPanelBase:Extend("UMG_Alchemy_VitalityPanel_C")

function UMG_Alchemy_VitalityPanel_C:OnActive(panelData)
  self.action = panelData.action
  self.uiData = panelData.data
  self.shouldClose = false
  self.ClickEnable = true
  self.CoinEnough = false
  self.ItemEnough = false
  self.limitText = _G.DataConfigManager:GetLocalizationConf("alchemy_bottle_stamina_is_max").msg
  self.itemInsufficient = _G.DataConfigManager:GetLocalizationConf("alchemy_make_item_short").msg
  self.coinInsufficient = _G.DataConfigManager:GetLocalizationConf("exchange_no_enough_currency").msg
  local btnText = _G.DataConfigManager:GetLocalizationConf("exchange_academic_execute").msg
  self.UMG_CoinButton:SetClickAble(true)
  self.UMG_CoinButton:SetBtnText(btnText)
  local titleText = _G.DataConfigManager:GetLocalizationConf("alchemy_bottle_stamina_title").msg
  self.Text_Title:SetText(titleText)
  self:RefreshPanelInfo(self.uiData)
  self:OnAddEventListener()
  self:PlayAnimation(self.In)
  self:BindInputAction()
end

function UMG_Alchemy_VitalityPanel_C:OnDeactive()
  self:OnRemoveEventListener()
  self:UnBindInputAction()
end

function UMG_Alchemy_VitalityPanel_C:BindInputAction()
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_CommonCloseUI")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, imc, self.depth)
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseUI")
  UE.UNRCEnhancedInputHelper.BindAction(ia, UE.ETriggerEvent.Triggered, self, "OnPcClose")
end

function UMG_Alchemy_VitalityPanel_C:UnBindInputAction()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseUI")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_CommonCloseUI")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, imc)
end

function UMG_Alchemy_VitalityPanel_C:OnPcClose()
  if not self.closeState then
    self:OnCloseBtnClick()
  end
end

function UMG_Alchemy_VitalityPanel_C:OnAddEventListener()
  self:AddButtonListener(self.ReturnBtn.btnClose, self.OnCloseBtnClick)
  self:AddButtonListener(self.UMG_CoinButton.btnLevelUp, self.OnConfirmClick)
end

function UMG_Alchemy_VitalityPanel_C:OnRemoveEventListener()
end

function UMG_Alchemy_VitalityPanel_C:OnConstruct()
end

function UMG_Alchemy_VitalityPanel_C:OnDestruct()
end

function UMG_Alchemy_VitalityPanel_C:OnCloseBtnClick()
  if not UIUtils.IsClickable(self) then
    return
  end
  if self:IsPlayingAnimation() then
    return
  end
  self.shouldClose = true
  self:PlayAnimation(self.Out)
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.CloseMaterialItems)
end

function UMG_Alchemy_VitalityPanel_C:OnConfirmClick()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_ALCHEMY_MAGIC, true)
  if isBan then
    return
  end
  if not UIUtils.IsClickable(self) then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Alchemy_VitalityPanel_C:OnConfirmClick")
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.DisableClick)
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.RequestForUpgrade, _G.Enum.VisualItem.VI_STAMINA, self.uiData.upgradeId, self.uiData.exchangeId, self.uiData.origin_value, self.uiData.target_value)
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_Alchemy_VitalityPanel_C:RefreshPanelInfo(data)
  self.uiData = data
  if data.upgradeId > 0 then
    self.PhysicalPower:SetUpgradeTimes(data.upgradeId - 1)
    self.PhysicalPower_1:SetUpgradeTimes(data.upgradeId)
  else
    local RolePowerConfTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.POWER_MAX_CONF):GetAllDatas()
    self.PhysicalPower_2:SetUpgradeTimes(#RolePowerConfTable)
  end
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.UpdateMaterialItems, data.exchangeId, 1)
  local exchangeId = self.uiData.exchangeId
  self.ClickEnable = true
  if exchangeId and 0 ~= exchangeId then
    local exchange_conf = _G.DataConfigManager:GetExchangeConf(exchangeId)
    self.ClickEnable = AlchemyUtils.GetCanExchangeNum(exchange_conf) > 0
    self.CoinEnough = AlchemyUtils.GetCoinCanExchangeNum(exchange_conf) > 0
    self.ItemEnough = AlchemyUtils.GetItemCanExchangeNum(exchange_conf) > 0
    self.IsUnlock = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.CheckExchangeUnlock, exchangeId)
  end
  self:UpdateCostIcon(exchangeId, 1)
  if 0 == data.upgradeId then
    self.Switcher:SetActiveWidgetIndex(1)
    self.UMG_CoinButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UMG_CoinButton2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.UMG_CoinButton2.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UMG_CoinButton2.btnLevelUp:SetIsEnabled(false)
    self.UMG_CoinButton2.Title_1:SetText(self.limitText)
  else
    self.Switcher:SetActiveWidgetIndex(0)
    if self.IsUnlock then
      if self.ClickEnable == true then
        self.UMG_CoinButton:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.UMG_CoinButton2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        local btnText = _G.DataConfigManager:GetLocalizationConf("exchange_academic_execute").msg
        if not self.ItemEnough then
          self.UMG_CoinButton2.Title_1:SetText(btnText)
        else
          self.UMG_CoinButton2.Title_1:SetText(btnText)
        end
        self.UMG_CoinButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.UMG_CoinButton2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.UMG_CoinButton2.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.UMG_CoinButton2.btnLevelUp:SetIsEnabled(false)
      end
    else
      self.UMG_CoinButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.UMG_CoinButton2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local btnText = _G.DataConfigManager:GetLocalizationConf("exchange_academic_execute").msg
      self.UMG_CoinButton2.Title_1:SetText(btnText)
      self.UMG_CoinButton2.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.UMG_CoinButton2.btnLevelUp:SetIsEnabled(false)
    end
  end
end

function UMG_Alchemy_VitalityPanel_C:UpdateCostIcon(exchangeId, item_num)
  if 0 == exchangeId then
    self.UMG_CoinButton.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UMG_CoinButton2.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if self.IsUnlock then
    local exchangeConf = _G.DataConfigManager:GetExchangeConf(exchangeId)
    local currencyIcon
    if exchangeConf and exchangeConf.visual_item_cost_num and 0 ~= exchangeConf.visual_item_cost_num then
      self.UMG_CoinButton.TitleCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.UMG_CoinButton2.TitleCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local CostCoinNum = exchangeConf.visual_item_cost_num
      if item_num and 0 ~= item_num then
        CostCoinNum = CostCoinNum * item_num
      end
      local current_coin_num = 0
      if exchangeConf.visual_item_cost_type == _G.Enum.VisualItem.VI_COIN then
        current_coin_num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_COIN) or 0
        currencyIcon = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/1.1'"
      else
        Log.Error("\232\191\153\228\184\170\230\149\176\230\141\174\230\156\137\233\151\174\233\162\152\239\188\140\231\155\174\229\137\141\229\143\170\230\148\175\230\140\129\230\180\155\229\133\139\232\180\157\239\188\140\230\156\137\230\150\176\232\180\167\229\184\129\230\182\136\232\128\151\232\175\183\230\143\144\230\150\176\233\156\128\230\177\130")
      end
      self.UMG_CoinButton:SetClickAble(true)
      self.UMG_CoinButton:SetTitleTextAndIcon(currencyIcon, CostCoinNum)
      self.UMG_CoinButton2:SetTitleTextAndIcon(currencyIcon, CostCoinNum)
      if CostCoinNum > current_coin_num then
        self.UMG_CoinButton.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#CF3D3E"))
        self.UMG_CoinButton2.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#CF3D3E"))
      else
        self.UMG_CoinButton.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F4EEE1FF"))
        self.UMG_CoinButton2.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F4EEE1FF"))
      end
    else
      self.UMG_CoinButton.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.UMG_CoinButton2.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    local ExchangeConf = _G.DataConfigManager:GetExchangeConf(exchangeId)
    local unlock_type = ExchangeConf and ExchangeConf.unlock_type
    local unlock_data = ExchangeConf and ExchangeConf.unlock_data
    self.UMG_CoinButton.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if unlock_type then
      if unlock_type == _G.Enum.ExchangeFormulaUnlockType.EFUT_ROLE_LEVEL then
        self.UMG_CoinButton2:SetTitleTextAndIcon(nil, nil, nil, nil, string.format(LuaText.alchemy_power_upgrade_role_lv_conditiont_text, unlock_data))
        self.UMG_CoinButton2.Tips:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#CF3D3E"))
        self.UMG_CoinButton2.TitleCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      elseif unlock_type == _G.Enum.ExchangeFormulaUnlockType.EFUT_ROLE_STAR then
        local WorldLevelConf = _G.DataConfigManager:GetWorldLevelConf(unlock_data)
        self.UMG_CoinButton2:SetTitleTextAndIcon(nil, nil, nil, nil, string.format(LuaText.alchemy_power_upgrade_world_lv_condition_text, WorldLevelConf.title))
        self.UMG_CoinButton2.Tips:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#CF3D3E"))
        self.UMG_CoinButton2.TitleCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.UMG_CoinButton2.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      self.UMG_CoinButton2.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Alchemy_VitalityPanel_C:RefreshPanel()
  local vitalityData = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetVitalityData)
  self:RefreshPanelInfo(vitalityData)
end

function UMG_Alchemy_VitalityPanel_C:ShowClose()
  self.closeState = true
  self:StopAllAnimations()
  self:PlayAnimation(self.Out)
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_Alchemy_VitalityPanel_C:ShowOpen()
  self.closeState = nil
  self:StopAllAnimations()
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:PlayAnimation(self.In)
  self:RefreshPanel()
end

function UMG_Alchemy_VitalityPanel_C:OnAnimationFinished(anim)
  if anim == self.Out then
    if self.shouldClose then
      _G.NRCEventCenter:DispatchEvent(_G.AlchemyModuleEvent.AlchemyVitalityPanelClosed)
      self:DoClose()
    end
  elseif anim == self.In then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

return UMG_Alchemy_VitalityPanel_C
