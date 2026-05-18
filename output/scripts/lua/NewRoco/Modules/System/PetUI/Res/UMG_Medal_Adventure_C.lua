local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Medal_Adventure_C = Base:Extend("UMG_Medal_Adventure_C")

function UMG_Medal_Adventure_C:OnConstruct()
end

function UMG_Medal_Adventure_C:OnDestruct()
end

function UMG_Medal_Adventure_C:OnItemUpdate(_data, datalist, index)
  self.Tex:SetText(_data.Text)
  self.Icon:SetPath(_data.Icon)
  if index == #datalist then
    self.Line1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Line1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:PlayAnimation(self.Change)
end

function UMG_Medal_Adventure_C:OnItemSelected(_bSelected)
end

function UMG_Medal_Adventure_C:OnDeactive()
end

return UMG_Medal_Adventure_C
