local NRCGlobalEvent = require("Common.NRCGlobalEvent")
local CinematicDataUtils = require("NewRoco.Modules.Core.Cinematic.CinematicDataUtils")
local CinematicModuleEvent = reload("NewRoco.Modules.Core.Cinematic.CinematicModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local DialogueStatusChecker = require("NewRoco.Modules.Core.Task.StatusCheckers.DialogueStatusChecker")
local CinematicFsm = require("NewRoco.Modules.Core.Cinematic.Fsm.CinematicFsm")
local TimeoutEventListener = require("Common.TimeoutEventListener")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ShowPlayPos = false
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local CinematicModule = NRCModuleBase:Extend("CinematicModule")

function CinematicModule:OnConstruct()
  self.data = self:SetData("CinematicModuleData", "NewRoco.Modules.Core.Cinematic.CinematicModuleData")
  self.Skip = false
  self.Playing = false
  self.BlackScreenOn = false
  self.ManagedNPCs = {}
  setmetatable(self.ManagedNPCs, {__mode = "kv"})
  self.CloseBlackScreenListener = TimeoutEventListener()
  local CinematicBlackScreen = _G.NRCPanelRegisterData()
  CinematicBlackScreen.panelName = "CinematicModuleBlackScreenPanel"
  CinematicBlackScreen.panelPath = "/Game/NewRoco/Modules/System/Cinematic/Res/UMG_CinematicBlackScreen"
  CinematicBlackScreen.panelLayer = Enum.UILayerType.UI_LAYER_TOP_LOADING
  CinematicBlackScreen.enablePcEsc = false
  self:RegisterPanel(CinematicBlackScreen)
  local CinematicBar = _G.NRCPanelRegisterData()
  CinematicBar.panelName = "CinematicBar"
  CinematicBar.panelPath = "/Game/NewRoco/Modules/System/Cinematic/Res/UMG_CinematicBar"
  CinematicBar.panelLayer = Enum.UILayerType.UI_LAYER_POPUP
  CinematicBar.enablePcEsc = false
  self:RegisterPanel(CinematicBar)
  self.CinematicPlayerClassPath = "/Game/NewRoco/Modules/Core/Cinematic/BP_CinematicPlayer"
  self.DialogueChecker = DialogueStatusChecker()
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, NPCModuleEvent.On_NPC_Create, self.OnNPCCreate)
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, CinematicModuleEvent.OnMovieSequenceSubtitleStart, self.SetSubtitle)
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, CinematicModuleEvent.OnMovieSequenceSubtitleEnd, self.ClearSubtitle)
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, CinematicModuleEvent.OpenCinematicBar, self.OpenCinematicBar)
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, CinematicModuleEvent.CloseCinematicBar, self.CloseCinematicBar)
  self.LastEndTime = -1
  self:OpenPanel("CinematicModuleBlackScreenPanel")
  self.HiddenPrimitiveScaleOrigin = 0.4
  self.ForceLoadStreamedLODIdxOrigin = 10
  local GetCVarSuccess = false
  self.HiddenPrimitiveScaleOrigin, GetCVarSuccess = UE4.UNRCStatics.GetAutoConsoleVarFloat("r.SkeletalMesh.Streaming.HiddenPrimitiveScale")
  Log.DebugFormat("Store Origin [r.SkeletalMesh.Streaming.HiddenPrimitiveScale] for Cinematic: %f. Success:%q", self.HiddenPrimitiveScaleOrigin, GetCVarSuccess)
  self.ForceLoadStreamedLODIdxOrigin, GetCVarSuccess = UE4.UNRCStatics.GetAutoConsoleVarInt("n.SkeletalMesh.ForceLoadStreamedLODIdx")
  Log.DebugFormat("Store Origin [n.SkeletalMesh.ForceLoadStreamedLODIdx] for Cinematic: %f. Success:%q", self.ForceLoadStreamedLODIdxOrigin, GetCVarSuccess)
end

