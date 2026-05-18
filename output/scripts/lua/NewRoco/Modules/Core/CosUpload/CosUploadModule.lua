local CosUploadModule = NRCModuleBase:Extend("CosUploadModule")
local EnmFileCosUploadState = {
  NONE = 1,
  WAIT = 2,
  WAIT_SERVER = 3,
  UPLOADING = 4,
  UPLOADED_SUCCESS = 5,
  SERVER_FAILED = -1,
  UPLOADED_FAILED = -2,
  FILE_REMOVED = -3
}
local EnmFileCosUploadType = {
  Log_Files = 1,
  Battle_Files = 2,
  Home_Files = 3
}

local function error_handler(err)
  local extMsg = ""
  extMsg = "[Error]" .. tostring(extMsg)
  if err then
    extMsg = extMsg .. "\n" .. tostring(err)
  end
  extMsg = extMsg .. "\n" .. debug.traceback()
  UE4.UNRCPlatformGameInstance.GetInstance():ReportLuaErrorMsg(extMsg)
  return extMsg
end

function CosUploadModule:OnConstruct()
  _G.CosUploadModuleCmd = reload("NewRoco.Modules.Core.CosUpload.CosUploadModuleCmd")
  self.data = self:SetData("CosUploadModuleData", "NewRoco.Modules.Core.CosUpload.CosUploadModuleData")
  self.HttpService = UE4.UMoreFunPlatformKits.CreateSimpleHttpService()
  self.HttpServiceRef = UnLua.Ref(self.HttpService)
  self.FileUploadQueue = Queue()
  self.FileUploadState = {}
  self.LastUploadedFiles = {}
  self.CurrentProcessedFile = nil
  self.TotalTypeFiles = {}
  self.LocalRemoteMapping = {}
  self.LogFilesUploadState = EnmFileCosUploadState.NONE
end

function CosUploadModule:OnActive()
  NRCEventCenter:RegisterEvent(self.moduleName, self, _G.NRCGlobalEvent.ON_LOGIN, self.OnLogin)
  NRCEventCenter:RegisterEvent(self.moduleName, self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnected)
end

function CosUploadModule:OnRelogin()
end

function CosUploadModule:OnDeactive()
  NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_LOGIN, self.OnLogin)
  NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnected)
end

function CosUploadModule:OnDestruct()
end

function CosUploadModule:OnLogin()
  if self.LogFilesUploadState == EnmFileCosUploadState.WAIT_SERVER then
    self:StartupUploadLogs()
  end
end

function CosUploadModule:OnReconnected()
  if self.LogFilesUploadState ~= EnmFileCosUploadState.WAIT_SERVER then
    return
  end
  if self.CurrentProcessedFile and self.FileUploadQueue:Size() > 0 then
    local ThisOne = self.FileUploadQueue:First()
    local FileName = ThisOne.FileName
    if self.CurrentProcessedFile == FileName then
      local FileType = ThisOne.FileType
      local FileMd5 = ThisOne.FileMd5
      local FileSize = ThisOne.FileSize
      local CustomData = ThisOne.CustomData
      self:Log("[CosUpload] queue reconnect upload request, filename:", FileName, FileType)
      self.FileUploadState[FileName] = EnmFileCosUploadState.NONE
      if self:InternalReqCosUploadUrl(FileType, FileName, FileSize, FileMd5, CustomData) then
        return
      end
      self:InternalQueueUpload()
    else
      Log.Error("[CosUpload] processing", self.CurrentProcessedFile, "but queue", FileName)
    end
  end
end

