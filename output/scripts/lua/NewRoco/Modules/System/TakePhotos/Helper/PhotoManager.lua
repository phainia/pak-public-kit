local PhotoFileDefine = require("NewRoco.Modules.System.TakePhotos.Helper.PhotoFileDefine")
local TakePhotosModuleEvent = require("NewRoco.Modules.System.TakePhotos.TakePhotosModuleEvent")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local TakePhotoFileBrief = require("NewRoco.Modules.System.TakePhotos.Common.TakePhotoFileBrief")
local TakePhotoFileManager = require("NewRoco.Modules.System.TakePhotos.Common.TakePhotoFileManager")
local ThumbnailScrollPool = require("NewRoco.Modules.System.TakePhotos.Common.ThumbnailScrollPool")
local PhotoManager = Class("PhotoManager")

function PhotoManager:Ctor()
  self.SerializeObjects = {}
  self.LocalPhotoList = {}
  self.LocalMaxiPhotoNum = TakePhotosEnum.TPGlobalNum("takephoto_storage_num")
  self.RemotePhotoList = {}
  self.RemoteMaxiPhotoNum = TakePhotosEnum.TPGlobalNum("takephoto_cloud_storage_num")
  self.TakePhotoFileManager = TakePhotoFileManager()
  self.ThumbnailScrollPool = ThumbnailScrollPool(self.TakePhotoFileManager)
  self.bResourceRequired = false
end

function PhotoManager:OnDestroy()
end

function PhotoManager:OnEnterSceneFinish()
end

function PhotoManager:InitThumbnailPool()
  self.bResourceRequired = true
  self.ThumbnailScrollPool:InitThumbnailSlots()
  self.TakePhotoFileManager:ReleaseResources()
  for i, v in ipairs(self.LocalPhotoList) do
    self:TryAllocateResourceByPhotoData(v)
  end
  for i, v in ipairs(self.RemotePhotoList) do
    self:TryAllocateResourceByPhotoData(v)
  end
end

function PhotoManager:ReleaseThumbnailPool()
  self.bResourceRequired = false
  for i, v in ipairs(self.LocalPhotoList) do
    v:SetTextureEvents(false)
  end
  for i, v in ipairs(self.RemotePhotoList) do
    v:SetTextureEvents(false)
  end
  self.ThumbnailScrollPool:ReleaseThumbnailSlots()
  self.TakePhotoFileManager:ReleaseResources()
end

