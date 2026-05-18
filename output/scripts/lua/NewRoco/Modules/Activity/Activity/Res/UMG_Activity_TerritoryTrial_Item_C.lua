local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_TerritoryTrial_Item_C = Base:Extend("UMG_Activity_TerritoryTrial_Item_C")

function UMG_Activity_TerritoryTrial_Item_C:OnItemUpdate(_data, datalist, index)
  self.HeadIcon:SetIconPathAndMaterial(_data.base_id)
end

return UMG_Activity_TerritoryTrial_Item_C
