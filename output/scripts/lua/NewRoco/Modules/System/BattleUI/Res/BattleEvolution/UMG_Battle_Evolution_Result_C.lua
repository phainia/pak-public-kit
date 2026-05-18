local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Battle_Evolution_Result_C = _G.NRCPanelBase:Extend("UMG_Battle_Evolution_Result_C")

function UMG_Battle_Evolution_Result_C:OnConstruct()
  self.uiData = {}
  self.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  Log.Debug("[UMG_PetEvolutionFinish_C:OnConstruct]")
  self:PlayAnimation(self.In)
end

function UMG_Battle_Evolution_Result_C:OnDestruct()
  Log.Debug("[UMG_PetEvolutionFinish_C:OnDestruct]")
  local param = self.uiData.param
  if param and param.owner and param.callback then
    param.callback(param.owner)
  end
  self.uiData = nil
end

function UMG_Battle_Evolution_Result_C:OnActive(_param, _param1)
  _G.NRCPanelBase.OnActive(self, _param, _param1)
  _G.NRCModuleManager:DoCmd(_G.TeachingManualModuleCmd.OnZoneUnlockTeachConditionReq, ProtoEnum.TeachClientTrigger.CT_EVOLUTION)
  self:OnAddEventListener()
  self.uiData.param = _param
  self.uiData.isEvo = _param1
  if true == _param1 then
    if not self:UpdateText(true) then
      self:OnBtnConfirmClick()
    end
  elseif not self:UpdateText(false) then
    if _G.BattleAutoTest.IsAutoBattle or _G.BattleManager.battleRuntimeData:GetBattleMode() == BattleEnum.BattleMode.Replay then
      self:DelaySeconds(5, function()
        self:OnBtnConfirmClick()
      end)
    else
      self:OnBtnConfirmClick()
    end
  end
end

function UMG_Battle_Evolution_Result_C:OnDeactive(...)
  _G.NRCPanelBase.OnDeactive(self, ...)
end

function UMG_Battle_Evolution_Result_C:CheckRePlay()
end

function UMG_Battle_Evolution_Result_C:OnAddEventListener()
  self:AddButtonListener(self.BtnConfirm.btnLevelUp, self.OnBtnConfirmClick)
  self:AddButtonListener(self.CloseBtn, self.OnBtnConfirmClick)
  self:AddButtonListener(self.DepartBtn, self.OnBtnRechristen_1Click)
  self:AddButtonListener(self.BloodPulse_1, self.OnBloodPulse)
  self.DepartBtn.OnPressed:Add(self, self.OnDepartBtnPressed)
  self.DepartBtn.OnReleased:Add(self, self.OnDepartBtnReleased)
  self.BloodPulse_1.OnPressed:Add(self, self.OnBloodPulsePressed)
  self.BloodPulse_1.OnReleased:Add(self, self.OnBloodPulseReleased)
end

function UMG_Battle_Evolution_Result_C:Show(_param, _param1)
  self:OnActive(_param, _param1)
end

function UMG_Battle_Evolution_Result_C:UpdateCloseInfo()
end

function UMG_Battle_Evolution_Result_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.BtnConfirm.btnLevelUp)
  self:RemoveButtonListener(self.CloseBtn)
end

