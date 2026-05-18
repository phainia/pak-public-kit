local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_WorldCombat_Heart_C = Base:Extend("UMG_WorldCombat_Heart_C")

function UMG_WorldCombat_Heart_C:OnConstruct()
end

function UMG_WorldCombat_Heart_C:OnDestruct()
end

function UMG_WorldCombat_Heart_C:OnItemUpdate(_data, datalist, index)
  if _data.show then
    self.Heart:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.Heart:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_WorldCombat_Heart_C:OnItemSelected(_bSelected)
end

function UMG_WorldCombat_Heart_C:OnDeactive()
end

return UMG_WorldCombat_Heart_C
