local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DotItem_C = Base:Extend("UMG_DotItem_C")

function UMG_DotItem_C:OnConstruct()
  self.isAnimOutState = false
end

function UMG_DotItem_C:OnDestruct()
end

function UMG_DotItem_C:OnItemUpdate(_data, datalist, index)
  if not self.isAnimOutState then
    self.isAnimOutState = true
    self:PlayAnimation(self.Select_not)
  end
end

function UMG_DotItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.isAnimOutState then
      self.isAnimOutState = false
      self:PlayAnimation(self.Select)
    end
  elseif not self.isAnimOutState then
    self.isAnimOutState = true
    self:PlayAnimation(self.Select_not)
  end
end

function UMG_DotItem_C:OnDeactive()
end

return UMG_DotItem_C
