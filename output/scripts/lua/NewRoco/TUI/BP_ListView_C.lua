local BP_ListView_C = NRCClass()

function BP_ListView_C:Ctor()
  Log.Debug("BP_ListView_C ctor:")
end

function BP_ListView_C:SetDatas(luaDatas)
  Log.Debug("BP_ListView_C SetDatas:")
  self:ClearListItems()
  local resRequest = NRCResourceManager:LoadResAsync(self, "/Game/NewRoco/TUI/BP_ListItemDataBase.BP_ListItemDataBase_C", 255, 0, function(caller, resRequest, itemDataClass)
    local length = #luaDatas
    local itemData
    for i = 1, length do
      itemData = NewObject(itemDataClass)
      itemData.data = luaDatas[i]
      self:AddItem(itemData)
    end
  end, function()
    Log.Error("BP_ListView_C SetDatas loadfailed")
  end, nil)
end

function BP_ListView_C:OnItemsChanged(addedItems, removedItems)
end

return BP_ListView_C
