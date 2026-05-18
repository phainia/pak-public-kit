local NRCBattleTestMapMode = NRCModeBase:Extend("NRCBattleTestMapMode")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local LocalModeEvent = require("NewRoco.Modes.LocalMode.NRCLocalModeEvent")
local AppearanceLocalUtils = require("NewRoco.Modules.System.Appearance.AppearanceLocalUtils")

function NRCBattleTestMapMode:OnConstruct()
  self.UIVisible = true
  local bMemoryTest = false
  if _G.GlobalConfig.MemoryAutoTest then
    bMemoryTest = _G.GlobalConfig.DisableGameplayMode or _G.GlobalConfig.EngineTestMode
  end
  self:CreateAction("BattleTestMapMode", "EnterBattleTestMapAction", "NewRoco.Modes.BattleCraneTestMode.Actions.EnterBattleTestMapAction")
  self:CreateAction("BattleTestMapMode", "ConnectionServerAuthenticationAction", "NewRoco.Modes.BattleCraneTestMode.Actions.ConnectionServerAuthenticationAction")
  if not bMemoryTest then
    self:RegisterModule("SceneModule", "Type_System", "NewRoco.Modules.Core.Scene.SceneModuleHead", "NewRoco.Modules.Core.Scene.SceneModule")
    self:RegisterModule("EnvSystemModule", "Type_System", nil, "NewRoco.Modules.System.EnvSystem.EnvSystemModule")
    self:RegisterModule("MainUIModule", "Type_System", "NewRoco.Modules.System.MainUI.MainUIModuleHead", "NewRoco.Modules.System.MainUI.MainUIModule")
    self:RegisterModule("NPCModule", "Type_System", "NewRoco.Modules.Core.NPC.NPCModuleHead", "NewRoco.Modules.Core.NPC.NPCModule")
    self:RegisterModule("InputModule", "Type_System", nil, "NewRoco.Modules.Core.Input.InputModule")
    self:RegisterModule("PlayerModule", "Type_System", "NewRoco.Modules.Core.PlayerModule.PlayerModuleHead", "NewRoco.Modules.Core.PlayerModule.PlayerModule")
    self:RegisterModule("BattleModule", "Type_Core", "NewRoco.Modules.Core.Battle.BattleModuleHead", "NewRoco.Modules.Core.Battle.BattleModule")
    self:RegisterModule("AreaAndZoneModule", "Type_System", "NewRoco.Modules.Core.Scene.Map.AreaAndZoneModuleHead", "NewRoco.Modules.Core.Scene.Map.AreaAndZoneModule")
    if _G.AppMain:HasDebug() then
      self:RegisterModule("DebugModule", NRCModuleTypeDef.Donnt_Destroy, nil, "NewRoco.Modules.System.Debug.DebugModule")
    end
    self:RegisterModule("VideoModule", "Type_System", "NewRoco.Modules.System.MediaPlayer.VideoModuleHead", "NewRoco.Modules.System.MediaPlayer.VideoModule")
    self:RegisterModule("TUIModule", "Type_System", nil, "NewRoco.Modules.System.TUI.TUIModule")
    self:RegisterModule("MissileModule", "Type_Core", "NewRoco.Modules.Core.Missile.MissileModuleHead", "NewRoco.Modules.Core.Missile.MissileModule")
    self:RegisterModule("CollisionModule", "Type_Core", "NewRoco.Modules.Core.Collision.CollisionModuleHead", "NewRoco.Modules.Core.Collision.CollisionModule")
    self:RegisterModule("TipsModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.System.TipsModule.TipsModuleHead", "NewRoco.Modules.System.TipsModule.TipsModule")
    self:RegisterModule("MultiTouchModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.MultiTouch.MultiTouchModuleHead", "NewRoco.Modules.Core.MultiTouch.MultiTouchModule")
    self:RegisterModule("WorldCombatModule", "Type_System", "NewRoco.Modules.System.WorldCombat.WorldCombatModuleHead", "NewRoco.Modules.System.WorldCombat.WorldCombatModule")
    self:RegisterModule("LoadingUIModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleHead", "NewRoco.Modules.System.LoadingUIModule.LoadingUIModule")
    self:RegisterModule("LoginModule", "Type_System", "NewRoco.Modules.System.LoginModule.LoginModuleHead", "NewRoco.Modules.System.LoginModule.LoginModule")
    self:RegisterModule("OnlineModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.Online.OnlineModuleHead", "NewRoco.Modules.Core.Online.OnlineModule")
    self:RegisterModule("TipsModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.System.TipsModule.TipsModuleHead", "NewRoco.Modules.System.TipsModule.TipsModule")
    self:RegisterModule("RedPointModule", "Type_System", nil, "NewRoco.Modules.System.RedPoint.RedPointModule")
    self:RegisterModule("RolePlayModule", "Type_System", "NewRoco.Modules.System.RolePlay.RolePlayModuleHead", "NewRoco.Modules.System.RolePlay.RolePlayModule")
    self:RegisterModule("UpdateUIModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.System.UpdateUIModule.UpdateUIModuleHead", "NewRoco.Modules.System.UpdateUIModule.UpdateUIModule")
    self:RegisterModule("FunctionBanModule", NRCModuleTypeDef.Donnt_Destroy, nil, "NewRoco.Modules.System.FunctionBan.FunctionBanModule")
    self:RegisterModule("BattleUIModule", "Type_System", nil, "NewRoco.Modules.System.BattleUI.BattleUIModule")
    self:RegisterModule("CosUploadModule", NRCModuleTypeDef.Donnt_Destroy, "NewRoco.Modules.Core.CosUpload.CosUploadModuleHead", "NewRoco.Modules.Core.CosUpload.CosUploadModule")
  end
