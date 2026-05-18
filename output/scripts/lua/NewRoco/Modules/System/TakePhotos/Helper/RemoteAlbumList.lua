local TakePhotosModuleEvent = require("NewRoco/Modules/System/TakePhotos/TakePhotosModuleEvent")
local Super = require("NewRoco/Modules/System/TakePhotos/Helper/AlbumList")
local RemoteAlbumList = Super:Extend("RemoteAlbumList")

function RemoteAlbumList:GetPhotoLimitTitle()
  return LuaText.takephoto_cloud_storage_text
end

function RemoteAlbumList:GetHintText(bFromTakingPhoto)
  if bFromTakingPhoto then
    return LuaText.takephoto_cloud_storage_tips_bottom
  else
    return LuaText.takephoto_card_tips_bottom
  end
end

function RemoteAlbumList:ReloadConditionally()
end

function RemoteAlbumList:BuildDataList()
  local Num = self:GetPhotoNum()
  local SerialList = {}
  for i = 1, Num do
    local SerialId = i
    table.insert(SerialList, {
      SerialId = SerialId,
      bSelected = false,
      PhotoData = self:GetPhotoBySerialId(SerialId),
      bRemoveMode = self:InRemoveMode(),
      DoSelectDelegate = function()
        return self:OnItemSelected(SerialId)
      end,
      CreateDateText = self:InternalBuildCreateDateText(SerialId),
      GetDesiredThumbnailSize = function()
        return self.FilmView.ThumbnailDesiredWidth, self.FilmView.ThumbnailDesiredHeight
      end
    })
  end
  for i = Num + 1, self:GetPhotoMaxNum() do
    table.insert(SerialList, {})
  end
  self.CurrDataList = SerialList
end

function RemoteAlbumList:InternalBuildCreateDateText(SerialId)
  local Data = self:GetPhotoBySerialId(SerialId)
  if not Data then
    return ""
  end
  local Name = Data:UnpackPhotoName()
  if not Name then
    return ""
  end
  local EndIdx = string.find(Name, "%.") or #Name + 1
  local Len = 13
  local J = EndIdx - 1
  local I = J - Len + 1
  local Timestamp = math.tointeger(string.sub(Name, I, J))
  if Timestamp then
    local Date = os.date("*t", math.floor(Timestamp / 1000))
    if Date then
      return string.format("%s/%s/%s", Date.year, Date.month, Date.day)
    end
  end
  return ""
end

function RemoteAlbumList:GetPhotoNum()
  local Manager = self:GetPhotoManager()
  return Manager:GetRemotePhotoNum()
end

function RemoteAlbumList:GetPhotoMaxNum()
  return TakePhotosEnum.TPGlobalNum("takephoto_cloud_storage_num")
end

function RemoteAlbumList:GetPhotoBySerialId(SerialId)
  local Manager = self:GetPhotoManager()
  return Manager:GetRemotePhotoDataBySerial(SerialId)
end

function RemoteAlbumList:RemovePhotoBySerialId(SerialId)
  if not SerialId then
    return
  end
  local Manager = self:GetPhotoManager()
  return Manager:RemoveRemotePhotoBySerial(SerialId)
end

function RemoteAlbumList:RemovePhotosBySerials(NeedRemove)
  local Manager = self:GetPhotoManager()
  return Manager:RemoveRemotePhotosBySerials(NeedRemove)
end

return RemoteAlbumList
