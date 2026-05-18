local BP_ScrollViewItemBase_C = NRCUmgClass:Extend("BP_ScrollViewItemBase_C")

function BP_ScrollViewItemBase_C:Construct()
  self._longPressThreshold = 2
  self._triggerLongPress = false
  self._longPressTimer = 0
  self._pressed = false
  self._index = 0
  self._data = nil
  self._dataUnShow = nil
  self._scrollView = nil
end

function BP_ScrollViewItemBase_C:OnUpdateItemData(ist, index)
end

function BP_ScrollViewItemBase_C:OnDataUpdated()
end

function BP_ScrollViewItemBase_C:SetData(data)
  self._data = data
  self:OnDataUpdated()
end

function BP_ScrollViewItemBase_C:SetDataUnShow(data)
  self._dataUnShow = data
  self:OnDataUpdated()
end

function BP_ScrollViewItemBase_C:SetIndex(idx)
  self._index = idx
end

function BP_ScrollViewItemBase_C:GetIndex()
  return self._index
end

function BP_ScrollViewItemBase_C:SetScrollView(scrollView)
  self._scrollView = scrollView
end

function BP_ScrollViewItemBase_C:OnSelectionChange(bSelected)
  if bSelected then
  else
  end
end

function BP_ScrollViewItemBase_C:OnOtherTouchStart()
end

function BP_ScrollViewItemBase_C:OnTouchStarted(MyGeometry, InTouchEvent)
  if self._scrollView and not self._scrollView.bAllowClick then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  self._pressed = true
  self._triggerLongPress = false
  self._longPressTimer = self._longPressThreshold
  if self._scrollView then
    self._scrollView:OnItemTouchStart(self, self._index)
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function BP_ScrollViewItemBase_C:OnTouchEnded(MyGeometry, InTouchEvent)
  if self._scrollView and not self._scrollView.bAllowClick then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  self._pressed = false
  if self._scrollView then
    self._scrollView:OnItemClick(self, self._index)
  end
  if self.ParentView then
    self.ParentView:OnChildItemClick(self, self._index)
  end
  if self.OnClick then
    self:OnClick()
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function BP_ScrollViewItemBase_C:Tick(MyGeometry, InDeltaTime)
  if self._pressed and not self._triggerLongPress then
    self._longPressTimer = self._longPressTimer - InDeltaTime
    if self._longPressTimer <= 0 then
      self:OnLongPressed()
      self._triggerLongPress = true
    end
  end
end

function BP_ScrollViewItemBase_C:Destruct()
  self._scrollView = nil
  NRCUmgClass.Destruct(self)
end

function BP_ScrollViewItemBase_C:GetData()
  return self._data
end

function BP_ScrollViewItemBase_C:OnDespawn()
end

function BP_ScrollViewItemBase_C:OnLongPressed()
end

function BP_ScrollViewItemBase_C:OnClick()
end

return BP_ScrollViewItemBase_C
