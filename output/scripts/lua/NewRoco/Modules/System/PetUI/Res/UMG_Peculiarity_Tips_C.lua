local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_Peculiarity_Tips_C = _G.NRCPanelBase:Extend("UMG_Peculiarity_Tips_C")

function UMG_Peculiarity_Tips_C:OnActive(PetData)
  if PetData then
    _G.NRCAudioManager:PlaySound2DAuto(41400009, "UMG_Peculiarity_Tips_C:OnActive")
    local GetPetbaseConf = _G.DataConfigManager:GetPetbaseConf(PetData.base_conf_id)
    self.HeadIcon:SetIconPathAndMaterial(PetData.base_conf_id, PetData.mutation_type, PetData.glass_info)
    self.Title:SetText(LuaText.umg_petleftpanel_11)
    local skillId, lock = PetUtils.GetPetFeatrueSkillId(GetPetbaseConf)
    if 0 ~= skillId then
      local skillCfg = _G.DataConfigManager:GetSkillConf(skillId)
      if skillCfg then
        if skillCfg.icon then
          self.SkillIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.SkillIconBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.SkillIcon:SetPath(skillCfg.icon)
        end
        local skillDesc = skillCfg.desc
        self.descText = skillDesc
        self.NRCTextDes:SetText(skillDesc)
        self.SkillNameTxt:SetText(skillCfg.name)
      end
    end
  else
    Log.Error("UMG_Peculiarity_Tips_C:OnActive", "PetData is nil")
  end
  self:LoadAnimation(0)
  self:OnAddEventListener()
end

function UMG_Peculiarity_Tips_C:GetPetFeatureSkillId(baseConf)
  local skillId = baseConf.pet_feature
  if 0 ~= skillId then
    return skillId, false
  else
    local evolution_pet_id = baseConf.evolution_pet_id[1]
    if nil == evolution_pet_id then
      return
    end
    local evoPetbaseCfg = _G.DataConfigManager:GetPetbaseConf(evolution_pet_id)
    if evolution_pet_id then
      skillId = evoPetbaseCfg.pet_feature
      if 0 ~= skillId then
        return skillId, true
      end
    end
  end
  return 0
end

function UMG_Peculiarity_Tips_C:OnDeactive()
end

function UMG_Peculiarity_Tips_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnCloseButtonClicked)
  self:AddButtonListener(self.CloseHyperLink, self.OnCloseHyperLink)
  self:AddButtonListener(self.CloseHyperLink_1, self.OnCloseHyperLink)
  self.NRCTextDes.OnRichTextClick:Add(self, self.OnDescTextClicked)
end

function UMG_Peculiarity_Tips_C:OnCloseHyperLink()
end

function UMG_Peculiarity_Tips_C:OnDescTextClicked(id)
  local nounInterpretationTipsInfo = {}
  nounInterpretationTipsInfo.text = self.descText
  _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNounInterpretationTipsPanel, nounInterpretationTipsInfo)
end

function UMG_Peculiarity_Tips_C:OnPcClose()
  self:OnCloseButtonClicked()
end

function UMG_Peculiarity_Tips_C:OnCloseButtonClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_Peculiarity_Tips_C:OnActive")
  self:LoadAnimation(2)
end

function UMG_Peculiarity_Tips_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_Peculiarity_Tips_C
