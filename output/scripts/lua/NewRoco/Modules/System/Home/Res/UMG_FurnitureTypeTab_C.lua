local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local HomeEnum = require("NewRoco.Modules.System.Home.HomeEnum")
local UMG_FurnitureTypeTab_C = Base:Extend("UMG_FurnitureTypeTab_C")

function UMG_FurnitureTypeTab_C:OnConstruct()
end

function UMG_FurnitureTypeTab_C:OnDestruct()
end

function UMG_FurnitureTypeTab_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if self.TextBlock_1 then
    self.TextBlock_1:SetText(_data.TabConf and _data.TabConf.tab_name or "")
  end
end

function UMG_FurnitureTypeTab_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.Press)
  else
    self:PlayAnimation(self.Normal)
  end
  if _bSelected and self.data.OnClick then
    self.data.OnClick()
  end
end

return UMG_FurnitureTypeTab_C
