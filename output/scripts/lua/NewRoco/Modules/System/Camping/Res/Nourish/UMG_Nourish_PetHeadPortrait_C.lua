local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Nourish_PetHeadPortrait_C = Base:Extend("UMG_Nourish_PetHeadPortrait_C")

function UMG_Nourish_PetHeadPortrait_C:OnConstruct()
end

function UMG_Nourish_PetHeadPortrait_C:OnDestruct()
end

function UMG_Nourish_PetHeadPortrait_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.PetBaseId)
  local modelConf = _G.DataConfigManager:GetModelConf(PetBaseConf.model_conf)
  self.Pet:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
end

function UMG_Nourish_PetHeadPortrait_C:OnItemSelected(_bSelected)
end

function UMG_Nourish_PetHeadPortrait_C:OnDeactive()
end

return UMG_Nourish_PetHeadPortrait_C
