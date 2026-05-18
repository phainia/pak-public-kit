local UMG_Alchemy_VitalityUpTips_C = _G.NRCPanelBase:Extend("UMG_Alchemy_VitalityUpTips_C")

function UMG_Alchemy_VitalityUpTips_C:OnActive(param)
  self:OnAddEventListener()
  local tipsTitle = _G.DataConfigManager:GetLocalizationConf("alchemy_bottle_stamina_result_title").msg
  self.Title:SetText(tipsTitle)
  self.VitalityUpTips_Item:SetUpgradeTimes(param.origin_upgradeId)
  local nowTimePoke = math.floor(_G.ZoneServer:GetServerTime() / 1000)
  local date = os.date("%Y.%m.%d", nowTimePoke)
  self.TimeText:SetText(date)
  _G.NRCAudioManager:PlaySound2DAuto(41500104, "UMG_Alchemy_VitalityUpTips_C:OnActive")
end

function UMG_Alchemy_VitalityUpTips_C:OnDeactive()
end

function UMG_Alchemy_VitalityUpTips_C:OnAddEventListener()
  self:AddButtonListener(self.HotArea, self.OnCloseBtnClicked)
end

function UMG_Alchemy_VitalityUpTips_C:OnRemoveEventListener()
end

function UMG_Alchemy_VitalityUpTips_C:OnConstruct()
end

function UMG_Alchemy_VitalityUpTips_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_Alchemy_VitalityUpTips_C:OnPcClose()
  if self.HotArea:IsVisible() then
    self:OnCloseBtnClicked()
  end
end

function UMG_Alchemy_VitalityUpTips_C:OnCloseBtnClicked()
  if self:IsPlayingAnimation() then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_Alchemy_VitalityUpTips_C:OnActive")
  self:OnClose()
end

function UMG_Alchemy_VitalityUpTips_C:OnAnimFinished(anim)
  if anim == self.Out then
    _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.ShowRewardFinish)
  end
end

return UMG_Alchemy_VitalityUpTips_C
