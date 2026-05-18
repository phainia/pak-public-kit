local UMG_PetCertificationTips_C = _G.NRCViewBase:Extend("UMG_PetCertificationTips_C")

function UMG_PetCertificationTips_C:OnConstruct()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PetCertificationTips_C:SetParent(parent)
  self.ParentPanel = parent
end

function UMG_PetCertificationTips_C:Show(tipData)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Title_Describe:SetText(tipData.effectText)
  self.Seal:SetPath(tipData.effectIcon)
  self.Title:SetText(tipData.titleText)
  self:PlayAnimation(self.Finish)
end

function UMG_PetCertificationTips_C:OnAnimationFinished(Anim)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.ParentPanel then
    self.ParentPanel:ConsumeNext()
  end
end

return UMG_PetCertificationTips_C