function UMG_Battle_Evolution_Result_C:UpdateText(bool)
  local globalConfigID = _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG
  local dialogTxt = _G.DataConfigManager:GetGlobalConfigByKeyType("pet_evolution_text_2", globalConfigID).str
  local petName = self.uiData.param.name
  local newPetCommonName = _G.BattleManager.battleRuntimeData.evolutionResultName
  local attrs = _G.BattleManager.battleRuntimeData.evolutionAttrs
  local beforeAttrs
  local showAttrs = true
  if true == bool then
    local confirmBtnTxt = _G.DataConfigManager:GetGlobalConfigByKeyType("pet_evolution_button_2", globalConfigID).str
    self.BtnConfirm:SetBtnText(confirmBtnTxt)
    local beforePetConf = _G.DataConfigManager:GetPetbaseConf(self.uiData.param.beforeBaseConfId)
    local afterPetConf = _G.DataConfigManager:GetPetbaseConf(self.uiData.param.afterBaseConfigId)
    if beforePetConf then
      petName = beforePetConf.name
      beforeAttrs = beforePetConf.unit_type
    end
    if afterPetConf then
      newPetCommonName = afterPetConf.name
      attrs = afterPetConf.unit_type
    end
    if beforeAttrs and #beforeAttrs == #attrs then
      if attrs[1] == beforeAttrs[1] then
        showAttrs = false
      else
        showAttrs = true
      end
    else
      showAttrs = true
    end
  else
    local confirmBtnTxt = _G.DataConfigManager:GetGlobalConfigByKeyType("pet_evolution_button_3", globalConfigID).str
    self.BtnConfirm:SetBtnText(confirmBtnTxt)
  end
  self.Evo_PetName:SetText(newPetCommonName)
  local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByPetBaseId(self.uiData.param.petbaseConfId)
  PetData = PetData or _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.uiData.param.petGid)
  if PetData then
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(PetData.base_conf_id)
    if PetBaseConf then
      self:updatePetGender(PetData.gender)
      self:updatePetTypeIcon(PetBaseConf.unit_type)
      self:SetSkillCharacter(PetBaseConf)
      self:SetTalentRank(PetData)
      return true
    end
  else
    return false
  end
end

function UMG_Battle_Evolution_Result_C:SetTalentRank(petData)
  self.PetRate:SetText(petData)
end

function UMG_Battle_Evolution_Result_C:OnDepartBtnPressed()
  self:StopAnimation(self.Press_1)
  self:StopAnimation(self.Up_1)
  self:PlayAnimation(self.Press_1)
end

function UMG_Battle_Evolution_Result_C:OnDepartBtnReleased()
  self:StopAnimation(self.Press_1)
  self:StopAnimation(self.Up_1)
  self:PlayAnimation(self.Up_1)
end

function UMG_Battle_Evolution_Result_C:OnBloodPulsePressed()
  self:StopAnimation(self.Press_2)
  self:StopAnimation(self.Up_2)
  self:PlayAnimation(self.Press_2)
end

function UMG_Battle_Evolution_Result_C:OnBloodPulseReleased()
  self:StopAnimation(self.Press_2)
  self:StopAnimation(self.Up_2)
  self:PlayAnimation(self.Up_2)
end

function UMG_Battle_Evolution_Result_C:updatePetTypeIcon(_dicTypes)
  local typeList = {}
  local BloodTypeList = {}
  for i, Type in ipairs(_dicTypes) do
    table.insert(typeList, Type)
  end
  self.Attr1:InitGridView(typeList)
  local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByPetBaseId(self.uiData.param.petbaseConfId)
  PetData = PetData or _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.uiData.param.petGid)
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(PetData.blood_id)
  if PetBloodConf then
    table.insert(BloodTypeList, {
      Name = PetBloodConf.blood_name,
      Path = PetBloodConf.icon
    })
  end
  self.Attr:InitGridView(BloodTypeList)
end

