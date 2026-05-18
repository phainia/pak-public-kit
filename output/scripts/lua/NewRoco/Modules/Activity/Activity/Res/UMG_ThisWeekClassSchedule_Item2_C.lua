local UMG_ThisWeekClassSchedule_Item2_C = _G.NRCPanelBase:Extend("UMG_ThisWeekClassSchedule_Item2_C")

function UMG_ThisWeekClassSchedule_Item2_C:OnConstruct()
  self:AddButtonListener(self.ClaimBtn, self.OnClickClaimBtn)
  self.ClaimBtn.OnPressed:Add(self, self.OnClaimBtnPressed)
  self.ClaimBtn.OnReleased:Add(self, self.OnClaimBtnReleased)
end

function UMG_ThisWeekClassSchedule_Item2_C:OnDestruct()
  self.ClaimBtn.OnPressed:Clear()
  self.ClaimBtn.OnReleased:Clear()
end

function UMG_ThisWeekClassSchedule_Item2_C:SetIcon(iconPath)
  self.IconImage:SetPath(iconPath)
end

function UMG_ThisWeekClassSchedule_Item2_C:SetName(name)
  self.IconText_Name:SetText(name)
end

function UMG_ThisWeekClassSchedule_Item2_C:SetQuantityText(quantity)
  self.Text_quantity_1:SetText(quantity)
end

function UMG_ThisWeekClassSchedule_Item2_C:SetBgColor(color)
  if self.NRCImage_25 then
    self.NRCImage_25:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
  end
  if self.NRCImage_410 then
    self.NRCImage_410:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
  end
end

function UMG_ThisWeekClassSchedule_Item2_C:SetClickCallback(clickCallback, pressCallback, releaseCallback)
  self.clickCallback = clickCallback
  self.pressCallback = pressCallback
  self.releaseCallback = releaseCallback
end

function UMG_ThisWeekClassSchedule_Item2_C:OnClickClaimBtn()
  local clickCallback = self.clickCallback
  if clickCallback then
    clickCallback()
  end
end

function UMG_ThisWeekClassSchedule_Item2_C:OnClaimBtnPressed()
  local pressCallback = self.pressCallback
  if pressCallback then
    pressCallback()
  end
end

function UMG_ThisWeekClassSchedule_Item2_C:OnClaimBtnReleased()
  local releaseCallback = self.releaseCallback
  if releaseCallback then
    releaseCallback()
  end
end

return UMG_ThisWeekClassSchedule_Item2_C
