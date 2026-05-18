local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PastActivity_PopupItem_C = Base:Extend("UMG_PastActivity_PopupItem_C")

function UMG_PastActivity_PopupItem_C:OnConstruct()
end

function UMG_PastActivity_PopupItem_C:OnDestruct()
end

function UMG_PastActivity_PopupItem_C:OnItemUpdate(_data, datalist, index)
  self.TextTime:SetText(_data)
end

function UMG_PastActivity_PopupItem_C:OnItemSelected(_bSelected)
end

return UMG_PastActivity_PopupItem_C