function CosUploadModule:InternalReqCosUploadUrl(FileType, FileName, FileSize, FileMd5, CustomData)
  if not FileName or not UE.UBlueprintPathsLibrary.FileExists(FileName) then
    self:LogError("[CosUpload] invalid file=", FileName)
    return false
  end
  local Files = self.TotalTypeFiles[FileType]
  if not Files then
    Files = {}
    self.TotalTypeFiles[FileType] = Files
  end
  Files[FileName] = true
  local State = self.FileUploadState[FileName] or EnmFileCosUploadState.NONE
  if State ~= EnmFileCosUploadState.NONE then
    if State == EnmFileCosUploadState.SERVER_FAILED then
      State = EnmFileCosUploadState.NONE
      self.FileUploadState[FileName] = State
      self:Log("[CosUpload] retry upload, previous server request upload url failed, filename:", FileName)
    else
      self:LogError("[CosUpload] file has been processed", FileName, State)
      return true
    end
  end
  if self.CurrentProcessedFile then
    self:Log("[CosUpload] processing file, enqueue wait for uploading", FileName)
    self.FileUploadQueue:Enqueue({
      FileType = FileType,
      FileName = FileName,
      FileSize = FileSize,
      FileMd5 = FileMd5,
      CustomData = CustomData
    })
    self.FileUploadState[FileName] = EnmFileCosUploadState.WAIT
    return true
  end
  self:Log("[CosUpload] request cos upload url:", FileType, FileName)
  self.CurrentProcessedFile = FileName
  self.FileUploadState[FileName] = EnmFileCosUploadState.WAIT_SERVER
  local SuffixFileNames = string.split(FileName, "/")
  local SuffixFileName = SuffixFileNames[#SuffixFileNames]
  local req = _G.ProtoMessage:newZoneGetCosUploadUrlReq()
  req.type = FileType
  req.file_name = SuffixFileName or FileName
  req.file_size = FileSize or 0
  req.file_md5 = FileMd5 or ""
  req.client_version = AppMain.AppVersion
  req.battle_id = CustomData and CustomData.BattleId or 0
  local rspWrapper = {}
  rspWrapper.handler = _G.MakeWeakFunctor(self, self.OnZoneGetCosUploadUrlRsp)
  rspWrapper.reqMsg = req
  rspWrapper.full_path_filename = FileName
  rspWrapper.custom_data = CustomData
  
  local function OnSvrRspHandle(_rspWrapper, _protoData)
    if _rspWrapper then
      _rspWrapper.handler(_protoData, _rspWrapper.reqMsg, _rspWrapper.full_path_filename, _rspWrapper.custom_data)
    end
  end
  
  local Success = _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_COS_UPLOAD_URL_REQ, req, rspWrapper, OnSvrRspHandle)
  if not Success then
    self.CurrentProcessedFile = nil
    self.FileUploadState[FileName] = nil
    self:LogError("[CosUpload] SendWithHandler Failed:", FileName)
  end
  return Success
end

function CosUploadModule:OnZoneGetCosUploadUrlRsp(Rsp, Req, FullFileName, CustomData)
  self.LocalRemoteMapping[FullFileName] = nil
  if 0 == Rsp.ret_info.ret_code then
    Log.Info("[CosUpload] OnZoneGetCosUploadUrlRsp, success, url:", Rsp.url, "type:", Rsp.type, "filename:", Rsp.file_name, "current:", self.CurrentProcessedFile)
    Log.Info("[CosUpload] cos gen_filename:", Rsp.gen_filename)
    self.LocalRemoteMapping[FullFileName] = Rsp.gen_filename
    if FullFileName == self.CurrentProcessedFile then
      self:InternalStartUpload(Rsp.type, FullFileName, Rsp.url)
    else
      Log.Error("[CosUpload] LogicalError:%s,%s", FullFileName, self.CurrentProcessedFile, Rsp.file_name)
      self:InternalQueueUpload()
    end
  else
    Log.Error("[CosUpload] OnZoneGetCosUploadUrlRsp, err:", Rsp.ret_info.ret_code, Rsp.ret_info.ret_msg, "filename:", Rsp.file_name)
    self.FileUploadState[FullFileName] = nil
    self:InternalQueueUpload()
  end
  local RspRemotePathDelegate = CustomData and CustomData.RspRemotePathDelegate
  if RspRemotePathDelegate then
    xpcall(RspRemotePathDelegate, error_handler, self.LocalRemoteMapping[FullFileName])
  end
end

