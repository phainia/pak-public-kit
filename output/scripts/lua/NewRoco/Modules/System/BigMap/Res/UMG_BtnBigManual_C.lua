local UMG_BtnBigManual_C = _G.NRCPanelBase:Extend("UMG_BtnBigManual_C")

function UMG_BtnBigManual_C:OnConstruct()
end

function UMG_BtnBigManual_C:OnDestruct()
end

function UMG_BtnBigManual_C:SetBtnState(_IsShowText, _AreaManualInfo)
  local AreaManualInfo = _AreaManualInfo
  if _IsShowText then
    if AreaManualInfo then
      if AreaManualInfo.btn_guide_text ~= nil then
        self.NRCImage_87:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.NRCText_48:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.NRCText_48:SetText(AreaManualInfo.btn_guide_text)
      else
        self.NRCImage_87:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.NRCText_48:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
    else
      self.NRCImage_87:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.NRCText_48:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  else
    self.NRCImage_87:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCText_48:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if AreaManualInfo then
    local AreaFunConf = _G.DataConfigManager:GetAreaFuncConf(AreaManualInfo.area_func_id[1])
    self.NRCText_55:SetText(AreaFunConf.name)
  else
    self.NRCText_55:SetText("")
  end
end

function UMG_BtnBigManual_C:SetBtnReturn()
  local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("Return_Map_Guide")
  if LocalizationConf.msg == nil then
    self.NRCImage_87:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCText_48:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.NRCImage_87:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCText_48:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCText_48:SetText(LocalizationConf.msg)
  end
  self:StopAllAnimations()
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.open)
end

function UMG_BtnBigManual_C:SetRedDot(_IsShow)
  if _IsShow then
    self.NrcRedPoint:SetupKey(91)
    self.NrcRedPoint.RedPointNode:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.NrcRedPoint:EraseRedPoint()
    self.NrcRedPoint.RedPointNode:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_BtnBigManual_C:OnAnimationFinished(Animation)
  if Animation == self.loop then
  elseif Animation == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

function UMG_BtnBigManual_C:OnActive()
end

function UMG_BtnBigManual_C:OnDeactive()
end

return UMG_BtnBigManual_C
