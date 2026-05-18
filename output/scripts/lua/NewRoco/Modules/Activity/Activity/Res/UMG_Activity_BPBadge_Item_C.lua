local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_BPBadge_Item_C = Base:Extend("UMG_Activity_BPBadge_Item_C")

function UMG_Activity_BPBadge_Item_C:OnConstruct()
  self._bSelected = false
end

function UMG_Activity_BPBadge_Item_C:OnDestruct()
end

function UMG_Activity_BPBadge_Item_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self.Text:SetText(_data.text)
end

function UMG_Activity_BPBadge_Item_C:OnItemSelected(_bSelected)
  if self._bSelected == _bSelected then
    return
  end
  self._bSelected = _bSelected
  if _bSelected then
    self.data.handler(self.data.caller, self.index)
    self:PlayAnimation(self.Press)
  else
    self:PlayAnimationReverse(self.Press)
  end
end

function UMG_Activity_BPBadge_Item_C:OnDeactive()
end

return UMG_Activity_BPBadge_Item_C
