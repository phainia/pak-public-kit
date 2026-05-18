local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabDownload = Base:Extend("DebugTabDownload")

function DebugTabDownload:Ctor()
  Base.Ctor(self)
end

function DebugTabDownload:SetupTabs()
  self:Add("\230\152\190\231\164\186\232\190\185\231\142\169\232\190\185\228\184\139\232\191\155\229\186\166", self.ShowAutoDownloadProgress, self, nil, "", "", nil, "", "")
  self:Add("\233\154\144\232\151\143\232\190\185\231\142\169\232\190\185\228\184\139\232\191\155\229\186\166", self.HideAutoDownloadProgress, self, nil, "", "", nil, "", "")
  self:Add("\231\166\129\231\148\168\232\190\185\228\184\139\232\190\185\231\142\169", self.DisableAutoDownload, self, nil, "", "", nil, "", "")
  self:Add("\229\188\128\229\167\139\228\184\139\232\189\189", self.StartAutoDownload, self, nil, "", "", nil, "", "")
  self:Add("\230\154\130\229\129\156\228\184\139\232\189\189", self.PauseAutoDownload, self, nil, "", "", nil, "", "")
  self:Add("\231\187\167\231\187\173\228\184\139\232\189\189", self.ResumeAutoDownload, self, nil, "", "", nil, "", "")
  self:Add("\232\174\190\231\189\174\230\156\128\229\164\167\233\128\159\229\186\166(MB/S)", self.SetDLMaxSpeed, self, nil, "", "", nil, "", "")
  self:Add("\232\174\190\231\189\174\230\156\128\229\164\167\229\185\182\229\143\145\228\187\187\229\138\161\230\149\176\233\135\143", self.SetDLMaxTask, self, nil, "", "", nil, "", "")
  self:Add("\232\174\190\231\189\174\228\187\187\229\138\161\230\156\128\229\164\167\233\147\190\230\142\165\230\149\176\233\135\143", self.SetImmDLMaxDownloadsPerTask, self, nil, "", "", nil, "", "")
  self:Add("\229\136\160\233\153\164\230\137\128\230\156\137Base\229\140\133", self.DeleteAllBasePaks, self, nil, "", "", nil, "", "")
  self:Add("\229\136\160\233\153\164\230\137\128\230\156\137\229\186\143\231\171\160\229\140\133", self.DeleteAllEarlyContentPaks, self, nil, "", "", nil, "", "")
  self:Add("\229\136\160\233\153\164\230\137\128\230\156\137Patch", self.DeleteAllPatch, self, nil, "", "", nil, "", "")
  self:Add("\229\136\160\233\153\164\230\140\135\229\174\154Pak", self.DeleteSelectedPak, self, nil, "", "", nil, "", "")
  self:Add("\230\154\130\229\129\156PSO\233\162\132\231\131\173", self.PausePSOWarmUp, self, nil, "", "", nil, "", "")
  self:Add("\231\187\167\231\187\173PSO\233\162\132\231\131\173", self.ResumePSOWarmUp, self, nil, "", "", nil, "", "")
  self:Add("\229\136\160\233\153\164PSO\231\188\147\229\173\152", self.DeletePSOCache, self, nil, "", "", nil, "", "")
  self:Add("\229\188\185\229\135\186\229\186\143\231\171\160\231\187\147\230\157\159\230\139\166\230\136\170\229\188\185\231\170\151", self.PopupDownloadPkgWindow, self, nil, "", "", nil, "", "")
end

function DebugTabDownload:ShowAutoDownloadProgress(name, panel)
  _G.NRCAutoDownloadManager:SetIfPrintToScreen(true)
end

function DebugTabDownload:HideAutoDownloadProgress(name, panel)
  _G.NRCAutoDownloadManager:SetIfPrintToScreen(false)
end

function DebugTabDownload:DisableAutoDownload(name, panel)
  _G.NRCAutoDownloadManager:RemoveAllDownloadTasks()
  _G.NRCAutoDownloadManager:EnableAutoDownload(false)
end

function DebugTabDownload:PauseAutoDownload(name, panel)
  _G.NRCAutoDownloadManager:PauseAllDownloadTasks()
  _G.NRCAutoDownloadManager:SetEnableNetworkListener(false)
