local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local UMG_ChangePetConfirmPanel_C = _G.NRCPanelBase:Extend("UMG_ChangePetConfirmPanel_C")

function UMG_ChangePetConfirmPanel_C:OnConstruct()
  self.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  self:SetChildViews(self.UMG_PetRate, self.CommonPetDetails)
end

function UMG_ChangePetConfirmPanel_C:OnDestruct()
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:OnDisable()
  end
end

function UMG_ChangePetConfirmPanel_C:OnActive(data, NeedBtn, PetNum, PetNumLimit, SkillPanel)
  if NeedBtn then
    self.UMG_Btn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Exchange:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UMG_Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Exchange:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.UpperLimit:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SkillPanel = SkillPanel
  if self.SkillPanel then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local posToIdDic = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetPetEquipSkillMap, data.PetData.gid, PetUIModuleEnum.PetEquipSkillType.PetBag)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetAssumptionEquipSkill, data.PetData.gid, posToIdDic)
    self.ChangePetSkillsPanel:LoadPanel(nil, data.PetData)
  else
    self.NRCSwitcher_46:SetActiveWidgetIndex(0)
    self.PanelSwitcher:SetActiveWidgetIndex(0)
    self:PlayAnimation(self.In)
  end
  self.data = self.module:GetData("PetUIModuleData")
  self.descText = {}
  self.skillId = nil
  self:SetPetInfo(data.PetData)
  self:UpDateLimit(PetNum, PetNumLimit)
  self:OnAddEventListener()
  self:RefreshShowLockSkillBtn()
  self.ShadeImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_ChangePetConfirmPanel_C:SetBtnVisible(NeedBtn)
  if NeedBtn then
    self.UMG_Btn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Exchange:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Btn_In)
  else
    self:PlayAnimation(self.Btn_Out)
  end
end

function UMG_ChangePetConfirmPanel_C:RefreshInfo()
  if self.petData then
    self:SetPetData(_G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.petData.gid))
    self:SetPetInfo(self.petData)
  end
end

function UMG_ChangePetConfirmPanel_C:UpDateLimit(PetNum, PetNumLimit)
  self.UpperLimit:InitNum(PetNum, PetNumLimit, "\228\187\147\229\186\147\231\178\190\231\129\181")
end

function UMG_ChangePetConfirmPanel_C:SetPetInfo(PetData)
  if not PetData then
    return
  end
  self.IconList:ScrollToStart()
  if PetData.PetBaseInfo then
    if self.petData and self.petData.gid == PetData.PetBaseInfo.gid then
    else
      self:PlayAnimation(self.Change)
    end
    self:SetPetData(PetData.PetBaseInfo)
  else
    if self.petData and self.petData.gid == PetData.gid then
    else
      self:PlayAnimation(self.Change)
    end
    self:SetPetData(PetData)
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petData.base_conf_id)
  local commonAttrData = {}
  local commonAttrData1 = {}
  self:UpdateChangePetSkills()
  self.textPetName:SetText(self.petData.name)
  self:updatePetGender(self.petData.gender)
  self.UMG_PetRate:SetText(self.petData, TipEnum.OpenPetTipsType.PetWareHouse)
  self.textPetLv:SetText(self.petData.level)
  local BreakThroughStarsList = PetUtils.GetBreakThroughStarsList(self.petData)
  self.CatchHardLv:InitGridView(BreakThroughStarsList)
  local petType = petBaseConf and petBaseConf.unit_type or {}
  for i = 1, 2 do
    if i <= #petType then
      local typeDic = _G.DataConfigManager:GetTypeDictionary(petType[i])
      if typeDic then
        table.insert(commonAttrData1, {
          Name = typeDic.short_name,
          Path = typeDic.type_icon
        })
      end
    end
  end
  if self.Attr1 then
    self.Attr1:InitGridView(commonAttrData1)
  end
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(self.petData.blood_id)
  self.UMG_CollectBtn:UpdateInfo(self.petData.partner_mark, true)
  table.insert(commonAttrData, {
    Name = PetBloodConf.blood_name,
    Path = PetBloodConf.icon
  })
  if self.Attr then
    self.Attr:InitGridView(commonAttrData)
  end
  local attrList = {}
  local attrInfo = self.petData.attribute_info
  local positive_effect, negative_effect
  local natureConf = _G.DataConfigManager:GetNatureConf(self.petData.nature)
  if 0 ~= self.petData.changed_nature_pos_attr_type then
    positive_effect = self:GetChangeAttrReqEnum(self.petData.changed_nature_pos_attr_type)
  else
    positive_effect = natureConf and natureConf.positive_effect
  end
  if 0 ~= self.petData.changed_nature_neg_attr_type then
    negative_effect = self:GetChangeAttrReqEnum(self.petData.changed_nature_neg_attr_type)
  else
    negative_effect = natureConf and natureConf.negative_effect
  end
  self.CommonPetDetails:InitPetBaseInfo(self.petData, petBaseConf)
  self:CheckCanSendToFriend()
