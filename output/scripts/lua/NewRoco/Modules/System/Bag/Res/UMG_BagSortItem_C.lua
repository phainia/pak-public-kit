local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BagSortItem_C = Base:Extend("UMG_BagSortItem_C")

function UMG_BagSortItem_C:OnConstruct()
end

function UMG_BagSortItem_C:OnDestruct()
end

function UMG_BagSortItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.SortText:SetText(self.data.text)
  self.CurSelected = false
  self.CanPlayAudio = true
end

function UMG_BagSortItem_C:OnItemSelected(_bSelected)
  if self.data.OnClick then
    self.data.OnClick(self.data, _bSelected)
  end
  if self.data.bDisableClickSelect then
    return
  end
  self:StopAllAnimations()
  if _bSelected then
    if self.CanPlayAudio then
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BagSortItem_C:OnItemSelected")
    else
      self.CanPlayAudio = true
    end
    self:PlayAnimation(self.Press)
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  else
    self:PlayAnimation(self.Cancel)
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
  self.CurSelected = _bSelected
end

function UMG_BagSortItem_C:DoSelect()
  self:StopAllAnimations()
  self:PlayAnimation(self.Press)
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BagSortItem_C:OnItemSelected")
end

function UMG_BagSortItem_C:DoUnSelect()
  self:StopAllAnimations()
  self:PlayAnimation(self.Cancel)
end

function UMG_BagSortItem_C:OnDeactive()
end

return UMG_BagSortItem_C
