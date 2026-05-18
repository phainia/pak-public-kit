local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Json = require("Common.JsonUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = DebugTabBase
local DebugTabTest = Base:Extend("DebugTabTest")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")

function DebugTabTest:SetupTabs()
  self:TryInitialize()
  self:Add("\229\188\128\229\144\175\230\137\128\230\156\137\230\151\165\229\191\151", self.OpenAllLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenAllLog")
  self:Add("\228\187\142Cos\228\184\139\232\189\189\230\150\135\228\187\182", self.DownloadFileFromCos, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149RT", self.TestRTCapture, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149RTActor", self.TestRTCaptureActor, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("PrintDir", self.PrintDir, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("EmmyLuaServer", self.OpenEmmyLuaServer, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\167\139\230\181\139\232\175\149\230\187\164\233\149\156RT", self.StartCaptureFilter, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "StartCaptureFilter")
  self:Add("\229\129\156\230\173\162\230\181\139\232\175\149\230\187\164\233\149\156RT", self.StopCaptureFilter, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "StopCaptureFilter")
  self:Add("\230\137\147\229\188\128\233\170\145\228\185\152\230\139\141\231\133\167\231\188\150\232\190\145\229\153\168", self.OpenPhotoRideEditor, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "OpenPhotoRideEditor")
end

function DebugTabTest:OpenAllLog()
  UE4.UNRCStatics.SetLogLevel(8)
  Log.SetLogLevel(Log.LOG_LEVEL.ELogTrace)
end

function DebugTabTest:TryInitialize()
  if not self.bInitialized then
    self.GMPlatformKits = UE4.UMoreFunPlatformKits
    self.ScreenShotService = self.GMPlatformKits.CreateScreenShotService()
    self.ScreenShotServiceRef = UnLua.Ref(self.ScreenShotService)
    self.HttpService = self.GMPlatformKits.CreateSimpleHttpService()
    self.HttpServiceRef = UnLua.Ref(self.HttpService)
    self.bInitialized = true
  end
end

function DebugTabTest:TestScreenShot()
  self:TryInitialize()
  self:_DoReqScreenShot(tostring(os.time()), function(bIsSuccess, SavePath, Service)
    local Content = string.format("\230\136\170\229\155\190\228\191\157\229\173\152: Success:%s, Path:%s", bIsSuccess, SavePath)
    Log.Info(Content)
    self:ShowDialog(Content)
  end)
end

function DebugTabTest:TestScreenShotShowUI()
  self:TryInitialize()
  self:ClosePanel()
  self:_DoReqScreenShot(tostring(os.time()), function(bIsSuccess, SavePath, Service)
    local Content = string.format("\229\133\179\233\151\173Debug\231\149\140\233\157\162\229\144\142\228\191\157\231\149\153\229\133\182\228\187\150\231\149\140\233\157\162\230\136\170\229\155\190\228\191\157\229\173\152: Success:%s, Path:%s", bIsSuccess, SavePath)
    Log.Info(Content)
    self:ShowDialog(Content)
  end, true)
end

function DebugTabTest:TestReqUploadUrl()
  self:TryInitialize()
  self:_DoReqUploadUrl(function(bIsSuccess, RspString, FileName)
    local Content = string.format("\230\139\137\229\143\150\230\136\170\229\155\190\228\184\138\230\138\165\229\156\176\229\157\128: Success:%s, \232\175\183\230\177\130\230\150\135\228\187\182\229\144\141:%s Rsp:%s", bIsSuccess, FileName, RspString)
    Log.Info(Content)
    self:ShowDialog(Content)
  end)
end

function DebugTabTest:TestCollectLocalInfo()
  self:TryInitialize()
  local InfoTable = self:_DoCollectReportInfoTable()
  for k, v in pairs(InfoTable) do
    print(k, v)
  end
  self:Inspect(InfoTable, "\230\148\182\233\155\134\230\156\172\229\156\176\228\191\161\230\129\175\239\188\136\230\181\139\232\175\149\239\188\137")
end

function DebugTabTest:TestPlayerZoneInfo()
  self:TryInitialize()
  local AreaCfg = _G.NRCModuleManager:DoCmd(AreaAndZoneModuleCmd.GetPlayerZoneInfo)
  self:Inspect(AreaCfg, "\229\140\186\229\159\159\228\191\161\230\129\175")
end

function DebugTabTest:UploadLevelResBugScreenShotNoUI()
  self:TryInitialize()
  local Ctx = DialogContext()
  Ctx:SetTitle("\229\156\186\230\153\175\232\181\132\230\186\144\231\188\186\233\153\183\230\136\170\229\155\190\228\184\138\230\138\165 - \231\186\175\229\135\128\230\151\160\231\149\140\233\157\162"):SetContent("\231\161\174\232\174\164\230\137\167\232\161\140\230\136\170\229\155\190\229\185\182\228\184\138\230\138\165\233\148\153\232\175\175\239\188\159\n(1)\231\173\137\229\190\133\230\139\137\229\143\150\228\184\138\230\138\165\229\156\176\229\157\128\n(2)\230\136\170\229\155\190\n(3)\228\184\138\228\188\160\230\136\170\229\155\190\n(4)\228\184\138\230\138\165\229\174\140\230\149\180\228\191\161\230\129\175"):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(self, function(obj, bProcess)
    if bProcess then
      return obj:_DoUploadLevelResBugScreenShot(false)
    end
  end):SetCloseOnCancel(true):SetButtonText("\231\161\174\232\174\164", "\229\143\150\230\182\136")
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabTest:UploadLevelResBugScreenShot()
  self:TryInitialize()
  local Ctx = DialogContext()
  Ctx:SetTitle("\229\156\186\230\153\175\232\181\132\230\186\144\231\188\186\233\153\183\230\136\170\229\155\190\228\184\138\230\138\165"):SetContent("\231\161\174\232\174\164\230\137\167\232\161\140\230\136\170\229\155\190\229\185\182\228\184\138\230\138\165\233\148\153\232\175\175\239\188\159\n(1)\231\173\137\229\190\133\230\139\137\229\143\150\228\184\138\230\138\165\229\156\176\229\157\128\n(2)\230\136\170\229\155\190\n(3)\228\184\138\228\188\160\230\136\170\229\155\190\n(4)\228\184\138\230\138\165\229\174\140\230\149\180\228\191\161\230\129\175"):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(self, function(obj, bProcess)
    if bProcess then
      return obj:_DoUploadLevelResBugScreenShot(true)
    end
  end):SetCloseOnCancel(true):SetButtonText("\231\161\174\232\174\164", "\229\143\150\230\182\136")
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabTest:_DoShowDialogNotify(Title, Content)
  local Ctx = DialogContext()
  Ctx:SetTitle(Title):SetContent(Content):SetMode(DialogContext.Mode.NotBtn)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabTest:_DoUploadLevelResBugScreenShot(bShowUI)
  self:ShowTips("\230\137\167\232\161\140 - \229\156\186\230\153\175\232\181\132\230\186\144\231\188\186\233\153\183\230\136\170\229\155\190\228\184\138\230\138\165")
  self:_DoShowDialogNotify("\229\156\186\230\153\175\232\181\132\230\186\144\231\188\186\233\153\183\230\136\170\229\155\190\228\184\138\230\138\165", "(1)\231\173\137\229\190\133\230\139\137\229\143\150\228\184\138\230\138\165\229\156\176\229\157\128...")
  self:_DoReqUploadUrl(function(bIsSuccess, RspString, FileName)
    local Content = string.format("\230\139\137\229\143\150\230\136\170\229\155\190\228\184\138\230\138\165\229\156\176\229\157\128: Success:%s, \232\175\183\230\177\130\230\150\135\228\187\182\229\144\141:%s Rsp:%s", bIsSuccess, FileName, RspString)
    Log.Info(Content)
    local JsonData = Json.StringToJson(RspString)
    local UploadUrl = JsonData.data.upload_url
    local InternalUrl = JsonData.data.file_download_info.internal_url
    Log.Info("UploadUrl:", UploadUrl)
    Log.Info("InternalUrl:", InternalUrl)
    Log.Info("ExternalUrl:", JsonData.data.file_download_info.external_url)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_CloseDialog)
    self:_DoReqScreenShot(FileName, function(bSaveSuccess, SavePath)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_CloseDialog)
      if bSaveSuccess then
        Content = string.format("\230\136\170\229\155\190\228\191\157\229\173\152: Success:%s, Path:%s", bIsSuccess, SavePath)
        Log.Info(Content)
        self:_DoShowDialogNotify("\229\156\186\230\153\175\232\181\132\230\186\144\231\188\186\233\153\183\230\136\170\229\155\190\228\184\138\230\138\165", string.format("(3)\231\173\137\229\190\133\230\136\170\229\155\190\228\184\138\228\188\160...\n%s", SavePath))
        self:_DoReqPutImage(UploadUrl, SavePath, function(bUploadSuccess, UploadRsp)
          Content = string.format("\228\184\138\228\188\160\230\136\170\229\155\190: Success:%s, Rsp:%s", bUploadSuccess, UploadRsp)
          Log.Info(Content)
          _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_CloseDialog)
          if bUploadSuccess then
            self:_DoShowDialogNotify("\229\156\186\230\153\175\232\181\132\230\186\144\231\188\186\233\153\183\230\136\170\229\155\190\228\184\138\230\138\165", "(4)\231\173\137\229\190\133\230\156\128\231\187\136\228\184\138\230\138\165...")
            self:_DoFinishReportBug(InternalUrl, function(bFinishReportSuccess, Rsp)
              _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_CloseDialog)
              self:_DoShowDialogNotify("\229\174\140\230\136\144\229\156\186\230\153\175\232\181\132\230\186\144\231\188\186\233\153\183\230\136\170\229\155\190\228\184\138\230\138\165", string.format("\230\136\170\229\155\190\239\188\154%s\n\231\187\147\230\158\156\239\188\154%s", SavePath, Rsp))
            end)
          else
            self:_DoShowDialogNotify("\229\156\186\230\153\175\232\181\132\230\186\144\231\188\186\233\153\183\230\136\170\229\155\190\228\184\138\230\138\165", "(3)\230\136\170\229\155\190\228\184\138\228\188\160\229\164\177\232\180\165...")
          end
        end)
      else
        self:_DoShowDialogNotify("\229\156\186\230\153\175\232\181\132\230\186\144\231\188\186\233\153\183\230\136\170\229\155\190\228\184\138\230\138\165", "\230\136\170\229\155\190\228\191\157\229\173\152\229\164\177\232\180\165...")
      end
    end, bShowUI)
  end)
end

function DebugTabTest:_DoReqUploadUrl(RspCallback)
  local FileName = tostring(os.time())
  self.HttpService:ResetHeaders()
  self.HttpService:ResetFields()
  self.GMPlatformKits.SetNRCAuthorization(self.HttpService)
  self.HttpService:SetUrl("https://mft.qq.com/mfat-api/v1/cos_file/nrc/upload_url")
  self.HttpService:SetVerb("GET")
  self.HttpService:SetField("file_uri", string.format("bug_screenshot/%s.png", FileName))
  self.HttpService:SetField("project_id", "NRC")
  self.HttpService:Request({
    self.HttpService,
    function(HttpService, Status)
      RspCallback(Status == UE4.EHttpServiceStatus.RspSuccess, HttpService:GetRspContent(), FileName)
    end
  })
end

function DebugTabTest:_DoReqScreenShot(FileName, Callback, bShowUI)
  self.ScreenShotService:RequestScreenshot({
    self.ScreenShotService,
    function(Service, Status)
      Callback(Status == UE4.EHttpServiceStatus.RspSuccess, Service:GetSavedFilePath(), Service)
    end
  }, FileName, bShowUI or false)
end

function DebugTabTest:_DoReqPutImage(Url, FilePath, Callback)
  self.HttpService:ResetHeaders()
  self.HttpService:ResetFields()
  self.HttpService:SetHeader("Content-Type", "image/png")
  self.HttpService:SetFile(FilePath)
  self.HttpService:SetUrl(Url)
  self.HttpService:SetVerb("PUT")
  self.HttpService:Request({
    self.HttpService,
    function(HttpService, Status)
      Callback(Status == UE4.EHttpServiceStatus.RspSuccess, HttpService:GetRspContent())
    end
  })
end

function DebugTabTest:_DoFinishReportBug(InternalPicUrl, Callback)
  self.HttpService:ResetHeaders()
  self.HttpService:ResetFields()
  self.HttpService:SetVerb("POST")
  self.HttpService:SetHeader("Content-Type", "application/json")
  self.GMPlatformKits.SetNRCAuthorization(self.HttpService)
  self.HttpService:SetUrl("https://mft.qq.com/mfat-api//v1/mfar/application/mfar_nrc/datatype/6662b232d1f04134a362f9a5/singledata")
  local InfoTable = self:_DoCollectReportInfoTable(InternalPicUrl)
  for k, v in pairs(InfoTable) do
    if type(v) ~= "string" then
      v = tostring(v)
    end
    self.HttpService:SetField(k, v)
  end
  self.HttpService:Request({
    self.HttpService,
    function(HttpService, Status)
      Callback(Status == UE4.EHttpServiceStatus.RspSuccess, HttpService:GetRspContent())
    end
  })
end

function DebugTabTest:_DoCollectReportInfoTable(InternalPicUrl)
  local InfoTable = {}
  InfoTable.screenshot_url = InternalPicUrl or ""
  InfoTable.device_mac_id = self:_GetDeviceId() or ""
  InfoTable.create_time = os.date("%Y-%m-%d %H:%M:%S", os.time())
  InfoTable.area = self:_GetCurAreaOrSceneName()
  InfoTable.platform = self:_GetPlatformReadableStr()
  InfoTable.build_version = _G.App:GetAppVersion() or ""
  InfoTable.position = self:_GetPlayerLocationAndCameraYawString()
  InfoTable.nearest_npc_info = self:_GetNearestNpcString()
  InfoTable.quality_level = self:_GetQualityLevel() or ""
  InfoTable.tod = self:_GetGameTODTime()
  InfoTable.weather = self:_GetGameWeather() or ""
  return InfoTable
end

function DebugTabTest:_GetDeviceId()
  if RocoEnv.PLATFORM_WINDOWS then
    return RocoEnv.MAC_ADDR
  else
    return UE4.UKismetSystemLibrary.GetDeviceId()
  end
end

function DebugTabTest:_GetCurAreaOrSceneName()
  local AreaCfg = _G.NRCModuleManager:DoCmd(AreaAndZoneModuleCmd.GetPlayerZoneInfo)
  if AreaCfg and AreaCfg.name then
    return AreaCfg.name
  end
  local SceneID = SceneUtils.GetSceneID()
  if not SceneID then
    return ""
  end
  local SceneConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SCENE_CONF):GetData(SceneID)
  if not SceneConf then
    return ""
  end
  return SceneConf.scene_name