function CinematicModule:OpenBlack(Caller, Callback)
  local HasBlack = self:HasPanel("CinematicModuleBlackScreenPanel")
  if not HasBlack then
    self:OpenPanel("CinematicModuleBlackScreenPanel", Caller, Callback)
    return
  end
  local Black = self:GetPanel("CinematicModuleBlackScreenPanel")
  if not Black then
    return
  end
  self:EnablePanel("CinematicModuleBlackScreenPanel")
  Black:RefreshView(Caller, Callback)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.PauseTip, TipEnum.TipsPauseReason.Video)
end

function CinematicModule:CloseBlack()
  local HasBlack = self:HasPanel("CinematicModuleBlackScreenPanel")
  if not HasBlack then
    return
  end
  local Black = self:GetPanel("CinematicModuleBlackScreenPanel")
  if Black and Black.enableView then
    self:DisablePanel("CinematicModuleBlackScreenPanel")
  end
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.ResumeTip, TipEnum.TipsPauseReason.Video)
end

function CinematicModule:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.On_NPC_Create, self.OnNPCCreate)
  _G.NRCEventCenter:UnRegisterEvent(self, CinematicModuleEvent.OnMovieSequenceSubtitleStart, self.SetSubtitle)
  _G.NRCEventCenter:UnRegisterEvent(self, CinematicModuleEvent.OnMovieSequenceSubtitleEnd, self.ClearSubtitle)
  _G.NRCEventCenter:UnRegisterEvent(self, CinematicModuleEvent.OpenCinematicBar, self.OpenCinematicBar)
  _G.NRCEventCenter:UnRegisterEvent(self, CinematicModuleEvent.CloseCinematicBar, self.CloseCinematicBar)
  if self.CinematicPlayer then
    self.CinematicPlayer:K2_DestroyActor()
    self.CinematicPlayer = nil
  end
  self.Klass = nil
  self.CinemaFsm = nil
end

function CinematicModule:OnLogin(isRelogin)
  table.clear(self.ManagedNPCs)
end

function CinematicModule:OnActive()
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_DISCONNECT, self.TryCleanUp)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.TryCleanUp)
end

function CinematicModule:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.TryCleanUp)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.TryCleanUp)
end

function CinematicModule:TryCleanUp()
  self:Log("CinematicModule:TryCleanUp")
  if not self.CinematicPlayer then
    return
  end
  if not self.CinematicPlayer.isPlaying then
    return
  end
  self.CinematicPlayer:Interrupt()
  UE.UNRCStatics.ReleaseSequenceAudioSession()
end

function CinematicModule:OnNPCCreate(npc)
  if not self.Playing then
    return
  end
  if not self.SeqConf then
    return
  end
  if not self.SeqConf.npc_refresh then
    return
  end
  if 0 == #self.SeqConf.npc_refresh then
    return
  end
  for _, Refresh in ipairs(self.SeqConf.npc_refresh) do
    if Refresh.refresh_cfg_id == npc.serverData.npc_base.npc_content_cfg_id then
      npc:SetVisibleForCinematicReason(false)
      self:AddManaged(npc, Refresh.refresh_cfg_id)
      break
    end
  end
end

function CinematicModule:RestoreNPC()
  if not self.Playing then
    return
  end
  if not self.SeqConf then
    return
  end
  if not self.SeqConf.npc_refresh then
    return
  end
  if 0 == #self.SeqConf.npc_refresh then
    return
  end
  for npc, refreshID in pairs(self.ManagedNPCs) do
    for _, Refresh in ipairs(self.SeqConf.npc_refresh) do
      if refreshID == Refresh.refresh_cfg_id then
        npc:SetVisibleForCinematicReason(true)
        local NearLand = npc.viewObj:GetNearLandLocation()
        NearLand.Z = NearLand.Z + npc.viewObj:GetHalfHeight()
        npc:SetActorLocation(NearLand)
      end
    end
  end
end

