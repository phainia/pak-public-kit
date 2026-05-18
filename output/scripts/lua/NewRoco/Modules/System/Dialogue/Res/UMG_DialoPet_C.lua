local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DialoPet_C = Base:Extend("UMG_DialoPet_C")

function UMG_DialoPet_C:OnConstruct()
end

function UMG_DialoPet_C:OnDestruct()
end

function UMG_DialoPet_C:OnItemUpdate(_data, datalist, index)
  self.Module = _G.NRCModuleManager:GetModule("PetUIModule")
  self.uiData = _data
  local SwitcherActiveIndex = 0
  local UnknownVisibility = UE4.ESlateVisibility.Collapsed
  local TryOutVisibility = UE4.ESlateVisibility.Collapsed
  local HeadIcon1Visibility = UE4.ESlateVisibility.Collapsed
  local TryOutIconPath = ""
  local textLevelText = ""
  if 0 == _data.petGid then
    SwitcherActiveIndex = 0
    self.Text_Number:SetText(index)
  else
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(_data.petGid, true)
    local petTypeInfoType = PetUtils.GetPetTypeInfoType(petData)
    if petTypeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
      SwitcherActiveIndex = 2
      textLevelText = "??"
      TryOutVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
      UnknownVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
      local typeInfo = petData and petData.type
      local typeInfoParam = typeInfo and typeInfo.param
      local skillDamType = typeInfoParam
      if 0 == skillDamType then
        TryOutIconPath = BattleConst.RandomPetTypeIcon
      else
        local damType = skillDamType
        local typeDictionaryConf = _G.DataConfigManager:GetTypeDictionary(damType)
        TryOutIconPath = typeDictionaryConf and typeDictionaryConf.type_icon or ""
      end
    elseif petData then
      SwitcherActiveIndex = 1
      self.HeadIcon:SetIconPathAndMaterial(petData.base_conf_id, petData.mutation_type, petData.glass_info)
    end
  end
  self.Switcher:SetActiveWidgetIndex(SwitcherActiveIndex)
  self.txtLV:SetText(textLevelText)
  self.TryOut:SetVisibility(TryOutVisibility)
  self.Unknown:SetVisibility(UnknownVisibility)
  self.HeadIcon_1:SetVisibility(HeadIcon1Visibility)
  self.TryOut:SetPath(TryOutIconPath)
end

function UMG_DialoPet_C:OnItemSelected(_bSelected)
end

function UMG_DialoPet_C:OnDeactive()
  self.uiData = nil
end

function UMG_DialoPet_C:OnLogin()
end

function UMG_DialoPet_C:OnAnimationFinished(anim)
end

function UMG_DialoPet_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

return UMG_DialoPet_C
