local TakePhotosModuleEvent = require("NewRoco/Modules/System/TakePhotos/TakePhotosModuleEvent")
local PhotoServer = Class("PhotoServer")
local EnmPhotoServerStatus = {
  None = 0,
  Initializing = 1,
  Initialized = 2
}

function PhotoServer:Ctor(TakePhotosModule)
  self.AlbumFileList = {}
  self.AlbumFileTable = {}
  
  function self.DummyFunction()
  end
  
  self.UploadServiceRefMap = {}
  self.DownloadServiceRefMap = {}
  self.Status = EnmPhotoServerStatus.None
end

function PhotoServer:InitBriefs()
  if self:IsInitialized() then
    return
  end
  
  local function OnAlbumFileListBriefEstablished(bSuccess)
    if bSuccess then
      Log.Debug("[PhotoServer] InitBriefs Success")
      self.Status = EnmPhotoServerStatus.Initialized
      NRCModuleManager:GetModule("TakePhotosModule"):DispatchEvent(TakePhotosModuleEvent.OnRemotePhotoFullEstablished)
    else
      Log.Error("[PhotoServer] InitBriefs Failed, wait for enter scene retry")
    end
  end
  
  Log.Debug("[PhotoServer] InitBriefs")
  self.Status = EnmPhotoServerStatus.Initializing
  self:ReqAlbumFileList(OnAlbumFileListBriefEstablished)
end

function PhotoServer:OnEnterSceneFinish()
  self:InitBriefs()
end

function PhotoServer:IsInitialized()
  return self.Status ~= EnmPhotoServerStatus.None and self.Status ~= EnmPhotoServerStatus.Initializing
end

function PhotoServer:ReqDownloadFile(File, OnDownloadFinish)
  if self.DownloadServiceRefMap[File.PhotoName] then
    return
  end
  Log.Debug("[PhotoServer] Start Download File", File.PhotoPath, File.FileUrl)
  local HttpService = UE4.UMoreFunPlatformKits.CreateSimpleHttpService()
  local HttpServiceRef = UnLua.Ref(HttpService)
  self.DownloadServiceRefMap[File.PhotoName] = HttpServiceRef
  HttpService:ResetHeaders()
  HttpService:ResetFields()
  HttpService:SetUrl(File.FileUrl)
  HttpService:SetVerb("GET")
  HttpService:Request({
    HttpService,
    function(Service, Status)
      if Status == UE4.EHttpServiceStatus.RspSuccess then
        Service:SaveToFile(File.PhotoPath)
        Log.Debug("[PhotoServer] DownloadFile Success", File.PhotoPath)
      else
        Log.Debug("[PhotoServer] DownloadFile Failed", File.PhotoPath)
      end
      self.DownloadServiceRefMap[File.PhotoName] = nil
      OnDownloadFinish(Status == UE4.EHttpServiceStatus.RspSuccess, File)
    end
  })
end

function PhotoServer:HasPhotoName(Name)
  return self.AlbumFileTable[Name]
end

function PhotoServer:IfReceiveSuccess(Proto, RspName)
  if Proto and Proto.ret_info then
    if 0 ~= Proto.ret_info.ret_code then
      Log.Error("[PhotoServer]", RspName, "err:", Proto.ret_info.ret_code, Proto.ret_info.ret_msg)
    else
      return true
    end
  else
    Log.Error("[PhotoServer]", RspName, "err: not ret_info")
  end
end

