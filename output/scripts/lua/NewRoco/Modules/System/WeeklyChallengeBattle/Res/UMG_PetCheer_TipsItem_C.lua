local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetCheer_TipsItem_C = Base:Extend("UMG_PetCheer_TipsItem_C")

function UMG_PetCheer_TipsItem_C:OnConstruct()
end

function UMG_PetCheer_TipsItem_C:OnDestruct()
end

function UMG_PetCheer_TipsItem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self:_InitItem()
end

function UMG_PetCheer_TipsItem_C:OnItemSelected(_bSelected)
end

function UMG_PetCheer_TipsItem_C:_InitItem()
  if self.Text then
    self.Text:SetText(self.uiData.cheerUpText)
  end
  if self.Headline then
    self.Headline:SetText(string.format("x%s", self.uiData.cheerUpCount))
  end
  if self.uiData.bIsActive then
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
  end
end

function UMG_PetCheer_TipsItem_C:OnDeactive()
end

return UMG_PetCheer_TipsItem_C