end

function UMG_ChangePetConfirmPanel_C:SetPetData(PetData)
  if not self.petData or self.petData.base_conf_id ~= PetData.base_conf_id then
    self:InitFilterAndSort()
  end
  self.petData = PetData
end

function UMG_ChangePetConfirmPanel_C:SetWeigthAndStature(PetBaseInfo)
  if not PetBaseInfo.weight or not PetBaseInfo.height then
    return
  end
  local WeightData = PetBaseInfo.weight * 0.001
  local num = string.format("%.2f", WeightData)
  self.TextWeight:SetText(num)
  self.TextStature:SetText(string.format("%.2f", PetBaseInfo.height * 0.01))
end

function UMG_ChangePetConfirmPanel_C:GetChangeAttrReqEnum(attribute)
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

function UMG_ChangePetConfirmPanel_C:updatePetGender(_gender)
  for gender, genderIcon in ipairs(self.genderIcons) do
    if _gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_ChangePetConfirmPanel_C:GetPetFeatrueSkillId(baseConf)
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

function UMG_ChangePetConfirmPanel_C:InitFeatures(PetbaseConf)
  local skillId, lock = PetUtils.GetPetFeatrueSkillId(PetbaseConf)
  if lock then
    self.CanvasPanel_71:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif skillId and 0 ~= skillId then
    self.CanvasPanel_71:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local skillCfg = _G.DataConfigManager:GetSkillConf(skillId)
    if skillCfg then
      if skillCfg.icon then
        self.SkillIcon_1:SetPath(skillCfg.icon)
      end
      self.SkillNameTxt_1:SetText(skillCfg.name)
    else
      self.CanvasPanel_71:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.CanvasPanel_71:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ChangePetConfirmPanel_C:GetPetEquipSkills(petData)
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

function UMG_ChangePetConfirmPanel_C:OnDeactive()
end

