local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_TerritoryTrial_LevelInformationText_C = Base:Extend("UMG_Activity_TerritoryTrial_LevelInformationText_C")

function UMG_Activity_TerritoryTrial_LevelInformationText_C:OnConstruct()
end

function UMG_Activity_TerritoryTrial_LevelInformationText_C:OnDestruct()
end

function UMG_Activity_TerritoryTrial_LevelInformationText_C:OnItemUpdate(_data, datalist, index)
  self.Name1:SetText(_data.name)
  self.ContentDetails1:SetText(_data.desc)
end

function UMG_Activity_TerritoryTrial_LevelInformationText_C:OnItemSelected(_bSelected)
end

function UMG_Activity_TerritoryTrial_LevelInformationText_C:OnDeactive()
end

return UMG_Activity_TerritoryTrial_LevelInformationText_C
