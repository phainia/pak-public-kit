local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_Level_FirstPublish_PetItem_C = Base:Extend("UMG_Level_FirstPublish_PetItem_C")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")

function UMG_Level_FirstPublish_PetItem_C:OnConstruct()
end

function UMG_Level_FirstPublish_PetItem_C:OnAddEventListener()
end

function UMG_Level_FirstPublish_PetItem_C:OnRemoveEventListener()
end

function UMG_Level_FirstPublish_PetItem_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_Level_FirstPublish_PetItem_C:OnItemUpdate(_data, datalist, index)
  self:OnAddEventListener()
  self.index = index
  self.petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(_data.pet_gid)
  self.gid = _data.pet_gid
  self.maxHp = PetUtils.GetPetAdditionalByType(self.petData, _G.ProtoEnum.AttributeType.AT_HPMAX)
  self.hp = self.maxHp
  self:UpdateUI()
end

function UMG_Level_FirstPublish_PetItem_C:OnItemSelected(Selected)
  if Selected then
    if not self.hasSelect then
      self.hasSelect = true
      self:PlayAnimation(self.select)
    end
    _G.NRCEventCenter:DispatchEvent(LevelSelectionModuleEvent.SelectFirstPetEvent, self.gid)
  elseif self.hasSelect then
    self.hasSelect = false
    self:PlayAnimation(self.cancel)
  end
end

function UMG_Level_FirstPublish_PetItem_C:SetSelectBg(visibility)
end

function UMG_Level_FirstPublish_PetItem_C:OnDeactive()
end

function UMG_Level_FirstPublish_PetItem_C:UpdateUI()
  if not self.petData then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.SelectedName:SetText(self.petData.name)
  self.SelectedGrade:SetText(string.format(LuaText.umg_petskilltemple2_1, self.petData.level))
  self.ProgressQuantity:SetText(self.hp .. "/" .. self.maxHp)
  self.Switcher_gender:SetActiveWidgetIndex(self.petData.gender - 1)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petData.base_conf_id)
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    self.HeadIcon:SetIconPathAndMaterial(self.petData.base_conf_id, self.petData.mutation_type, self.petData.glass_info)
  end
end

function UMG_Level_FirstPublish_PetItem_C:OpenDetailsPanel()
  NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenPreparePanelPetInfo)
end

return UMG_Level_FirstPublish_PetItem_C