function CinematicModule:AddManaged(npc, refreshID)
  Log.Debug("put npc into cinematic management", npc:DebugNPCNameAndID())
  if not self.ManagedNPCs[npc] then
    npc:AddEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.RemoveManaged)
  end
  self.ManagedNPCs[npc] = refreshID
end

function CinematicModule:RemoveManaged(npc)
  npc:RemoveEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.RemoveManaged)
  self.ManagedNPCs[npc] = nil
end

function CinematicModule:OnOpenLoad(Caller, Callback)
end

local CurrentSuccess

function CinematicModule:OnCloseCinematic(Success)
  UE4.UNRCStatics.ExecConsoleCommand("SigMan.ForceSignificance -1")
  UE4.UNRCStatics.ExecConsoleCommand("r.SkeletalMesh.Streaming.HiddenPrimitiveScale " .. self.HiddenPrimitiveScaleOrigin)
  UE4.UNRCStatics.ExecConsoleCommand("n.SkeletalMesh.ForceLoadStreamedLODIdx " .. self.ForceLoadStreamedLODIdxOrigin)
  local Mode = NRCModeManager:GetCurMode()
  if Mode then
    if self.DialogueChecker:CheckPass() then
      Mode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    end
    Mode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_DIALOGUE)
    Mode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    Mode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  end
  local Player = self:GetCinematicHero()
  if Player and Player.viewObj then
    if ShowPlayPos then
      local Trans = self.CinematicPlayer:GetTransform()
      local Relative = Trans.Translation
      UE.UKismetSystemLibrary.DrawDebugArrow(Player.viewObj, Relative, Relative + Trans.Rotation:GetForwardVector() * 100, 20, UE.FLinearColor(1, 0, 1, 1), 100, 2)
      UE.UKismetSystemLibrary.DrawDebugSphere(Player.viewObj, Relative, 20, 8, UE.FLinearColor(1, 0, 1, 1), 100)
    end
    local PlayerLocation = Player.viewObj:Abs_K2_GetActorLocation()
    PlayerLocation = SceneUtils.GetPosInNearLand(PlayerLocation, nil, nil, nil, true)
    if PlayerLocation then
      PlayerLocation.Z = PlayerLocation.Z + Player.viewObj:GetHalfHeight()
      Player:SetActorLocation(PlayerLocation)
    end
    if self.SeqConf and self.SeqConf.yaw > 0 then
      Player.viewObj:K2_SetActorRotation(UE.FRotator(0, self.SeqConf.yaw, 0), false)
      local Controller = Player:GetUEController()
      if Controller then
        Controller:SetControlRotation(Player.viewObj:K2_GetActorRotation())
      end
    end
    Player:EnablePlayerTick(self)
  else
    Log.Error("CinematicModule:OnCloseCinematic can't find player!!")
  end
  if 0 == self.SeqConf.keep_light then
    self:ToggleLight(true)
  end
  CurrentSuccess = Success
  local TaskIDs = _G.DataConfigManager:GetSequenceUsedByTaskConf(self.SeqConf.id)
  if TaskIDs and #TaskIDs.task_id > 0 and TaskModuleCmd and BlackScreenModuleCmd then
    for _, TaskID in ipairs(TaskIDs.task_id) do
      local Task = NRCModuleManager:DoCmd(TaskModuleCmd.getTaskByID, TaskID)
      local bValidTask = nil ~= Task
      if bValidTask then
        NRCModuleManager:DoCmd(BlackScreenModuleCmd.OpenGlobalBlackScreenIfNeed, TaskID, false)
        break
      end
    end
  end
  if self.SeqConf.end_black > 0 then
    if self.SeqConf.end_black > 1 then
      if self.SeqConf.cancel_bgm_rtpc then
        _G.NRCAudioManager:LerpGlobalRTPC("BlackScreen_Volume", 1.0, 0.0, 0.5)
      end
      self.CancelBGM = self.SeqConf.cancel_bgm_rtpc
      self.DelayCloseHandle = _G.DelayManager:DelaySeconds(self.SeqConf.end_black / 1000, function()
        self.DelayCloseHandle = nil
        self:FadeoutBlackScreen(true)
      end)
    else
      self:FadeoutBlackScreen(true)
    end
    self:EndCinematic(Success)
  else
    self:RegisterEvent(self, CinematicModuleEvent.BlackScreenOut, self.CloseMyPanel)
    self:DispatchEvent(CinematicModuleEvent.CloseBlackScreen, false)
  end
  self:RestoreNPC()
  local SKMComponent = Player.viewObj and Player.viewObj.Mesh
  if SKMComponent and SKMComponent:IsA(UE4.USkeletalMeshComponent) then
    SKMComponent.bNRCUseFixedSkelBounds = self.SKMComponentUseFixedSkelBounds
  end
