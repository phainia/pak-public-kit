local UMG_DeductHp_C = _G.NRCPanelBase:Extend("UMG_DeductHp_C")

function UMG_DeductHp_C:OnActive()
  if self:IsPCMode() then
    self:PCModeScreenSetting()
  end
end

function UMG_DeductHp_C:OnDeactive()
end

function UMG_DeductHp_C:OnAddEventListener()
end

function UMG_DeductHp_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

function UMG_DeductHp_C:PCModeScreenSetting()
  local Padding = UE4.FMargin()
  Padding.Left = -164
  Padding.Top = -74
  Padding.Right = -164
  Padding.Bottom = -74
  self.NRCSafeZone_18:SetRenderScale(UE4.FVector2D(0.88, 0.88))
  self.NRCSafeZone_18.Slot:SetOffsets(Padding)
end

return UMG_DeductHp_C
