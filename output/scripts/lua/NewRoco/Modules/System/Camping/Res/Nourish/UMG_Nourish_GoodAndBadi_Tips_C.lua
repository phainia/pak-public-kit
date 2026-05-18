local UMG_Nourish_GoodAndBadi_Tips_C = _G.NRCPanelBase:Extend("UMG_Nourish_GoodAndBadi_Tips_C")

function UMG_Nourish_GoodAndBadi_Tips_C:OnActive(AdvantageType, DisadvantageType)
  _G.NRCAudioManager:PlaySound2DAuto(1060, "CampingModule:OpenNourishRightFruit")
  self:PlayAnimation(self.TweenIn)
  self:AddButtonListener(self.HotArea, self.OnClose)
  if not AdvantageType or #AdvantageType <= 0 then
    self.AdvantageType:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.AdvantageType:Init(AdvantageType, true)
    self.AdvantageType:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if not DisadvantageType or #DisadvantageType <= 0 then
    self.DisadvantageType:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.DisadvantageType:Init(DisadvantageType, false)
    self.DisadvantageType:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if not (DisadvantageType and not (#DisadvantageType <= 0) and AdvantageType) or #AdvantageType <= 0 then
    self.Spacer:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Spacer:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Nourish_GoodAndBadi_Tips_C:OnDeactive()
  self:RemoveButtonListener(self.HotArea)
end

function UMG_Nourish_GoodAndBadi_Tips_C:OnAddEventListener()
end

function UMG_Nourish_GoodAndBadi_Tips_C:OnClose()
  _G.NRCAudioManager:PlaySound2DAuto(1060, "CampingModule:OpenNourishRightFruit")
  self:PlayAnimation(self.TweenOut)
end

function UMG_Nourish_GoodAndBadi_Tips_C:OnAnimationFinished(anim)
  if anim == self.TweenOut then
    self.module.GoodAndBadiTipsOpen = false
    self:DoClose()
  end
end

return UMG_Nourish_GoodAndBadi_Tips_C
