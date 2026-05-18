local UMG_PurchaseSuccessfulTips_C = _G.NRCPanelBase:Extend("UMG_PurchaseSuccessfulTips_C")

function UMG_PurchaseSuccessfulTips_C:OnActive(purchaseData)
  _G.NRCAudioManager:PlaySound2DAuto(1231, "UMG_PurchaseSuccessfulTips_C:OnActive")
  if purchaseData then
    self.closeCallback = purchaseData.closeCallback
    self.closeCallbackParam = purchaseData.closeCallbackParam
    self.effectText = purchaseData.effectText
    self.effectIcon = purchaseData.effectIcon
    self.titleText = purchaseData.titleText
    if self.effectText and self.Title_Describe then
      self.Title_Describe:SetText(self.effectText)
    end
    if self.Seal and self.effectIcon then
      self.Seal:SetPath(self.effectIcon)
    end
    if self.NRCImage_73 and self.effectIcon then
      self.NRCImage_73:SetPath(self.effectIcon)
    end
    if self.Title and self.titleText then
      self.Title:SetText(self.titleText)
    end
  end
  self.CloseTimer = _G.TimerManager:CreateTimer(self, "UMG_PurchaseSuccessfulTips_C", 15, nil, self.OnTimerClose, 15)
end

function UMG_PurchaseSuccessfulTips_C:OnTimerClose()
  if self.closeCallback and self.closeCallbackParam then
    self.closeCallback(self.closeCallbackParam)
  end
  self:ClearCloseTimer()
  self:OnClose()
end

function UMG_PurchaseSuccessfulTips_C:OnDeactive()
  Log.Debug("UMG_PurchaseSuccessfulTips_C:OnDeactive")
  self:ClearCloseTimer()
end

function UMG_PurchaseSuccessfulTips_C:ClearCloseTimer()
  if self.CloseTimer then
    self.CloseTimer:Stop()
    self.CloseTimer:Clear()
    self.CloseTimer = nil
  end
end

function UMG_PurchaseSuccessfulTips_C:OnAddEventListener()
end

function UMG_PurchaseSuccessfulTips_C:OnAnimationFinished(Anim)
  if Anim == self.Finish then
    if self.closeCallback and self.closeCallbackParam then
      self.closeCallback(self.closeCallbackParam)
    end
    self:ClearCloseTimer()
    self:OnClose()
  end
end

function UMG_PurchaseSuccessfulTips_C:OnPcClose()
  Log.Debug("UMG_PurchaseSuccessfulTips_C:OnPcClose")
end

return UMG_PurchaseSuccessfulTips_C
