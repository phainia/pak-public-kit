local UMG_LoadingPanel_C = _G.NRCPanelBase:Extend("UMG_LoadingPanel_C")

function UMG_LoadingPanel_C:OnActive()
  self:PlayAnimation(self.Loading, nil, 99999)
end

function UMG_LoadingPanel_C:OnDeactive()
  if self.delayID then
    self:CancelDelayByID(self.delayID)
    self.delayID = nil
  end
end

function UMG_LoadingPanel_C:OnAddEventListener()
end

function UMG_LoadingPanel_C:ShowWithoutAnim()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.CanvasPanel_42:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCText_46:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_109:SetRenderOpacity(1)
  self.delayID = self:DelaySeconds(2, function()
    self:DoClose()
  end)
end

function UMG_LoadingPanel_C:PlayFadeOutAnim()
  self:PlayAnimation(self.FadeOut)
end

function UMG_LoadingPanel_C:OnAnimationFinished(anim)
  if anim == self.FadeOut then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_LoadingPanel_C