end

function CinematicModule:FadeoutBlackScreen(bIsTimeout)
  if bIsTimeout then
    if self.CancelBGM then
      self.CancelBGM = false
      local cur_rtpc = _G.NRCAudioManager:GetGlobalRTPC("BlackScreen_Volume") or 1.0
      _G.NRCAudioManager:LerpGlobalRTPC("BlackScreen_Volume", cur_rtpc, 1.0, (1.0 - cur_rtpc) / 2.0)
    end
    self:RegisterEvent(self, CinematicModuleEvent.BlackScreenOut, self.PostClosePanel)
    self:DispatchEvent(CinematicModuleEvent.CloseBlackScreen, true)
  else
    self:CloseBlack()
  end
end

function CinematicModule:PostClosePanel()
  self:CloseBlack()
  self:UnRegisterEvent(self, CinematicModuleEvent.BlackScreenOut)
end

function CinematicModule:CloseMyPanel()
  self:CloseBlack()
  self:UnRegisterEvent(self, CinematicModuleEvent.BlackScreenOut)
  if nil == CurrentSuccess then
    Log.Error("Cinematic Module \230\151\182\229\186\143\229\135\186\233\151\174\233\162\152\228\186\134")
  end
  self:EndCinematic(CurrentSuccess or false)
  CurrentSuccess = nil
end

function CinematicModule:EndCinematic(Success)
  self:ClosePanel("CinematicBar")
  Log.Debug("Cinematic Finished", self.SeqConf.id, Success)
  self:ClearSubtitle()
  self.LastEndTime = _G.UpdateManager.Timestamp
  self.Playing = false
  NRCEventCenter:DispatchEvent(CinematicModuleEvent.Ended, Success)
  self:FireCallback(Success)
  if self.CinematicPlayer and UE.UObject.IsValid(self.CinematicPlayer) then
    self.CinematicPlayer:K2_DestroyActor()
  end
  self.CinematicPlayer = nil
  self.SeqConf = nil
  _G.NRCSDKManager:PerfEndMark("Sequence")
end

function CinematicModule:FireCallback(Success)
  local Caller = self.CBCaller
  local Func = self.CBFunc
  self.CBCaller = nil
  self.CBFunc = nil
  NRCModuleManager:DoCmd(FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_CG)
  self:TriggerCallback(Caller, Func, Success)
  if Success then
    self:PostCinematic()
  end
end

function CinematicModule:TriggerCallback(Caller, Func, Success)
  if not Func then
    return
  end
  if Caller then
    Func(Caller, Success)
  else
    Func(Success)
  end
end

