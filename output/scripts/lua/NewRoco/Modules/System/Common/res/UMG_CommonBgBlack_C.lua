local UMG_CommonBgBlack_C = _G.NRCViewBase:Extend("UMG_CommonBgBlack_C")

function UMG_CommonBgBlack_C:Construct()
  NRCViewBase.Construct(self)
  local TUIModule = NRCModuleManager:GetModule("TUIModule")
  if TUIModule then
    TUIModule:PushBlackBackgroundWidget(self)
  end
end

function UMG_CommonBgBlack_C:OnDestruct()
  local TUIModule = NRCModuleManager:GetModule("TUIModule")
  if TUIModule then
    TUIModule:PopBlackBackgroundWidget(self)
  end
end

function UMG_CommonBgBlack_C:SetBackgroundVisible(bVisible)
  local Value
  if bVisible then
    Value = UE.ESlateVisibility.HitTestInvisible
  else
    Value = UE.ESlateVisibility.Collapsed
  end
  self:SetVisibility(Value)
end

return UMG_CommonBgBlack_C
