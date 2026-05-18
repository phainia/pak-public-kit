local NRCUpdateMode = NRCModeBase:Extend("NRCUpdateMode")

function NRCUpdateMode:OnConstruct()
  BattleNetManager:ShutDown()
  Log.Debug("NRCUpdateMode OnConstruct")
  local bMemoryTest = false
  if _G.GlobalConfig.MemoryAutoTest then
    bMemoryTest = _G.GlobalConfig.DisableGameplayMode or _G.GlobalConfig.EngineTestMode
    local PufferPaksFolder = UE.UBlueprintPathsLibrary.Combine({
      UE.UBlueprintPathsLibrary.ProjectSavedDir(),
      "Puffer/Paks",
      ""
    })
    Log.Debug("[UpdateUIModule:MountDownloadedPaks] Folder: ", PufferPaksFolder)
    local PufferPakNames = UE4.UNRCStatics.GetFileNamesInDirectory(PufferPaksFolder, "pakchunk"):ToTable()
    local FullPath
    for _, Path in ipairs(PufferPakNames) do
      FullPath = UE.UBlueprintPathsLibrary.Combine({
        UE.UBlueprintPathsLibrary.ProjectSavedDir(),
        "Puffer/Paks",
        Path
      })
      Log.Debug("[UpdateUIModule:MountDownloadedPaks] Asset: ", FullPath)
      if not UE4.UHotUpdateUtils.IsPakMounted(FullPath) then
        local bSuccess = UE4.UHotUpdateUtils.MountPak(FullPath, PufferPakMountOrder)
        Log.Debug(string.format("[UpdateUIModule:MountDownloadedPaks] mount local downloaded pak:%s bSuccess:%s", FullPath, tostring(bSuccess)))
      end
    end
  end
  if not bMemoryTest then
    self:RegisterModule("MultiTouchModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.MultiTouch.MultiTouchModuleHead", "NewRoco.Modules.Core.MultiTouch.MultiTouchModule")
    self:RegisterModule("UpdateUIModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.System.UpdateUIModule.UpdateUIModuleHead", "NewRoco.Modules.System.UpdateUIModule.UpdateUIModule")
    self:RegisterModule("ScreenClickModule", "Type_System", "NewRoco.Modules.System.ScreenClick.ScreenClickModuleHead", "NewRoco.Modules.System.ScreenClick.ScreenClickModule")
    self:RegisterModule("OnlineModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.Online.OnlineModuleHead", "NewRoco.Modules.Core.Online.OnlineModule")
    self:RegisterModule("LoginModule", "Type_System", "NewRoco.Modules.System.LoginModule.LoginModuleHead", "NewRoco.Modules.System.LoginModule.LoginModule")
    self:RegisterModule("TipsModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.System.TipsModule.TipsModuleHead", "NewRoco.Modules.System.TipsModule.TipsModule")
    self:RegisterModule("LoginCacheNotifyModule", "Type_System", nil, "NewRoco.Modules.System.LoginCacheNotify.LoginCacheNotifyModule")
    if _G.AppMain:HasDebug() then
      self:RegisterModule("DebugModule", NRCModuleTypeDef.Donnt_Destroy, nil, "NewRoco.Modules.System.Debug.DebugModule")
    end
    self:RegisterModule("CosUploadModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.CosUpload.CosUploadModuleHead", "NewRoco.Modules.Core.CosUpload.CosUploadModule")
    self:RegisterModule("EnhancedInputModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleHead", "NewRoco.Modules.Core.EnhancedInput.EnhancedInputModule")
    self:RegisterModule("FunctionBanModule", NRCModuleTypeDef.Donnt_Destroy, nil, "NewRoco.Modules.System.FunctionBan.FunctionBanModule")
  end
end

function NRCUpdateMode:OnDestruct()
end

function NRCUpdateMode:CheckPCACEEnv()
  if RocoEnv.PLATFORM_WINDOWS and not _G.NRCSDKManager.bInitACESuccess then
    local Context = DialogContext()
    Context:SetTitle(_G.LuaText.TIPS):SetContent(LuaText.ace_init_fail_tips):SetMode(DialogContext.Mode.OK):SetButtonText(LuaText.OK):SetCallbackOkOnly(self, function()
      Context:Close()
      UE4.UNRCStatics.QuitGame()
    end)
    NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  end
end

function NRCUpdateMode:OnActive()
  local bMemoryTest = false
  if _G.GlobalConfig.MemoryAutoTest then
    bMemoryTest = _G.GlobalConfig.DisableGameplayMode or _G.GlobalConfig.EngineTestMode
  end
  if not bMemoryTest then
    _G.GEMPostManager:GEMPostStepEvent("AgreementsAccepted")
    self:ActiveModule("MultiTouchModule")
    self:ActiveModule("ScreenClickModule")
    self:ActiveModule("TipsModule")
    self:ActiveModule("LoginCacheNotifyModule")
    self:ActiveModule("LoginModule")
    self:ActiveModule("UpdateUIModule")
    self:GetModule("UpdateUIModule"):StartUpdateFsm()
    NRCModuleManager:DoCmd(UpdateUIModuleCmd.ShowUid, false)
    self:ActiveModule("DebugModule")
    self:ActiveModule("CosUploadModule")
    self:ActiveModule("EnhancedInputModule")
    self:ActiveModule("FunctionBanModule")
    self:CheckPCACEEnv()
  end
  if _G.GlobalConfig.DisableGameplayMode then
    _G.NRCModeManager:ActiveMode("LocalMode")
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "n.CustomGameModePath /Game/Game/NRC/GameMode/AutoTest/DefaultGM.DefaultGM_C")
    local loadLevelPath = UE4.UNRCStatics.GetLoadLevelPath()
    if "None" == loadLevelPath then
      _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release")
    else
      _G.LevelHelper:OpenLevel(loadLevelPath)
    end
  end
  if _G.GlobalConfig.EngineTestMode then
    _G.NRCModeManager:ActiveMode("LocalMode")
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "n.CustomGameModePath /Game/Game/NRC/GameMode/AutoTest/DefaultGM.DefaultGM_C")
    _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/NothingWorldDGM")
  end
end

function NRCUpdateMode:OnAllGroupFinished()
end

function NRCUpdateMode:OnDeactive()
  local bMemoryTest = false
  if _G.GlobalConfig.MemoryAutoTest then
    bMemoryTest = _G.GlobalConfig.DisableGameplayMode or _G.GlobalConfig.EngineTestMode
  end
  if not bMemoryTest then
    BattleNetManager:Init()
    BattleNetManager:GetNotifyCache()
    DataModelMgr.LoginNotifyModel:ClearCache()
  end
  collectgarbage("collect")
  UE4.UNRCStatics.ForceGarbageCollection(true)
end

return NRCUpdateMode
