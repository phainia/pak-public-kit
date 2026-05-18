local BP_TileListView_C = NRCClass()

function BP_TileListView_C:Construct()
  Log.Error("BP_TileListView_C")
end

function BP_TileListView_C:SetDatas(luaDatas)
  self:ClearListItems()
  local resRequest = NRCResourceManager:LoadResAsync(self, UEPath.BP_LIST_ITEM_DATA_BASE, 255, 0, function(caller, resRequest, itemDataClass)
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

return BP_TileListView_C
