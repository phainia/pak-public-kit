local UMG_Tips_StrongPoint_C = _G.NRCViewBase:Extend("UMG_Tips_StrongPoint_C")

function UMG_Tips_StrongPoint_C:OnActive()
end

function UMG_Tips_StrongPoint_C:SetPanelInfo(TalentList)
  self.List:InitGridView(TalentList)
end

function UMG_Tips_StrongPoint_C:AnimClose()
  self:StopAllAnimations()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1061, "UMG_Tips_StrongPoint_C:AnimClose")
  self:PlayAnimation(self.Out)
end

function UMG_Tips_StrongPoint_C:AnimOpen()
  self:StopAllAnimations()
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1086, "UMG_Tips_StrongPoint_C:AnimOpen")
  self:PlayAnimation(self.In)
end

function UMG_Tips_StrongPoint_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Tips_StrongPoint_C:OnAddEventListener()
end

return UMG_Tips_StrongPoint_C
