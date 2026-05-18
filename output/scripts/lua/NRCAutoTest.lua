local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local JsonUtils = require("Common.JsonUtils")
NRCAutoTestModule = {}

function NRCAutoTestModule.AvatarMergeTestStart(count)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd TestAvatar Start " .. count, localPlayer:GetUEController())
end

function NRCAutoTestModule.AvatarMergeTestPause()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd TestAvatar pause ", localPlayer:GetUEController())
end

function NRCAutoTestModule.AvatarMergeTestResume()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd TestAvatar resume ", localPlayer:GetUEController())
end

function NRCAutoTestModule.GetMemoryPoolCacheSize()
  local MemoryPoolCache = UE4.UNRCStatics.GetMemoryPoolCacheSize()
  Log.DebugFormat("MemoryPoolCacheSize = %dMB", MemoryPoolCache)
  return MemoryPoolCache
end

function NRCAutoTestModule.DumpLuaObjectInfos()
  local mcw = require("Debug.MemoryCheckWrapper")
  mcw:DumpCurrMemorySnapshotWithGC()
  _G.SnapshotNum = _G.SnapshotNum + 1
  collectgarbage("collect")
end

function NRCAutoTestModule.StartMoveRecord()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  playerModule.movementRecorder:StartRecord()
end

function NRCAutoTestModule.StopMoveRecord()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  playerModule.movementRecorder:StopRecord()
end

function NRCAutoTestModule.StartMainPlayerAutoMove()
  local debugModule = NRCModuleManager:GetModule("DebugModule")
  debugModule:StartMainPlayerAutoMove()
end

function NRCAutoTestModule.EnterTextInLogin(Text)
  NRCEventCenter:DispatchEvent(LoginModuleEvent.AutoTestEnterText, Text)
end

function NRCAutoTestModule.SetEnableTeleport()
  GlobalConfig.EnableDeahTeleport = not GlobalConfig.EnableDeahTeleport
  Log.Debug("EnableDeathTeleport=", GlobalConfig.EnableDeahTeleport)
end

function NRCAutoTestModule.ChangeTime(value)
  local time = value or 0
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, time)
end

function NRCAutoTestModule.ChangeTimeScale(value)
  local scale = value or 0
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, scale)
end

function NRCAutoTestModule.GetPlayerUin()
  return _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
end

function initModuleEnv(envTable, inModuleDotPath)
  envTable.__module_define__ = true
  envTable.__module_writable__ = true
  envTable.__module_path__ = inModuleDotPath
  envTable.__sub_module_pure_names__ = {}
  envTable.__all_fields__ = {}
  
  function envTable.Ref(prop)
    envTable.__all_fields__[prop] = prop
  end
  
  local modObjMT = {
    __index = {},
    __newindex = {}
  }
  return setmetatable(envTable, modObjMT)
end

function error_handler(err)
  local extMsg = ""
  extMsg = "[Error]" .. tostring(extMsg)
  if err then
    extMsg = extMsg .. "\n" .. tostring(err)
  end
  extMsg = extMsg .. "\n" .. debug.traceback()
  UE4.UNRCPlatformGameInstance.GetInstance():ReportLuaErrorMsg(extMsg)
  return extMsg
end

function NRCAutoTestModule.DoString(chunkStr)
  local func, err = load(chunkStr, "ChunkDoString", "bt")
  local _bOK, _rt = xpcall(func, error_handler)
  if not _bOK then
    Log.Error("[NRCEnv][NRCEditorEntrance]ChunkDoString xpcall error!!!!!!! " .. (_rt or ""))
    return
  end
  return _rt
end

function NRCAutoTestModule.StartAutoPlayBattleRecords(recordsFileName)
  BattleAutoTest:StartAutoPlayBattleRecords(recordsFileName)
end

function NRCAutoTestModule.StartAutoBattle()
  BattleAutoTest:StartAutoBattle()
end

function NRCAutoTestModule.GetIsInAutoBattle()
  if BattleAutoTest.IsAutoBattle then
    return "1"
  else
    return "0"
  end
end

function NRCAutoTestModule.GetIsInBattle()
  if BattleAutoTest.IsStartBattle then
    return "1"
  else
    return "0"
  end
end

function NRCAutoTestModule.GetAutoBattleLogFilePath()
  return BattleAutoTest.LogFilePath
end

function NRCAutoTestModule.GetBattleFailNumber()
  return tostring(BattleAutoTest.failNumber)
end

function NRCAutoTestModule.BreakAutoBattle()
  BattleAutoTest:AddFailNumber()
  Log.Warning("\232\135\170\229\138\168\229\140\150\230\136\152\230\150\151\230\181\139\232\175\149\228\184\173, error \230\151\165\229\191\151\230\149\176\231\155\174\232\182\133\229\135\186\233\153\144\229\136\182")
end

function NRCAutoTestModule.ServerUnlockNPC(npc_refresh_cfg_id)
  local req = ProtoMessage:newZoneGmUnlockWorldMapStaticNpcReq()
  req.npc_refresh_cfg_id = npc_refresh_cfg_id
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_UNLOCK_WORLD_MAP_STATIC_NPC_REQ, req, nil, function()
  end)
