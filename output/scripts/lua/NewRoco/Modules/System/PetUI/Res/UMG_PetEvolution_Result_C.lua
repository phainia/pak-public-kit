local UMG_PetEvolution_Result_C = _G.NRCPanelBase:Extend("UMG_PetEvolution_Result_C")

function UMG_PetEvolution_Result_C:OnConstruct()
  self.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  self:PlayAnimation(self.In)
end

function UMG_PetEvolution_Result_C:OnActive(arg)
  self.petID = arg.petID
  self.evoPetID = arg.evoPetID
  self.Action = arg.Action
  self:OnAddEventListener()
  self:InitConfig()
  self:InitUI()
end

function UMG_PetEvolution_Result_C:OnAddEventListener()
  self:AddButtonListener(self.BtnConfirm.btnLevelUp, self.OnBtnConfirmClick)
  self:AddButtonListener(self.CloseBtn, self.OnBtnConfirmClick)
  self:AddButtonListener(self.DepartBtn, self.OnBtnRechristenClick)
end

function UMG_PetEvolution_Result_C:InitConfig()
  if self.petID and self.evoPetID then
    self.PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petID)
    self.PetEvoConf = _G.DataConfigManager:GetPetbaseConf(self.evoPetID)
  end
end

function UMG_PetEvolution_Result_C:InitUI()
  self:UpdateText()
  self:UpdatePetGender()
  self:UpdatePetTypeIcon()
  self:SetTalentRank()
  self:SetSkillCharacter()
end

function UMG_PetEvolution_Result_C:UpdateText()
  local globalConfigID = _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG
  if globalConfigID then
    if _G.DataConfigManager:GetGlobalConfigByKeyType("pet_evolution_button_2", globalConfigID) then
      local confirmBtnTxt = _G.DataConfigManager:GetGlobalConfigByKeyType("pet_evolution_button_2", globalConfigID).str
      self.BtnConfirm:SetBtnText(confirmBtnTxt)
    end
    if self.PetEvoConf then
      local name = self.PetEvoConf.name
      if name then
        self.Evo_PetName:SetText(name)
      end
    end
  end
end

function UMG_PetEvolution_Result_C:SetTalentRank()
  self.PetRate:SetText({})
end

function UMG_PetEvolution_Result_C:UpdatePetTypeIcon()
  local typeList = {}
  local BloodTypeList = {}
  if self.PetEvoConf then
    local _dicTypes = self.PetEvoConf.unit_type
    for _, Type in ipairs(_dicTypes or {}) do
      table.insert(typeList, Type)
    end
  end
  self.Attr1:InitGridView(typeList)
  self.Attr:InitGridView(BloodTypeList)
end

function UMG_PetEvolution_Result_C:UpdatePetGender()
  for _, genderIcon in ipairs(self.genderIcons) do
    genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetEvolution_Result_C:SetSkillCharacter()
  self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PetEvolution_Result_C:OnBtnConfirmClick()
  if self:IsAnimationPlaying(self.Out) then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetEvolution_Result_C:OnBtnOKClick")
  self:PlayAnimation(self.Out)
end

function UMG_PetEvolution_Result_C:OnBtnRechristenClick()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_PetBaseInfo_C:OnBtnBtnRechristenClick")
  self:StopAnimation(self.Press_1)
  self:StopAnimation(self.Up_1)
  self:PlayAnimation(self.Press_1)
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.PetUIOpenPetTips, {
    base_conf_id = self.evoPetID
  })
end

function UMG_PetEvolution_Result_C:OnAnimationFinished(Anim)
  if Anim == self.Press_1 then
    self:PlayAnimation(self.Up_1)
  elseif Anim == self.Press_2 then
    self:PlayAnimation(self.Up_2)
  elseif Anim == self.Out then
    if self.Action then
      self.Action:Finish()
    end
    self.DelayId = _G.DelayManager:DelaySeconds(0.3, function()
      _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.ClosePetEvoOnlyPanel)
      self:DoClose()
    end)
  end
end

function UMG_PetEvolution_Result_C:OnDestruct()
  self:RemoveButtonListener(self.BtnConfirm.btnLevelUp)
  self:RemoveButtonListener(self.CloseBtn)
  self:RemoveButtonListener(self.DepartBtn)
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  self.Action = nil
end

return UMG_PetEvolution_Result_C
