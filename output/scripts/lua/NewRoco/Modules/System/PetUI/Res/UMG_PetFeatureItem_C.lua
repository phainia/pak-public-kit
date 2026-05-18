local UMG_PetFeatureItem_C = _G.NRCViewBase:Extend("UMG_PetFeatureItem_C")

function UMG_PetFeatureItem_C:Initialize(Initializer)
end

function UMG_PetFeatureItem_C:OnConstruct()
  Log.Debug("UMG_PetFeatureItem_C:OnConstruct")
  self.uiData = {}
  self:OnAddEventListener()
end

function UMG_PetFeatureItem_C:OnDestruct()
  self:OnRemoveEventListener()
  self.uiData = nil
  Log.Debug("UMG_PetFeatureItem_C:OnDestruct")
end

function UMG_PetFeatureItem_C:OnEnable()
end

function UMG_PetFeatureItem_C:OnDisable()
end

function UMG_PetFeatureItem_C:OnAddEventListener()
  self:AddButtonListener(self.featureBtn, self.Ontip)
end

function UMG_PetFeatureItem_C:OnRemoveEventListener()
end

function UMG_PetFeatureItem_C:Ontip()
  Log.Debug("UMG_PetFeatureItem_C:Ontip")
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenPetFeatureTips, self.uiData.skillConf)
  _G.NRCAudioManager:PlaySound2DAuto(1212, "UMG_PetFeatureItem_C:Ontip")
end

function UMG_PetFeatureItem_C:SetValue()
  local skillConf = self.uiData.skillConf
  if skillConf then
    self.specialSkillIicon:SetPath(skillConf.icon)
    self.nameTxt:SetText(skillConf.name)
  end
end

function UMG_PetFeatureItem_C:ShowOrHide(_isShow)
  if _isShow then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetFeatureItem_C:updatePetInfo(_petData, _skillConf)
  self.uiData.petData = _petData
  self.uiData.skillConf = _skillConf
  self:SetValue()
end

return UMG_PetFeatureItem_C