end

function NRCAutoTestModule.EnterBigWorldLocalMode()
  NRCModeManager:ActiveMode("LocalMode")
  if _G.GlobalConfig.MemoryAutoTest then
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "n.CustomGameModePath /Game/Game/NRC/GameMode/AutoTest/DefaultGM.DefaultGM_C")
    _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release")
  else
    _G.NRCModeManager:DoCmd(SceneModuleCmd.EnterMap, 103)
  end
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
end

function NRCAutoTestModule.EnterNothingWorldLocalMode()
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/NothingWorldDGM")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
end

function NRCAutoTestModule.GetPerformanceTestOver()
  local RSPTable = require("Common.LocalServer.LocalBattleRSPTable")
  return RSPTable.AutoTestOver
end

function NRCAutoTestModule.MoveToLocation(targetPos)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerPos = localPlayer:GetActorLocation()
  local currentLocation = SceneUtils.GetPosInNearLand(playerPos) or playerPos
  currentLocation = SceneUtils.ConvertAbsoluteToRelative(currentLocation)
  targetPos = SceneUtils.ConvertAbsoluteToRelative(targetPos)
  UE4.UNRCNavLibrary.MoveToLocationForce(localPlayer.viewObj, localPlayer:GetUEController(), currentLocation, targetPos, -1, true, true)
end

function NRCAutoTestModule.SpawnNPC(num)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.NPCPressureComponent:SpawnNPC(num)
end

function NRCAutoTestModule.SpawnPet(num)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.NPCPressureComponent:SpawnPet(num)
end

function NRCAutoTestModule.PreLoadNPCTable()
  DataConfigManager:GetTable(119)
  DataConfigManager:GetTable(107)
  DataConfigManager:GetTable(142)
  DataConfigManager:GetTable(140)
  DataConfigManager:GetTable(209)
  DataConfigManager:GetTable(126)
  DataConfigManager:GetTable(174)
end

function NRCAutoTestModule.StartUpdateLocalProtocol()
  local tab = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBattle")
  tab:UpdateLocalProtocol()
end

function NRCAutoTestModule.StartSkillPerformAutoBattle()
  local tab = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBattle")
  tab:AutoPerformBattle()
end

function NRCAutoTestModule.AutomationStartSkillPerformAutoBattle_FxPerfTool()
  local LoginModule = NRCModuleManager:GetModule("LoginModule")
  local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
  if not LoginModule then
    return false
  end
  local Panel = LoginModule:GetPanel(LoginEnum.PanelNames.NRCLoginPanel)
  if not Panel then
    return false
  end
  local defaultServerList = JsonUtils.LoadDefaultServerList({})
  if defaultServerList then
    for index, server in ipairs(defaultServerList) do
      if 18 == server.id then
        Panel.data:SetServer(server)
        break
      end
    end
  end
  NRCAutoTestModule.StartSkillPerformAutoBattle()
  return true
end

function NRCAutoTestModule.GetIsUpdateLocalProtocolFinished()
  return ProtoRecorder.IsFinished
end

function NRCAutoTestModule.GetIsSkillPerformAutoBattleStarted()
  local SkillPerformAutoBattle = require("Common.LocalServer.SkillPerformAutoBattle")
  return SkillPerformAutoBattle.isStarted
end

function NRCAutoTestModule.GetIsSkillPerformAutoBattleFinished()
  local SkillPerformAutoBattle = require("Common.LocalServer.SkillPerformAutoBattle")
  return SkillPerformAutoBattle.isFinished
end

function NRCAutoTestModule.GetSequenceConf()
  local Raw = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SEQUENCE_CONF):GetAllDatas()
  return JsonUtils.EncodeTable(Raw)
end

function NRCAutoTestModule.IsSequencePlaying()
  return _G.NRCModuleManager:DoCmd(_G.CinematicModuleCmd.IsPlaying)
end

function NRCAutoTestModule.LoginToMagicAcademy()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.LoadLevelPath /Game/ArtRes/Level/Game/MagicAcademy/Release/MA_Release")
end

function NRCAutoTestModule.ProfileLayerActorDensity(StreamingLayer)
  return UE4.UNRCStatics.ProfileLayerActorDensity(StreamingLayer)
end

function NRCAutoTestModule.LocalEnterBigWorld()
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
end

function NRCAutoTestModule.LocalEnterMagicAcademy()
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/MagicAcademy/Release/MA_Release")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
end

function NRCAutoTestModule.PureSceneTeleport(X, Y, Z)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeAllLevels 0")
  local ValueX = tostring(X)
  local ValueY = tostring(Y)
  local ValueZ = tostring(Z)
  local TeleportCommand = "NRCTransport " .. ValueX .. " " .. ValueY .. " " .. ValueZ
  Log.Warning(TeleportCommand)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, TeleportCommand)
end

return NRCAutoTestModule