function PhotoServer:ReqAlbumFileList(Callback)
  Callback = Callback or self.DummyFunction
  local Cmd = ProtoCMD.ZoneSvrCmd.ZONE_PHOTO_ALBUM_PREVIEW_REQ
  local Req = ProtoMessage:newZonePhotoAlbumPreviewReq()
  Req.home_id = self.MasterId
  local rspWrapper = {}
  rspWrapper.reqMsg = Req
  local bSuccess = false
  
  local function OnSvrRspHandle(_, protoData)
    bSuccess = self:IfReceiveSuccess(protoData, "ZonePhotoAlbumPreviewRsp")
    if bSuccess then
      local PersistentPhotos = UE.UBlueprintPathsLibrary.Combine({
        UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
        "RemotePhotos"
      })
      local photo_list = protoData.photo_list or {}
      for i, v in ipairs(photo_list) do
        local FileName = v.photo_name
        local File = self.AlbumFileTable[FileName]
        if File then
          File.bUpdate = true
          assert(File.PhotoName == FileName)
          assert(File.PhotoMd5 == v.photo_md5)
        else
          local PhotoPath = UE.UBlueprintPathsLibrary.Combine({PersistentPhotos, FileName})
          PhotoPath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(PhotoPath)
          File = {
            SerialId = i,
            PhotoName = v.photo_name,
            PhotoMd5 = v.photo_md5,
            PhotoPath = PhotoPath,
            bUpdate = true
          }
          self.AlbumFileTable[v.photo_name] = File
        end
        self.AlbumFileList[i] = File
        Log.Debug("[PhotoServer] File=", v.photo_name, v.photo_md5)
      end
      while #self.AlbumFileList > #photo_list do
        table.remove(self.AlbumFileList)
      end
      for k, v in pairs(self.AlbumFileTable) do
        if not v.bUpdate then
          self.AlbumFileTable[k] = nil
        end
        v.bUpdate = nil
      end
      for i, v in ipairs(self.AlbumFileList) do
        v.SerialId = i
      end
      if #self.AlbumFileList > 0 then
        local function OnFileUrlEstablish(bUrlSuccess)
          Callback(bUrlSuccess, protoData)
        end
        
        self:ReqAlumDownloadList(self.AlbumFileList, OnFileUrlEstablish)
      else
        Callback(true, protoData)
      end
    else
      Callback(bSuccess, protoData)
    end
  end
  
  Log.Debug("[PhotoServer] ReqAlbumFileList")
  bSuccess = _G.ZoneServer:SendWithHandler(Cmd, Req, rspWrapper, OnSvrRspHandle)
  if not bSuccess then
    Log.Error("[PhotoServer] ReqAlbumFileList ZonePhotoAlbumPreviewReq send failed")
    Callback(bSuccess)
  end
  return bSuccess
end

function PhotoServer:ReqAlumDownloadList(NeedDownloadFileList, Callback)
  Callback = Callback or self.DummyFunction
  local Cmd = ProtoCMD.ZoneSvrCmd.ZONE_PHOTO_ALBUM_DOWNLOAD_URL_REQ
  local Req = ProtoMessage:newZonePhotoAlbumDownloadUrlReq()
  local PhotoNameList = {}
  for i, v in ipairs(NeedDownloadFileList) do
    PhotoNameList[i] = v.PhotoName
  end
  Req.photo_list = PhotoNameList
  local rspWrapper = {}
  rspWrapper.reqMsg = Req
  local bSuccess = false
  
  local function OnSvrRspHandle(_, protoData)
    bSuccess = self:IfReceiveSuccess(protoData, "ZonePhotoAlbumDownloadUrlRsp")
    if bSuccess then
      local DownloadList = protoData.download_list
      if not DownloadList or not next(DownloadList) then
      else
        for i, v in ipairs(DownloadList) do
          local FileName = v.photo_name
          local File = self.AlbumFileTable[FileName]
          if not File then
            Log.Error("ZonePhotoAlbumDownloadUrlRsp cannot found file by name", FileName)
          else
            File.FileUrl = v.url
          end
        end
      end
    end
    Callback(bSuccess, protoData)
  end
  
  Log.Debug("[PhotoServer] ReqAlumDownloadList")
  bSuccess = _G.ZoneServer:SendWithHandler(Cmd, Req, rspWrapper, OnSvrRspHandle)
  if not bSuccess then
    Log.Error("[PhotoServer] ReqAlumDownloadList ZonePhotoAlbumDownloadUrlReq send failed")
    Callback(bSuccess)
  end
  return bSuccess
end