function UMG_ChangePetConfirmPanel_C:TryClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(40002010, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  if self.IsChangeSkill then
    self.NRCSwitcher_46:SetActiveWidgetIndex(0)
    self.PanelSwitcher:SetActiveWidgetIndex(0)
    self.IsChangeSkill = false
    local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
    if ChangePetSkillsPanel then
      ChangePetSkillsPanel:OnDisable()
    end
    self:InitFilterAndSort()
    return
  end
  if self.data.bPetWarehouseTipBtnEnable then
    if 0 == GlobalConfig.OpenMainPanelFromDebugBtn then
      _G.NRCModuleManager:DoCmd(CampingModuleCmd.OpenPetWarehouseTips, false)
    end
    local panel = self.module:GetPanel("PetWarehousePanelMain")
    if panel then
      panel:PlayAnimation(panel.House_open)
    end
    self:PlayAnimation(self.Out)
  end
end

function UMG_ChangePetConfirmPanel_C:OnAddEventListener()
  self.BtnRechristen_1.OnPressed:Add(self, self.OnBtnRechristenPressed)
  self.BtnRechristen_1.OnReleased:Add(self, self.OnBtnRechristenReleased)
  self.BloodPulse.OnPressed:Add(self, self.OnBloodPulsePressed)
  self.BloodPulse.OnReleased:Add(self, self.OnBloodPulseReleased)
  self:AddButtonListener(self.Btn_Details, self.ClosePanel)
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.TryClosePanel)
  self:AddButtonListener(self.BtnRechristen_1, self.OpenPetTips)
  self:AddButtonListener(self.BloodPulse, self.OnBloodPulse)
  self:AddButtonListener(self.UMG_CollectBtn.Button, self.OnCollectBtn)
  self:AddButtonListener(self.UMG_Btn.btnLevelUp, self.OnBtnSkillClicked)
  self:AddButtonListener(self.changeBtn4.btnLevelUp, self.SaveSkillChange)
  self:AddButtonListener(self.changeBtn2.btnLevelUp, self.SaveSkillChange)
  self:AddButtonListener(self.ViewPet.btnLevelUp, self.OnSelectSkillClick)
  self:AddButtonListener(self.ViewPet_2.btnLevelUp, self.OnSortSkillClick)
  self:AddButtonListener(self.ViewPet_3.btnLevelUp, self.OnShowLockSkillClick)
  self:AddButtonListener(self.Exchange.btnLevelUp, self.OpenExChangeMainPetPanelBtnClick)
  self:AddButtonListener(self.RecommendedBtn.btnLevelUp, self.OnRecommendedBtnClick)
  self:AddButtonListener(self.RecommendedBtn_1.btnLevelUp, self.OnBtnCultivateClicked)
  self:AddButtonListener(self.GiftColleaguesBtn.btnLevelUp, self.OnGiftBtnClick)
  self:RegisterEvent(self, PetUIModuleEvent.OnSendPetFailed, self.OnSendPetFailed)
  self:RegisterEvent(self, PetUIModuleEvent.UpdatePetCollect, self.UpdateCollect)
  self:RegisterEvent(self, PetUIModuleEvent.UpdateChangePetSkillsPanel, self.UpdateChangePetSkills)
  self:RegisterEvent(self, PetUIModuleEvent.EQUIP_SKILL_SUCCESS, self.OnEquippedSuccess)
  if self.ChangePetSkillsPanel then
    self.ChangePetSkillsPanel.OnLoadPanelCallbackDelegate:Add(self, self.OnChangePetSkillPanelCallback)
  end
end

function UMG_ChangePetConfirmPanel_C:OnEquippedSuccess(_changes)
  local curPetData = self.petData
  if not curPetData or not _changes then
    return
  end
  for i, changItem in ipairs(_changes) do
    if changItem.type == _G.ProtoEnum.GoodsType.GT_PET then
      local petData = changItem.pet_data
      if curPetData.gid == petData.gid then
        self:SetPetData(petData)
        self:SetPetInfo(petData)
      end
    end
  end
end

function UMG_ChangePetConfirmPanel_C:OnChangePetSkillPanelCallback()
  if self.SkillPanel then
    self.SkillPanel = false
    self.NRCSwitcher_46:SetActiveWidgetIndex(2)
    self.PanelSwitcher:SetActiveWidgetIndex(1)
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.In)
  else
    self.NRCSwitcher_46:SetActiveWidgetIndex(2)
    self.PanelSwitcher:SetActiveWidgetIndex(1)
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_ChangePetConfirmPanel_C:UpdateCollect(partner_mark)
  self.petData.partner_mark = partner_mark
  self.UMG_CollectBtn:UpdateInfo(partner_mark)
end

function UMG_ChangePetConfirmPanel_C:UpdateChangePetSkills()
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:RefreshUI(self.petData)
  end
end

function UMG_ChangePetConfirmPanel_C:OnCollectBtn()
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetCollectPanel, self.petData.gid, self.petData.partner_mark)
end

function UMG_ChangePetConfirmPanel_C:OnBtnRechristenPressed()
  self:StopAnimation(self.BtnRechristen_Press)
  self:StopAnimation(self.BtnRechristen_Up)
  self:PlayAnimation(self.BtnRechristen_Press)
end

function UMG_ChangePetConfirmPanel_C:OnBtnRechristenReleased()
  self:StopAnimation(self.BtnRechristen_Press)
  self:StopAnimation(self.BtnRechristen_Up)
  self:PlayAnimation(self.BtnRechristen_Up)
end

function UMG_ChangePetConfirmPanel_C:OnBloodPulsePressed()
  self:StopAnimation(self.BloodPulse_Press)
  self:StopAnimation(self.BloodPulse_Up)
  self:PlayAnimation(self.BloodPulse_Press)
end

function UMG_ChangePetConfirmPanel_C:OnBloodPulseReleased()
  self:StopAnimation(self.BloodPulse_Press)
  self:StopAnimation(self.BloodPulse_Up)
  self:PlayAnimation(self.BloodPulse_Up)