end

function DebugTabTest:_GetPlatformReadableStr()
  if RocoEnv.PLATFORM == "PLATFORM_ANDROID" then
    return "Android"
  elseif RocoEnv.PLATFORM == "PLATFORM_OPENHARMONY" then
    return "OpenHarmony"
  elseif RocoEnv.PLATFORM == "PLATFORM_WINDOWS" and not RocoEnv.IS_EDITOR then
    return "PC"
  elseif RocoEnv.PLATFORM == "PLATFORM_WINDOWS" and RocoEnv.IS_EDITOR then
    return "Editor"
  else
    return "IOS"
  end
  return "Unknown"
end

function DebugTabTest:_GetPlayerLocationAndCameraYawString()
  local Player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not Player then
    return "Cannot found player"
  end
  if not Player.viewObj then
    return "Cannot found viewObj"
  end
  if not Player.viewObj:GetController() then
    return "Cannot found controller"
  end
  local CameraRotation = Player.viewObj:GetController():GetControlRotation()
  local PlayerLoc = Player.viewObj:Abs_K2_GetActorLocation()
  return string.format("%0.f,%0.f,%0.f,%0.f", PlayerLoc.X, PlayerLoc.Y, PlayerLoc.Z, CameraRotation.Yaw)
end

function DebugTabTest:_GetNearestNpcString()
  local npc = self:GetNearestNpc()
  if not npc then
    return "Cannot found NPC"
  end
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
  local LocationInfo = string.format("\229\189\147\229\137\141\228\186\186\231\137\169\228\189\141\231\189\174 %f,%f,%f", playerLocation.X, playerLocation.Y, playerLocation.Z)
  local ControllerInfo = string.format("\230\152\175\229\144\166\232\162\171\230\156\172\229\156\176\231\142\169\229\174\182\230\142\167\229\136\182?%s", npc:IsControlledByPlayer() and "\230\152\175" or "\229\144\166")
  local NPCOwnerInfo = string.format("NPC Creator: %u", npc:GetCreatorID())
  local WorldOwnerInfo = string.format("World Owner: %u", npc:GetWorldOwnerID())
  return string.format([[
%s,%d,%d
%u,%d
%s
%s
%s
%s]], npc.config.name, npc.config.id, npc.serverData.npc_base.npc_content_cfg_id or 0, npc.serverData.base.actor_id, npc.serverData.base.actor_id, LocationInfo, ControllerInfo, NPCOwnerInfo, WorldOwnerInfo)
end

