local UMG_Dialogue_MainRoleBlack_C = _G.NRCPanelBase:Extend("UMG_Dialogue_MainRoleBlack_C")

function UMG_Dialogue_MainRoleBlack_C:OnActive(showTime)
  self.Handler = nil
  self.ShowTime = showTime
  self:StopAllAnimations()
  self:PlayAnimation(self.FadeIn)
end

function UMG_Dialogue_MainRoleBlack_C:OnAnimationFinished(Animation)
  if not self then
    return
  end
  if Animation == self.FadeIn then
    local function cb()
      self:PlayAnimation(self.FadeOut)
    end
    
    if self.ShowTime and 0 ~= self.ShowTime then
      self.Handler = _G.DelayManager:DelaySeconds(self.ShowTime, cb)
    else
      cb()
    end
  elseif Animation == self.FadeOut then
    self:ClosePanel()
  end
end

function UMG_Dialogue_MainRoleBlack_C:ClosePanel()
  if self.Handler then
    _G.DelayManager:CancelDelayById(self.Handler)
    self.Handler = nil
  end
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.CLOSE_NORMAL_BLACK)
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.CloseNormalBlack)
end

return UMG_Dialogue_MainRoleBlack_C
