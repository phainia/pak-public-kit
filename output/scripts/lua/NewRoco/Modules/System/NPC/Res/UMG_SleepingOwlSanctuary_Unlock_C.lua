local UMG_SleepingOwlSanctuary_Unlock_C = _G.NRCPanelBase:Extend("UMG_SleepingOwlSanctuary_Unlock_C")

function UMG_SleepingOwlSanctuary_Unlock_C:OnActive(_Param)
  self:UpdateTipInfo(_Param)
end

function UMG_SleepingOwlSanctuary_Unlock_C:OnDeactive()
end

function UMG_SleepingOwlSanctuary_Unlock_C:OnAddEventListener()
end

function UMG_SleepingOwlSanctuary_Unlock_C:OnConstruct()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_SleepingOwlSanctuary_Unlock_C:OnDestruct()
  self:CancelDelay()
end

function UMG_SleepingOwlSanctuary_Unlock_C:UpdateTipInfo(_Param)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local Icon
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(_Param.bag_item.id)
  if BagItemConf then
    local MagicBaseConf = _G.DataConfigManager:GetMagicBaseConf(BagItemConf.magic_id)
    local LocalizationConf = _G.DataConfigManager:GetLocalizationConf(MagicBaseConf.localization_id)
    self.IconText:SetText(LocalizationConf.msg)
    Icon = MagicBaseConf.get_path or "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/T_UI_WZ_005.T_UI_WZ_005'"
    self.NRCImage_3:SetPath(Icon)
  end
  local request = NRCResourceManager:LoadResAsync(self, Icon, -1, -1, function(caller, resRequest, asset)
    self:SetMaterial(asset)
    self:PlayAnimation(self.LevelUpTips)
  end, nil, nil)
end

function UMG_SleepingOwlSanctuary_Unlock_C:OnAnimationFinished(anim)
  if anim == self.LevelUpTips then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ParentPanel:ConsumeNext()
  end
end

function UMG_SleepingOwlSanctuary_Unlock_C:SetParent(panel)
  self.ParentPanel = panel
end

return UMG_SleepingOwlSanctuary_Unlock_C