function DebugTabTest:_GetQualityLevel()
  return UE4.UNRCQualityLibrary.GetImageQuality()
end

function DebugTabTest:_GetGameTODTime()
  local time = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime) or 0
  local hour = math.floor(time / 3600)
  local min = math.floor((time - hour * 3600) / 60)
  if min < 10 then
    min = "0" .. min
  end
  if hour < 10 then
    hour = "0" .. hour
  end
  local TODTimeStr = hour .. ":" .. min
  return TODTimeStr
end

function DebugTabTest:_GetGameWeather()
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  local WeatherSystemValue = EnvSys:GetWeatherStat()
  return WeatherSystemValue
end

function DebugTabTest:RepairUpdatedRes()
  local Ctx = DialogContext()
  Ctx:SetTitle("\230\143\144\231\164\186"):SetContent("\230\184\133\231\144\134\232\181\132\230\186\144\229\144\142\228\188\154\232\135\170\229\138\168\233\128\128\229\135\186\230\184\184\230\136\143\239\188\140\228\184\139\230\172\161\229\144\175\229\138\168\230\184\184\230\136\143\228\188\154\233\135\141\230\150\176\228\184\139\232\189\189\232\181\132\230\186\144\239\188\140\230\152\175\229\144\166\231\187\167\231\187\173\239\188\159"):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(self, function(obj, bProcess)
    if bProcess and AppMain then
      AppMain.RepairCleanup()
      UE4.UNRCStatics.QuitGame()
    end
  end):SetCloseOnCancel(true):SetButtonText("\231\161\174\232\174\164", "\232\191\148\229\155\158")
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabTest:DownloadFileFromCos(name, panel, RemotePath)
  if panel then
    RemotePath = panel.InputBox:GetText()
  end
  local Module = NRCModuleManager:GetModule("CosUploadModule")
  if Module then
    Module:DownloadFile(RemotePath)
  end