function UMG_Battle_Evolution_Result_C:updatePetGender(_gender)
  for gender, genderIcon in ipairs(self.genderIcons) do
    if _gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Battle_Evolution_Result_C:SetSkillCharacter(PetBaseConf)
  local skillId, lock = self:GetPetFeatrueSkillId(PetBaseConf)
  if 0 ~= skillId and 2 == PetBaseConf.stage then
    local skillCfg = _G.DataConfigManager:GetSkillConf(skillId)
    if skillCfg then
      if skillCfg.icon then
        self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Visible)
        self.SkillIcon:SetPath(NRCUtils:FormatConfIconPath(skillCfg.icon, _G.UIIconPath.SkillIconPath))
      else
        self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      local desc = string.gsub(skillCfg.desc, "%<(.-)>", "")
      self.NRCTextDes:SetText(desc)
      self.SkillNameTxt:SetText(skillCfg.name)
      self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Evolution_Result_C:GetPetFeatrueSkillId(petBaseConf)
  local uiData = self.uiData
  local beforePetBaseId = uiData and uiData.param and uiData.param.beforeBaseConfId
  local beforePetBaseConf = beforePetBaseId and _G.DataConfigManager:GetPetbaseConf(beforePetBaseId)
  local beforeFeatureSkillId = beforePetBaseConf and beforePetBaseConf.pet_feature
  local curFeatureSkillId = petBaseConf and petBaseConf.pet_feature
  if curFeatureSkillId ~= beforeFeatureSkillId then
    return curFeatureSkillId or 0
  end
  return 0
end

function UMG_Battle_Evolution_Result_C:OnBtnConfirmClick()
  self.CloseBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Battle_Evolution_Result_C:OnBtnOKClick")
  Log.Debug("[UMG_Battle_Evolution_Result_C:OnBtnOKClick]")
  if self.uiData and (self.uiData.isEvo == false or self.uiData.isEvo == nil) then
    Log.Debug("Battle Evo Progress: UMG_Battle_Evolution_Result_C OnBtnConfirmClick")
    Log.Debug("Battle Evo Progress: UMG_Battle_Evolution_Result_C OnBtnConfirmClick->Show Loading Panel(BattleUIModuleCmd.OpenLoading)")
    local asyncData = {
      owner = self,
      callback = self.CloseBattleEvoPanel
    }
    _G.NRCModuleManager:DoCmdAsync(asyncData, _G.BattleUIModuleCmd.OpenLoading)
  else
    local PetUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
    local panel = PetUIModule:GetPanel("PetEvoNewPanel")
    if panel then
      panel:OnEvoSuccClose()
    end
  end
end

function UMG_Battle_Evolution_Result_C:OnBtnRechristen_1Click()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetBaseInfo_C:OnBtnBtnRechristenClick")
  if self.uiData and self.uiData.param and self.uiData.param.petGid then
    local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.uiData.param.petGid)
    _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.PetUIOpenPetTips, PetData)
  end
end

function UMG_Battle_Evolution_Result_C:OnBloodPulse()
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_PetBaseInfo_C:OnBloodPulse")
  if self.uiData and self.uiData.param and self.uiData.param.petGid then
    local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.uiData.param.petGid)
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.PetUIOpenPetBloodPulse, PetData)
  end
end

function UMG_Battle_Evolution_Result_C:CloseBattleEvoPanel()
  _G.BattleManager.battleRuntimeData.isEvolutionWaiting = false
  Log.Debug("Battle Evo Progress: UMG_Battle_Evolution_Result_C OnBtnConfirmClick->Dispatch BattleEvent.BATTLE_PROCESS_EVOLUTION_END(maybe deprecated event?)")
  _G.BattleEventCenter:Dispatch(BattleEvent.BATTLE_PROCESS_EVOLUTION_END)
  Log.Debug("Battle Evo Progress: UMG_Battle_Evolution_Result_C Close Panel(BattleUIModuleCmd.CloseBattleEvolutionPanel)")
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.CloseBattleEvolutionPanel)
  Log.Debug("Battle Evo Progress: UMG_Battle_Evolution_Result_C Close Panel(BattleUIModuleCmd.CloseLoading)")
  local asyncData = {owner = self, callback = nil}
  NRCModuleManager:DoCmdAsync(asyncData, _G.BattleUIModuleCmd.CloseLoading)
  Log.Debug("Battle Evo Progress: UMG_Battle_Evolution_Result_C DoClose")
  self:DoClose()
end

return UMG_Battle_Evolution_Result_C
