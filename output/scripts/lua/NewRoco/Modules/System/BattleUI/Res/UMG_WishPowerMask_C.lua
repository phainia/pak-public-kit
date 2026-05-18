local UMG_WishPowerMask_C = _G.NRCPanelBase:Extend("UMG_WishPowerMask_C")

function UMG_WishPowerMask_C:OnActive()
  self:OnAddEventListener()
  self:OpenTutorial()
end

function UMG_WishPowerMask_C:OnDeactive()
end

function UMG_WishPowerMask_C:OnAddEventListener()
  self:AddButtonListener(self.CloseWishPowerTutorialBtn, self.CloseWishPowerTutorial)
end

function UMG_WishPowerMask_C:OpenTutorial(Data)
  self.Tutorial:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.CloseWishPowerTutorialBtn:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_WishPowerMask_C:CloseWishPowerTutorial()
  self:OnClose()
end

return UMG_WishPowerMask_C
