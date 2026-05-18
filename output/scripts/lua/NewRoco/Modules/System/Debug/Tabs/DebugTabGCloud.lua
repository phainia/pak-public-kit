local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local rapidjson = require("rapidjson")
local JsonUtils = require("Common.JsonUtils")
local UpdateAppTask = require("Core.Service.GCloud.Tasks.UpdateAppTask")
local UpdateResTask = require("Core.Service.GCloud.Tasks.UpdateResTask")
local MapleTask = require("Core.Service.GCloud.Tasks.MapleTask")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local NRCSDKManagerEnum = require("Core.Service.SDKManager.NRCSDKManagerEnum")
local Base = DebugTabBase
local DebugTabGCloud = Base:Extend("DebugTabGCloud")

function DebugTabGCloud:SetupTabs()
  self:Add("GRobot\229\188\128\229\144\175", self.ShowGRobot, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "ShowGRobot")
  self:Add("GRobot\229\133\179\233\151\173", self.CloseGRobot, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CloseGRobot")
  self:Add("ShowFileVersion", self.ShowFileVersion, self)
  self:Add("DownloadFile", self.DownloadFile, self)
end

function DebugTabGCloud:RestartApp(Name, Panel)
  UE.UNRCStatics.RestartApp()
end

function DebugTabGCloud:MakeSavedPath(Sub)
  local Path = UE.UBlueprintPathsLibrary.Combine({
    UE.UBlueprintPathsLibrary.ProjectSavedDir(),
    Sub
  })
  Path = UE.UBlueprintPathsLibrary.ConvertRelativePathToFull(Path)
  UE.UNRCStatics.MakeDirectory(Path)
  return Path
end

function DebugTabGCloud:AppUpdateTest(Name, Panel)
  local AppUpdate = UpdateAppTask()
  AppUpdate.NewVersionDelegate:Add(self, self.OnNewAppVersion)
  AppUpdate.ProgressDelegate:Add(self, self.OnProgress)
  AppUpdate.SuccessDelegate:Add(self, self.OnSuccess)
  AppUpdate:Init()
  AppUpdate:StartCheck()
end

function DebugTabGCloud:OnNewAppVersion(UpdateTask, NewVersion)
  Log.Error("\230\150\176\231\137\136\230\156\172\230\157\165\228\186\134\239\188\140\229\188\128\229\167\139\232\135\170\229\138\168\228\184\139\232\189\189", NewVersion.versionNumberOne, NewVersion.versionNumberTwo, NewVersion.versionNumberThree, NewVersion.versionNumberFour, NewVersion.needDownloadSize)
  UpdateTask:ContinueUpdate(true)
end

function DebugTabGCloud:ResUpdateTest(Name, Panel)
  local UpdateTask = UpdateResTask()
  UpdateTask.NewVersionDelegate:Add(self, self.OnNewResVersion)
  UpdateTask.ProgressDelegate:Add(self, self.OnProgress)
  UpdateTask.SuccessDelegate:Add(self, self.OnSuccess)
  UpdateTask:Init()
  UpdateTask:StartCheck()
end

function DebugTabGCloud:OnNewResVersion(UpdateTask, NewVersion)
  UpdateTask:ContinueUpdate(true)
end

function DebugTabGCloud:OnProgress(UpdateTask, Stage, Total, Now)
  local Percent = 0
  if 0 ~= Total then
    Percent = Now / Total
  end
  Log.Error("Stage...", Stage, Percent, UpdateTask:GetAverageSpeed(), UpdateTask:GetCurrentSpeed())
end

function DebugTabGCloud:OnSuccess(Task)
  Task:Uninit()
end

function DebugTabGCloud:StartMaple(Name, Panel)
  self.Observer = MapleTask()
  self.Observer:Start("1234", self, self.MapleCallback)
end

function DebugTabGCloud:MapleCallback(Success, Content)
  if Success then
    Log.Dump(Content, 4, "Maple Dirs")
  end
end

function DebugTabGCloud:StopMaple(Name, Panel)
  if self.Observer then
    self.Observer:Stop()
    self.Observer = nil
  end
end

function DebugTabGCloud:ShowGRobot()
  _G.NRCSDKManager:ShowGRobotH5(NRCSDKManagerEnum.GRobot.SOURCE_GAMES, NRCSDKManagerEnum.ScreenType.Default)
end

function DebugTabGCloud:CloseGRobot()
  _G.NRCSDKManager:CloseGRobot()
end

function DebugTabGCloud:TestLogin(Name, Panel)
  local Observer = NewObject(UE.ULoginObserver, _G.UE4Helper.GetCurrentWorld(), "LoginObserver", "Core.Service.GCloud.LoginObserver")
  UE.ULoginStatics.SetLoginObserver(Observer)
  UE.ULoginStatics.Login("QQ", "", "")
end

function DebugTabGCloud:PrintPaths(Name, Panel)
  local PathTable = {}
  PathTable.ProjectFile = UE.UBlueprintPathsLibrary.GetProjectFilePath()
  PathTable.ProjectDir = UE.UBlueprintPathsLibrary.ProjectDir()
  PathTable.ProjectContent = UE.UBlueprintPathsLibrary.ProjectContentDir()
  PathTable.ProjectConfig = UE.UBlueprintPathsLibrary.ProjectConfigDir()
  PathTable.ProjectSaved = UE.UBlueprintPathsLibrary.ProjectSavedDir()
  PathTable.EngineDir = UE.UBlueprintPathsLibrary.EngineDir()
  PathTable.EngineContent = UE.UBlueprintPathsLibrary.EngineContentDir()
  PathTable.EngineConfig = UE.UBlueprintPathsLibrary.EngineConfigDir()
  PathTable.EngineSaved = UE.UBlueprintPathsLibrary.EngineSavedDir()
  PathTable.APKFile = UE.UNRCStatics.GetApkPath()
  PathTable.DeviceID = UE.UKismetSystemLibrary.GetDeviceId()
  PathTable.Read = UE.UNRCStatics.ConvertToAbsolutePath("", true)
  PathTable.Write = UE.UNRCStatics.ConvertToAbsolutePath("", false)
  PathTable.ProjectPersistentDownloadDir = UE.UBlueprintPathsLibrary.ProjectPersistentDownloadDir()
  PathTable.InternalFilePath = UE.UNRCStatics.GetInternalStoragePath()
  PathTable.ExternalFilePath = UE.UNRCStatics.GetExternalStoragePath()
  PathTable.FileBasePath = UE.UNRCStatics.GetFilePathBase()
  if RocoEnv.PLATFORM_IOS then
    PathTable.PSO = UE.UNRCStatics.ConvertToAbsolutePath("", false) .. "/Caches/com.tencent.nrc/com.apple.metal"
    local ListOfAssets = UE.TArray("")
    UE.UNRCStatics.ListFolder(PathTable.PSO, ListOfAssets, true)
    PathTable.PSOFolders = ListOfAssets:ToTable()
  end
  self:Inspect(PathTable, "PathTable")
end

function DebugTabGCloud:CopyAppFile(Name, Panel)
  local FileName = self:GetInputString()
  local DestPath = UE.UBlueprintPathsLibrary.Combine({
    UE.UBlueprintPathsLibrary.ProjectSavedDir(),
    FileName
  })
  if RocoEnv.PLATFORM == "PLATFORM_ANDROID" then
    Log.Error("Android Branch")
    local SrcPath = FileName
    Log.Error("From Path", SrcPath)
    Log.Error("To Path", DestPath)
    local Result = UE.UNRCStatics.CopyFile(SrcPath, DestPath)
    if Result then
      Log.Error("Copy Success")
    else
      Log.Error("Copy Failed")
    end
  elseif RocoEnv.PLATFORM == "PLATFORM_IOS" then
    Log.Error("IOS Branch")
    local AbsPath = UE.UNRCStatics.ConvertToAbsolutePath("", true)
    local prefix = "cookeddata/"
    if string.sub(AbsPath, -string.len(prefix)) == prefix then
      AbsPath = string.sub(AbsPath, 1, -string.len(prefix) - 1)
    end
    AbsPath = AbsPath:sub(string.len("/private") + 1)
    local SrcPath = AbsPath .. FileName
    Log.Error("Show Path", SrcPath)
    local Result = UE.UNRCStatics.CopyFile(SrcPath, DestPath)
    if Result then
      Log.Error("Copy Success")
    else
      Log.Error("Copy Failed")
    end
  elseif RocoEnv.PLATFORM == "PLATFORM_OPENHARMONY" then
    Log.Error("OpenHarmony Branch")
    local SrcPath = FileName
    Log.Error("From Path", SrcPath)
    Log.Error("To Path", DestPath)
    local Result = UE.UNRCStatics.CopyFile(SrcPath, DestPath)
    if Result then
      Log.Error("Copy Success")
    else
      Log.Error("Copy Failed")
    end
  end
end

function DebugTabGCloud:MountPaks(Name, Panel)
  self:Inspect(_G.AppMain.MountPaks(), "Paks")
end

function DebugTabGCloud:OpenLibraries(Name, Panel)
  self:Inspect(_G.AppMain.OpenLibraries(), "Libraries")
end

function DebugTabGCloud:ReloadLevel(Name, Panel)
  _G.NRCModeManager:GetCurMode():CloseAllPanel()
  UE.UNRCStatics.RestartGame()
end

function DebugTabGCloud:DumpLevelObject(Name, Panel)
  UE.UNRCStatics.DumpLevelObject()
end

function DebugTabGCloud:PrintProjectVersion(Name, Panel)
  local File = string.format("%sNewRoco/DataConfig/appinfo.json", UE4.UBlueprintPathsLibrary.ProjectContentDir())
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local Result, Success = UE4.UNRCStatics.LoadToString(File)
  if not Success then
    Result = {}
  end
  local AppInfo = rapidjson.decode(Result)
  AppInfo.Project = UE.UNRCStatics.GetProjectVersion()
  self:Inspect(AppInfo, "Version")
end

function DebugTabGCloud:ListPakFiles(Name, Panel)
  local PathSegs
  if RocoEnv.PLATFORM_ANDROID or RocoEnv.PLATFORM_OPENHARMONY then
    if RocoEnv.IS_SHIPPING then
      PathSegs = {
        UE.UNRCStatics.GetExternalStoragePath(),
        "UE4Game",
        "NRC",
        "NRC",
        "Saved",
        "Paks"
      }
    else
      PathSegs = {
        UE.UNRCStatics.GetFilePathBase(),
        "UE4Game",
        "NRC",
        "NRC",
        "Saved",
        "Paks"
      }
    end
  else
    PathSegs = {
      UE.UBlueprintPathsLibrary.ProjectSavedDir(),
      "Paks"
    }
  end
  local PakFolder = UE.UBlueprintPathsLibrary.Combine(PathSegs)
  if RocoEnv.PLATFORM_IOS then
    PakFolder = UE.UNRCStatics.ConvertToAbsolutePath(PakFolder, false)
  end
  local PakFiles = UE.UNRCStatics.ListFiles(PakFolder, "*.pak")
  local Table = PakFiles:ToTable()
  Table.PakFolder = PakFolder
  self:Inspect(PakFiles:ToTable(), "Paks")
end

function DebugTabGCloud:ListMountedPaks(Name, Panel)
  local Array = UE.UNRCStatics.GetMountedPakFileNames()
  local Table = Array:ToTable()
  self:Inspect(Table, "Paks")
end

function DebugTabGCloud:ReloadPipelineCache(Name, Panel)
  local Result = UE.UNRCStatics.ReloadShaderPipelineCache()
  Log.Error("Reload Pipeline Cache", Result and "Success" or "Failed")
end

function DebugTabGCloud:ShowWritePSOFlag(Name, Panel)
  local Flag = UE.UNRCStatics.ReadSavePSOLogFlag()
  Log.Error("SaveBoundPSOLog", Flag)
end

function DebugTabGCloud:EnablePSOWrite(Name, Panel)
  _G.AppMain.ReapplyWritePSO()
end

function DebugTabGCloud:DisablePSOWrite(Name, Panel)
  _G.AppMain.DisableWritePSO()
end

function DebugTabGCloud:OverrideDolphinVersion(Name, Panel)
  JsonUtils.DumpSaved("DolphinVersion", {
    ResVersion = self:GetInputString()
  })
end

function DebugTabGCloud:CheckFullPackage(Name, Panel)
  local Payload = {
    IsFull = _G.AppMain.IsFullPackage(),
    Platform = RocoEnv.PLATFORM,
    Editor = RocoEnv.IS_EDITOR
  }
  self:Inspect(Payload)
end

function DebugTabGCloud:TryDecode(Name, Panel)
  local Encrypted = self:GetInputString()
  local Map = UE.UNRCStatics.DecodeLaunchParams(Encrypted, "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn")
  self:Inspect(Map:ToTable())
end

function DebugTabGCloud:GetNetworkState(Name, Panel)
  UE.UTDMStatics.EnableDeviceInfo(true)
  Log.Error("this is network state", UE.UNetworkStatics.GetNetworkState())
  local Detail = UE.UNetworkStatics.GetNetworkDetail()
  local Payload = {
    state = Detail:state(),
    carrier = Detail:carrier(),
    carrierCode = tostring(Detail.carrierCode),
    ssid = tostring(Detail.ssid),
    bssid = tostring(Detail.bssid),
    currentAPN = tostring(Detail.currentAPN)
  }
  self:Inspect(Payload, "NetworkDetail")
  Log.Error("this is detail", Detail:state(), Detail:carrier(), tostring(Detail.carrierCode), tostring(Detail.ssid), tostring(Detail.bssid), tostring(Detail.currentAPN))
end

local FakeObserver

function DebugTabGCloud:RegisterNetworkCallback(Name, Panel)
  if FakeObserver then
    UE.UNetworkStatics.RemoveObserver(FakeObserver)
    Log.Error("\231\167\187\233\153\164\229\155\158\232\176\131\230\136\144\229\138\159", FakeObserver)
    FakeObserver = nil
  else
    FakeObserver = NewObject(UE.UNetworkStatusObserver, _G.UE4Helper.GetCurrentWorld(), "NetworkStatusObserver", "Core.Service.GCloud.NetworkStatusObserver")
    UE.UNetworkStatics.AddObserver(FakeObserver)
    Log.Error("\230\183\187\229\138\160\229\155\158\232\176\131\230\136\144\229\138\159", FakeObserver)
  end
end

function DebugTabGCloud:ShowDeviceInfo(Name, Panel)
  UE.UTDMStatics.EnableDeviceInfo(true)
  local Payload = UE.UTDMStatics.PullDeviceInfo()
  self:Inspect(Payload, "Show Device Info")
end

function DebugTabGCloud:ShowFileVersion(Name, Panel)
  local Version = UE.UNRCStatics.GetSupportedFileVersion()
  Log.Error("\229\189\147\229\137\141\230\148\175\230\140\129\231\154\132\230\156\128\233\171\152\231\137\136\230\156\172\228\184\186", Version)
end

function DebugTabGCloud:DownloadFile(Name, Panel, InputContent)
  if Panel then
    InputContent = Panel:GetInputString()
  end
  local PartialUrl = InputContent
  local FullUrl = PartialUrl
  if string.StartsWith(PartialUrl, "https://") then
    FullUrl = PartialUrl
  else
    FullUrl = string.format("https://nrc-server-log-1258344700.cos.ap-nanjing.myqcloud.com%s", PartialUrl)
  end
  local FileName = FullUrl:match(".*/([^/?]+)")
  local SaveFilePath = string.format("%s%s", UE.UBlueprintPathsLibrary.ProjectSavedDir(), FileName)
  Log.Debug("[DebugTabGCloud] Start Download File", PartialUrl, FileName, SaveFilePath)
  local HttpService = UE4.UMoreFunPlatformKits.CreateSimpleHttpService()
  local HttpServiceRef = UnLua.Ref(HttpService)
  self.ServiceRef = HttpServiceRef
  HttpService:ResetHeaders()
  HttpService:ResetFields()
  HttpService:SetUrl(FullUrl)
  HttpService:SetVerb("GET")
  HttpService:Request({
    HttpService,
    function(Service, Status)
      if Status == UE4.EHttpServiceStatus.RspSuccess then
        Service:SaveToFile(SaveFilePath)
        Log.Debug("[DebugTabGCloud] DownloadFile Success", SaveFilePath)
      else
        Log.Debug("[DebugTabGCloud] DownloadFile Failed", SaveFilePath)
      end
      self.ServiceRef = nil
    end
  })
end

return DebugTabGCloud
