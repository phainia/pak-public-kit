local UMG_MagicStar_C = _G.NRCPanelBase:Extend("UMG_MagicStar_C")

function UMG_MagicStar_C:OnConstruct()
end

function UMG_MagicStar_C:OnDestruct()
end

function UMG_MagicStar_C:OnItemUpdate(_data, datalist, index)
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.data = _data
  self.starNormal:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.star:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.isStar then
    self.starNormal:SetVisibility(UE4.ESlateVisibility.Visible)
    self.star:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif self.data.isNext then
    self.star:SetVisibility(UE4.ESlateVisibility.Visible)
    self.starNormal:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_MagicStar_C:PlayAnimationIn()
  self:PlayAnimation(self.PrimaryLevelUp1)
end

function UMG_MagicStar_C:OnAnimationFinished(anim)
  if anim == self.PrimaryLevelUp1 then
    self.star:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_MagicStar_C:OnDeactive()
end

return UMG_MagicStar_C