end

function UMG_ChangePetConfirmPanel_C:OpenPetTips()
  local petData = self.petData
  local uidata = {petData = petData}
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenPetTips, uidata, _G.Enum.GoodsType.GT_PET)
end

function UMG_ChangePetConfirmPanel_C:OnFeatureSkillBtnClick()
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenPeculiarityTips, self.petData)
end

function UMG_ChangePetConfirmPanel_C:OnNRCButton_112Click()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_ChangePetConfirmPanel_C:OnBtnBtnRechristenClick")
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.PetUIOpendblockerTips, TipEnum.OpenPetTipsType.PetWareHouse, self.petData)
end

function UMG_ChangePetConfirmPanel_C:OnTalentBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_ChangePetConfirmPanel_C:OnBtnBtnRechristenClick")
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenTipsStrongPoint, self.petData)
end

function UMG_ChangePetConfirmPanel_C:OnBloodPulse()
  local petData = self.petData
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetBloodPulse, petData, TipEnum.OpenPetTipsType.PetWareHouse)
end

function UMG_ChangePetConfirmPanel_C:SaveSkillChange()
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:OnChangeButtonClick()
    ChangePetSkillsPanel:OnDisable()
  end
  self:InitFilterAndSort()
  self.NRCSwitcher_46:SetActiveWidgetIndex(0)
  self.PanelSwitcher:SetActiveWidgetIndex(0)
  self.IsChangeSkill = false
end

function UMG_ChangePetConfirmPanel_C:CloseTipsAndClearSkillListSelection()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.IsHavePetSkillTips)
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:ClearSkillListSelection()
  end
end

function UMG_ChangePetConfirmPanel_C:OnSelectSkillClick()
  self:CloseTipsAndClearSkillListSelection()
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:OpenSkillFilteringPanelByCurShowSkillList()
  end
end

function UMG_ChangePetConfirmPanel_C:OnSortSkillClick()
  self:CloseTipsAndClearSkillListSelection()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnCmdOpenPetSortPanel, self.sortRuleId, self.skillSortReverse)
end

function UMG_ChangePetConfirmPanel_C:OnPetSkillFilterRuleChange(filterRule)
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    local path
    if filterRule then
      path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_Screen3_png.img_Screen3_png'"
    else
      path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_Screen1_png.img_Screen1_png'"
    end
    self.ViewPet:SetPath(path, path, path)
    ChangePetSkillsPanel:OnPetSkillFilterRuleChange(filterRule)
  end
end

function UMG_ChangePetConfirmPanel_C:OnPetSkillSortRuleChange(id, skillSortReverse)
  self.sortRuleId = id
  self.skillSortReverse = skillSortReverse
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:OnPetSkillSortRuleChange(id, skillSortReverse)
  end
end

function UMG_ChangePetConfirmPanel_C:OnShowLockSkillClick()
  _G.NRCAudioManager:PlaySound2DAuto(40002004, "UMG_ChangePetConfirmPanel_C:OnShowLockSkillClick")
  self:CloseTipsAndClearSkillListSelection()
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    self.showLockSkill = not self.showLockSkill
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetIsShowPetNotUnlockSkill, self.showLockSkill)
    self:RefreshShowLockSkillBtn()
    ChangePetSkillsPanel:OnShowLockSkillChange(self.showLockSkill)
  end
end

function UMG_ChangePetConfirmPanel_C:RefreshShowLockSkillBtn()
  local path
  if self.showLockSkill then
    path = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_UnlockVisible_png.img_UnlockVisible_png'"
  else
    path = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_UnlockInvisible_png.img_UnlockInvisible_png'"
  end
  self.ViewPet_3:SetPath(path, path, path)
end

function UMG_ChangePetConfirmPanel_C:OnBtnSkillClicked()
  self.showLockSkill = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetIsShowPetNotUnlockSkill)
  self:RefreshShowLockSkillBtn()
  _G.NRCAudioManager:PlaySound2DAuto(40002004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  self.IsChangeSkill = true
  local posToIdDic = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetPetEquipSkillMap, self.petData.gid, PetUIModuleEnum.PetEquipSkillType.PetBag)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetAssumptionEquipSkill, data.PetData.gid, posToIdDic)
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:OnEnable(self.petData)
    self.NRCSwitcher_46:SetActiveWidgetIndex(2)
    self.PanelSwitcher:SetActiveWidgetIndex(1)
  else
    self.ChangePetSkillsPanel:LoadPanel(nil, self.petData)
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
  self:ShowSkillBtnState()
