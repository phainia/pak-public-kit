local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ExpansionConditions_C = Base:Extend("UMG_ExpansionConditions_C")

function UMG_ExpansionConditions_C:OnConstruct()
end

function UMG_ExpansionConditions_C:OnDestruct()
end

function UMG_ExpansionConditions_C:OnItemUpdate(_data, datalist, index)
  self.Text_Describe:SetText(_data.Desc)
  if self.Check then
    self.Check:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if self.Check1 then
    if _data.bFinish then
      self.Check1:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Check1:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_ExpansionConditions_C:OnItemSelected(_bSelected)
end

function UMG_ExpansionConditions_C:OnDeactive()
end

return UMG_ExpansionConditions_C
