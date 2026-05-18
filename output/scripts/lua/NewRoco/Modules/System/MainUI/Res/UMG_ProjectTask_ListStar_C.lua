local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ProjectTask_ListStar_C = Base:Extend("UMG_ProjectTask_ListStar_C")

function UMG_ProjectTask_ListStar_C:OnConstruct()
end

function UMG_ProjectTask_ListStar_C:OnDestruct()
end

function UMG_ProjectTask_ListStar_C:OnItemUpdate(_data, datalist, index)
  self:PlayAnimation(self.Star_in)
end

function UMG_ProjectTask_ListStar_C:OnItemSelected(_bSelected)
end

function UMG_ProjectTask_ListStar_C:OnDeactive()
end

return UMG_ProjectTask_ListStar_C
