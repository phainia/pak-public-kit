local Enum = reload("Data.Config.Enum")
local UMG_PetFeatureTips_C = _G.NRCPanelBase:Extend("UMG_PetFeatureTips_C")

function UMG_PetFeatureTips_C:Initialize(Initializer)
end

function UMG_PetFeatureTips_C:OnConstruct()
  Log.Debug("UMG_PetFeatureTips_C:OnConstruct")
  self.uiData = {}
  self:OnAddEventListener()
end

function UMG_PetFeatureTips_C:OnActive(_param, ...)
  self:PlayAnimation(self.Appear)
  self.uiData.skillConf = _param
  self:ShowInfo()
end

function UMG_PetFeatureTips_C:SetPanelData(module, panelData)
  self.panelName = panelData.panelName
  self.panelData = panelData
  self.module = module
end

function UMG_PetFeatureTips_C:OnDestruct()
  self:OnRemoveEventListener()
  self.uiData = nil
end

function UMG_PetFeatureTips_C:OnEnable()
end

function UMG_PetFeatureTips_C:OnDisable()
end

function UMG_PetFeatureTips_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnClose)
end

function UMG_PetFeatureTips_C:OnRemoveEventListener()
end

function UMG_PetFeatureTips_C:ShowInfo()
  local skillConf = self.uiData.skillConf
  if skillConf then
    self.specialSkillIicon:SetPath(skillConf.icon)
    self.nameTxt:SetText(skillConf.name)
    self.NRCText_Des:SetText(skillConf.desc)
  end
end

function UMG_PetFeatureTips_C:OnClose()
  self.btnCloseTips:SetIsEnabled(false)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1076, "UMG_Handbook_C:OnPressRewardsBtn")
  self:PlayAnimation(self.Disappear)
end

function UMG_PetFeatureTips_C:OnAnimationFinished(Animation)
  if Animation == self.Disappear then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.ClosePetFeatureTips)
    self.btnCloseTips:SetIsEnabled(true)
  end
end

return UMG_PetFeatureTips_C