function CinematicModule:OnStartCinematic(ID, Caller, Callback)
  Log.Debug("Starting Cinematic.....", ID)
  if self.Playing then
    Log.Error("Cinematic Already Playing!", ID, self.SeqConf and self.SeqConf.id or "nil")
    self:TriggerCallback(Caller, Callback, false)
    return
  end
  if self.CBFunc then
    Log.Error("Cinematic Already Playing!", ID, self.SeqConf and self.SeqConf.id or "nil")
    self:TriggerCallback(Caller, Callback, false)
    return
  end
  self.CBFunc = Callback
  self.CBCaller = Caller
  if type(ID) == "number" then
    self.SeqConf = _G.DataConfigManager:GetSequenceConf(ID, true)
  else
    self.SeqConf = ID
  end
  if not self.SeqConf then
    Log.Error("Cannot find Conf for Sequence")
    self:FireCallback(false)
    return
  end
  if string.IsNilOrEmpty(self.SeqConf.sequence_path) then
    Log.Error("Sequence path is empty")
    self:FireCallback(false)
    return
  end
  local Player = self:GetPlayer()
  if not Player then
    self:FireCallback(false)
    return
  end
  _G.NRCSDKManager:PerfBeginMark("Sequence")
  self.Playing = true
  local settings = CinematicDataUtils:NewSequenceSettings()
  self:RegisterEvent(self, CinematicModuleEvent.BlackScreenIn, self.Play)
  Player = self:GetCinematicHero()
  self.PlayResTrans = Player.viewObj:GetTransform()
  if ShowPlayPos then
    local Relative = self.PlayResTrans.Translation
    UE.UKismetSystemLibrary.DrawDebugArrow(Player.viewObj, Relative, Relative + self.PlayResTrans.Rotation:GetForwardVector() * 100, 20, UE.FLinearColor(1, 0, 0, 1), 100, 2)
    UE.UKismetSystemLibrary.DrawDebugSphere(Player.viewObj, Relative, 20, 8, UE.FLinearColor(1, 0, 0, 1), 100)
  end
  if UE4.UObject.IsValid(self.CinematicPlayer) then
    self.CinematicPlayer:K2_SetActorTransform(self.PlayResTrans, false, nil, false)
  else
    local Always = UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn
    local Klass = _G.NRCBigWorldPreloader:Get("CinematicPlayer")
    local CurrentWorld = _G.UE4Helper.GetCurrentWorld()
    self.CinematicPlayer = CurrentWorld:SpawnActor(Klass, self.PlayResTrans, Always, CurrentWorld)
  end
  self.CinematicPath = self.SeqConf.sequence_path
  self.CinematicPlayer.settings = settings
  if not self.CinemaFsm then
    self.CinemaFsm = CinematicFsm()
  end
  self.CinemaFsm:SetProperty("Result", false)
  self.CinemaFsm:SetProperty("CinematicConfID", self.SeqConf.id)
  local SKMComponent = Player.viewObj and Player.viewObj.Mesh
  if SKMComponent and SKMComponent:IsA(UE4.USkeletalMeshComponent) then
    self.SKMComponentUseFixedSkelBounds = SKMComponent.bNRCUseFixedSkelBounds
    SKMComponent.bNRCUseFixedSkelBounds = false
  end
  self:OpenBlack(self, self.PanelUp)
end

function CinematicModule:PanelUp()
  if self.DelayCloseHandle then
    Log.Debug("CinematicModule:PanelUp, close delay close handle")
    _G.DelayManager:CancelDelayById(self.DelayCloseHandle)
    self.DelayCloseHandle = nil
  end
  self:UnRegisterEvent(self, CinematicModuleEvent.BlackScreenOut)
  if not self.SeqConf then
    Log.Error("\230\137\190\228\184\141\229\136\176SeqConf!!")
    self:DispatchEvent(CinematicModuleEvent.CloseBlackScreen, false)
    self:CloseBlack()
    return
  end
  if NRCModuleManager:DoCmd(BlackScreenModuleCmd.IsGlobalBlackScreenOn) then
    self:DispatchEvent(CinematicModuleEvent.OpenBlackScreen, false)
    self.BlackScreenOn = true
    return
  end
  if self.SeqConf.begin_black > 0 then
    if self.SeqConf.begin_black_fade_in and self.SeqConf.begin_black_fade_in > 0 then
      self:DispatchEvent(CinematicModuleEvent.OpenBlackScreen, true)
      self.BlackScreenOn = true
    else
      self:DispatchEvent(CinematicModuleEvent.OpenBlackScreen, false)
      self.BlackScreenOn = true
    end
  else
    self:DispatchEvent(CinematicModuleEvent.CloseBlackScreen, false)
    self:Play()
  end
