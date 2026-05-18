local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ActivityGraphList_C = Base:Extend("UMG_ActivityGraphList_C")

function UMG_ActivityGraphList_C:OnConstruct()
end

function UMG_ActivityGraphList_C:OnDestruct()
end

function UMG_ActivityGraphList_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.Bg:SetPath(_data.kvBg)
end

function UMG_ActivityGraphList_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenSeasonalCombinationBagShop, _G.AppearanceModuleEnum.FashionMallShopId.SEASONAL_COMBINATION_BAG, self.index)
  end
end

function UMG_ActivityGraphList_C:OnDeactive()
end

return UMG_ActivityGraphList_C
