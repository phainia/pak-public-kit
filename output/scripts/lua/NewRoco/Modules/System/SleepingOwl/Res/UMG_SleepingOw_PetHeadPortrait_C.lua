local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SleepingOw_PetHeadPortrait_C = Base:Extend("UMG_SleepingOw_PetHeadPortrait_C")

function UMG_SleepingOw_PetHeadPortrait_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.PetBaseId)
  if PetBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(PetBaseConf.model_conf)
    self.Pet:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
    self.NRCImage_80:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IconText_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_SleepingOw_PetHeadPortrait_C
