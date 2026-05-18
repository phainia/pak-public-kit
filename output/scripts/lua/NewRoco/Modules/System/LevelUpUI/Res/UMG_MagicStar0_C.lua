local UMG_MagicStar0_C = _G.NRCPanelBase:Extend("UMG_MagicStar0_C")

function UMG_MagicStar0_C:OnConstruct()
end

function UMG_MagicStar0_C:OnDestruct()
end

function UMG_MagicStar0_C:OnItemUpdate(_data, datalist, index)
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.data = _data
  self.starNormal:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.star:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.isStar then
    self.starNormal:SetVisibility(UE4.ESlateVisibility.Visible)
    self.star:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif self.data.isNext then
    self.starNormal:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_MagicStar0_C:PlayAnimationIn()
  self.star:SetVisibility(UE4.ESlateVisibility.Visible)
  self:PlayAnimation(self.PrimaryLevelUp1)
end

function UMG_MagicStar0_C:OnAnimationFinished(anim)
end

function UMG_MagicStar0_C:OnDeactive()
end

return UMG_MagicStar0_C
