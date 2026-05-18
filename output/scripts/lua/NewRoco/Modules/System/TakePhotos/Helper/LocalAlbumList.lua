local Super = require("NewRoco/Modules/System/TakePhotos/Helper/AlbumList")
local LocalAlbumList = Super:Extend("LocalAlbumList")

function LocalAlbumList:BuildDataList()
  local Num = self:GetPhotoNum()
  local SerialList = {}
  for i = 1, Num do
    local SerialId = i
    local PhotoData = self:GetPhotoBySerialId(SerialId)
    table.insert(SerialList, {
      SerialId = SerialId,
      bSelected = false,
      PhotoData = PhotoData,
      bRemoveMode = self:InRemoveMode(),
      DoSelectDelegate = function()
        return self:OnItemSelected(SerialId)
      end,
      GetDesiredThumbnailSize = function()
        return self.FilmView.ThumbnailDesiredWidth, self.FilmView.ThumbnailDesiredHeight
      end
    })
    if PhotoData then
      PhotoData:DetachSection()
    end
  end
  for i = Num + 1, self:GetPhotoMaxNum() do
    table.insert(SerialList, {})
  end
  self.CurrDataList = SerialList
end

function LocalAlbumList:GetHintText(bFromTakingPhoto)
  return LuaText.takephoto_storage_cleared_tips_bottom
end

function LocalAlbumList:GetPhotoLimitTitle()
  return LuaText.takephoto_storage_text
end

function LocalAlbumList:GetPhotoNum()
  local Manager = self:GetPhotoManager()
  return Manager:GetLocalPhotoNum()
end

function LocalAlbumList:GetPhotoBySerialId(SerialId)
  local Manager = self:GetPhotoManager()
  return Manager:GetLocalPhotoDataBySerial(SerialId)
end

function LocalAlbumList:GetPhotoMaxNum()
  return self:GetPhotoManager().LocalMaxiPhotoNum
end

function LocalAlbumList:RemovePhotoBySerialId(SerialId)
  local Manager = self:GetPhotoManager()
  Manager:RemoveLocalPhotoBySerial(SerialId)
end

function LocalAlbumList:RemovePhotosBySerials(NeedRemove)
  local Manager = self:GetPhotoManager()
  Manager:RemoveLocalPhotosBySerials(NeedRemove)
end

return LocalAlbumList
