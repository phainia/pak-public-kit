local UMG_RecoverTimeUpTips_C = _G.NRCPanelBase:Extend("UMG_RecoverTimeUpTips_C")

function UMG_RecoverTimeUpTips_C:OnActive(data)
  local title = _G.DataConfigManager:GetLocalizationConf("alchemy_bottle_times_result_title")
  self.Title:SetText(title and title.msg or "\232\175\183\233\133\141\231\189\174alchemy_bottle_times_result_title")
  self.origin_value = data.origin_value
  self.target_value = data.target_value
  self.TimeUpItem:SetData(self.origin_value)
  self.TimeUpItem_1:SetData(self.target_value)
  local nowTimePoke = math.floor(_G.ZoneServer:GetServerTime() / 1000)
  local date = os.date("%Y.%m.%d", nowTimePoke)
  self.TimeText:SetText(date)
  self:OnAddEventListener()
  _G.NRCAudioManager:PlaySound2DAuto(1371, "ShowTips")
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.In)
end

function UMG_RecoverTimeUpTips_C:OnDeactive()
end

function UMG_RecoverTimeUpTips_C:OnAddEventListener()
  self:AddButtonListener(self.HotArea, self.OnClose)
end

function UMG_RecoverTimeUpTips_C:OnClose()
  if self:IsPlayingAnimation() then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "Close Panel")
  UE4Helper.SetEnableWorldRendering(true)
  self:PlayAnimation(self.Out)
end

function UMG_RecoverTimeUpTips_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.ShowRewardFinish)
    self:DoClose()
  elseif Animation == self.In then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

return UMG_RecoverTimeUpTips_C
