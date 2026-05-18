local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_PetSelectItem_C = _G.NRCViewBase:Extend("UMG_Activity_PetSelectItem_C")

function UMG_Activity_PetSelectItem_C:OnConstruct()
end

function UMG_Activity_PetSelectItem_C:OnDestruct()
end

function UMG_Activity_PetSelectItem_C:SetInfo(data)
  self:AddButtonListener(self.ExamineBtn.btnLevelUp, self.ExamineBtnClick)
  self.specFlowerSeedId = data.activity_spec_flower_seed_conf_id
  local bloodId = data.pet_blood_conf_id
  local bloodConf = _G.DataConfigManager:GetPetBloodConf(bloodId)
  local retSeedData, level = ActivityUtils.GetPlayerSelectSpecFlowerSeedDataById(self.specFlowerSeedId)
  local specFlowerSeedConf = retSeedData.seedConf
  self.PetBaseConf = _G.DataConfigManager:GetPetbaseConf(retSeedData.petBaseId)
  if specFlowerSeedConf.enum_pet_evo == Enum.SpecFlowerSeedPetId.SFSPI_PET_EVOLUTION_ID then
    self.petEvolutionList = _G.DataConfigManager:GetPetEvolutionConf(specFlowerSeedConf.pet_evo_param).evolution_chain
  elseif specFlowerSeedConf.enum_pet_evo == Enum.SpecFlowerSeedPetId.SFSPI_PET_BASE_ID then
    self.petEvolutionList = _G.DataConfigManager:GetPetEvolutionConf(self.PetBaseConf.pet_evolution_id[1]).evolution_chain
  end
  if self.PetBaseConf then
    local petType = self.PetBaseConf.unit_type
    self.List_1:InitGridView(petType)
  end
  self.Image:SetPath(data.image)
  self.flower:SetPath(bloodConf.icon_activity_limited_flower_seed)
  local Name = self.PetBaseConf.name
  for i, v in pairs(self.petEvolutionList) do
    if i == #self.petEvolutionList then
      Name = v.pet_name
    end
  end
  self.Text_Title:SetText(Name)
end

function UMG_Activity_PetSelectItem_C:OnAddEventListener()
end

function UMG_Activity_PetSelectItem_C:OnAnimationFinished(anim)
  if anim == self.Press_in or anim == self.Press_in then
    self:PlayAnimation(self.Press_loop)
  end
end

function UMG_Activity_PetSelectItem_C:ExamineBtnClick()
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OpenPetDetailPanel, self.PetBaseConf.id, true)
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_Activity_PetSelectItem_C:ExamineBtnClick")
end

function UMG_Activity_PetSelectItem_C:OnClick(NeedSetOtherUnSelect)
  self:StopAllAnimations()
  self:PlayAnimation(self.Press_in)
  _G.NRCModuleManager:GetModule("ActivityModule"):DispatchEvent(ActivityModuleEvent.SetSelectLimitedFlowerId, self.specFlowerSeedId, NeedSetOtherUnSelect)
end

function UMG_Activity_PetSelectItem_C:CancelSelect()
  self:StopAllAnimations()
  self:PlayAnimation(self.Press_out)
end

function UMG_Activity_PetSelectItem_C:OnTouchEnded(MyGeometry, InTouchEvent)
  self:OnClick(true)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

return UMG_Activity_PetSelectItem_C
