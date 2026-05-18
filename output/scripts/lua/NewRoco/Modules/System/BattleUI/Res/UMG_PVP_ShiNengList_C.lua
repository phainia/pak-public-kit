local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PVP_ShiNengList_C = Base:Extend("UMG_PVP_ShiNengList_C")

function UMG_PVP_ShiNengList_C:OnConstruct()
end

function UMG_PVP_ShiNengList_C:OnDestruct()
end

function UMG_PVP_ShiNengList_C:OnItemUpdate(_data, datalist, index)
  if _data.IsFirstOpenPanel == true then
    self:PlayAnimation(self.Open)
  end
  self.Text:SetText(_data.activedNum)
  self.ShiNeng:SetPath(_data.typeCfg.type_icon)
end

function UMG_PVP_ShiNengList_C:OnItemSelected(_bSelected)
end

function UMG_PVP_ShiNengList_C:OnDeactive()
end

return UMG_PVP_ShiNengList_C