end

function DebugTabDownload:ResumeAutoDownload(name, panel)
  _G.NRCAutoDownloadManager:SetEnableNetworkListener(true)
  _G.NRCAutoDownloadManager:ResumeAllDownloadTasks()
end

function DebugTabDownload:StartAutoDownload(name, panel)
  _G.NRCAutoDownloadManager:EnableAutoDownload(true)
  _G.NRCAutoDownloadManager:SetSpeedLimitMode()
  _G.NRCAutoDownloadManager:StartDownloadBasePaks()
end

function DebugTabDownload:SetDLMaxSpeed(name, panel)
  if panel then
    local InputNum = panel:GetInputNumber()
    Log.Debug("[DebugTabDownload:SetDLMaxSpeed] InputString: ", InputString)
    if nil == InputNum or InputNum <= 0 then
      Log.Error("[\232\174\190\231\189\174\230\156\128\229\164\167\233\128\159\229\186\166] \232\190\147\229\133\165\231\154\132\233\128\159\229\186\166\228\184\141\229\144\136\230\179\149")
    else
      InputNum = InputNum * 1024 * 1024
      _G.PufferUpdateResTask:SetDownloadMaxSpeed(InputNum)
    end
  else
    Log.Error("panel is nil")
  end
end

function DebugTabDownload:SetDLMaxTask(name, panel)
  if panel then
    local InputNum = panel:GetInputNumber()
    Log.Debug("[DebugTabDownload:SetDLMaxTask] InputString: ", InputString)
    if nil == InputNum or InputNum <= 0 then
      Log.Error("[\232\174\190\231\189\174\230\156\128\229\164\167\229\185\182\229\143\145\228\187\187\229\138\161\230\149\176] \232\190\147\229\133\165\231\154\132\230\149\176\229\173\151\228\184\141\229\144\136\230\179\149")
    else
      _G.PufferUpdateResTask:SetDLMaxTask(InputNum)
    end
  else
    Log.Error("panel is nil")
  end
end

function DebugTabDownload:SetImmDLMaxDownloadsPerTask(name, panel)
  if panel then
    local InputNum = panel:GetInputNumber()
    Log.Debug("[DebugTabDownload:SetDLMaxTask] InputString: ", InputString)
    if nil == InputNum or InputNum <= 0 then
      Log.Error("[\232\174\190\231\189\174\228\187\187\229\138\161\230\156\128\229\164\167\233\147\190\230\142\165\230\149\176\233\135\143] \232\190\147\229\133\165\231\154\132\230\149\176\229\173\151\228\184\141\229\144\136\230\179\149")
    else
      _G.PufferUpdateResTask:SetImmDLMaxDownloadsPerTask(InputNum)
    end
  else
    Log.Error("panel is nil")
  end
end

function DebugTabDownload:DeleteAllBasePaks(name, panel)
  local PakList = _G.PufferDownloadInfo:GetBasePakList()
  self:DeletePakList(PakList, "\229\136\160\233\153\164\230\137\128\230\156\137Base\229\140\133")
end

function DebugTabDownload:DeleteAllEarlyContentPaks(name, panel)
  local PakList = _G.PufferDownloadInfo:GetEarlyContentPakList()
  self:DeletePakList(PakList, "\229\136\160\233\153\164\230\137\128\230\156\137\229\186\143\231\171\160\229\140\133")
end

function DebugTabDownload:DeleteAllPatch(name, panel)
  local PakList = _G.PufferDownloadInfo:GetAllPatchList()
  self:DeletePakList(PakList, "\229\136\160\233\153\164\230\137\128\230\156\137Patch")
  local RestartAppVersionRecord = string.format("%s%s.json", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), "PatchRestartAppVersionRecord")
  UE.UNRCStatics.DeleteToFile(RestartAppVersionRecord)
  RestartAppVersionRecord = string.format("%s%s.json", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), "RestartAppVersionRecord")
  UE.UNRCStatics.DeleteToFile(RestartAppVersionRecord)
  local PSOPath = string.format("%s%s", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), "PipelineCaches")
  Log.Debug("[DebugTabDownload:DeleteAllPatch] PSOPath: ", PSOPath)
  UE.UNRCStatics.RemoveFolder(PSOPath)
end