function PhotoManager:InitLocalBriefList()
  if #self.LocalPhotoList > 0 then
    return
  end
  local GetFileStamp = UEGetFileDateTime
  local LocalPhotos = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
    "LocalPhotos"
  })
  local Files = UE.UNRCStatics.ListFiles(LocalPhotos, "*.*")
  if Files:Num() > 0 then
    Files = Files:ToTable()
    for i = #Files, 1, -1 do
      if string.EndsWith(Files[i], "_Thumbnail") then
        table.remove(Files, i)
      else
        Files[i] = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(Files[i])
      end
    end
    local Uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
    for i = #Files, 1, -1 do
      local PhotoFile = Files[i]
      local Names = string.split(PhotoFile, "/")
      local UinText = Names[#Names - 1]
      local TestUin = math.tointeger(UinText)
      if not TestUin or TestUin ~= Uin then
        table.remove(Files, i)
      end
    end
    table.sort(Files, function(a, b)
      return GetFileStamp(a) > GetFileStamp(b)
    end)
    local Num = 0
    for i = #Files, 1, -1 do
      local PhotoFile = Files[i]
      local bDeleted, Md5 = self:InternalJudgeMd5DeleteLocalFile(PhotoFile)
      if not bDeleted then
        Num = Num + 1
        self:AddPhotoByLocalPhoto(PhotoFile, Md5)
        if Num == self.LocalMaxiPhotoNum then
          break
        end
      end
    end
  end
end

function PhotoManager:UpdateRemoteBriefList(RemoteDataList)
  local CurrentRemoteMap = {}
  for i, PhotoFileData in pairs(self.RemotePhotoList) do
    CurrentRemoteMap[PhotoFileData.Brief.Url] = false
  end
  for i = #RemoteDataList, 1, -1 do
    local RemoteData = RemoteDataList[i]
    local PhotoUrl = RemoteData.FileUrl
    CurrentRemoteMap[PhotoUrl] = RemoteData
  end
  for i = #self.RemotePhotoList, 1, -1 do
    local PhotoFileData = self.RemotePhotoList[i]
    if not CurrentRemoteMap[PhotoFileData.Brief.Url] then
      table.remove(self.RemotePhotoList, i)
      self.TakePhotoFileManager:DeleteBrief(PhotoFileData.Brief)
    end
    CurrentRemoteMap[PhotoFileData.Brief.Url] = nil
  end
  for PhotoUrl, RemoteData in pairs(CurrentRemoteMap) do
    self:AddPhotoByRemotePhoto(RemoteData)
  end
end

function PhotoManager:AddPhotoByLocalPhoto(FilePath, DesiredMd5)
  local Brief = TakePhotoFileBrief():SetThumbnail(512):AsLocalFile(FilePath, DesiredMd5)
  local PhotoData = PhotoFileDefine.MakePhotoData()
  PhotoData:Attach(self.LocalPhotoList, self)
  PhotoData.OnShareDelegate:Add(self, self.OnReqShare)
  PhotoData.OnDeleteDelegate:Add(self, self.OnReqDeleteByUser)
  PhotoData.OnUploadDelegate:Add(self, self.OnReqUpload)
  PhotoData.OnUploadCardDelegate:Add(self, self.OnReqUploadCard)
  PhotoData:SetBriefInfo(Brief)
  Log.Debug("[TakePhoto] AddPhotoByLocalPhoto", FilePath, DesiredMd5)
  return PhotoData
end

function PhotoManager:AddPhotoByRemotePhoto(File)
  local PhotoUrl, PhotoMd5, PhotoPath = File.FileUrl, File.PhotoMd5, File.PhotoPath
  local Brief = TakePhotoFileBrief():SetThumbnail(512):AsRemoteFile(PhotoPath, PhotoUrl, PhotoMd5)
  local RemotePhotoData = PhotoFileDefine.MakePhotoData()
  RemotePhotoData:Attach(self.RemotePhotoList, self)
  RemotePhotoData.OnShareDelegate:Add(self, self.OnReqShare)
  RemotePhotoData.OnDeleteDelegate:Add(self, self.OnReqDeleteRemoteByUser)
  RemotePhotoData.OnUploadCardDelegate:Add(self, self.OnReqUploadCard)
  RemotePhotoData:SetBriefInfo(Brief)
  return RemotePhotoData
end

function PhotoManager:TryAllocateResourceByPhotoData(PhotoFileData)
  if self.bResourceRequired then
    local Brief = PhotoFileData:GetBriefInfo()
    if Brief then
      self.TakePhotoFileManager:CreateFileByBrief(Brief)
      PhotoFileData:SetTextureEvents(true)
    end
  end
end

function PhotoManager:AddPhotoByTakingPhoto(RT)
  local PhotoData = PhotoFileDefine.MakePhotoData()
  local TempPhotos = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
    "LocalPhotos"
  })
  if not UE.UNRCStatics.DirectoryExists(TempPhotos) then
    UE.UNRCStatics.MakeDirectory(TempPhotos)
  end
  local Uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  local FileName = string.format("%d%d", Uin, math.floor(_G.ZoneServer:GetServerTime()))
  local PhotoPath = UE.UBlueprintPathsLibrary.Combine({
    TempPhotos,
    Uin,
    FileName
  })
  local ImageMapping = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(PhotoPath)
  if self:AddRenderTargetThumbnail(RT, ImageMapping, PhotoData) then
    PhotoData:Attach(self.LocalPhotoList, self)
    PhotoData.OnShareDelegate:Add(self, self.OnReqShare)
    PhotoData.OnDeleteDelegate:Add(self, self.OnReqDeleteByUser)
    PhotoData.OnUploadDelegate:Add(self, self.OnReqUpload)
    PhotoData.OnUploadCardDelegate:Add(self, self.OnReqUploadCard)
    return PhotoData
  end
end

