local UMG_PetBaseInfo2_C = _G.NRCViewBase:Extend("UMG_PetBaseInfo2_C")
local PetUtils = require("NewRoco.Utils.PetUtils")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")

function UMG_PetBaseInfo2_C:OnConstruct()
  self:SetChildViews(self.PetRadarInfo, self.UMG_PetRate)
  self:AddButtonListener(self.UMG_btnLevelUp.btnLevelUp, self.OnClickBtn1)
  self:AddButtonListener(self.SkillBtn, self.OnFeatureSkillBtnClick)
  self:AddButtonListener(self.NRCButton_112, self.OnNRCButton_112Click)
  self:AddButtonListener(self.NRCButton_43, self.OnNRCButton_112Click)
  self:AddButtonListener(self.NRCButton_1, self.OnTalentBtnClick)
  self:AddButtonListener(self.NRCButton, self.OnTalentBtnClick)
  self:AddButtonListener(self.BloodPulse, self.OnBloodPulse)
  self:AddButtonListener(self.BtnRechristen_1, self.OnBtnRechristen_1Click)
  self.NRCButton_43.OnPressed:Add(self, self.OnNRCButton_43Pressed)
  self.NRCButton_43.OnReleased:Add(self, self.OnNRCButton_43Released)
  self.NRCButton_112.OnPressed:Add(self, self.OnNRCButton_43Pressed)
  self.NRCButton_112.OnReleased:Add(self, self.OnNRCButton_43Released)
  self.NRCButton_1.OnPressed:Add(self, self.OnNRCButton_1Pressed)
  self.NRCButton_1.OnReleased:Add(self, self.OnNRCButton_1Released)
  self.NRCButton.OnPressed:Add(self, self.OnNRCButton_1Pressed)
  self.NRCButton.OnReleased:Add(self, self.OnNRCButton_1Released)
  self.Button_Dazzling.OnPressed:Add(self, self.OnOpenIconTips)
  self.Button_Dazzling.OnReleased:Add(self, self.OnReleaseMutationBtn)
  self.Button_DazzlingYise.OnPressed:Add(self, self.OnOpenIconTips)
  self.Button_DazzlingYise.OnReleased:Add(self, self.OnReleaseMutationBtn)
  self.Button_Heterochrome.OnPressed:Add(self, self.OnOpenIconTips)
  self.Button_Heterochrome.OnReleased:Add(self, self.OnReleaseMutationBtn)
  self.Button_Nightmare.OnPressed:Add(self, self.OnOpenIconTips)
  self.Button_Nightmare.OnReleased:Add(self, self.OnReleaseMutationBtn)
  self.Button_DazzlingSeason.OnPressed:Add(self, self.OnOpenIconTips)
  self.Button_DazzlingSeason.OnReleased:Add(self, self.OnReleaseMutationBtn)
  self.Button_DazzlingSeason_Hide.OnPressed:Add(self, self.OnOpenIconTips)
  self.Button_DazzlingSeason_Hide.OnReleased:Add(self, self.OnReleaseMutationBtn)
  self.BloodPulse.OnPressed:Add(self, self.OnBloodPulsePressed)
  self.BloodPulse.OnReleased:Add(self, self.OnBloodPulseReleased)
  self.BtnRechristen_1.OnPressed:Add(self, self.OnRechristenPressed)
  self.BtnRechristen_1.OnReleased:Add(self, self.OnRechristenReleased)
end

function UMG_PetBaseInfo2_C:OnDestruct()
  self.NRCButton_43.OnPressed:Clear()
  self.NRCButton_43.OnReleased:Clear()
  self.NRCButton_112.OnPressed:Clear()
  self.NRCButton_112.OnReleased:Clear()
  self.NRCButton_1.OnPressed:Clear()
  self.NRCButton_1.OnReleased:Clear()
  self.NRCButton.OnPressed:Clear()
  self.NRCButton.OnReleased:Clear()
  self.Button_Dazzling.OnPressed:Clear()
  self.Button_Dazzling.OnReleased:Clear()
  self.Button_DazzlingYise.OnPressed:Clear()
  self.Button_DazzlingYise.OnReleased:Clear()
  self.Button_Heterochrome.OnPressed:Clear()
  self.Button_Heterochrome.OnReleased:Clear()
  self.Button_Nightmare.OnPressed:Clear()
  self.Button_Nightmare.OnReleased:Clear()
  self.Button_DazzlingSeason.OnPressed:Clear()
  self.Button_DazzlingSeason.OnReleased:Clear()
  self.Button_DazzlingSeason_Hide.OnPressed:Clear()
  self.Button_DazzlingSeason_Hide.OnReleased:Clear()
  self.BloodPulse.OnPressed:Clear()
  self.BloodPulse.OnReleased:Clear()
  self.BtnRechristen_1.OnPressed:Clear()
  self.BtnRechristen_1.OnReleased:Clear()
