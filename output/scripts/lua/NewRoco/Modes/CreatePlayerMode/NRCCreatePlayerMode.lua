local NRCCreatePlayerMode = NRCModeBase:Extend("NRCLocalMode")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local LocalModeEvent = require("NewRoco.Modes.LocalMode.NRCLocalModeEvent")
local LoadingUIModuleCmd = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleCmd")
local NPCModule = require("NewRoco.Modules.Core.NPC.NPCModule")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")

function NRCCreatePlayerMode:OnConstruct()
  self:RegisterModule("PlayerModule", "Type_System", nil, "NewRoco.Modules.Core.PlayerModule.PlayerModuleSimple")
  self:RegisterModule("MainUIModule", "Type_System", "NewRoco.Modules.System.MainUI.MainUIModuleHead", "NewRoco.Modules.System.MainUI.MainUIModule")
  self:RegisterModule("MultiTouchModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.MultiTouch.MultiTouchModuleHead", "NewRoco.Modules.Core.MultiTouch.MultiTouchModule")
  self:RegisterModule("CreatePlayerModule", NRCModuleTypeDef.Type_System, nil, "NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModule")
  self:RegisterModule("LoginModule", "Type_System", "NewRoco.Modules.System.LoginModule.LoginModuleHead", "NewRoco.Modules.System.LoginModule.LoginModule")
  self:RegisterModule("EnvSystemModule", "Type_System", nil, "NewRoco.Modules.System.EnvSystem.EnvSystemModule")
  self:RegisterModule("LoadingUIModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleHead", "NewRoco.Modules.System.LoadingUIModule.LoadingUIModule")
  self:RegisterModule("SystemSettingModule", "Type_System", nil, "NewRoco.Modules.System.SystemSetting.SystemSettingModule")
  self:RegisterModule("NPCModule", "Type_System", "NewRoco.Modules.Core.NPC.NPCModuleHead", "NewRoco.Modules.Core.NPC.NPCModule")
  self:RegisterModule("DialogueModule", "Type_System", "NewRoco.Modules.System.Dialogue.DialogueModuleHead", "NewRoco.Modules.System.Dialogue.DialogueModule")
  self:RegisterModule("TaskModule", "Type_System", "NewRoco.Modules.Core.Task.TaskModuleHead", "NewRoco.Modules.Core.Task.TaskModule")
  self:RegisterModule("CinematicModule", "Type_Core", "NewRoco.Modules.Core.Cinematic.CinematicModuleHead", "NewRoco.Modules.Core.Cinematic.CinematicModule")
  _G.NRCEventCenter:RegisterEvent("NRCCreatePlayerMode", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
  self.bHasDownloadInfo = false
end

function NRCCreatePlayerMode:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
  self.bHasDownloadInfo = false
end

function NRCCreatePlayerMode:DownloadCreatePlayerLevelInfo()
  self.bHasDownloadInfo = false
  _G.DataModelMgr.RemoteStorage:Get("CreatePlayerLevelInfo", ".Next.PointList", self, self.DownloadCreatePlayerLevelInfoSucc)
end

function NRCCreatePlayerMode:DownloadCreatePlayerLevelInfoSucc(data)
  self.levelData = data
  _G.DataModelMgr.RemoteStorage:Get("DimoPosInfo", ".Next.PointList", self, self.OnDownloadInfoRsp)
end

function NRCCreatePlayerMode:OnDownloadInfoRsp(data)
  Log.Dump(data, 2, "OnDownloadInfoRsp")
  self.posData = data
  self.bHasDownloadInfo = true
  local CurLevelName = LevelHelper:GetLevelName()
  self:PreLoadAsset()
end

function NRCCreatePlayerMode:OnActive()
  self:DownloadCreatePlayerLevelInfo()
end

function NRCCreatePlayerMode:OnReconnect()
  if not self.bHasDownloadInfo then
    self:DownloadCreatePlayerLevelInfo()
  end
end

function NRCCreatePlayerMode:PreLoadAsset()
  local Preloader = require("NewRoco.Modes.CreatePlayerMode.CreatePlayerAssetPreloader")
  self.AssetPreloader = Preloader()
  self.AssetPreloader:StartPreload(self, self.OnPreloadFinish)
end

function NRCCreatePlayerMode:OnPreloadFinish()
  local Options = "Game=/Game/Game/NRC/GameMode/BP_NRCCreatePlayerMode.BP_NRCCreatePlayerMode_C"
  NRCEventCenter:RegisterEvent("NRCCreatePlayerMode", self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnMapLoaded)
  LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Plot/A1/Plot_A1_LearnMagic_New/Plot_A1_LearnMagic_New_Release", Options)
end

function NRCCreatePlayerMode:OnMapLoaded()
  self.delayID = DelayManager:DelayFrames(1, function()
    NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnMapLoaded)
    if self:CheckPlayer() then
      self:ActiveModules()
      self:Init()
    end
  end)
