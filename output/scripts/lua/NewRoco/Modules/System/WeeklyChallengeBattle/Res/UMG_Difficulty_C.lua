local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Difficulty_C = Base:Extend("UMG_Difficulty_C")

function UMG_Difficulty_C:OnConstruct()
end

function UMG_Difficulty_C:OnDestruct()
end

function UMG_Difficulty_C:OnItemUpdate(_data, datalist, index)
  self.itemData = _data
  self:_InitItem()
end

function UMG_Difficulty_C:OnItemSelected(_bSelected)
end

function UMG_Difficulty_C:_InitItem()
  if self.itemData.bShow then
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
  else
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  end
end

function UMG_Difficulty_C:OnDeactive()
end

return UMG_Difficulty_C