function PhotoManager:AddRenderTargetThumbnail(RenderTarget, LocalMapping, PhotoData)
  if not RenderTarget or not UE.UObject.IsValid(RenderTarget) then
    Log.Error("[TakePhoto] Invalid RenderTarget")
    return
  end
  local SerializeService = NewObject(UE.URenderTextureService)
  local SerializeServiceBox = ObjectRefBoxing(SerializeService)
  local ThumbnailSavePath = LocalMapping .. "_Thumbnail"
  
  local function OnThumbnailTextureGenerated(_, ServiceObj, Texture)
  end
  
  local function OnRenderTextureSerialized(_, ServiceObj, SavePath, FileMD5)
    if PhotoData:IsValid() then
      local Brief = TakePhotoFileBrief():SetThumbnail(512):AsLocalFile(LocalMapping, FileMD5)
      PhotoData:SetBriefInfo(Brief)
      self:GetModule().data:RecordLocalPhotoStats(LocalMapping, FileMD5)
      self:TryAllocateResourceByPhotoData(PhotoData)
      PhotoData.OnRenderTextureSerialized:Invoke()
      self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnRenderTextureSerialized, PhotoData)
    else
      UE.UNRCStatics.DeleteToFile(LocalMapping)
      UE.UNRCStatics.DeleteToFile(ThumbnailSavePath)
    end
    if self.SerializeObjects[LocalMapping] then
      local Obj = ObjectRefUnBoxing(self.SerializeObjects[LocalMapping])
      self.SerializeObjects[LocalMapping] = nil
      UnLua.Unref(Obj)
    end
  end
  
  local bUsingGpuFence = RocoEnv.PLATFORM_IOS or RocoEnv.PLATFORM_WINDOWS
  local TaskType = SerializeService:MakeThumbnailSerializeTask(RenderTarget, 512, LocalMapping, ThumbnailSavePath, "TakePhotos_", {SerializeService, OnThumbnailTextureGenerated}, {SerializeService, OnRenderTextureSerialized}, true, bUsingGpuFence)
  if TaskType ~= UE.ERenderTextureTask.UnKnown then
    self.SerializeObjects[LocalMapping] = SerializeServiceBox
    SerializeService:StartTask(TaskType)
    return true
  else
    Log.Error("[TakePhoto] Invalid TaskType", TaskType)
  end
end

function PhotoManager:AddPhotoByCustomUpload(CustomFilePath, CustomUpload)
  if not UE.UNRCStatics.FileExists(CustomFilePath) then
    return
  end
  local TempPhotos = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
    "TempPhotos"
  })
  if not UE.UNRCStatics.DirectoryExists(TempPhotos) then
    UE.UNRCStatics.MakeDirectory(TempPhotos)
  end
  local DstFilePath = UE.UBlueprintPathsLibrary.Combine({
    TempPhotos,
    string.format("%d%d", _G.DataModelMgr.PlayerDataModel:GetPlayerUin(), math.floor(_G.ZoneServer:GetServerTime()))
  })
  UE.UNRCStatics.CopyFile(CustomFilePath, DstFilePath)
  if not UE.UNRCStatics.FileExists(DstFilePath) then
    return
  end
  local PhotoData = PhotoFileDefine.MakePhotoData()
  local Brief = TakePhotoFileBrief():AsLocalFile(DstFilePath, UE.UNRCStatics.HashFileMD5(DstFilePath))
  PhotoData:SetBriefInfo(Brief)
  PhotoData.OnUploadDelegate:Add(self, function()
    if CustomUpload then
      CustomUpload()
    end
  end)
  PhotoData.OnUploadCardDelegate:Add(self, function()
    if CustomUpload then
      CustomUpload()
    end
  end)
  PhotoData.OnUploadDelegate:Add(self, self.OnReqUpload)
  PhotoData.OnUploadCardDelegate:Add(self, self.OnReqUploadCard)
  PhotoData.OnShareDelegate:Add(self, self.OnReqShare)
  return PhotoData
end

function PhotoManager:GetModule()
  return NRCModuleManager:GetModule("TakePhotosModule")
end

function PhotoManager:GetLocalPhotoNum()
  return #self.LocalPhotoList
end

function PhotoManager:GetLocalPhotoDataBySerial(Serial)
  return self.LocalPhotoList[Serial]
end

function PhotoManager:RemoveLocalPhotoBySerial(SerialId)
  local PhotoData = self:GetLocalPhotoDataBySerial(SerialId)
  self:OnReqDelete(PhotoData, true)
  self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnPhotosRemoved)
end

