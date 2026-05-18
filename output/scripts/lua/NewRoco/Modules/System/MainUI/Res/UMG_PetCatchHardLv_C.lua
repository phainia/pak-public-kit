local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetCatchHardLv_C = Base:Extend("UMG_PetCatchHardLv_C")

function UMG_PetCatchHardLv_C:OnConstruct()
end

function UMG_PetCatchHardLv_C:OnDestruct()
end

function UMG_PetCatchHardLv_C:OnItemUpdate(_data, _datalist, _index)
  self.uiData = _data
  self.index = _index
  Log.Dump(self.uiData, 2, "UMG_PetCatchHardLv_C:OnItemUpdate")
  self:UpdateItemInfo()
end

function UMG_PetCatchHardLv_C:UpdateItemInfo()
  self.LightSwitcher:SetActiveWidgetIndex(self.uiData)
end

return UMG_PetCatchHardLv_C
