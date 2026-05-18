local UMG_CompassUnLockTips_C = _G.NRCPanelBase:Extend("UMG_CompassUnLockTips_C")

function UMG_CompassUnLockTips_C:OnActive(param)
  self:DoShow(param)
end

function UMG_CompassUnLockTips_C:OnDeactive()
  if self.request then
    _G.NRCResourceManager:UnLoadResByCaller(self)
  end
end

function UMG_CompassUnLockTips_C:OnConstruct()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_CompassUnLockTips_C:OnAddEventListener()
end

function UMG_CompassUnLockTips_C:DoShow(param)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.IconText:SetText(param.name)
  self.request = _G.NRCResourceManager:LoadResAsync(self, param.icon, -1, -1, function(caller, resRequest, asset)
    self:SetTexture(asset)
  end, nil, nil)
  if param.name == LuaText.umg_compassunlocktips_1 then
  else
  end
  self.Icon:SetPath(param.icon)
  self:ShowUnlock()
end

function UMG_CompassUnLockTips_C:SetTexture(Texture)
  self.Icon1:GetDynamicMaterial():SetTextureParameterValue("Maintex", Texture)
  self.Icon1:GetDynamicMaterial():SetTextureParameterValue("Mask_Texture", Texture)
  self.Icon2:GetDynamicMaterial():SetTextureParameterValue("Maintex", Texture)
  self.Icon2:GetDynamicMaterial():SetTextureParameterValue("Mask_Texture", Texture)
end

function UMG_CompassUnLockTips_C:ShowUnlock()
  self:PlayAnimation(self.LevelUpTips)
end

function UMG_CompassUnLockTips_C:ShowGuide()
end

function UMG_CompassUnLockTips_C:SetParent(parent)
  self.ParentPanel = parent
end

function UMG_CompassUnLockTips_C:OnAnimationFinished(Animation)
  if Animation == self.LevelUpTips then
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.DoCompassUnlockShow)
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ParentPanel:ConsumeNext()
  end
end

return UMG_CompassUnLockTips_C
