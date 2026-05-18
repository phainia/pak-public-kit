local UMG_Battle_Popup_GeneralFX_C = _G.NRCClass:Extend("UMG_Battle_Popup_GeneralFX_C")

function UMG_Battle_Popup_GeneralFX_C:SetCallBack(Caller, CallBack, PopupData)
  self.Caller = Caller
  self.CallBack = CallBack
  self.PopupData = PopupData
end

function UMG_Battle_Popup_GeneralFX_C:OnDestruct()
  if self.Caller and self.CallBack then
    self.CallBack(self.Caller, self.PopupData)
  end
  self.Caller = nil
  self.CallBack = nil
  self.PopupData = nil
end

return UMG_Battle_Popup_GeneralFX_C
