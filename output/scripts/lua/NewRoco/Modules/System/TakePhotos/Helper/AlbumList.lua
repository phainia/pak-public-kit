local EnmOperationMode = {Default = 0, Remove = 1}
local AlbumList = Class("AlbumList")

function AlbumList:Ctor(FilmView)
  self.FilmView = FilmView
  self.CurrOperationMode = EnmOperationMode.Default
  self.CurrDataList = {}
  self.List = FilmView.List
end

function AlbumList:DispatchEvent(...)
  self:GetModule():DispatchEvent(...)
end

function AlbumList:GetModule()
  if self._Module then
    return self._Module
  end
  self._Module = NRCModuleManager:GetModule("TakePhotosModule")
  return self._Module
end

function AlbumList:GetModuleData()
  return (self:GetModule() or {}).data or {}
end

function AlbumList:GetPhotoManager()
  return self:GetModule().Controller.PhotoManager
end

function AlbumList:Reset()
  self.CurrOperationMode = EnmOperationMode.Default
end

function AlbumList:GetPhotoBySerialId(SerialId)
end

function AlbumList:ReloadConditionally()
end

function AlbumList:InDefaultMode()
  return self.CurrOperationMode == EnmOperationMode.Default
end

function AlbumList:InRemoveMode()
  return self.CurrOperationMode == EnmOperationMode.Remove
end

function AlbumList:GetDataList()
  return self.CurrDataList
end

function AlbumList:ToggleSelectFlagBySerialId(SerialId)
  if self.CurrDataList[SerialId] then
    self.CurrDataList[SerialId].bSelected = not self.CurrDataList[SerialId].bSelected
  end
end

function AlbumList:SelectPhotoBySerialId(SerialId)
  if self.CurrDataList[SerialId] then
    self.CurrDataList[SerialId].bSelected = true
  end
end

function AlbumList:ToggleToDefault()
  self.CurrOperationMode = EnmOperationMode.Default
end

function AlbumList:ToggleMode()
  if self.CurrOperationMode == EnmOperationMode.Remove then
    self.CurrOperationMode = EnmOperationMode.Default
  elseif self.CurrOperationMode == EnmOperationMode.Default then
    self.CurrOperationMode = EnmOperationMode.Remove
  end
end

function AlbumList:OnItemSelected(SerialId)
  return self.FilmView:OnItemSelected(SerialId)
end

function AlbumList:RefreshSelectAllView()
  local bHasNoSelect = false
  for i, Data in ipairs(self.CurrDataList) do
    if Data.SerialId and not Data.bSelected then
      bHasNoSelect = true
      break
    end
  end
  return bHasNoSelect
end

function AlbumList:RefreshRemoveBtnStatus()
  local bHasSelect = false
  for i, Data in ipairs(self.CurrDataList) do
    if Data.SerialId and Data.bSelected then
      bHasSelect = true
      break
    end
  end
  return bHasSelect
end

function AlbumList:ToggleSelectAllWaitRemove()
  local bHasNoSelect = false
  for i, Data in ipairs(self.CurrDataList) do
    if Data.SerialId and not Data.bSelected then
      bHasNoSelect = true
      break
    end
  end
  local bSelectAll = bHasNoSelect
  for i, Data in ipairs(self.CurrDataList) do
    if Data.SerialId then
      Data.bSelected = bSelectAll
    end
  end
  return bSelectAll
end

function AlbumList:GetHintText()
end

function AlbumList:GetPhotoNum()
end

function AlbumList:GetPhotoMaxNum()
end

function AlbumList:RemovePhotoBySerialId(SerialId)
end

function AlbumList:GetPhotoLimitTitle()
end

function AlbumList:BuildDataList()
end

function AlbumList:RemoveSelection()
  local NeedRemove = {}
  for i, Data in ipairs(self.CurrDataList) do
    if Data.bSelected then
      table.insert(NeedRemove, i)
    end
  end
  self:ToggleToDefault()
  self:RemovePhotosBySerials(NeedRemove)
end

function AlbumList:RemovePhotosBySerials(NeedRemove)
end

function AlbumList:OnThumbnailTextureGenerated(PhotoData)
  local bValidPhotoData = false
  for i, Data in ipairs(self.CurrDataList) do
    if Data.PhotoData == PhotoData then
      bValidPhotoData = true
      break
    end
  end
  if not bValidPhotoData then
    return
  end
  local SerialId = PhotoData.SerializeId
  local Item = self.List:GetItemByIndex(SerialId - 1)
  if Item then
    Item:OnItemUpdate(self.CurrDataList[SerialId])
  end
end

return AlbumList
