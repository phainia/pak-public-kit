local NRCLocalMode = NRCModeBase:Extend("NRCLocalMode")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local LocalModeEvent = require("NewRoco.Modes.LocalMode.NRCLocalModeEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")

function NRCLocalMode:OnConstruct()
  Log.Debug("NRCLocalMode OnConstruct")
  self.UIVisible = true
  local bMemoryTest = false
  if _G.GlobalConfig.MemoryAutoTest then
    bMemoryTest = _G.GlobalConfig.DisableGameplayMode or _G.GlobalConfig.EngineTestMode
  end
  if not bMemoryTest then
    self:RegisterModule("SceneModule", "Type_System", "NewRoco.Modules.Core.Scene.SceneModuleHead", "NewRoco.Modules.Core.Scene.SceneModule")
    self:RegisterModule("EnvSystemModule", "Type_System", nil, "NewRoco.Modules.System.EnvSystem.EnvSystemModule")
    self:RegisterModule("MainUIModule", "Type_System", "NewRoco.Modules.System.MainUI.MainUIModuleHead", "NewRoco.Modules.System.MainUI.MainUIModule")
    self:RegisterModule("NPCModule", "Type_System", "NewRoco.Modules.Core.NPC.NPCModuleHead", "NewRoco.Modules.Core.NPC.NPCModule")
    self:RegisterModule("InputModule", "Type_System", nil, "NewRoco.Modules.Core.Input.InputModule")
    self:RegisterModule("PlayerModule", "Type_System", "NewRoco.Modules.Core.PlayerModule.PlayerModuleHead", "NewRoco.Modules.Core.PlayerModule.PlayerModule")
    self:RegisterModule("BattleModule", "Type_Core", "NewRoco.Modules.Core.Battle.BattleModuleHead", "NewRoco.Modules.Core.Battle.BattleModule")
    self:RegisterModule("AreaAndZoneModule", "Type_System", "NewRoco.Modules.Core.Scene.Map.AreaAndZoneModuleHead", "NewRoco.Modules.Core.Scene.Map.AreaAndZoneModule")
    self:RegisterModule("DebugModule", NRCModuleTypeDef.Donnt_Destroy, nil, "NewRoco.Modules.System.Debug.DebugModule")
    self:RegisterModule("VideoModule", "Type_System", "NewRoco.Modules.System.MediaPlayer.VideoModuleHead", "NewRoco.Modules.System.MediaPlayer.VideoModule")
    self:RegisterModule("TUIModule", "Type_System", nil, "NewRoco.Modules.System.TUI.TUIModule")
    self:RegisterModule("MissileModule", "Type_Core", "NewRoco.Modules.Core.Missile.MissileModuleHead", "NewRoco.Modules.Core.Missile.MissileModule")
    self:RegisterModule("CollisionModule", "Type_Core", "NewRoco.Modules.Core.Collision.CollisionModuleHead", "NewRoco.Modules.Core.Collision.CollisionModule")
    self:RegisterModule("TipsModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.System.TipsModule.TipsModuleHead", "NewRoco.Modules.System.TipsModule.TipsModule")
    self:RegisterModule("MultiTouchModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.MultiTouch.MultiTouchModuleHead", "NewRoco.Modules.Core.MultiTouch.MultiTouchModule")
    self:RegisterModule("WorldCombatModule", "Type_System", "NewRoco.Modules.System.WorldCombat.WorldCombatModuleHead", "NewRoco.Modules.System.WorldCombat.WorldCombatModule")
    self:RegisterModule("DebugModule", NRCModuleTypeDef.Donnt_Destroy, nil, "NewRoco.Modules.System.Debug.DebugModule")
    self:RegisterModule("CosUploadModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.CosUpload.CosUploadModuleHead", "NewRoco.Modules.Core.CosUpload.CosUploadModule")
    self:RegisterModule("EnhancedInputModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleHead", "NewRoco.Modules.Core.EnhancedInput.EnhancedInputModule")
    self:RegisterModule("FunctionBanModule", NRCModuleTypeDef.Donnt_Destroy, nil, "NewRoco.Modules.System.FunctionBan.FunctionBanModule")
    self:RegisterModule("BlackScreenModule", "Type_System", "NewRoco.Modules.System.BlackScreen.BlackScreenModuleHead", "NewRoco.Modules.System.BlackScreen.BlackScreenModule")
  end