end

function UMG_ChangePetConfirmPanel_C:OnBtnCultivateClicked()
  self:DispatchEvent(PetUIModuleEvent.CultivatePet)
end

function UMG_ChangePetConfirmPanel_C:ShowSkillBtnState()
  if self.petData.blood_id == Enum.PetBloodType.PBT_NIGHTMARE then
    self.changeBtn4:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.changeBtn4:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_ChangePetConfirmPanel_C:OpenExChangeMainPetPanelBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self:DispatchEvent(PetUIModuleEvent.ExChangeMainPetPanel)
end

function UMG_ChangePetConfirmPanel_C:OnRecommendedBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_ChangePetConfirmPanel_C:OnRecommendedBtnClick")
  _G.NRCModeManager:DoCmd(_G.HandbookModuleCmd.OnCmdOpenDistrictMapGuide, self.petData)
end

function UMG_ChangePetConfirmPanel_C:OnNatureBtn()
  local petData = self.petData
  local uidata = {petData = petData}
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.OpendblockerTips, uidata, TipEnum.OpenPetTipsType.PetWareHouse)
end

function UMG_ChangePetConfirmPanel_C:PetSkillChangeToBaseInfo(PetInfo)
  if self.petData and PetInfo.gid ~= self.petData.gid and (self.IsChangeSkill or 1 == self.PanelSwitcher:GetActiveWidgetIndex()) then
    self.SkillPanel = false
    self.NRCSwitcher_46:SetActiveWidgetIndex(0)
    self.PanelSwitcher:SetActiveWidgetIndex(0)
    self.IsChangeSkill = false
    local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
    if ChangePetSkillsPanel then
      ChangePetSkillsPanel:OnDisable()
    end
    self:InitFilterAndSort()
  end
end

function UMG_ChangePetConfirmPanel_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(40002010, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  if self.data.bPetWarehouseTipBtnEnable then
    if 0 == GlobalConfig.OpenMainPanelFromDebugBtn then
      _G.NRCModuleManager:DoCmd(CampingModuleCmd.OpenPetWarehouseTips, false)
    end
    local panel = self.module:GetPanel("PetWarehousePanelMain")
    if panel then
      panel:PlayAnimation(panel.House_open)
    end
    self:PlayAnimation(self.Out)
  end
end

function UMG_ChangePetConfirmPanel_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:DoClose()
  elseif Anim == self.Btn_Out then
    self.UMG_Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Exchange:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ChangePetConfirmPanel_C:InitFilterAndSort()
  self.sortRuleId = 1
  self.skillSortReverse = false
  self.showLockSkill = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetIsShowPetNotUnlockSkill)
  local ChangePetSkillsPanel = self.ChangePetSkillsPanel:GetPanel()
  if ChangePetSkillsPanel then
    ChangePetSkillsPanel:InitFilterAndSort()
  end
  self:RefreshShowLockSkillBtn()
  local path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_Screen1_png.img_Screen1_png'"
  self.ViewPet:SetPath(path, path, path)
end

function UMG_ChangePetConfirmPanel_C:PetWarehouseReadyToClose()
  self.ShadeImage:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_ChangePetConfirmPanel_C:CheckCanSendToFriend()
  self.GiftColleaguesBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.petData and self.petData.together_catch_info and self.petData.together_catch_info.is_onwer_catch then
    local timeStamp = self.petData.together_catch_info.transfer_deadline
    if timeStamp then
      local currentTime = _G.ZoneServer:GetServerTime() / 1000
      if currentTime and timeStamp > currentTime then
        local text = LuaText.peer_pet_give_btn_text
        self.GiftColleaguesBtn:SetText(text)
        self.GiftColleaguesBtn:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end
end

function UMG_ChangePetConfirmPanel_C:OnGiftBtnClick()
  if self.petData and self.petData.gid then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SendPetToFriend, self.petData.gid, true)
  end
end

function UMG_ChangePetConfirmPanel_C:OnSendPetFailed()
  self:CheckCanSendToFriend()
end

return UMG_ChangePetConfirmPanel_C