end

function UMG_PetBaseInfo2_C:OnClickBtn1()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_PetBaseInfo2_C:OnClickBtn1")
  local callback1 = self.callback1
  if callback1 then
    callback1()
  end
end

function UMG_PetBaseInfo2_C:OnFeatureSkillBtnClick()
  if self.petData then
    _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenPeculiarityTips, self.petData)
  end
end

function UMG_PetBaseInfo2_C:OnCollectBtn()
  if self.petData then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetCollectPanel, self.petData.gid, self.petData.partner_mark)
  end
end

function UMG_PetBaseInfo2_C:OnNRCButton_112Click()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetBaseInfo2_C:OnNRCButton_112Click")
  if self.petData then
    _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.PetUIOpendblockerTips, TipEnum.OpenPetTipsType.InheritancePet, self.petData)
  end
end

function UMG_PetBaseInfo2_C:OnTalentBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetBaseInfo2_C:OnTalentBtnClick")
  if self.petData then
    _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenTipsStrongPoint, self.petData)
  end
end

function UMG_PetBaseInfo2_C:OnBloodPulse()
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_PetBaseInfo2_C:OnBloodPulse")
  if self.petData then
    _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.PetUIOpenPetBloodPulse, self.petData)
  end
end

function UMG_PetBaseInfo2_C:OnBtnRechristen_1Click()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetBaseInfo2_C:OnBtnRechristen_1Click")
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.PetUIOpenPetTips, self.petData)
end

function UMG_PetBaseInfo2_C:OnOpenIconTips()
  self:StopAnimation(self.Press_3)
  self:StopAnimation(self.Up_3)
  self:PlayAnimation(self.Press_3)
  local petData = self.petData
  if not petData then
    return
  end
  if PetUtils.CheckIsHiddenShiningGlass(petData.mutation_type, petData.glass_info) or PetUtils.CheckIsHiddenGlass(petData.mutation_type, petData.glass_info) or PetUtils.CheckIsShiningGlass(petData.mutation_type) or PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenDazzlingTipsPanel, petData)
  elseif PetUtils.CheckIsCHAOS(petData.mutation_type) or PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenMutationTipsPanel, petData)
  end
end

function UMG_PetBaseInfo2_C:OnNRCButton_43Pressed()
  self:StopAnimation(self.Press_4)
  self:StopAnimation(self.Up_4)
  self:PlayAnimation(self.Press_4)
end

function UMG_PetBaseInfo2_C:OnNRCButton_43Released()
  self:StopAnimation(self.Press_4)
  self:StopAnimation(self.Up_4)
  self:PlayAnimation(self.Up_4)
end

function UMG_PetBaseInfo2_C:OnNRCButton_1Pressed()
  self:StopAnimation(self.Press_5)
  self:StopAnimation(self.Up_5)
  self:PlayAnimation(self.Press_5)
end

function UMG_PetBaseInfo2_C:OnNRCButton_1Released()
  self:StopAnimation(self.Press_5)
  self:StopAnimation(self.Up_5)
  self:PlayAnimation(self.Up_5)
end

function UMG_PetBaseInfo2_C:OnReleaseMutationBtn()
  self:StopAnimation(self.Press_3)
  self:StopAnimation(self.Up_3)
  self:PlayAnimation(self.Up_3)
end

function UMG_PetBaseInfo2_C:OnBloodPulsePressed()
  self:StopAnimation(self.Press_2)
  self:StopAnimation(self.Up_2)
  self:PlayAnimation(self.Press_2)
end

function UMG_PetBaseInfo2_C:OnBloodPulseReleased()
  self:StopAnimation(self.Press_2)
  self:StopAnimation(self.Up_2)
  self:PlayAnimation(self.Up_2)
end

function UMG_PetBaseInfo2_C:OnRechristenPressed()
  self:StopAnimation(self.Press_1)
  self:StopAnimation(self.Up_1)
  self:PlayAnimation(self.Press_1)
end

function UMG_PetBaseInfo2_C:OnRechristenReleased()
  self:StopAnimation(self.Press_1)
  self:StopAnimation(self.Up_1)
  self:PlayAnimation(self.Up_1)