function CosUploadModule:InternalQueueUpload()
  self:Log("[CosUpload] finish current processing filename", self.CurrentProcessedFile)
  self.CurrentProcessedFile = nil
  while self.FileUploadQueue:Size() > 0 do
    local NextOne = self.FileUploadQueue:Dequeue()
    local FileName = NextOne.FileName
    local FileType = NextOne.FileType
    local FileMd5 = NextOne.FileMd5
    local FileSize = NextOne.FileSize
    local CustomData = NextOne.CustomData
    self:Log("[CosUpload] queue next upload request, filename:", FileName, FileType)
    self.FileUploadState[FileName] = EnmFileCosUploadState.NONE
    if self:InternalReqCosUploadUrl(FileType, FileName, FileSize, FileMd5, CustomData) then
      return
    end
  end
  self:Log("[CosUpload] finish all upload requests.")
  local LogsFiles = self.TotalTypeFiles[EnmFileCosUploadType.Log_Files]
  if LogsFiles then
    local bSuccess = true
    for File, _ in pairs(LogsFiles) do
      local State = self.FileUploadState[File]
      if State ~= EnmFileCosUploadState.UPLOADED_SUCCESS then
        bSuccess = false
      end
      self:Log("[CosUpload] upload logs, file state:", State or "nil", File)
    end
    if bSuccess then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.repairtools_upload_success)
      self.LogFilesUploadState = EnmFileCosUploadState.UPLOADED_SUCCESS
    else
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.repairtools_upload_failed)
      self.LogFilesUploadState = EnmFileCosUploadState.UPLOADED_FAILED
    end
  end
  self.LastUploadedFiles = self.FileUploadState
  self.FileUploadState = {}
  self.TotalTypeFiles = {}
  self.LocalRemoteMapping = {}
  if self.DelayCleanUploadRecord then
    DelayManager:CancelDelayById(self.DelayCleanUploadRecord)
    self.DelayCleanUploadRecord = nil
  end
  self.DelayCleanUploadRecord = DelayManager:DelaySeconds(60, function()
    self.DelayCleanUploadRecord = nil
    self.LastUploadedFiles = {}
  end)
end

function CosUploadModule:OnInternalUploadSuccessFinish(Type, FileName)
  if Type == EnmFileCosUploadType.Log_Files then
    self:Log("[CosUpload] delete log file:", FileName)
    if string.find(FileName, "NRC%-backup") then
      UE.UNRCStatics.DeleteToFile(FileName)
    elseif FileName ~= self.TheNewestLogFile then
      UE.UNRCStatics.DeleteToFile(FileName)
    end
  end
end

function CosUploadModule:OnInternalUploadFailedFinish(Type, FileName)
end

function CosUploadModule:InternalStartUpload(Type, FileName, Url)
  if not UE.UBlueprintPathsLibrary.FileExists(FileName) then
    self:LogError("[CosUpload] start upload, but cannot found file:", FileName, Type, Url)
    self.FileUploadState[FileName] = EnmFileCosUploadState.FILE_REMOVED
    self:OnInternalUploadFailedFinish(Type, FileName)
    self:InternalQueueUpload()
    return
  end
  local ContentType = ""
  if Type == EnmFileCosUploadType.Log_Files then
    ContentType = "text/plain"
  else
    ContentType = "application/json"
  end
  self.FileUploadState[FileName] = EnmFileCosUploadState.UPLOADING
  self:Log("[CosUpload] uploading file:", FileName, Type, Url)
  if _G and _G.NNRCModeManager and _G.PlayerModuleCmd then
    local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if player then
      local NowHeroPos = player:GetActorLocation()
      Log.Debug("CosUploadModule:InternalStartUpload Current player Pos: ", NowHeroPos.X, NowHeroPos.Y, NowHeroPos.Z)
    end
  end
  if FileName == self.TheNewestLogFile and UE.UNRCStatics.FlushLog then
    UE.UNRCStatics:FlushLog()
  end
  self.HttpService:ResetHeaders()
  self.HttpService:ResetFields()
  self.HttpService:SetHeader("Content-Type", ContentType)
  self.HttpService:SetFile(FileName)
  self.HttpService:SetUrl(Url)
  self.HttpService:SetVerb("PUT")
  self.HttpService:Request({
    self.HttpService,
    function(HttpService, Status)
      local RspContent = HttpService:GetRspContent()
      self:Log("[CosUpload] upload finish", FileName, "rsp:", RspContent, "status:", Status)
      if Status == UE.EHttpServiceStatus.RspSuccess then
        self.FileUploadState[FileName] = EnmFileCosUploadState.UPLOADED_SUCCESS
        self:OnInternalUploadSuccessFinish(Type, FileName)
      else
        self.FileUploadState[FileName] = EnmFileCosUploadState.UPLOADED_FAILED
        self:OnInternalUploadFailedFinish(Type, FileName)
      end
      self:InternalQueueUpload()
    end
  })
end

function CosUploadModule:ReqCosUploadUrlForLog(FullFilePath)
  if self.FileUploadState[FullFilePath] then
    return false
  end
  local Ret = self:InternalReqCosUploadUrl(EnmFileCosUploadType.Log_Files, FullFilePath)
  return Ret
