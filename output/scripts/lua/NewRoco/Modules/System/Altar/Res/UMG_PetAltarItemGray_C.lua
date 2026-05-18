local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetAltarItemGray_C = Base:Extend("UMG_PetAltarItemGray_C")

function UMG_PetAltarItemGray_C:OnConstruct()
end

function UMG_PetAltarItemGray_C:OnDestruct()
end

function UMG_PetAltarItemGray_C:OnItemUpdate(petBaseId, datalist, index)
  self.index = index
  self:SetData(petBaseId)
end

function UMG_PetAltarItemGray_C:SetData(petBaseId)
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
  Log.Debug("iconPath", modelConf.ui_icon)
  self.Icon:SetPath(modelConf.icon)
  self:SetQuality(petBaseConf.quality)
end

function UMG_PetAltarItemGray_C:SetQuality(quality)
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

function UMG_PetAltarItemGray_C:OnActive()
end

function UMG_PetAltarItemGray_C:OnDeactive()
end

return UMG_PetAltarItemGray_C