end

function UMG_PetBaseInfo2_C:updatePetLevelAndExp(petData)
  local petLevelConf = _G.DataConfigManager:GetPetLevelConf(petData.level)
  local curExp = petData.exp or 0
  local maxExp = petLevelConf and petLevelConf.pet_exp or 1
  local expInfo, levelInfo
  local maxPetLevel = PetUtils.GetPetMaxLevel(petData)
  if petData.level > 1 then
    petLevelConf = _G.DataConfigManager:GetPetLevelConf(petData.level - 1)
    if petLevelConf then
      maxExp = maxExp - petLevelConf.pet_exp
      curExp = curExp - petLevelConf.pet_exp
    end
  end
  expInfo = string.format("%d<tex2>/%d</>", curExp, maxExp)
  levelInfo = string.format("<lv>%d</><tex2>/%d</>", petData.level or 0, maxPetLevel)
  self.NRCText_MAX:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.textPetExp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.textPetExp:SetText(expInfo)
  self.textPetLevel:SetText(levelInfo)
  self.progressPetExp:SetPercent(curExp / maxExp)
  local maxPetLevelInfo = _G.DataConfigManager:GetPetGlobalConfig("pet_level_toplimit").num
  if maxPetLevelInfo <= petData.level then
    self.textPetExp:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.progressPetExp:SetPercent(1)
  end
  if maxPetLevelInfo > petData.level and petData.overflow_exp and 0 ~= petData.overflow_exp then
    self.textPetExp_1:SetText(petData.overflow_exp)
    self.experience:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.experience:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetBaseInfo2_C:updateFeatureSkill(petBaseConf)
  local skillId, lock = PetUtils.GetPetFeatrueSkillId(petBaseConf)
  if lock then
    self.CanvasPanel_71:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif 0 ~= skillId then
    self.CanvasPanel_71:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local skillCfg = _G.DataConfigManager:GetSkillConf(skillId)
    if skillCfg then
      if skillCfg.icon then
        self.SkillIcon:SetPath(skillCfg.icon)
      end
      self.SkillNameTxt:SetText(skillCfg.name)
    end
  else
    self.CanvasPanel_71:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetBaseInfo2_C:updatePetGender(_gender)
  local genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  for gender, genderIcon in ipairs(genderIcons) do
    if _gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PetBaseInfo2_C:updatePetTypeIcon(_dicTypes, _bloodId)
  local typeList = {}
  for _, Type in ipairs(_dicTypes) do
    table.insert(typeList, Type)
  end
  self.Attr1:InitGridView(typeList)
  local BloodTypeList = {}
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(_bloodId)
  if PetBloodConf then
    table.insert(BloodTypeList, {
      Name = PetBloodConf.blood_name,
      Path = PetBloodConf.icon
    })
  end
  self.Attr:InitGridView(BloodTypeList)
end

function UMG_PetBaseInfo2_C:UpdateMedalIcon(petData)
  local _, WearMedal = _G.DataModelMgr.PlayerDataModel:GetMedalListAndWearMedalByPetGid(petData.gid)
  if WearMedal then
    local MedalConf = _G.DataConfigManager:GetMedalConf(WearMedal.conf_id)
    if MedalConf then
      self.MedaIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.MedaIcon:SetPath(MedalConf.icon)
    end
  else
    self.MedaIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetBaseInfo2_C:updatePetTotleProp(petData, petBaseConf)
  local PetBasePropList = {
    Enum.AttributeType.AT_HPMAX,
    Enum.AttributeType.AT_PHYATK,
    Enum.AttributeType.AT_PHYDEF,
    Enum.AttributeType.AT_SPEATK,
    Enum.AttributeType.AT_SPEDEF,
    Enum.AttributeType.AT_SPEED
  }
  if petData and petBaseConf then
    local value = 0
    for _, propType in ipairs(PetBasePropList) do
      value = value + PetUtils.CalcProperty(petBaseConf, petData, propType) or 0
    end
    self.textPetTotleProp:SetText(value)
  end
end

function UMG_PetBaseInfo2_C:SetCatchHardLV(petData)
  self.CatchHardLv:Clear()
  local BreakThroughStarsList = PetUtils.GetBreakThroughStarsList(petData)
  self.CatchHardLv:InitGridView(BreakThroughStarsList)
end

