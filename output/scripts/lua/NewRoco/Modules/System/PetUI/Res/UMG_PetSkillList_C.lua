local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetSkillList_C = Base:Extend("UMG_PetSkillList_C")

function UMG_PetSkillList_C:OnConstruct()
end

function UMG_PetSkillList_C:OnDestruct()
end

function UMG_PetSkillList_C:OnItemUpdate(_data, datalist, index)
  self.NRCSwitcher_te:SetActiveWidgetIndex(_data.iconType - 1)
end

function UMG_PetSkillList_C:OnItemSelected(_bSelected)
end

function UMG_PetSkillList_C:OnDeactive()
end

return UMG_PetSkillList_C