end

function CinematicModule:Play()
  self.Playing = true
  local Player = self:GetPlayer()
  if Player and self.SeqConf.yaw > 0 then
    local Controller = Player:GetUEController()
    Controller:SetControlRotation(UE.FRotator(0, self.SeqConf.yaw, 0))
  end
  NRCEventCenter:DispatchEvent(CinematicModuleEvent.Started, self.SeqConf)
  NRCModuleManager:DoCmd(FunctionBanModuleCmd.AddCondition, Enum.PlayerConditionType.PCT_CG)
  self.CinemaFsm:Play()
  self:UnRegisterEvent(self, CinematicModuleEvent.BlackScreenIn)
end

function CinematicModule:OnPlayCinematic(Caller, Callback)
  if not self.CinematicPlayer then
    Log.Error("CinematicPlayer\228\184\141\229\173\152\229\156\168\239\188\129")
    self:TriggerCallback(Caller, Callback, false)
    return
  end
  NRCModuleManager:DoCmd(LoadingUIModuleCmd.CloseLoadingUI, 0, false, true)
  UE4.UNRCStatics.ExecConsoleCommand("SigMan.ForceSignificance 0")
  UE4.UNRCStatics.ExecConsoleCommand("r.SkeletalMesh.Streaming.HiddenPrimitiveScale 1")
  UE4.UNRCStatics.ExecConsoleCommand("n.SkeletalMesh.ForceLoadStreamedLODIdx 0")
  self:OpenPanel("CinematicBar")
  self.CinematicPlayer:SetCallbackOwner(Caller):SetFinishCallback(Callback)
  local Mode = NRCModeManager:GetCurMode()
  if Mode then
    Mode:DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    Mode:DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    Mode:DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
    Mode:ClosePanelByLayer(_G.Enum.UILayerType.UI_LAYER_DIALOGUE)
  end
  if 0 == self.SeqConf.keep_light then
    self:ToggleLight(false)
  end
  local Player = self:GetPlayer()
  if Player and Player.viewObj then
    Player:DisablePlayerTick(Caller or self)
  end
  if self.CinematicPlayer then
    self.CinematicPlayer:Play(self.CinematicPath, self.SeqConf, self.CinemaFsm)
  else
    Log.Error("CinematicPlayer\228\184\141\229\173\152\229\156\168\239\188\129")
    self:TriggerCallback(Caller, Callback, false)
  end
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.CLOSE_BLACK_SCREEN, false)
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.CLOSE_WHITE_SCREEN, false)
  if self.BlackScreenOn then
    self:DispatchEvent(CinematicModuleEvent.CloseBlackScreen, true)
  else
    self:DispatchEvent(CinematicModuleEvent.CloseBlackScreen, false)
  end
  self.BlackScreenOn = false
end

function CinematicModule:GetIsPlaying()
  return self.Playing
end

function CinematicModule:GetCinematicHero()
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player:IsInTogetherMove() and player:IsTogetherMove2P() then
    local other_player = player:GetAnotherTogetherMovePlayer()
    return other_player
  end
  return player
end

function CinematicModule:GetPlayer()
  local Player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  return Player
end

function CinematicModule:ToggleLight(On)
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  local LightManager = EnvSys and EnvSys:GetEnvLightManager()
  if not LightManager then
    Log.Error("\230\151\160\230\179\149\230\137\190\229\136\176light manager")
    return
  end
  LightManager:SetSceneLightSwitch(On)
end