function PhotoManager:RemoveLocalPhotosBySerials(Serials)
  local PhotoList = {}
  for i, SerialId in ipairs(Serials) do
    local PhotoData = self:GetLocalPhotoDataBySerial(SerialId)
    table.insert(PhotoList, PhotoData)
  end
  for i, PhotoData in ipairs(PhotoList) do
    self:OnReqDelete(PhotoData, true)
  end
  self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnPhotosRemoved)
end

function PhotoManager:GetRemotePhotoNum()
  return #self.RemotePhotoList
end

function PhotoManager:GetRemotePhotoDataBySerial(Serial)
  return self.RemotePhotoList[Serial]
end

function PhotoManager:RemoveRemotePhotoBySerial(SerialId)
  local PhotoData = self:GetRemotePhotoDataBySerial(SerialId)
  self:OnReqDeleteRemote(PhotoData, true)
end

function PhotoManager:RemoveRemotePhotosBySerials(Serials)
  local PhotoList = {}
  for i, SerialId in ipairs(Serials) do
    local PhotoData = self:GetRemotePhotoDataBySerial(SerialId)
    table.insert(PhotoList, PhotoData)
  end
  local RemoveNameList = {}
  for i, PhotoData in ipairs(PhotoList) do
    table.insert(RemoveNameList, PhotoData:UnpackPhotoName())
  end
  local PhotoServer = NRCModuleManager:GetModule("TakePhotosModule").PhotoServer
  local bSuccess = self:GetModule().PhotoServer:ReqRemovePhotos(RemoveNameList, function(bSuccess)
    self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnPhotosRemoved, bSuccess)
    if bSuccess then
      for i, PhotoData in ipairs(PhotoList) do
        if not PhotoServer:HasPhotoName(PhotoData:UnpackPhotoName()) then
          self:OnReqDeleteRemote(PhotoData, true)
        end
      end
    end
  end)
  if bSuccess then
    self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnBeginRemovePhotos)
  end
end

function PhotoManager:InternalJudgeMd5DeleteLocalFile(PhotoFile)
  local Md5 = self:GetModule().data:GetLocalPhotoStats(PhotoFile)
  if not Md5 or "" == Md5 then
    Log.Warning("[PhotoManager] delete unknown file", PhotoFile)
    self:InternalDeleteLocalFile(PhotoFile)
    return true, Md5
  else
    local FileMd5 = UE.UNRCStatics.HashFileMD5(PhotoFile)
    if Md5 ~= FileMd5 then
      Log.Warning("[PhotoManager] delete invalid file", PhotoFile, "expected", Md5, "but got", FileMd5)
      self:InternalDeleteLocalFile(PhotoFile)
      return true, Md5
    end
  end
  return false, Md5
end

function PhotoManager:InternalDeleteLocalFile(PhotoFile)
  UE.UNRCStatics.DeleteToFile(PhotoFile)
  self:GetModule().data:RemoveLocalPhotoStats(PhotoFile)
  Log.Debug("[PhotoManager] ReleaseCachedCardPhoto", PhotoFile)
end

function PhotoManager:IsRemoteAlbumInitialized()
  return self:GetModule().PhotoServer:IsInitialized()
end

function PhotoManager:IsLocalPhotosFull()
  return #self.LocalPhotoList >= self.LocalMaxiPhotoNum
end

function PhotoManager:GetRemainingLocalPhotoSlots()
  return self.LocalMaxiPhotoNum - #self.LocalPhotoList
end

function PhotoManager:IsRemotePhotosFull()
  return #self.RemotePhotoList >= self.RemoteMaxiPhotoNum
end

function PhotoManager:IsRemotePhoto(PhotoData)
  return PhotoData and self.RemotePhotoList == PhotoData.PhotoList
end

function PhotoManager:OnReqDeleteByUser(PhotoData)
  if not self:GetModule().data:IfNeedNotifyDelete() then
    self:OnReqDelete(PhotoData)
  else
    self:GetModule():DisplayDeletePrompt({
      OnConfirm = function()
        self:OnReqDelete(PhotoData)
      end
    })
  end
end

function PhotoManager:OnReqDeleteRemoteByUser(PhotoData)
  if not self:GetModule().data:IfNeedNotifyDelete() then
    self:OnReqDeleteRemote(PhotoData)
  else
    self:GetModule():DisplayDeletePrompt({
      OnConfirm = function()
        self:OnReqDeleteRemote(PhotoData)
      end
    })
  end
end

