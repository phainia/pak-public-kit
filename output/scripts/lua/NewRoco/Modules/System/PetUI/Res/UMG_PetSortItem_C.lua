local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetSortItem_C = Base:Extend("UMG_PetSortItem_C")

function UMG_PetSortItem_C:OnConstruct()
end

function UMG_PetSortItem_C:OnDestruct()
end

function UMG_PetSortItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.SortText:SetText(self.data.sequence_desc)
  self.CurSelected = false
end

function UMG_PetSortItem_C:OnNotPlaySound()
  self.IsNotPlaySound = true
end

function UMG_PetSortItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    if not self.IsNotPlaySound then
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BagSortItem_C:OnItemSelected")
    else
      self.IsNotPlaySound = false
    end
  end
  self.CurSelected = _bSelected
  if self.CurSelected then
    self:PlayAnimation(self.Press)
  else
    self:PlayAnimation(self.Cancel)
  end
  if self.CurSelected then
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  else
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
end

function UMG_PetSortItem_C:OnDeactive()
end

return UMG_PetSortItem_C