function DebugTabDownload:DeletePakList(PakList, LogTag)
  local FullPath
  if PakList then
    for _, Path in ipairs(PakList) do
      FullPath = _G.PufferUpdateResTask:GetRelativePathToPuffer(Path)
      if UE.UNRCStatics.FileExists(FullPath) then
        if not UE.UNRCStatics.DeleteToFile(FullPath) then
          Log.Error(string.format("[%s]\229\136\160\233\153\164\229\164\177\232\180\165\239\188\154%s", LogTag, Path))
        else
          Log.PrintScreenMsg("\229\136\160\233\153\164\230\136\144\229\138\159: " .. Path)
        end
      end
    end
  end
end

function DebugTabDownload:DeleteSelectedPak(name, panel)
  if panel then
    local InputString = panel:GetInputString()
    Log.Debug("[DebugTabDownload:DeleteSelectedPak] InputString: ", InputString)
    if string.IsNilOrEmpty(InputString) then
      Log.Error("[\229\136\160\233\153\164\230\140\135\229\174\154Pak] \232\190\147\229\133\165\231\154\132\230\150\135\230\156\172\228\184\186\231\169\186")
    else
      self:DeleteSelectedPakByString(InputString)
    end
  else
    Log.Error("panel is nil")
  end
end

function DebugTabDownload:DeleteSelectedPakByString(InStr)
  local PakList = _G.PufferDownloadInfo:GetAllPakFileList()
  local FullPath
  if PakList then
    for _, Path in tpairs(PakList) do
      if string.find(Path, InStr) then
        FullPath = _G.PufferUpdateResTask:GetRelativePathToPuffer(Path)
        if UE.UNRCStatics.FileExists(FullPath) then
          if not UE.UNRCStatics.DeleteToFile(FullPath) then
            Log.Error("\229\136\160\233\153\164\229\164\177\232\180\165\239\188\154", Path)
          else
            Log.PrintScreenMsg("\229\136\160\233\153\164\230\136\144\229\138\159: " .. Path)
          end
        end
      end
    end
  end
end

function DebugTabDownload:PausePSOWarmUp(name, panel)
  UE.UNRCStatics.PausePSOWarmUp()
end

function DebugTabDownload:ResumePSOWarmUp(name, panel)
  UE.UNRCStatics.ResumePSOWarmUp()
end

function DebugTabDownload:DeletePSOCache(name, panel)
  UE.UNRCStatics.ExecConsoleCommand("PSO.DeleteCache")
end

function DebugTabDownload:PopupDownloadPkgWindow(name, panel)
  Log.Debug("[DebugTabDownload:PopupDownloadPkgWindow]Need To Download Base Paks")
  local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
  local UpdateUIModuleEvent = require("NewRoco.Modules.System.UpdateUIModule.UpdateUIModuleEvent")
  local NeedToDownloadBasePakList, SizeNeedToDownload, LargestSize = _G.PufferUpdateResTask:GetBasePakListNeedToDownload()
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  local GB = string.format("%.2f", SizeNeedToDownload / 1024 / 1024 / 1024)
  local Content
  if _G.NRCBackgroundDownloadMgr:IsEnableBackgroundDownload() then
    local AppendText = string.format("(%s)", LuaText.Download_All_tips3)
    Content = string.format(LuaText.Download_All_tips1, AppendText, GB)
  else
    Content = string.format(LuaText.Download_All_tips1, "", GB)
  end
  Context:SetTitle(LuaText.updateuimodule_26):SetContent(Content):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(self, function(this, result)
    if result then
      _G.NRCEventCenter:DispatchEvent(UpdateUIModuleEvent.ReportDownloadBtnClick, LoginEnum.DownloadReportType.BaseDownloadBtn)
      _G.AppMain:SetIfDownloadBasePaksWithoutLogin(true)
    else
      _G.NRCEventCenter:DispatchEvent(UpdateUIModuleEvent.ReportDownloadBtnClick, LoginEnum.DownloadReportType.RefuseBaseDownloadBtn)
    end
    _G.ZoneServer:DisConnect(true, false)
    _G.AppMain.BackToLogin(true)
  end):SetButtonText(LuaText.Download_All_button2, LuaText.Download_All_button1)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

return DebugTabDownload