function PhotoManager:OnReqDelete(PhotoData, bForce)
  if bForce or PhotoData:IsReady() then
    local Next = PhotoData:GetNext()
    local Previous = PhotoData:GetPrevious()
    local Brief = PhotoData:GetBriefInfo()
    self.TakePhotoFileManager:DeleteBrief(Brief)
    PhotoData:OnDestroy()
    self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnPhotoRemoved, PhotoData, Next or Previous)
    return true
  end
end

function PhotoManager:OnReqDeleteRemote(PhotoData, bForce)
  local RemoveList = {
    PhotoData:UnpackPhotoName()
  }
  local bSuccess = self:GetModule().PhotoServer:ReqRemovePhotos(RemoveList, function(bSuccess)
    if bSuccess then
      self:OnReqDelete(PhotoData, bForce)
    end
  end)
  if bSuccess then
    self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnBeginRemovePhotos)
  end
end

function PhotoManager:OnReqUpload(PhotoData, FinishCallback)
  self:InternalReqUpload(PhotoData, FinishCallback, false)
end

function PhotoManager:InternalReqUpload(PhotoData, FinishCallback, bIgnoreSuccessTips)
  if PhotoData:IsReady() then
    local PhotoPath = PhotoData:GetPhotoPath()
    local Md5 = PhotoPath and UE.UNRCStatics.HashFileMD5(PhotoPath)
    if Md5 and Md5 == PhotoData:GetDesiredMd5() then
      local Names = string.split(PhotoPath, "/")
      local Name = Names[#Names]
      if self:GetModule().PhotoServer:HasPhotoName(Name) then
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.takephoto_upload_cloud_repeat)
        return
      end
      local ban = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_CLOUD_BACKGROUND_IMAGE, true)
      if ban then
        return
      end
      ban = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_CLOUD_IMAGE, true)
      if ban then
        return
      end
      if self:IsRemotePhotosFull() then
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.takephoto_cloud_storage_full)
        return
      end
      local bSendSuccess = true
      self:GetModule().PhotoServer:ReqUploadTempPhoto(PhotoPath, ProtoEnum.PlayerPhotoAlbumType.PLAYER_PHOTO_ALBUM_TYPE_PHOTO, function(bSuccess, File, isIdipBan)
        bSendSuccess = bSuccess
        if bSuccess then
          local RemotePhotoData = self:AddPhotoByRemotePhoto(File)
          self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnFinishUploadPhoto, PhotoData, RemotePhotoData)
          if FinishCallback then
            FinishCallback(PhotoData, RemotePhotoData)
          end
        else
          self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnFinishUploadPhoto, PhotoData)
          if FinishCallback then
            FinishCallback(PhotoData)
          end
        end
        if bSuccess then
          if not bIgnoreSuccessTips then
            _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.takephoto_upload_cloud_succeed)
          end
        elseif not isIdipBan then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.takephoto_upload_cloud_failed)
        end
      end)
      if bSendSuccess then
        self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnBeginUploadPhoto, PhotoData)
      end
      return bSendSuccess
    end
  end
end

function PhotoManager:OnReqUploadCard(PhotoData)
  local ban = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_CLOUD_BACKGROUND_IMAGE, true)
  if ban then
    return
  else
    ban = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_BACKGROUND_IMAGE, true)
    if ban then
      return
    end
  end
  local Names = string.split(PhotoData:GetPhotoPath(), "/")
  local Name = Names[#Names]
  
  local function OnEnterCard()
    self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnBeginCroppingCard, PhotoData:GetPhotoTexture2D())
    local FriendModule = NRCModuleManager:GetModule("FriendModule")
    if not FriendModule:HasPanel("StudentCard") and not NRCPanelManager:IsLoadingPanel("FriendModule", "StudentCard") then
      FriendModule.data:SetCroppingPhotoData(PhotoData)
      _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenStudentCardPanel, nil, FriendEnum.AdminFriendType.Own, FriendEnum.Source.Friend, nil, false, true)
    end
  end
  
  if self:GetModule().PhotoServer:HasPhotoName(Name) then
    OnEnterCard()
    return
  end
  self:InternalReqUpload(PhotoData, function(_, RemoteData)
    if RemoteData then
      OnEnterCard()
    end
  end, true)
end

function PhotoManager:OnReqShare(PhotoData)
  self:GetModule():OpenSharePhotoPanel(PhotoData)
end

return PhotoManager