function PhotoServer:ReqRemovePhotos(RemoveNames, Callback)
  Callback = Callback or self.DummyFunction
  Log.Debug("[PhotoServer] ReqRemovePhotos", table.concat(RemoveNames, ";"))
  local Cmd = ProtoCMD.ZoneSvrCmd.ZONE_PHOTO_ALBUM_DELETE_REQ
  local Req = ProtoMessage:newZonePhotoAlbumDeleteReq()
  Req.photo_list = RemoveNames
  local rspWrapper = {}
  rspWrapper.reqMsg = Req
  local bSuccess = false
  
  local function OnSvrRspHandle(_, protoData)
    bSuccess = self:IfReceiveSuccess(protoData, "ZonePhotoAlbumDeleteRsp")
    if bSuccess then
      local PhotoNames = protoData.photo_list
      if PhotoNames then
        for i, PhotoName in ipairs(PhotoNames) do
          self.AlbumFileTable[PhotoName] = nil
        end
        for i = #self.AlbumFileList, 1, -1 do
          local File = self.AlbumFileList[i]
          if not self.AlbumFileTable[File.PhotoName] then
            Log.Debug("[PhotoServer] ZonePhotoAlbumDeleteRsp remove", File.PhotoName)
            table.remove(self.AlbumFileList, i)
          end
        end
      else
        Log.Error("[PhotoServer] cannot found names by ZonePhotoAlbumDeleteRsp")
      end
    end
    for i = #self.AlbumFileList, 1, -1 do
      local File = self.AlbumFileList[i]
      File.SerialId = i
    end
    Callback(bSuccess, protoData)
  end
  
  bSuccess = _G.ZoneServer:SendWithHandler(Cmd, Req, rspWrapper, OnSvrRspHandle)
  if not bSuccess then
    Log.Error("[PhotoServer] ZonePhotoAlbumDeleteReq send failed")
    Callback(bSuccess)
  end
  return bSuccess
end

function PhotoServer:ReqUploadTempPhoto(PhotoPath, Type, Callback)
  if not self:IsInitialized() then
    Callback(false)
    return
  end
  if Type ~= ProtoEnum.PlayerPhotoAlbumType.PLAYER_PHOTO_ALBUM_TYPE_PHOTO and Type ~= ProtoEnum.PlayerPhotoAlbumType.PLAYER_PHOTO_ALBUM_TYPE_CARD then
    Callback(false)
    return
  end
  Callback = Callback or self.DummyFunction
  if self.UploadServiceRefMap[PhotoPath] then
    Callback(false)
    Log.Debug("[PhotoServer] uploading ...", PhotoPath)
    return
  end
  if not UE.UNRCStatics.FileExists(PhotoPath) then
    Callback(false)
    return
  end
  local Cmd = ProtoCMD.ZoneSvrCmd.ZONE_PHOTO_ALBUM_UPLOAD_URL_REQ
  local Req = ProtoMessage:newZonePhotoAlbumUploadUrlReq()
  local Names = string.split(PhotoPath, "/")
  local Name = Names[#Names]
  Req.photo_name = Name
  Req.album_type = Type
  Log.Debug("[PhotoServer] upload", PhotoPath, Name, Type)
  local rspWrapper = {}
  rspWrapper.reqMsg = Req
  local bSuccess = false
  
  local function OnSvrRspHandle(_, protoData)
    bSuccess = self:IfReceiveSuccess(protoData, "ZonePhotoAlbumUploadUrlRsp")
    if bSuccess then
      Log.Debug("[PhotoServer] ZonePhotoAlbumUploadUrlRsp", protoData.photo_name, protoData.url, Type, PhotoPath)
      
      local function OnUploadFinish(bUploadSuccess)
        if bUploadSuccess then
          if UE.UNRCStatics.FileExists(PhotoPath) then
            local MD5 = UE.UNRCStatics.HashFileMD5(PhotoPath)
            if Type == ProtoEnum.PlayerPhotoAlbumType.PLAYER_PHOTO_ALBUM_TYPE_PHOTO then
              self:InternalNotifyServerAlbum(Callback, protoData.photo_name, Type, MD5, PhotoPath)
            elseif Type == ProtoEnum.PlayerPhotoAlbumType.PLAYER_PHOTO_ALBUM_TYPE_CARD then
              self:InternalNotifyServerCard(Callback, protoData.photo_name, Type, MD5)
            end
          else
            Log.Error("[PhotoServer] cannot found photo after upload", PhotoPath)
            Callback(false)
          end
        else
          Callback(false)
        end
      end
      
      self:InternalUploadFile(PhotoPath, protoData.url, OnUploadFinish, protoData)
    else
      local isIdipBan = protoData.ban_info and protoData.ban_info.uin and 0 ~= protoData.ban_info.uin
      if isIdipBan then
        local timeStr = os.date("%Y-%m-%d %H:%M:%S", protoData.ban_info.ban_time)
        local GlobalConfig = _G.DataConfigManager:GetGlobalConfig("banned_notice")
        local tipStr = string.format(GlobalConfig.str, protoData.ban_info.uin, timeStr, protoData.ban_info.ban_reason)
        local dialogContext = DialogContext()
        dialogContext:SetTitle(LuaText.TIPS):SetContent(tipStr):SetMode(DialogContext.Mode.OK):SetCloseOnOK(true)
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, dialogContext)
      end
      Callback(false, nil, isIdipBan)
    end
  end
  
  bSuccess = _G.ZoneServer:SendWithHandler(Cmd, Req, rspWrapper, OnSvrRspHandle)
  if not bSuccess then
    Log.Error("[PhotoServer] ZonePhotoAlbumUploadUrlReq send failed")
    Callback(bSuccess)
  end
