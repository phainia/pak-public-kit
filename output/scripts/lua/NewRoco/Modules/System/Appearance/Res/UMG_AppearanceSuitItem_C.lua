local UMG_AppearanceSuitItem_C = _G.NRCPanelBase:Extend("UMG_AppearanceSuitItem_C")

function UMG_AppearanceSuitItem_C:OnActive()
  self.bHadPlayAnimationIn = false
end

function UMG_AppearanceSuitItem_C:OnDeactive()
  self:StopAllAnimations()
end

function UMG_AppearanceSuitItem_C:SetData(index, bSelected, bHasOwned, bBig, iconPath, color, greyColor)
  local icon = self.smallIcon
  local text = self.TextQuantitySmall
  if bBig then
    self.Itemwitcher:SetActiveWidgetIndex(1)
    icon = self.BigIcon
    text = self.TextQuantityBig
  else
    self.Itemwitcher:SetActiveWidgetIndex(0)
  end
  icon:SwitchToSetBrushFromMaterialInstanceMode(false)
  icon:SetPath(iconPath)
  text:SetText(index)
  text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(color))
  local theBg = self.Bg1_2
  if bSelected then
    self.Bg2_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Bg4_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local greyBg = self.Bg3_1
    if bBig then
      theBg = self.Bg4_1
      greyBg = self.Bg3_1
    else
      theBg = self.Bg2_2
      greyBg = self.Bg1_2
    end
    greyBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(greyColor))
    theBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
  else
    self.Bg2_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Bg4_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if bBig then
      theBg = self.Bg3_1
    else
      theBg = self.Bg1_2
    end
    theBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
  end
  self.bHadPlayAnimationIn = false
  self:StopAllAnimations()
  if bSelected and bHasOwned then
    self:PlayAnimation(self.DangQian_Loop, 0, 0)
  else
    self:PlayAnimation(self.DangQian_Normal)
  end
end

function UMG_AppearanceSuitItem_C:StartPerform()
  self.bHadPlayAnimationIn = true
  self:PlayAnimation(self.DangQian_In)
end

function UMG_AppearanceSuitItem_C:OnAnimationFinished(Anim)
  if Anim == self.DangQian_In and self.bHadPlayAnimationIn then
    self:PlayAnimation(self.DangQian_Loop, 0, 0)
  end
end

return UMG_AppearanceSuitItem_C