function UMG_PetBaseInfo2_C:UpdatePetMutationIcon(petData)
  self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if petData and petData.mutation_type ~= _G.Enum.MutationDiffType.MDT_NONE then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
      self.Switcher:SetActiveWidgetIndex(0)
      self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_CHAOS) then
      self.Switcher:SetActiveWidgetIndex(1)
    elseif PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
      self.Switcher:SetActiveWidgetIndex(2)
      self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PetBaseInfo2_C:SetSpecialSign(petData)
  self.State_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if PetUtils.CheckIsCHAOS(petData.mutation_type) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(2)
  elseif PetUtils.CheckIsHiddenShiningGlass(petData.mutation_type, petData.glass_info) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(5)
    local path = self:GetHiddenGlassIcon(petData, true)
    if "" ~= path then
      self.Nightmare_3:SetPath(path)
    end
  elseif PetUtils.CheckIsShiningGlass(petData.mutation_type) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(3)
  elseif PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(1)
  elseif PetUtils.CheckIsHiddenGlass(petData.mutation_type, petData.glass_info) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(4)
    local path = self:GetHiddenGlassIcon(petData, false)
    if "" ~= path then
      self.Nightmare_2:SetPath(path)
    end
  elseif PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(0)
  end
end

function UMG_PetBaseInfo2_C:SetPetInfo(petData)
  self.petData = petData
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  self.Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.UMG_CollectBtn:UpdateInfo(petData.partner_mark, true)
  self.UMG_CollectBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  if 0 ~= petData.changed_nature_neg_attr_type or 0 ~= petData.changed_nature_pos_attr_type then
    self.Character:SetPath("PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_lailang_png.img_lailang_png'")
  else
    self.Character:SetPath("PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_character_png.img_character_png'")
  end
  if petData.speciality_id then
    local petTalentConf = _G.DataConfigManager:GetPetTalentConf(petData.speciality_id)
    if petTalentConf then
      self.textPetNature_1:SetText(petTalentConf.name)
    end
  end
  self.petHpText:SetText(string.format("<curhp4>%d</><curhp4>/%d</>", petData.energy, petBaseConf.max_energy))
  local petNatureConf = _G.DataConfigManager:GetNatureConf(petData.nature)
  if petNatureConf then
    self.textPetNature:SetText(petNatureConf.name or "")
  end
  if self.PetRadarInfo and self.PetRadarInfo.updatePetInfo then
    self.PetRadarInfo:updatePetInfo(petData, petBaseConf)
  end
  local name = petData.name
  if not string.IsNilOrEmpty(name) then
    local len = utf8.len(name)
    if len and len > _G.DataConfigManager:GetPetGlobalConfig("pet_name_num_max").num then
      name = string.sub(name, 1, string.len(name) - 3)
    end
  else
    name = petBaseConf.name
  end
  self.textPetName:SetText(name)
  self.UMG_PetEvoTip:SetIcon(petData.ball_id)
  self.UMG_PetEvoTip:SetDisableEvoTips(true)
  self.UMG_PetRate:SetText(petData, TipEnum.OpenPetTipsType.InheritancePet)
  self:updatePetLevelAndExp(petData)
  self:updateFeatureSkill(petBaseConf)
  self:updatePetGender(petData.gender)
  self:updatePetTypeIcon(petBaseConf.unit_type, petData.blood_id)
  self:UpdateMedalIcon(petData)
  self:updatePetTotleProp(petData, petBaseConf)
  self:SetCatchHardLV(petData)
  self:UpdatePetMutationIcon()
  self:SetSpecialSign(petData)
end

function UMG_PetBaseInfo2_C:SetOneButtonWithoutRedpoint(btnText, caller, callback, ...)
  self.Btn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Btn:SetActiveWidgetIndex(0)
  self.UMG_btnLevelUp:SetBtnText(btnText)
  self.callback1 = _G.MakeWeakFunctor(caller, callback, ...)
end

function UMG_PetBaseInfo2_C:GetHiddenGlassIcon(petData, bShiningGlass)
  if petData and petData.glass_info then
    local HiddenGlassID = petData.glass_info.glass_value
    if HiddenGlassID then
      local HiddenGlassConf = _G.DataConfigManager:GetHiddenGlassConf(HiddenGlassID)
      if HiddenGlassConf then
        if bShiningGlass and HiddenGlassConf.yise_icon then
          return HiddenGlassConf.yise_icon
        elseif HiddenGlassConf.icon then
          return HiddenGlassConf.icon
        end
      end
    end
  end
  return ""
end

return UMG_PetBaseInfo2_C