function CinematicModule:OnOpenPanelCallback(panelName, panelIndex, isSucc)
  NRCModuleBase.OnOpenPanelCallback(self, panelName, panelIndex, isSucc)
  if "CinematicBar" == panelName then
    local cinematicBar = self:GetPanel("CinematicBar")
    if self.bRemoveCinematicBarBackground and cinematicBar and cinematicBar.RemoveBackground then
      cinematicBar:RemoveBackground()
    end
    self:UpdateSubtitle()
  end
end

function CinematicModule:SetSubtitle(SubtitleID)
  Log.Debug("CinematicModule:SetSubtitle", SubtitleID)
  self.SubtitleID = SubtitleID
  self:UpdateSubtitle()
end

function CinematicModule:ClearSubtitle()
  Log.Debug("CinematicModule:ClearSubtitle")
  self.SubtitleID = nil
  self:UpdateSubtitle()
end

function CinematicModule:UpdateSubtitle()
  if not self:HasPanel("CinematicBar") then
    Log.Debug("CinematicModule:UpdateSubtitle, CinematicBar not found")
    return
  end
  local cinematicBar = self:GetPanel("CinematicBar")
  if cinematicBar then
    local SubtitleText = ""
    local LockeWordText = ""
    if self.SubtitleID ~= nil then
      local subtitleContent = _G.DataConfigManager:GetSubtitleConf(self.SubtitleID)
      if subtitleContent then
        SubtitleText = subtitleContent.msg
      end
    end
    cinematicBar.SubtitleText:SetText(SubtitleText)
    cinematicBar.LockeWordText:SetText(LockeWordText)
  end
end

function CinematicModule:OpenCinematicBar(bRemoveBackground)
  if self:HasPanel("CinematicBar") == false then
    self:OpenPanel("CinematicBar", bRemoveBackground)
  end
  self.bRemoveCinematicBarBackground = nil
  if bRemoveBackground then
    self.bRemoveCinematicBarBackground = true
  end
end

function CinematicModule:CloseCinematicBar()
  self:ClosePanel("CinematicBar")
  self.bRemoveCinematicBarBackground = nil
end

function CinematicModule:PostCinematic()
  local restart_bgm = self.SeqConf and self.SeqConf.restart_bgm
  if restart_bgm then
    _G.NRCAudioManager:StopWwiseEventForActor(9031, nil)
  end
  local mute_time = self.SeqConf and self.SeqConf.mute_time
  if mute_time and 0 ~= mute_time then
    _G.NRCAudioManager:LerpGlobalRTPC("Seq_Ducking", 0, 1, mute_time / 1000)
  end
  Log.Debug("CinematicModule:PostCinematic", restart_bgm, mute_time)
end

function CinematicModule:OnSyncCinematic(msg)
  if msg.operation.operator_type == ProtoEnum.ClientOperationType.COT_TOGETHER_CINEMATIC and msg.operation and msg.operation.cinematic_info then
    Log.Debug("CinematicModule:OnSyncCinematic", msg.operation.cinematic_info.target_npc_id or 0, msg.operation.cinematic_info.cinematic_id or 0)
    local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local player_id = player and player:GetServerId()
    if msg.operation.cinematic_info.target_npc_id == player_id then
      local cinematic_id = msg.operation.cinematic_info.cinematic_id
      if cinematic_id >= 0 then
        if msg.operation.cinematic_info.sync_type == ProtoEnum.PlayerOperationSyncType.POST_START then
          if self:GetIsPlaying() then
            self:OnCloseCinematic(true)
          end
          self:OnStartCinematic(cinematic_id)
        elseif msg.operation.cinematic_info.sync_type == ProtoEnum.PlayerOperationSyncType.POST_END and self:GetIsPlaying() and self.CinematicPlayer then
          self.CinematicPlayer:Stop()
        end
      end
    end
  end
end

function CinematicModule:OnCloseBlackScreen()
  if self.DelayCloseHandle then
    _G.DelayManager:CancelDelayById(self.DelayCloseHandle)
    self.DelayCloseHandle = nil
  end
  self:FadeoutBlackScreen(true)
end

return CinematicModule
