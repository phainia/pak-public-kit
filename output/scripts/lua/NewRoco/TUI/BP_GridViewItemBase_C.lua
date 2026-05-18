local BP_GridViewItemBase_C = NRCClass()

function BP_GridViewItemBase_C:Construct()
  self._itemData = nil
end

function BP_GridViewItemBase_C:SetData(_data)
  self._itemData = _data
  self:OnUpdateItemChange(self._itemData)
end

function BP_GridViewItemBase_C:GetData()
  return self._itemData
end

function BP_GridViewItemBase_C:OnOtherTouchStart()
end

function BP_GridViewItemBase_C:OnTouchStarted(_MyGeometry, _InTouchEvent)
end

function BP_GridViewItemBase_C:OnTouchEnded(_MyGeometry, _InTouchEvent)
end

function BP_GridViewItemBase_C:Destruct()
  self._itemData = nil
end

function BP_GridViewItemBase_C:OnUpdateItemChange(_data)
end

return BP_GridViewItemBase_C
