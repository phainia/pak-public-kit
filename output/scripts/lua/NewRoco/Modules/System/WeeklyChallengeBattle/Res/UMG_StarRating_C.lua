local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_StarRating_C = Base:Extend("UMG_StarRating_C")

function UMG_StarRating_C:OnConstruct()
end

function UMG_StarRating_C:OnDestruct()
end

function UMG_StarRating_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self:_InitItem()
end

function UMG_StarRating_C:OnItemSelected(_bSelected)
end

function UMG_StarRating_C:OnDeactive()
end

function UMG_StarRating_C:_InitItem()
  self:PlayAnimation(self.Cheer)
  self.Headline:SetText(string.format("x%s", self.uiData.point))
  if self.uiData.bHas then
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
  end
  self.Text:SetText(self.uiData.text)
end

return UMG_StarRating_C