end

function CosUploadModule:ReqCosUploadUrlForBattle(BattleId, FullFilePath, RspRemotePathDelegate)
  if self.LocalRemoteMapping[FullFilePath] and RspRemotePathDelegate then
    RspRemotePathDelegate(self.LocalRemoteMapping[FullFilePath])
  end
  if self.FileUploadState[FullFilePath] then
    return false
  end
  local Ret = self:InternalReqCosUploadUrl(EnmFileCosUploadType.Battle_Files, FullFilePath, nil, nil, {RspRemotePathDelegate = RspRemotePathDelegate, BattleId = BattleId})
  return Ret
end

function CosUploadModule:ReqCosUploadUrlForHome(FullFilePath)
  if self.FileUploadState[FullFilePath] then
    return false
  end
  local Ret = self:InternalReqCosUploadUrl(EnmFileCosUploadType.Home_Files, FullFilePath)
  return Ret
end

function CosUploadModule:GetLogDir()
  if UE.UNRCStatics.IsBqLogEnabled and UE.UNRCStatics.IsBqLogEnabled() then
    return UE.UBlueprintPathsLibrary.Combine({
      UE.UBlueprintPathsLibrary.ProjectLogDir(),
      "bqLog"
    }), true
  end
  return UE.UBlueprintPathsLibrary.ProjectLogDir(), false
end

function CosUploadModule:StartupUploadLogs()
  if ENABLE_CLICK_UPLOAD_COPY_LOGS then
    xpcall(function()
      self:CopyLogs()
    end, function(err)
      self:LogError(err)
    end)
  end
  if not _G.ZoneServer:IsConnected() then
    self.LogFilesUploadState = EnmFileCosUploadState.WAIT_SERVER
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.repairtools_uploading)
    return
  end
  if self.LogFilesUploadState == EnmFileCosUploadState.UPLOADING then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.repairtools_uploading)
    return
  end
  if self.DelayCleanUploadRecord then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.repairtools_upload_cooldown)
    return
  end
  self.LogFilesUploadState = EnmFileCosUploadState.UPLOADING
  self:Log("[CosUpload] StartupUploadLogs")
  local bFinishAll = true
  local bHasSuccessUploading = false
  local LogsFolder, bqLogEnabled = self:GetLogDir()
  if UE.UNRCStatics.FlushLog then
    UE.UNRCStatics.FlushLog()
  end
  local Files = UE.UNRCStatics.ListFiles(LogsFolder, "*.*")
  if Files then
    local LogFiles = {}
    local TheNewestLogFile
    for _, File in tpairs(Files) do
      local bLogFile = false
      if bqLogEnabled then
        bLogFile = string.find(File, "logcompr")
      else
        bLogFile = string.find(File, "NRC(.*)%.log")
      end
      if bLogFile then
        self:Log("[CosUpload] check upload log file", File, not self.LastUploadedFiles[File])
        local bNRCLog = string.find(File, "NRC%.log")
        if not bqLogEnabled and bNRCLog then
          TheNewestLogFile = File
        end
        if bqLogEnabled then
          table.insert(LogFiles, File)
        elseif not bNRCLog then
          table.insert(LogFiles, File)
        end
        if not self.LastUploadedFiles[File] then
          bFinishAll = false
        end
      end
    end
    
    local function GetFileDateIndex(File)
      local Date, Index = File:match("nrc_log_(%d+)_(%d+)")
      if Date and Index then
        return Date, Index
      end
      return 0, 0
    end
    
    local GetFileStamp = UEGetFileDateTime
    table.sort(LogFiles, function(a, b)
      local aStamp = GetFileStamp and GetFileStamp(a) or 0
      local bStamp = GetFileStamp and GetFileStamp(b) or 0
      if aStamp ~= bStamp then
        return aStamp > bStamp
      end
      local aDate, aIndex = GetFileDateIndex(a)
      local bDate, bIndex = GetFileDateIndex(b)
      if aDate ~= bDate or aIndex ~= bIndex then
        if aDate ~= bDate then
          return aDate > bDate
        end
        return aIndex > bIndex
      end
      return b < a
    end)
    if bqLogEnabled then
      TheNewestLogFile = LogFiles[1]
    end
    if not bFinishAll then
      self.TheNewestLogFile = TheNewestLogFile
      self:LogWarning("[CosUpload] TheNewestLogFile:", self.TheNewestLogFile)
      for i = #LogFiles, 1, -1 do
        local File = LogFiles[i]
        if not self.LastUploadedFiles[File] and self:ReqCosUploadUrlForLog(File) then
          bHasSuccessUploading = true
        end
      end
      if not bqLogEnabled and not self.LastUploadedFiles[TheNewestLogFile] and self:ReqCosUploadUrlForLog(TheNewestLogFile) then
        bHasSuccessUploading = true
      end
    end
  end
  if bFinishAll then
    self.LogFilesUploadState = EnmFileCosUploadState.UPLOADED_SUCCESS
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.repairtools_upload_success)
    self:Log("[CosUpload] StartupUploadLogs finish directly")
  elseif bHasSuccessUploading then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.repairtools_uploading)
    self:Log("[CosUpload] StartupUploadLogs wait")
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.repairtools_upload_failed)
    self:Log("[CosUpload] StartupUploadLogs failed all")
  end