end

function PhotoServer:InternalUploadFile(FullPath, Url, Callback)
  local HttpService = UE4.UMoreFunPlatformKits.CreateSimpleHttpService()
  local HttpServiceRef = UnLua.Ref(HttpService)
  self.UploadServiceRefMap[FullPath] = HttpServiceRef
  HttpService:ResetHeaders()
  HttpService:ResetFields()
  HttpService:SetHeader("Content-Type", "image/png")
  HttpService:SetFile(FullPath)
  HttpService:SetUrl(Url)
  HttpService:SetVerb("PUT")
  HttpService:Request({
    HttpService,
    function(_, Status)
      self.UploadServiceRefMap[FullPath] = nil
      if Status == UE.EHttpServiceStatus.RspSuccess then
        Log.Debug("[PhotoServer] upload success,", FullPath, Url)
        Callback(true)
      else
        Log.Error("[PhotoServer] upload failed,", FullPath, Url)
        Callback(false)
      end
    end
  })
end

function PhotoServer:InternalNotifyServerCard(Callback, Name, Type, MD5)
  Log.Debug("[PhotoServer] InternalNotifyServerAlbumToCard", Name, Type, MD5)
  local Cmd = ProtoCMD.ZoneSvrCmd.ZONE_BUSINESS_CARD_UPLOAD_SUCCESS_REQ
  local Req = ProtoMessage:newZoneBusinessCardUploadSuccessReq()
  Req.photo_name = Name
  Req.album_type = Type
  Req.photo_md5 = MD5
  local rspWrapper = {}
  rspWrapper.reqMsg = Req
  local bSuccess = false
  
  local function OnSvrRspHandle(_, protoData)
    bSuccess = self:IfReceiveSuccess(protoData, "ZoneBusinessCardUploadSuccessRsp")
    Log.Debug("[PhotoServer] ZoneBusinessCardUploadSuccessReq", bSuccess)
    if bSuccess then
      local briefInfo = _G.DataModelMgr.PlayerDataModel:GetCardBriefInfo()
      briefInfo.business_card_info = protoData.business_card_info
      _G.DataModelMgr.PlayerDataModel:SetCardBriefInfo(briefInfo)
      Log.Debug("[PhotoServer] ZoneBusinessCardUploadSuccessReq", briefInfo.business_card_info.cur_card_url)
    end
    Callback(bSuccess)
  end
  
  bSuccess = _G.ZoneServer:SendWithHandler(Cmd, Req, rspWrapper, OnSvrRspHandle)
  if not bSuccess then
    Log.Error("[PhotoServer] ZoneBusinessCardUploadSuccessReq send failed")
    Callback(bSuccess)
  end
end

function PhotoServer:InternalNotifyServerAlbum(Callback, Name, Type, MD5, SrcPhotoPath)
  Log.Debug("[PhotoServer] InternalNotifyServerAlbumToCard", Name, Type, MD5)
  local Cmd = ProtoCMD.ZoneSvrCmd.ZONE_PHOTO_ALBUM_UPLOAD_SUCCESS_REQ
  local Req = ProtoMessage:newZonePhotoAlbumUploadSuccessReq()
  Req.photo_name = Name
  Req.album_type = Type
  Req.photo_md5 = MD5
  local rspWrapper = {}
  rspWrapper.reqMsg = Req
  local bSuccess = false
  
  local function OnSvrRspHandle(_, protoData)
    bSuccess = self:IfReceiveSuccess(protoData, "ZonePhotoAlbumUploadSuccessRsp")
    Log.Debug("[PhotoServer] ZonePhotoAlbumUploadSuccessRsp", bSuccess)
    local File
    if bSuccess then
      local PersistentPhotos = UE.UBlueprintPathsLibrary.Combine({
        UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
        "RemotePhotos"
      })
      local PhotoPath = UE.UBlueprintPathsLibrary.Combine({PersistentPhotos, Name})
      PhotoPath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(PhotoPath)
      UE.UNRCStatics.CopyFile(SrcPhotoPath, PhotoPath)
      if Type == ProtoEnum.PlayerPhotoAlbumType.PLAYER_PHOTO_ALBUM_TYPE_PHOTO then
        File = {
          SerialId = #self.AlbumFileList + 1,
          PhotoName = Name,
          PhotoMd5 = MD5,
          PhotoPath = PhotoPath
        }
        table.insert(self.AlbumFileList, File)
        self.AlbumFileTable[Name] = File
      end
      
      local function OnDownloadUrlEstablish(ProtoData)
        File = self.AlbumFileTable[Name]
        Callback(bSuccess, File)
      end
      
      self:ReqAlumDownloadList({File}, OnDownloadUrlEstablish)
    else
      Callback(false)
    end
  end
  
  bSuccess = _G.ZoneServer:SendWithHandler(Cmd, Req, rspWrapper, OnSvrRspHandle)
  if not bSuccess then
    Log.Error("[PhotoServer] ZonePhotoAlbumUploadSuccessReq send failed")
    Callback(bSuccess)
  end