end

function NRCCreatePlayerMode:CheckPlayer()
  local playerActor = _G.UE4Helper.GetPlayerCharacter(0)
  if not UE.UObject.IsValid(playerActor) then
    Log.Error("NRCCreatePlayerMode:CheckPlayer Player Actor InValid")
    UE.UNRCStatics.QuitGame()
    return false
  end
  return true
end

function NRCCreatePlayerMode:OpenMainUI()
  UE4Helper.PrintScreenMsg("NRCCreatePlayerMode MainUIModuleCmd.OpenPanelLobbyMain")
end

function NRCCreatePlayerMode:OnDeactive()
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.CloseNPCInteract)
  if self.AssetPreloader then
    self.AssetPreloader = nil
    self:GetModule("CreatePlayerModule"):ResetAssetLoader()
  end
end

function NRCCreatePlayerMode:ActiveModules()
  self:ActiveModule("MultiTouchModule")
  self:ActiveModule("EnvSystemModule")
  self:ActiveModule("PlayerModule")
  self:ActiveModule("LoginModule")
  self:ActiveModule("LoadingUIModule")
  self:ActiveModule("NPCModule")
  self:ActiveModule("MainUIModule")
  self:ActiveModule("DialogueModule")
  self:ActiveModule("CreatePlayerModule")
  self:ActiveModule("TaskModule")
  self:GetModule("CreatePlayerModule"):InitCreatePlayerFsm(self.levelData, self.posData)
  self:GetModule("CreatePlayerModule"):SetAssetLoader(self.AssetPreloader)
  self:ActiveModule("SystemSettingModule")
  self:ActiveModule("CinematicModule")
  self:OpenMainUI()
end

function NRCCreatePlayerMode:Init()
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenNPCInteract)
  self:LoadNPCs()
  UE.NPCBaseCommon.ToggleNPCCheck(true)
end

function NRCCreatePlayerMode:LoadNPCs()
  local SpawnerClass = self.AssetPreloader and self.AssetPreloader:Get(_G.UEPath.LOGIN_NPC_SPAWNER)
  SpawnerClass = SpawnerClass or UE4.UClass.Load(_G.UEPath.LOGIN_NPC_SPAWNER)
  local Spawners = UE4.UGameplayStatics.GetAllActorsOfClass(_G.UE4Helper.GetCurrentWorld(), SpawnerClass):ToTable()
  for _, Spawner in pairs(Spawners) do
    local NPC_ID = Spawner.NPC_ID
    local NPC_Trans = Spawner:Abs_GetTransform()
    local NPC_Forward = NPC_Trans.Rotation:GetForwardVector()
    local NPC_Yaw = math.deg(math.atan(NPC_Forward.Y, NPC_Forward.X))
    if nil ~= NPC_ID then
      Log.DebugFormat("NRCCreatePlayerMode:LoadNPCs, try create local npc with id[%d]", NPC_ID)
      local NewNPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.CreateLocalNPC, NPC_ID, SceneUtils.ClientPos2ServerPos(NPC_Trans.Translation), NPC_Yaw * 10.0, nil, PriorityEnum.Passive_World_NPC_Close_BP)
      if nil ~= NewNPC then
        NewNPC.SpawnInCreatePlayerMode = true
      else
        Log.ErrorFormat("NRCCreatePlayerMode:LoadNPCs, fail to load NPC with id[%d]", NPC_ID)
      end
    end
  end
end

function NRCCreatePlayerMode:LoadDefaultOptionsOnNPC(NPC)
  if nil == NPC then
    return
  end
  local NPCConf = _G.DataConfigManager:GetNpcConf(NPC.config.id)
  for _, NPCOptionID in ipairs(NPCConf.option_id) do
    local AddNPCOption = _G.ProtoMessage:newSpaceAct_AddNpcOption()
    AddNPCOption.npc_id = NPC:GetServerId()
    AddNPCOption.opt_info.option_id = NPCOptionID
    AddNPCOption.opt_info.enabled = true
    AddNPCOption.opt_info.executable_times = -1
    local NPCOptionConf = _G.DataConfigManager:GetNpcOptionConf(NPCOptionID)
    if NPCOptionConf.action.action_type == Enum.ActionType.ACT_DIALOGUE_LOCAL then
      AddNPCOption.opt_info.first_dialog_id = tonumber(NPCOptionConf.action.action_param1)
    end
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.AddOptionAction, AddNPCOption)
  end
end

function NRCCreatePlayerMode:StartCreatePlayerFsm()
end

function NRCCreatePlayerMode:OnDestruct()
  if self.delayID then
    _G.DelayManager:CancelDelayById(self.delayID)
    self.delayID = nil
  end
end

return NRCCreatePlayerMode
