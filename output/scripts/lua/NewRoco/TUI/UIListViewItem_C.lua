local UIListViewItem_C = Class()

function UIListViewItem_C:Construct()
  Log.Error("UIListViewItem_C::  Construct---")
  self.data = nil
end

function UIListViewItem_C:SetData(itemData)
  local data = itemData:Cast(UE4.UItemData)
  if data then
    self.data = data
  else
    Log.Error("cast failed")
  end
end

function UIListViewItem_C:OnItemSelected(selected)
  Log.Error("item selected" .. tostring(selected))
end

function UIListViewItem_C:OnItemDespawned()
  Log.Error("UIListViewItem_C.OnItemDespawned")
end

return UIListViewItem_C
