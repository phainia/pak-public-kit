local UMG_RecoverNumber_C = _G.Class("UMG_RecoverNumber_C")

function UMG_RecoverNumber_C:Initialize()
  Log.Debug("UMG_RecoverNumber_C:Initialize")
end

function UMG_RecoverNumber_C:Construct()
  Log.Debug("UMG_RecoverNumber_C:Construct")
end

function UMG_RecoverNumber_C:Destruct()
  Log.Debug("UMG_RecoverNumber_C:Destruct")
  self:StopAllAnimations()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_RecoverNumber_C:PlayEffect(val)
  self:InternalPlayEffect(val)
end

function UMG_RecoverNumber_C:ResetEffect()
  Log.Debug("UMG_RecoverNumber_C:ResetEffect")
  if self.ValTxt then
    self.ValTxt:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_RecoverNumber_C:InternalPlayEffect(val)
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  Log.Debug("UMG_RecoverNumber_C:InternalPlayEffect")
  if self:IsAnimationPlaying(self.Open) then
    self:StopAnimation(self.Open)
  end
  if self.ValTxt then
    self.ValTxt:SetText(string.format("+%d", val))
    self.ValTxt:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    Log.Warning("UMG_RecoverNumber_C:InternalPlayEffect no ValTxt")
  end
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.Open)
end

function UMG_RecoverNumber_C:OnAnimationFinished(Animation)
  if Animation == self.Open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
    if self.ValTxt then
      self.ValTxt:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

return UMG_RecoverNumber_C
