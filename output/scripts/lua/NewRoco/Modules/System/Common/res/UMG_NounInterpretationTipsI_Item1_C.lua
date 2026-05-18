local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_NounInterpretationTipsI_Item1_C = Base:Extend("UMG_NounInterpretationTipsI_Item1_C")

function UMG_NounInterpretationTipsI_Item1_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_NounInterpretationTipsI_Item1_C:OnDestruct()
end

function UMG_NounInterpretationTipsI_Item1_C:OnAddEventListener()
  self.textBuffDesc.OnRichTextClick:Add(self, self.OnDescTextClicked)
end

function UMG_NounInterpretationTipsI_Item1_C:OnDescTextClicked(id)
  if self.uiData.parent then
    self.uiData.parent:OnDescTextClicked(id)
  end
end

function UMG_NounInterpretationTipsI_Item1_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self:SetText(self.uiData.descText)
end

function UMG_NounInterpretationTipsI_Item1_C:SetText(descText)
  self.textBuffDesc:SetVisibility(UE4.ESlateVisibility.Visible)
  self.textBuffDesc:SetText(descText)
  if self.index < self.uiData.limitIndex then
    self.Line1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_NounInterpretationTipsI_Item1_C:HideDesc()
  self.textBuffDesc:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Line1:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_NounInterpretationTipsI_Item1_C:OnItemSelected(_bSelected)
end

function UMG_NounInterpretationTipsI_Item1_C:OnDeactive()
end

return UMG_NounInterpretationTipsI_Item1_C
