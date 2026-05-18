local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local ProtoEnum = require("Data.PB.ProtoEnum")
local UMG_PVPQualifier_HeadPortrait_C = Base:Extend("UMG_PVPQualifier_HeadPortrait_C")

function UMG_PVPQualifier_HeadPortrait_C:OnConstruct()
  self:AddButtonListener(self.Button1, self.OnClickPet)
end

function UMG_PVPQualifier_HeadPortrait_C:OnDestruct()
  self:RemoveButtonListener(self.Button1, self.OnClickPet)
end

function UMG_PVPQualifier_HeadPortrait_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self:InitPanel()
end

function UMG_PVPQualifier_HeadPortrait_C:OnItemSelected(_bSelected)
end

function UMG_PVPQualifier_HeadPortrait_C:OnDeactive()
end

function UMG_PVPQualifier_HeadPortrait_C:OnLogin()
end

function UMG_PVPQualifier_HeadPortrait_C:OnAnimationFinished(anim)
end

function UMG_PVPQualifier_HeadPortrait_C:OnClickPet()
  if self.uiData.canClickOpenTeamReplace then
    if self.uiData.hasPet then
      _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.OnCmdHideUmgPVPQualifier)
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetTeamReplacePanel, self.uiData.teamType, self.uiData.teamIdx, self.uiData.petGid, nil, PetUIModuleEnum.ModifyPetMode.SingleEdit, PetUIModuleEnum.OpenTeamReplaceType.PvpQualifier)
    else
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetTeamReplacePanel, self.uiData.teamType, self.uiData.teamIdx, nil, self.index, PetUIModuleEnum.ModifyPetMode.SingleEdit, PetUIModuleEnum.OpenTeamReplaceType.PvpQualifier)
    end
  end
end

function UMG_PVPQualifier_HeadPortrait_C:RefreshPlayerPet()
  if not self.uiData.hasPet then
    self.Switcher:SetActiveWidgetIndex(0)
    self.Text_Number:SetText(self.index)
    return
  end
  self.Switcher:SetActiveWidgetIndex(1)
  local petInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.uiData.petGid, self.uiData.isMirror)
  local UnknownVisibility = UE4.ESlateVisibility.Collapsed
  local TryOutVisibility = UE4.ESlateVisibility.Collapsed
  local HeadIconVisibility = UE4.ESlateVisibility.Collapsed
  local ReportVisibility = UE4.ESlateVisibility.Collapsed
  local TryOutIconPath = ""
  local textLevelText = ""
  if petInfo then
    local petTypeInfoType = PetUtils.GetPetTypeInfoType(petInfo)
    local baseConfId = petInfo.base_conf_id
    textLevelText = petInfo.level or ""
    if baseConfId then
      HeadIconVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
      self.HeadIcon:SetIconPathAndMaterial(petInfo.base_conf_id, petInfo.mutation_type, petInfo.glass_info)
    elseif petTypeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
      textLevelText = "??"
      TryOutVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
      UnknownVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
      local typeInfo = petInfo and petInfo.type
      local typeInfoParam = typeInfo and typeInfo.param
      local skillDamType = typeInfoParam
      if 0 == skillDamType then
        TryOutIconPath = BattleConst.RandomPetTypeIcon
      else
        local damType = skillDamType
        local typeDictionaryConf = _G.DataConfigManager:GetTypeDictionary(damType)
        TryOutIconPath = typeDictionaryConf and typeDictionaryConf.type_icon or ""
      end
    end
    if petInfo.is_trial_pet then
      TryOutVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
      TryOutIconPath = BattleConst.TrialPetTypeIcon
    end
  end
  self.txtLV:SetText(textLevelText)
  self.TryOut:SetVisibility(TryOutVisibility)
  self.Unknown:SetVisibility(UnknownVisibility)
  self.HeadIcon:SetVisibility(HeadIconVisibility)
  self.Report:SetVisibility(ReportVisibility)
  if not string.IsNilOrEmpty(TryOutIconPath) then
    self.TryOut:SetPath(TryOutIconPath)
  end
end

function UMG_PVPQualifier_HeadPortrait_C:RefreshEnemyPet()
  self.Switcher:SetActiveWidgetIndex(1)
  local petBaseId = self.uiData.pet_base_id
  local mutationType = self.uiData.mutation_type
  local petTypeInfo = self.uiData and self.uiData.type
  local petTypeInfoType = petTypeInfo and petTypeInfo.type
  local UnknownVisibility = UE4.ESlateVisibility.Collapsed
  local ReportVisibility = UE4.ESlateVisibility.Collapsed
  local TryOutVisibility = UE4.ESlateVisibility.Collapsed
  if petTypeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
    ReportVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
  end
  self.HeadIcon:SetIconPathAndMaterial(petBaseId, mutationType, self.uiData.glass_info)
  self.txtLV:SetText(self.uiData.pet_level)
  self.Unknown:SetVisibility(UnknownVisibility)
  self.Report:SetVisibility(ReportVisibility)
  self.TryOut:SetVisibility(TryOutVisibility)
end

function UMG_PVPQualifier_HeadPortrait_C:InitPanel()
  if self.uiData.isPlayer then
    self:RefreshPlayerPet()
  else
    self:RefreshEnemyPet()
  end
end

return UMG_PVPQualifier_HeadPortrait_C
