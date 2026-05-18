local UMG_RecoverUpTips_C = _G.NRCPanelBase:Extend("UMG_RecoverUpTips_C")

function UMG_RecoverUpTips_C:OnActive(data)
  local title = _G.DataConfigManager:GetLocalizationConf("alchemy_bottle_volume_result_title")
  self.Title:SetText(title and title.msg or "\232\175\183\233\133\141\231\189\174alchemy_bottle_volume_result_title")
  self.origin_value = data.origin_value
  self.target_value = data.target_value
  self.OldText:SetText(string.format("%d", self.origin_value))
  self.NewText:SetText(string.format("%d", self.target_value))
  self:OnAddEventListener()
  _G.NRCAudioManager:PlaySound2DAuto(1372, "ShowTips")
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.In)
end

function UMG_RecoverUpTips_C:OnDeactive()
end

function UMG_RecoverUpTips_C:OnAddEventListener()
  self:AddButtonListener(self.HotArea, self.OnClose)
end

function UMG_RecoverUpTips_C:OnClose()
  if self:IsPlayingAnimation() then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "Close Panel")
  self:PlayAnimation(self.Out)
end

function UMG_RecoverUpTips_C:OnAnimationFinished(Animation)
  if Animation == self.In then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  elseif Animation == self.Out then
    _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.ShowRewardFinish)
    self:DoClose()
  end
end

return UMG_RecoverUpTips_C