end

function DebugTabTest:TestRTCapture()
  ENABLE_RT_DEBUG = not ENABLE_RT_DEBUG
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\188\128\229\144\175RT\230\181\139\232\175\149:" .. ENABLE_RT_DEBUG)
end

function DebugTabTest:TestRTCaptureActor()
  ENABLE_RT_ACTOR_DEBUG = not ENABLE_RT_ACTOR_DEBUG
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\188\128\229\144\175RTActor\230\181\139\232\175\149:" .. ENABLE_RT_ACTOR_DEBUG)
end

function DebugTabTest:PrintDir()
  local Ctx = DialogContext()
  Ctx:SetTitle("\232\183\175\229\190\132"):SetContent("Root\232\183\175\229\190\132:" .. UE.UBlueprintPathsLibrary.RootDir() .. "\n" .. "ProjectDir\232\183\175\229\190\132:" .. UE.UBlueprintPathsLibrary.ProjectDir() .. "\n" .. "ProjectContentDir\232\183\175\229\190\132:" .. UE.UBlueprintPathsLibrary.ProjectContentDir() .. "\n" .. "EngineDir\232\183\175\229\190\132:" .. UE.UBlueprintPathsLibrary.EngineDir() .. "\n" .. "EngineUserDir\232\183\175\229\190\132:" .. UE.UBlueprintPathsLibrary.EngineUserDir() .. "\n" .. "GetPlatformUserDir\232\183\175\229\190\132:" .. UE.UKismetSystemLibrary.GetPlatformUserDir() .. "\n" .. "Absolute\232\183\175\229\190\132:" .. UE.UKismetSystemLibrary.ConvertToAbsolutePath("") .. "\n" .. "NRCAbsolute\232\183\175\229\190\132:" .. UE.UNRCStatics.ConvertToAbsolutePath("", false) .. "\n" .. "Saved\232\183\175\229\190\132:" .. UE4.UBlueprintPathsLibrary.ProjectSavedDir() .. "\n" .. "PersistentDownloadDir\232\183\175\229\190\132:" .. UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir() .. "\n" .. "FileBase\232\183\175\229\190\132:" .. UE.UNRCStatics.GetFilePathBase() .. "\n" .. "Internal\232\183\175\229\190\132:" .. UE.UNRCStatics.GetInternalStoragePath() .. "\n" .. "External\232\183\175\229\190\132:" .. UE.UNRCStatics.GetExternalStoragePath() .. "\n"):SetMode(DialogContext.Mode.NotBtn)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabTest:OpenEmmyLuaServer()
  UE.UNRCStatics.ExecConsoleCommand("emmy.opendbg")
  local Ctx = DialogContext()
  Ctx:SetTitle("Debugger"):SetContent(emmy_core and "Lua\232\176\131\232\175\149\229\153\168\229\144\175\229\138\168\230\136\144\229\138\159"):SetMode(DialogContext.Mode.NotBtn)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabTest:StartCaptureFilter()
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not Player.viewObj or not UE.UObject.IsValid(Player.viewObj) then
    return
  end
  if self.FilterCaptureActor then
    return
  end
  local Transform = Player:GetActorTransform()
  local ClassPath = "/Game/NewRoco/Modules/System/TakePhotos/BP_TestCapture.BP_TestCapture_C"
  local ClassObject = UE.UClass.Load(ClassPath)
  if ClassObject then
    self.FilterCaptureActor = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(ClassObject, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    self.FilterCaptureActor:SetActorEnableCollision(false)
  end
end

function DebugTabTest:StopCaptureFilter()
  if self.FilterCaptureActor and UE.UObject.IsValid(self.FilterCaptureActor) then
    self.FilterCaptureActor:K2_DestroyActor()
    self.FilterCaptureActor = nil
  end
end

function DebugTabTest:OpenPhotoRideEditor()
  local Module = NRCModuleManager:GetModule("TakePhotosModule")
  if Module then
    Module:OpenRideEditor()
  end
end

return DebugTabTest