end

function NRCBattleTestMapMode:OnDestruct()
  Log.Debug("yukaheTestMap NRCBattleTestMapMode.OnDestruct")
end

function NRCBattleTestMapMode:OnActive()
  Log.Debug("yukaheTestMap NRCBattleTestMapMode.OnActive")
  _G.ZoneServer:DisConnect()
  self:ActiveModule("MultiTouchModule")
  self:ActiveModule("LoadingUIModule")
  self:ActiveModule("DebugModule")
  self:ActiveModule("WorldCombatModule")
  self:ActiveModule("EnvSystemModule")
  self:ActiveModule("NPCModule")
  self:ActiveModule("SceneModule")
  self:ActiveModule("InputModule")
  self:ActiveModule("PlayerModule")
  self:ActiveModule("VideoModule")
  self:ActiveModule("LoginModule")
  self:ActiveModule("OnlineModule")
  self:ActiveModule("TipsModule")
  self:ActiveModule("RedPointModule")
  self:ActiveModule("RolePlayModule")
  self:ActiveModule("UpdateUIModule")
  self:ActiveModule("BattleModule")
  self:ActiveModule("AreaAndZoneModule")
  self:ActiveModule("FunctionBanModule")
  self:ActiveModule("BattleUIModule")
  self:LoadPlayer()
  self:ActiveModule("TUIModule")
  self:ActiveModule("CosUploadModule")
  UE.NPCBaseCommon.ToggleNPCCheck(true)
  _G.NRCModeManager:DoCmd(SceneModuleCmd.EnterMap, 243)
  self:StartGroup("BattleTestMapMode")
  _G.NRCEventCenter:RegisterEvent("NRCBattleTestMapMode", self, SceneEvent.LoadMapFinish, self.OnSceneLoaded)
end

function NRCBattleTestMapMode:LoadPlayer()
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
end

function NRCBattleTestMapMode:OnDeactive()
  Log.Debug("yukaheTestMap OnDeactive")
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.LoadMapFinish, self.OnSceneLoaded)
end

function NRCBattleTestMapMode:OnSceneLoaded()
  Log.Debug("yukaheTestMap OnSceneLoaded")
  local bMemoryTest = false
  if _G.GlobalConfig.MemoryAutoTest then
    bMemoryTest = _G.GlobalConfig.DisableGameplayMode or _G.GlobalConfig.EngineTestMode
  end
  if not bMemoryTest then
    local playerModule = self:GetModule("PlayerModule")
    local localPlayer = playerModule:GetLocalPlayer()
    GlobalConfig.DebugOpenRideAbility = true
    localPlayer.viewObj.CharacterMovement:SetComponentTickEnabled(true)
    GlobalConfig.FreeVitality = true
    GlobalConfig.SyncVitality = false
    if not _G.NRCModuleManager:GetModule("MainUIModule") then
      self:ActiveModule("MainUIModule")
      NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMain)
    end
  end
  _G.NRCEventCenter:DispatchEvent(LocalModeEvent.PostSceneLoaded)
end

return NRCBattleTestMapMode