end

function CosUploadModule:InternalDownloadImmediately(RemotePath, LocalPath)
  if not _G.RocoEnv.IS_EDITOR then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "Cos\228\184\139\232\189\189\229\183\165\229\133\183\229\143\170\229\156\168\231\188\150\232\190\145\229\153\168\228\184\139\228\189\191\231\148\168")
    return
  end
  local Names = string.split(RemotePath, "/")
  local Name = Names[#Names]
  local NameSuffix = string.split(Name, "%.")
  table.remove(NameSuffix)
  local NameNoSuffix = table.concat(NameSuffix)
  Name = string.gsub(Name, "[\\/:*?\"<>|]", ".")
  local bBattleFile = string.StartsWith(RemotePath, "battle_record")
  if not LocalPath then
    if string.StartsWith(RemotePath, "log") then
      local LogDir = UE.UBlueprintPathsLibrary.ProjectLogDir()
      LocalPath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(UE.UBlueprintPathsLibrary.Combine({LogDir, Name}))
    else
      local SaveDir = UE.UBlueprintPathsLibrary.ProjectSavedDir()
      LocalPath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(UE.UBlueprintPathsLibrary.Combine({SaveDir, Name}))
    end
  end
  local NoFixLocalPath = LocalPath
  local NoFixRemotePath = RemotePath
  RemotePath = "\"" .. RemotePath .. "\""
  LocalPath = "\"" .. LocalPath .. "\""
  self:Log("[CosUpload] download:", RemotePath)
  self:Log("[CosUpload] savepath:", LocalPath)
  local ProjectDir = UE.UBlueprintPathsLibrary.ProjectDir()
  local WorkingDirectory = UE.UBlueprintPathsLibrary.Combine({
    ProjectDir,
    "Tools",
    "Cos",
    "download"
  })
  local Parameters = RemotePath .. " " .. LocalPath
  local Command = WorkingDirectory .. "/cos_download.exe"
  local Content = UE.UNRCStatics.CreateCommandProcInEditor(WorkingDirectory, Command, Parameters)
  local bSuccess = UE.UBlueprintPathsLibrary.FileExists(NoFixLocalPath)
  local WarnContent = ""
  if bBattleFile then
    WarnContent = "\232\191\156\231\168\139\239\188\154" .. NoFixRemotePath .. "\n" .. "\230\156\172\229\156\176\239\188\154" .. NoFixLocalPath .. "\n\230\152\175\229\144\166\231\155\180\230\142\165\230\146\173\230\148\190\230\136\152\230\150\151\229\189\149\229\131\143?"
  else
    WarnContent = "\232\191\156\231\168\139\239\188\154" .. NoFixRemotePath .. "\n" .. "\230\156\172\229\156\176\239\188\154" .. NoFixLocalPath .. "\n\230\152\175\229\144\166\229\164\141\229\136\182\230\150\135\228\187\182\229\144\141?"
  end
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Ctx = DialogContext()
  Ctx:SetTitle("\228\187\142Cos\228\184\139\232\189\189\230\150\135\228\187\182"):SetContent(bSuccess and WarnContent or Content):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.OK, LuaText.CANCEL):SetCloseOnCancel(true):SetCloseOnOK(true):SetCallback(self, function(_, isOK)
    if isOK and bSuccess then
      if bBattleFile then
        UE.UNRCStatics.ExecConsoleCommand("gm.ReplayBattleGM " .. NameNoSuffix)
      else
        UE4.UNRCStatics.ClipboardCopy(NameNoSuffix)
      end
    end
  end)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function CosUploadModule:DownloadFile(RemotePath, LocalPath)
  self:InternalDownloadImmediately(RemotePath, LocalPath)