end

function NRCLocalMode:OnDestruct()
  Log.Debug("NRCLocalMode OnDestruct")
end

function NRCLocalMode:OnActive()
  Log.Debug("NRCLocalMode OnActive")
  _G.ZoneServer:DisConnect()
  SceneUtils.debugDisableAutoCollect = true
  local bMemoryTest = false
  if _G.GlobalConfig.MemoryAutoTest then
    bMemoryTest = _G.GlobalConfig.DisableGameplayMode or _G.GlobalConfig.EngineTestMode
  end
  if UE4.UNRCStatics.IsRenderingMovie() then
    local playerActor = _G.UE4Helper.GetPlayerCharacter(0)
    UE4.UNRCStatics.PrepareRenderingMovie(playerActor:GetWorld())
    UE4.UNRCStatics.BlockTillLevelStreamingCompleted(UE4Helper.GetCurrentWorld())
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeWorldComposition 1")
    self:ActiveModule("EnvSystemModule")
    return
  elseif not bMemoryTest then
    self:ActiveModule("DebugModule")
    self:ActiveModule("WorldCombatModule")
    self:ActiveModule("EnvSystemModule")
    self:ActiveModule("NPCModule")
    self:ActiveModule("SceneModule")
    self:ActiveModule("InputModule")
    self:ActiveModule("PlayerModule")
    self:ActiveModule("VideoModule")
    self:ActiveModule("MultiTouchModule")
    self:ActiveModule("CosUploadModule")
    self:ActiveModule("EnhancedInputModule")
    self:ActiveModule("FunctionBanModule")
    local loginData = ProtoMessage:newZoneLoginRsp()
    loginData.player_info.brief_info.vitem_info.vitem_list[_G.ProtoEnum.VisualItem.VI_ROLE_HP_MAX] = 999999
    DataModelMgr.PlayerDataModel:SetLoginData(loginData)
    local playerInfo = ProtoMessage:newActorInfo_Avatar()
    playerInfo.base.actor_id = 0
    playerInfo.base.name = "default player"
    playerInfo.base.lv = 10
    playerInfo.base.gender = GlobalConfig.CharacterIndex
    playerInfo.fashion_info = nil
    _G.NRCModeManager:DoCmd(PlayerModuleCmd.AddSelfPlayer, playerInfo)
    local playerActor = _G.UE4Helper.GetPlayerCharacter(0)
    if playerActor then
      local playerModule = self:GetModule("PlayerModule")
      playerModule:CreateLocalPlayer(playerActor, playerInfo, true)
      self:OnSceneLoaded()
    end
    self:ActiveModule("TUIModule")
    UE.NPCBaseCommon.ToggleNPCCheck(true)
  end
  _G.NRCEventCenter:RegisterEvent("NRCLocalMode", self, SceneEvent.LoadMapFinish, self.OnSceneLoaded)
  _G.NRCAudioManager:SetStateByName("Main_UI", "Visible")
end

function NRCLocalMode:OnDeactive()
  Log.Debug("NRCLocalMode OnDeactive")
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.LoadMapFinish, self.OnSceneLoaded)
end

function NRCLocalMode:OnSceneLoaded()
  Log.Debug("NRCLocalMode OnSceneLoaded")
  local bMemoryTest = false
  if _G.GlobalConfig.MemoryAutoTest then
    bMemoryTest = _G.GlobalConfig.DisableGameplayMode or _G.GlobalConfig.EngineTestMode
  end
  if not bMemoryTest then
    local playerModule = self:GetModule("PlayerModule")
    local localPlayer = playerModule:GetLocalPlayer()
    GlobalConfig.DebugOpenRideAbility = true
    if MainUIModuleCmd then
    end
    localPlayer:SetCharacterMovementTickEnable(self, true)
    GlobalConfig.FreeVitality = true
    GlobalConfig.SyncVitality = false
    if not _G.NRCModuleManager:GetModule("MainUIModule") then
      self:ActiveModule("MainUIModule")
      NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMain)
    end
  end
  _G.NRCEventCenter:DispatchEvent(LocalModeEvent.PostSceneLoaded)
end

return NRCLocalMode
