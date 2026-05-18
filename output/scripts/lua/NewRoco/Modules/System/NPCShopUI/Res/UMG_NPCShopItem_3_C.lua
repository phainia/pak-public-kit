local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_NPCShopItem_3_C = Base:Extend("UMG_NPCShopItem_3_C")

function UMG_NPCShopItem_3_C:OnConstruct()
end

function UMG_NPCShopItem_3_C:OnDestruct()
end

function UMG_NPCShopItem_3_C:OnItemUpdate(_data, datalist, index)
  Log.Dump(_data, 6, "UMG_NPCShopItem_3_C:OnItemUpdate")
end

function UMG_NPCShopItem_3_C:OnItemSelected(_bSelected)
end

function UMG_NPCShopItem_3_C:OnDeactive()
end

return UMG_NPCShopItem_3_C
