local UMG_CoinButton_C = _G.NRCPanelBase:Extend("UMG_CoinButton_C")

function UMG_CoinButton_C:OnActive()
end

function UMG_CoinButton_C:OnDeactive()
end

function UMG_CoinButton_C:OnAddEventListener()
  self.BuildButton.btnLevelUp.OnPressed:Add(self, self.OnBtnPressed)
  self.BuildButton.btnLevelUp.OnReleased:Add(self, self.OnBtnReleased)
end

function UMG_CoinButton_C:OnRemoveEventListener()
  self.BuildButton.btnLevelUp.OnPressed:Clear()
  self.BuildButton.btnLevelUp.OnReleased:Clear()
end

function UMG_CoinButton_C:UpdateCostIcon(exchangeId, item_num)
  if 0 == exchangeId then
    self.CurrencyPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    local exchangeConf = _G.DataConfigManager:GetExchangeConf(exchangeId)
    if exchangeConf and exchangeConf.visual_item_cost_num then
      local CostCoinNum = exchangeConf.visual_item_cost_num
      if item_num and 0 ~= item_num then
        CostCoinNum = CostCoinNum * item_num
      end
      self.CurrencyPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.CurrencyText:SetText(string.format("%d", CostCoinNum))
      local current_coin_num = 0
      if exchangeConf.visual_item_cost_type == _G.Enum.VisualItem.VI_COIN then
        current_coin_num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_COIN) or 0
        self.CurrencyIcon:SetPath("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/1.1'")
      else
        Log.Error("\232\191\153\228\184\170\230\149\176\230\141\174\230\156\137\233\151\174\233\162\152\239\188\140\231\155\174\229\137\141\229\143\170\230\148\175\230\140\129\230\180\155\229\133\139\232\180\157\239\188\140\230\156\137\230\150\176\232\180\167\229\184\129\230\182\136\232\128\151\232\175\183\230\143\144\230\150\176\233\156\128\230\177\130")
      end
      if CostCoinNum > current_coin_num then
        self.CurrencyText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("ff4a4aff"))
      else
        self.CurrencyText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F4EEE1FF"))
      end
    else
      self.CurrencyPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_CoinButton_C:UpdateButtonStyle(bCanBuild)
  if bCanBuild then
    self.BtnSwitcher:SetActiveWidgetIndex(0)
  else
    self.BtnSwitcher:SetActiveWidgetIndex(1)
  end
end

function UMG_CoinButton_C:SetDisableButtonText(DisableText)
  self.DisableButtonText:SetText(DisableText)
end

function UMG_CoinButton_C:SetEnableButtonText(EnableText)
  self.BuildButton:SetBtnText(EnableText)
end

function UMG_CoinButton_C:OnBtnPressed()
  self:StopAnimation(self.Btn_up)
  self:PlayAnimation(self.Btn_Press)
end

function UMG_CoinButton_C:OnBtnReleased()
  self:StopAnimation(self.Btn_Press)
  self:PlayAnimation(self.Btn_up)
end

return UMG_CoinButton_C