end

function PhotoServer:ReqDownloadCard(Url, Callback)
  local HttpService = UE4.UMoreFunPlatformKits.CreateSimpleHttpService()
  local HttpServiceRef = UnLua.Ref(HttpService)
  self.UploadServiceRefMap[Url] = HttpServiceRef
  HttpService:ResetHeaders()
  HttpService:ResetFields()
  HttpService:SetHeader("Content-Type", "image/png")
  HttpService:SetUrl(Url)
  HttpService:SetVerb("GET")
  HttpService:Request({
    HttpService,
    function(_, Status)
      if Status == UE.EHttpServiceStatus.RspSuccess then
        Log.Debug("[PhotoServer] download success,", Url)
        self:InternalBuildCardTexture(HttpService, Callback, Url)
        self.UploadServiceRefMap[Url] = nil
      else
        Log.Error("[PhotoServer] download failed,", Url)
        Callback(false)
      end
    end
  })
end

function PhotoServer:InternalBuildCardTexture(HttpService, Callback, Url)
  local Names = string.split(Url, "/")
  local Name = Names[#Names]
  Log.Debug("[PhotoServer] InternalBuildCardTexture Url:", Url, Name)
  local PersistentPhotos = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
    "CardPhotos"
  })
  if not UE.UNRCStatics.DirectoryExists(PersistentPhotos) then
    UE.UNRCStatics.MakeDirectory(PersistentPhotos)
  end
  self:ConditionReleaseCachedCardPhotos()
  local FileName = Name
  local PhotoPath = UE.UBlueprintPathsLibrary.Combine({PersistentPhotos, FileName})
  local ImageSavePath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(PhotoPath)
  if not HttpService:SaveToFile(ImageSavePath) then
    Log.Error("[PhotoServer] cannot save file", ImageSavePath)
  end
  Callback(true, ImageSavePath)
end

function PhotoServer:GetLocalCachedPhotoFileByUrl(Url)
  local Names = string.split(Url, "/")
  local PhotoName = Names[#Names]
  if PhotoName then
    local PersistentPhoto = UE.UBlueprintPathsLibrary.Combine({
      UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
      "CardPhotos",
      PhotoName
    })
    local FullPersistentPhotoPath = UE.UBlueprintPathsLibrary.ConvertRelativePathToFull(PersistentPhoto)
    if UE.UNRCStatics.FileExists(FullPersistentPhotoPath) then
      Log.Debug("[PhotoServer] GetLocalCachedPhotoFileByUrl", Url, FullPersistentPhotoPath)
      return FullPersistentPhotoPath
    end
  end
end

function PhotoServer:ConditionReleaseCachedCardPhotos()
  local CacheNum = 10
  local GetFileStamp = UEGetFileDateTime
  local CardPhotos = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
    "CardPhotos"
  })
  local Files = UE.UNRCStatics.ListFiles(CardPhotos, "*.*")
  if CacheNum < Files:Num() then
    Files = Files:ToTable()
    table.sort(Files, function(a, b)
      return GetFileStamp(a) > GetFileStamp(b)
    end)
    for i = 11, #Files do
      local PhotoFile = Files[i]
      UE.UNRCStatics.DeleteToFile(PhotoFile)
      Log.Debug("[PhotoServer] ReleaseCachedCardPhoto", PhotoFile)
    end
  end
end

return PhotoServer
