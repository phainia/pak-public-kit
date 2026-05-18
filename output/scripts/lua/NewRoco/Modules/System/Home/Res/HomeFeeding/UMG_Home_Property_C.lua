local UMG_Home_Property_C = _G.NRCPanelBase:Extend("UMG_Home_Property_C")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local HomeModuleEvent = require("NewRoco/Modules/System/Home/HomeModuleEvent")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_Home_Property_C:OnConstruct()
  self.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  self:SetChildViews(self.CommonPetDetails, self.UMG_PetRate)
end

function UMG_Home_Property_C:OnActive(petData, furnitureId)
  if not petData or not furnitureId then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40008035, "UMG_Home_Property_C:OnActive")
  self:PlayAnimation(self.In, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  self.currentFurnitureId = furnitureId
  self:SetPetInfo(petData)
  self:OnAddEventListener()
end

function UMG_Home_Property_C:OnAddEventListener()
  self:AddButtonListener(self.BtnPackUp.btnLevelUp, self.ClosePanel)
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.ClosePanel)
  self:AddButtonListener(self.changeBtn4.btnLevelUp, self.ConfirmPetLiveIn)
  self:AddButtonListener(self.UMG_CollectBtn.Button, self.OnCollectBtn)
  self:AddButtonListener(self.BloodPulse, self.OnBloodPulse)
  self:AddButtonListener(self.BtnRechristen_1, self.OpenPetTips)
  self:RegisterEvent(self, HomeModuleEvent.SwitchDetailPanelData, self.UpdatePanelData)
end

function UMG_Home_Property_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_Home_Property_C:ClosePanel")
  local panel = self.module:GetPanel("HomePetChoosing")
  if panel then
    panel:PlayAnimation(panel.Change_open)
  end
  self:PlayAnimation(self.Out)
  self:DoClose()
end

function UMG_Home_Property_C:ConfirmPetLiveIn()
  if self.petData then
    _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Home_Property_C:ConfirmPetLiveIn")
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.ConfirmPetLive, self.petData.gid, self.currentFurnitureId)
  end
end

function UMG_Home_Property_C:OnCollectBtn()
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenPetCollectPanel, self.petData.gid, self.petData.partner_mark)
end

function UMG_Home_Property_C:UpdateCollect(partner_mark)
  self.petData.partner_mark = partner_mark
  self.UMG_CollectBtn:UpdateInfo(partner_mark)
end

function UMG_Home_Property_C:OnBloodPulse()
  local itemNum = self.AttrList_2:GetItemCount()
  for i = 1, itemNum do
    self.AttrList_2:OpItemByIndex(i, {type = 0, animName = "Press"})
  end
  local petData = self.petData
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenPetBloodPulse, petData, TipEnum.OpenPetTipsType.HomePet)
end

function UMG_Home_Property_C:OpenPetTips()
  local itemNum = self.AttrList_1:GetItemCount()
  for i = 1, itemNum do
    self.AttrList_1:OpItemByIndex(i, {type = 0, animName = "Press"})
  end
  local uiData = {
    petData = self.petData
  }
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenPetTips, uiData, _G.Enum.GoodsType.GT_PET)
end

function UMG_Home_Property_C:UpdatePanelData(petData)
  if not petData then
    return
  end
  self:PlayAnimation(self.Change, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  self:SetPetInfo(petData)
end

function UMG_Home_Property_C:GetChangeAttrReqEnum(attribute)
  if not attribute then
    return nil
  end
  if attribute == Enum.AttributeType.AT_HPMAX then
    return Enum.AttributeType.AT_HPMAX_PERCENT
  elseif attribute == Enum.AttributeType.AT_PHYATK then
    return Enum.AttributeType.AT_PHYATK_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEATK then
    return Enum.AttributeType.AT_SPEATK_PERCENT
  elseif attribute == Enum.AttributeType.AT_PHYDEF then
    return Enum.AttributeType.AT_PHYDEF_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEDEF then
    return Enum.AttributeType.AT_SPEDEF_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEED then
    return Enum.AttributeType.AT_SPEED_PERCENT
  end
end

function UMG_Home_Property_C:GetPetFeatrueSkillId(baseConf)
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

function UMG_Home_Property_C:InitFeatures(skillId, lock)
  if 0 == skillId or nil == skillId then
    self.SizeBox_67:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local skillCfg = _G.DataConfigManager:GetSkillConf(skillId)
  if skillCfg then
    if skillCfg.icon then
      self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      self.SkillIconBg:SetVisibility(UE4.ESlateVisibility.Visible)
      self.SkillIcon:SetPath(skillCfg.icon)
    else
      self.SkillIconBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.SkillNameTxt:SetText(skillCfg.name)
    local skillDesc = skillCfg.desc
    self.NRCTextDes:SetText(skillDesc)
    self.SizeBox_67:SetVisibility(UE4.ESlateVisibility.Visible)
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.SizeBox_67:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Home_Property_C:GetPetEquipSkills(petData)
  local petEquipSkills = {}
  if petData then
    for i, skillData in ipairs(petData.skill.skill_data) do
      if skillData.is_equipped and 1 == skillData.type and skillData.pos > 0 and skillData.pos <= 4 then
        petEquipSkills[skillData.pos] = skillData
      end
    end
  end
  return petEquipSkills
end

function UMG_Home_Property_C:SetPetInfo(petData)
  self.petData = petData
  self.textPetName:SetText(self.petData.name or "")
  for gender, genderIcon in ipairs(self.genderIcons) do
    if self.petData.gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self.UMG_PetRate:SetText(self.petData, TipEnum.OpenPetTipsType.HomePet)
  self.textPetLv:SetText(self.petData.level)
  self.CatchHardLv:Clear()
  local PetStarsList = PetUtils.GetPetStarsListByPetGID(self.petData.gid)
  self.CatchHardLv:InitGridView(PetStarsList)
  local typeInfoTable = {}
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  local petType = petBaseConf.unit_type
  if petType and type(petType) == "table" and #petType >= 1 then
    for i = 1, table.len(petType) do
      local typeDic = _G.DataConfigManager:GetTypeDictionary(petType[i])
      if typeDic then
        table.insert(typeInfoTable, {
          Name = typeDic.short_name,
          Path = typeDic.type_icon
        })
      end
    end
    if typeInfoTable then
      self.AttrList_1:InitGridView(typeInfoTable)
    end
  end
  local petBloodConf = _G.DataConfigManager:GetPetBloodConf(self.petData.blood_id)
  local bloodInfoTable = {
    {
      Name = petBloodConf.blood_name,
      Path = petBloodConf.icon
    }
  }
  self.AttrList_2:InitGridView(bloodInfoTable)
  self.CommonPetDetails:InitPetBaseInfo(self.petData, petBaseConf)
  self.CommonPetDetails:SetSpecificOpenPetTipsType(TipEnum.OpenPetTipsType.HomePet)
  self.UMG_CollectBtn:UpdateInfo(self.petData.partner_mark, true)
end

function UMG_Home_Property_C:OnDeactive()
  local petUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
  if petUIModule then
    petUIModule:UnRegisterEvent(self, PetUIModuleEvent.UpdatePetCollect)
  end
  self:UnRegisterEvent(self, HomeModuleEvent.SwitchDetailPanelData)
end

return UMG_Home_Property_C