end

local LogsRelativeDir = "UE4Game/NRC/NRC/Saved/Logs"

function CosUploadModule:CopyLogs()
  if not RocoEnv.PLATFORM_ANDROID then
    return
  end
  local ExternalRoot = "../../.."
  local InternalRoot = UE.UNRCStatics.GetInternalStoragePath()
  local LogsFolder = UE.UBlueprintPathsLibrary.Combine({InternalRoot, LogsRelativeDir})
  Log.ErrorFormat("ExternalRoot(%s)", ExternalRoot)
  Log.ErrorFormat("InternalRoot(%s)", InternalRoot)
  Log.ErrorFormat("LogsFolder(%s)", LogsFolder)
  
  local function OnPermissionCallback()
    local Files = UE.UNRCStatics.ListFiles(LogsFolder, "*.*")
    local UE4GameTemp = "UE4Game_" .. tostring(os.time())
    for i, File in tpairs(Files) do
      local DstFile = string.gsub(File, InternalRoot, ExternalRoot)
      DstFile = string.gsub(DstFile, "UE4Game", UE4GameTemp)
      local Names = string.split(DstFile, "/")
      local Name = table.remove(Names)
      local DstPath = table.concat(Names, "/")
      UE.UNRCStatics.MakeDirectory(DstPath)
      UE.UNRCStatics.CopyFile(File, DstFile)
      Log.ErrorFormat("Copy DstPath(%s)", DstPath)
      Log.ErrorFormat("CopyLogs Copy File(%s), From(%s), To(%s), Exists(%s)", Name, File, DstFile, UE4.UBlueprintPathsLibrary.FileExists(DstPath))
    end
  end
  
  local bGranted = UE.UNRCPermissionMgr.IfPermissionGranted(UE.ENRCPermissionType.AccessAlbum)
  if not bGranted then
    self.requestCode = UE.UNRCPermissionMgr.RequestPermission(UE.ENRCPermissionType.AccessAlbum, {
      self,
      function(_, bInGranted)
        self.requestCode = nil
        if bInGranted then
          OnPermissionCallback()
        end
      end
    })
  else
    OnPermissionCallback()
  end
end

function CosUploadModule:CopyToInternal()
  local ExternalRoot = UE.UNRCStatics.GetExternalStoragePath()
  local InternalRoot = UE.UNRCStatics.GetInternalStoragePath()
  local LogsFolder = UE.UBlueprintPathsLibrary.ConvertRelativePathToFull(UE.UBlueprintPathsLibrary.ProjectLogDir())
  Log.ErrorFormat("ExternalRoot(%s)", ExternalRoot)
  Log.ErrorFormat("InternalRoot(%s)", InternalRoot)
  Log.ErrorFormat("LogsFolder(%s)", LogsFolder)
  
  local function OnPermissionCallback()
    local Files = UE.UNRCStatics.ListFiles(LogsFolder, "*.*")
    for i, File in tpairs(Files) do
      local DstFile = string.gsub(File, "%.%./%.%./%.%.", InternalRoot .. "/UE4Game/NRC")
      local Names = string.split(DstFile, "/")
      local Name = table.remove(Names)
      local DstPath = table.concat(Names, "/")
      UE.UNRCStatics.MakeDirectory(DstPath)
      UE.UNRCStatics.CopyFile(File, DstFile)
      Log.ErrorFormat("Copy DstPath(%s)", DstPath)
      Log.ErrorFormat("Copy File(%s), From(%s), To(%s), Exists(%s)", Name, File, DstFile, UE4.UBlueprintPathsLibrary.FileExists(DstPath))
    end
  end
  
  local bGranted = UE.UNRCPermissionMgr.IfPermissionGranted(UE.ENRCPermissionType.AccessAlbum)
  if not bGranted then
    self.requestCode = UE.UNRCPermissionMgr.RequestPermission(UE.ENRCPermissionType.AccessAlbum, {
      self,
      function(_, bInGranted)
        self.requestCode = nil
        if bInGranted then
          OnPermissionCallback()
        end
      end
    })
  else
    OnPermissionCallback()
  end
end

return CosUploadModule
