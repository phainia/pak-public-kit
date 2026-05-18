local BP_GridViewEx_C = NRCClass()

function BP_GridViewEx_C:Construct()
  self._listDatas = nil
end

function BP_GridViewEx_C:Destruct()
end

function BP_GridViewEx_C:SetDatas(_itemDatas)
  if not _itemDatas then
    return
  end
  self._listDatas = _itemDatas
  local count = #self._listDatas
  self:SetItemCount(count)
  for i = 1, count do
    local uiItem = self:GetItemByIndex(i - 1)
    if uiItem then
      uiItem:SetData(self._listDatas[i])
    end
  end
end

return BP_GridViewEx_C
