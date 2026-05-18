local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local AltarModuleEvent = require("NewRoco.Modules.System.AltarModule.AltarModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetAltarItem_C = Base:Extend("UMG_PetAltarItem_C")

function UMG_PetAltarItem_C:OnConstruct()
end

function UMG_PetAltarItem_C:OnDestruct()
end

function UMG_PetAltarItem_C:OnItemUpdate(petData, datalist, index)
  self:SetUnSelectedUI()
  Log.Dump(petData, 6, "UMG_PetAltarItem_C:OnItemUpdate")
  self.index = index
  self.uiData = petData
  local petBaseId = petData.base_conf_id
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
  if not petBaseConf then
    Log.Error("UMG_PetAltarItem_C:SetData \230\137\190\228\184\141\229\136\176petBaseConf")
    return
  end
  self.txtName:SetText(petBaseConf.name)
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
  if not modelConf then
    Log.Error("UMG_PetAltarItem_C:SetData \230\137\190\228\184\141\229\136\176modelConf")
    return
  end
  Log.Debug("iconPath", petData.gid)
  self.Icon:SetIconPathAndMaterial(petData.base_conf_id, petData.mutation_type, petData.glass_info)
  Log.Debug("lv", petData.level)
  self.txtLV:SetText(string.format(LuaText.umg_petaltaritem_1, petData.level))
  self:SetQuality(petBaseConf.quality)
end

function UMG_PetAltarItem_C:SetQuality(quality)
  if quality == _G.Enum.PetQuality.PQ_BLUE then
    self.Background:SetPath(UEPath.PROP_QUALITY_3)
  elseif quality == _G.Enum.PetQuality.PQ_PURPLE then
    self.Background:SetPath(UEPath.PROP_QUALITY_4)
  elseif quality == _G.Enum.PetQuality.PQ_ORANGE then
    self.Background:SetPath(UEPath.PROP_QUALITY_5)
  else
    self.Background:SetPath(UEPath.PROP_QUALITY_NONE)
  end
end

function UMG_PetAltarItem_C:UpdatePetMutationIcon()
  local petData = self.uiData
  self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if petData and petData.mutation_type ~= _G.Enum.MutationDiffType.MDT_NONE then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
      self.Switcher:SetActiveWidgetIndex(0)
    elseif PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_CHAOS) then
      self.Switcher:SetActiveWidgetIndex(1)
    elseif PetMutationUtils.GetMutationValue(petData.mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
      self.Switcher:SetActiveWidgetIndex(2)
    else
      self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PetAltarItem_C:OnItemSelected(selected)
  if selected then
    _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetAltarItem_C:OnItemSelectedTrue")
    self:SetSelectedUI()
    NRCEventCenter:DispatchEvent(AltarModuleEvent.PetAltarItemSelect, self.uiData)
  else
    _G.NRCAudioManager:PlaySound2DAuto(41401016, "UMG_PetAltarItem_C:OnItemSelectedFalse")
    self:SetUnSelectedUI()
    NRCEventCenter:DispatchEvent(AltarModuleEvent.PetAltarItemUnSelect)
  end
end

function UMG_PetAltarItem_C:SetSelectedUI()
  self.Background_Selected:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_PetAltarItem_C:SetUnSelectedUI()
  self.Background:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Background_Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_PetAltarItem_C:OnActive()
end

function UMG_PetAltarItem_C:OnDeactive()
end

return UMG_PetAltarItem_C
