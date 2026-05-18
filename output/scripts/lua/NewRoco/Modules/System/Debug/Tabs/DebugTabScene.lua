local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local rapidjson = require("rapidjson")
require("Test.NRCAutoDDC")
local Base = DebugTabBase
local DebugTabScene = Base:Extend("DebugTabScene")
DebugTabScene.navBound = nil

function DebugTabScene:Ctor()
  Base.Ctor(self)
end

function DebugTabScene:SetupTabs()
  self:Add("\229\188\128\229\133\179\230\152\190\231\164\186STGArea(\229\137\175\230\156\172\228\184\173)", self.DrawSTGArea, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\133\179\229\157\160\228\186\161\229\140\186\229\159\159(\229\137\175\230\156\172\228\184\173)", self.DrawDeathArea, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\133\179\228\188\160\233\128\129\233\157\162\230\157\191", self.SwitchLoadingEnable, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabScene:BeginCloud(name, panel)
  UE4.UNRCStatics.ImmediateRemovePlotStreamingLevel("Plot_A1_Thunderclouds_After_Persistent")
  UE4.UNRCStatics.ImmediateLoadPlotStreamingLevel("Plot_A1_Thunderclouds_Before_Persistent")
end

function DebugTabScene:EndCloud(name, panel)
  UE4.UNRCStatics.ImmediateRemovePlotStreamingLevel("Plot_A1_Thunderclouds_Before_Persistent")
  UE4.UNRCStatics.ImmediateLoadPlotStreamingLevel("Plot_A1_Thunderclouds_After_Persistent")
end

function DebugTabScene:GetServerSceneAssetSvnVersion(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText or "" == inputText then
    inputText = "1"
  end
  local asset_type = tonumber(inputText)
  local req = _G.ProtoMessage:newZoneGmQuerySceneAssetSvnVersionReq()
  req.asset_type = asset_type
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
  req.pos.x = math.floor(PlayerLocation.X)
  req.pos.y = math.floor(PlayerLocation.Y)
  req.pos.z = math.floor(PlayerLocation.Z)
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_QUERY_SCENE_ASSET_SVN_VERSION_REQ, req, self, self.GetServerSceneAssetSvnVersionRsp, false, true)
end

function DebugTabScene:GetServerSceneAssetSvnVersionRsp(rsp)
  self:ClosePanel()
  if 0 ~= rsp.ret_info.ret_code then
    return
  end
  local Context = DialogContext()
  Context:SetTitle(LuaText.TIPS):SetContent(string.format([[
[Asset SVN version]: 
%s]], rsp.svn_version)):SetMode(DialogContext.Mode.NotBtn):SetCloseOnCancel(true)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  local SceneModule = self:GetModule("SceneModule")
  if not SceneModule then
    self:ShowTips("\232\191\155\230\184\184\230\136\143\230\137\141\232\131\189\231\148\168\229\147\166")
    return
  end
  local File = string.format("%s%s.json", UE4.UBlueprintPathsLibrary.ProjectContentDir(), "NewRoco/DataConfig/MapVersion")
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local Result, Success = UE4.UNRCStatics.LoadToString(File)
  if Success then
    local Client = rapidjson.decode(Result)
    Log.Dump(Client, 6, "Show Client Info")
    local FinalPayload = {}
    FinalPayload["\229\144\142\229\143\176\231\137\136\230\156\172\228\191\161\230\129\175"] = rsp
    local ID = rsp.scene_res_logic_id
    rsp.scene_res_id = ID
    for Name, Payload in pairs(Client) do
      if Payload.id == ID then
        FinalPayload[Name] = Payload
      end
    end
    self:Inspect(FinalPayload)
  else
    Log.Error("\230\151\160\230\179\149\232\142\183\229\143\150\229\174\162\230\136\183\231\171\175\230\139\191\230\149\176\230\141\174")
  end
end

function DebugTabScene:RegenerateT2D(name, panel)
  UE4.UNRCStatics.ForceGenerateTexture2DArray()
end

function DebugTabScene:EnterLevelByPath(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  Log.Debug(value)
  if "" == value then
    value = "/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release"
  end
  self.config = _G.DataConfigManager:GetSceneResConf(10002)
  self.config.source = value
  if panel then
    panel:DoClose()
  end
  NRCModeManager:ActiveMode("LocalMode")
  _G.NRCModeManager:DoCmd(SceneModuleCmd.EnterMap, 102)
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
end

function DebugTabScene:ActiveLoginMode(name, panel)
  NRCModeManager:ActiveMode("LoginMode")
end

function DebugTabScene:SwitchLevelByID(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  Log.Debug(value, tonumber(value))
  local sceneModule = NRCModuleManager:GetModule("SceneModule")
  sceneModule:RequestSwitchScene(tonumber(value))
end

function DebugTabScene:EnterBigWorld01(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:EnterUniversalClassroom(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  if _G.GlobalConfig.MemoryAutoTest then
    _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Indoor/B1/L_Indoor_B1_01.L_Indoor_B1_01")
  else
    _G.NRCModeManager:DoCmd(SceneModuleCmd.EnterMap, 117)
  end
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:EnterMagicSchool(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  if _G.GlobalConfig.MemoryAutoTest then
    _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Indoor/B1/Indoor_B1_01_LD_01Test.Indoor_B1_01_LD_01Test")
  else
    _G.NRCModeManager:DoCmd(SceneModuleCmd.EnterMap, 118)
  end
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:RealEnterMagicSchool(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(278584, 429443, 27000))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:EnterClothShop(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  if _G.GlobalConfig.MemoryAutoTest then
    _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Indoor/A1/L_Indoor_A1_02.L_Indoor_A1_02")
  else
    _G.NRCModeManager:DoCmd(SceneModuleCmd.EnterMap, 119)
  end
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:RealEnterClothShop(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(4007, 753, 420))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:EnterPropShop(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  if _G.GlobalConfig.MemoryAutoTest then
    _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Indoor/A1/L_Indoor_A1_03.L_Indoor_A1_03")
  else
    _G.NRCModeManager:DoCmd(SceneModuleCmd.EnterMap, 120)
  end
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:EnterNothingWorldLocalMode(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/NothingWorldDGM")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:LocalModeTeleportToKC(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(582400, 590300, 2900))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:EnterBigWorld01BigWorldMode(name, panel)
  NRCModuleManager:DoCmd(OnlineModuleCmd.SetUserAccountInfo, "cloudcheng", "53535353535")
  NRCModuleManager:DoCmd(OnlineModuleCmd.ConnectAndLogin, "\230\151\165\230\155\180\230\181\139\232\175\149_114_\230\150\176", 0, 0, "devgs.nrc.qq.com", 8103, "cloudcheng")
  NRCModeManager:ActiveMode("BigWorldMode")
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:EnterLevelByID(name, panel, InputText)
  if panel then
    panel:DoClose()
  end
  NRCModeManager:ActiveMode("LocalMode")
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  Log.Debug(value, tonumber(value))
  _G.NRCModeManager:DoCmd(SceneModuleCmd.EnterMap, tonumber(value))
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
end

function DebugTabScene:EnterDungeon(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.NRCModeManager:DoCmd(SceneModuleCmd.EnterMap, self:GetInputNumber(104))
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:OpenLevelByPath(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  Log.Debug(value)
  if "" == value then
    value = "/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release"
  end
  panel:DoClose()
  NRCModeManager:DeactiveMode("LoginMode")
  NRCModeManager:ActiveMode("LocalMode")
  LevelHelper:OpenLevel(value)
end

function DebugTabScene:OpenActorSequencePerformLevel(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText() or 0
  else
    value = InputText or 0
  end
  panel:DoClose()
  NRCModeManager:DeactiveMode("LoginMode")
  UE.APlayerControllerForTest.SetTestAnimationType(tonumber(value))
  LevelHelper:OpenLevel("/Game/ArtRes/Temp/zhimingcui/SkillBlueprint/SkillPrint_test")
end

function DebugTabScene:TeleporToGlobalCfgPt__ROLE_GLOBAL_CONFIG__special_role_born_point(name, panel)
  local _DCM = DataConfigManager
  self:_TeleToGlobalCfgPt(_DCM.ConfigTableId.ROLE_GLOBAL_CONFIG, "special_role_born_point")
end

function DebugTabScene:_TeleToGlobalCfgPt(cfgTableId, cfgKey, rspHandler)
  local _DCM = DataConfigManager
  local ptList = _DCM:GetGlobalConfigByKeyType(cfgKey, cfgTableId).numList
  local ptListCnt = #ptList
  if ptListCnt < 3 then
    Log.DebugFormat("Invalid config: %s.%s, cfgCnt:%s, ptListCnt:%s", cfgTableId, cfgKey, ptListCnt)
    return
  end
  local teleReq = ProtoMessage.newZoneSceneGmTeleportReq()
  local bornSceneCfgId = _DCM:GetGlobalConfigByKeyType("novice_pt", _DCM.ConfigTableId.ROLE_GLOBAL_CONFIG).num
  if SceneUtils.GetSceneID() ~= bornSceneCfgId then
    teleReq.to_scene_cfg_id = bornSceneCfgId
  else
    teleReq.to_scene_cfg_id = SceneUtils.GetSceneID()
  end
  local toPos = teleReq.to_point.pos
  toPos.x = ptList[1]
  toPos.y = ptList[2]
  toPos.z = ptList[3]
  if ptListCnt >= 6 then
    teleReq.to_point.dir.x = ptList[4]
    teleReq.to_point.dir.y = ptList[5]
    teleReq.to_point.dir.z = ptList[6]
  end
  Log.DebugFormat("Teleport to config spec point, " .. "cfg:%s.%s, toPos:(%s,%s,%s), toDir:(%s,%s,%s)", cfgTableId, cfgKey, toPos.x, toPos.y, toPos.x, teleReq.to_point.dir.x, teleReq.to_point.dir.y, teleReq.to_point.dir.z)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, teleReq, self, rspHandler or self._OnTeleportRsp, true, true)
end

function DebugTabScene:_OnTeleportRsp(rsp)
  self:ClosePanel()
  local retCode = rsp.ret_info.ret_code
  if 0 ~= retCode then
    Log.Error("Teleport failed")
    local promptTxt = string.format("\228\188\160\233\128\129\229\164\177\232\180\165, \233\148\153\232\175\175\231\160\129:%s", retCode)
    self:_ShowOKMsgBox(promptTxt)
    return
  end
  Log.Debug("Teleport succeed!")
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLoc = player.viewObj:Abs_K2_GetActorLocation()
  local promptTxt = string.format("\228\188\160\233\128\129\230\136\144\229\138\159\n\229\156\186\230\153\175:%d\n\228\189\141\231\189\174:(%.0f, %.0f, %.0f)", SceneUtils.GetSceneID(), playerLoc.X, playerLoc.Y, playerLoc.Z)
  UE4.UNRCStatics.ClipboardCopy(string.format("(X=%.0f,Y=%.0f,Z=%.0f)", playerLoc.X, playerLoc.Y, playerLoc.Z))
  self:_ShowOKMsgBox(promptTxt)
end

function DebugTabScene:EnterMagicLevel(Name, Panel)
  local Target = self:GetNearestNpc()
  if not Target.TestAction then
    local NPCActionLearnMagic = require("NewRoco.Modules.Core.NPC.Actions.NPCActionLearnMagic")
    local Key, Option = next(Target.InteractionComponent._options)
    local Action = NPCActionLearnMagic(Option, nil, Option.optionInfo)
    Target.TestAction = Action
  end
  Target.TestAction:GoLearnMagicLevel()
  self:ClosePanel()
end

function DebugTabScene:LeaveMagicLevel(Name, Panel)
  local Target = self:GetNearestNpc()
  Target.TestAction:LeaveLearnMagicLevel()
  self:ClosePanel()
end

function DebugTabScene:_ShowOKMsgBox(txt)
  local dlgCtx = DialogContext()
  dlgCtx:SetContent(txt)
  dlgCtx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dlgCtx)
end

function DebugTabScene:CloseAllAirWall(Name, Panel)
  local AirWallClass = _G.NRCResourceManager:LoadForDebugOnly("/Game/NewRoco/Modules/System/WorldCombat/AirWalls/BP_AirWall_Gen.BP_AirWall_Gen")
  local Array = UE.TArray(UE.AActor)
  UE.UGameplayStatics.GetAllActorsOfClass(_G.UE4Helper.GetCurrentWorld(), AirWallClass, Array)
  for Index, Actor in tpairs(Array) do
    Actor:SetActorEnableCollision(false)
    Actor:SetActorHiddenInGame(true)
    Log.ErrorFormat("\229\133\179\233\151\173\231\169\186\230\176\148\229\162\153", UE.UObject.GetName(Actor))
  end
end

function DebugTabScene:IfShowLoction(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowPlayerLoction, false)
end

function DebugTabScene:OpenServerDebugDraw(Name, Panel, InputText)
  local inputText
  if Panel then
    inputText = Panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_DEBUG_DRAW
  req.param1 = tonumber(inputText)
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, false)
end

function DebugTabScene:DrawNpcRefreshPoints(Name, Panel, InputText)
  local inputText
  if Panel then
    inputText = Panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_DEBUG_DRAW_NPC_REFRESH_POINS
  req.param1 = tonumber(inputText)
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, false)
end

function DebugTabScene:DrawNearestNavMesh(Name, Panel, InputText)
  local playerModule = self:GetModule("PlayerModule")
  local localPlayer = playerModule:GetLocalPlayer()
  local inputText
  if Panel then
    inputText = Panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local args = string.split(inputText, ";")
  local posVecsLen = #args
  local player_pos = localPlayer.viewObj:Abs_K2_GetActorLocation()
  local pos = UE4.FIntVector(math.ceil(player_pos.X), math.ceil(player_pos.Y), math.ceil(player_pos.Z))
  local extent = UE4.FIntVector(1000, 1000, 1000)
  local layer = 0
  if posVecsLen >= 1 and "" ~= args[1] then
    layer = tonumber(args[1])
  end
  if posVecsLen >= 2 and "" ~= args[2] then
    local posVecs = string.split(args[2], ",")
    if 3 == #posVecs then
      pos = UE4.FIntVector(tonumber(posVecs[1]), tonumber(posVecs[2]), tonumber(posVecs[3]))
    else
      Log.Error("arg1 is pos need x,y,z")
    end
  end
  if posVecsLen >= 3 and "" ~= args[3] then
    local extentVecs = string.split(args[3], ",")
    if 3 == #extentVecs then
      extent = UE4.FIntVector(tonumber(extentVecs[1]), tonumber(extentVecs[2]), tonumber(extentVecs[3]))
    else
      Log.Error("arg2 is extent need x,y,z")
    end
  end
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_DEBUG_SHOW_NAV_TILE
  req.gm_op_type = ProtoEnum.SceneGmOpType.SGOT_QUERY
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.param1 = 0
  req.param2 = 0
  req.rpt_params = {
    pos.X,
    pos.Y,
    pos.Z,
    extent.X,
    extent.Y,
    extent.Z,
    layer
  }
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, false)
end

function DebugTabScene:RaycastTest(Name, Panel, InputText)
  local playerModule = self:GetModule("PlayerModule")
  local localPlayer = playerModule:GetLocalPlayer()
  local inputText
  if Panel then
    inputText = Panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local args = string.split(inputText, ";")
  local posVecsLen = #args
  local player_pos = localPlayer.viewObj:Abs_K2_GetActorLocation()
  local pos = UE4.FIntVector(math.ceil(player_pos.X), math.ceil(player_pos.Y), math.ceil(player_pos.Z))
  local dir = UE4.FIntVector(0, 0, -1)
  local dist = 1000
  if posVecsLen >= 1 and "" ~= args[1] then
    local posVecs = string.split(args[1], ",")
    if 3 == #posVecs then
      pos = UE4.FIntVector(tonumber(posVecs[1]), tonumber(posVecs[2]), tonumber(posVecs[3]))
    else
      Log.Error("arg1 is pos need x,y,z")
    end
  end
  if posVecsLen >= 2 and "" ~= args[2] then
    local dirVecs = string.split(args[2], ",")
    if 3 == #dirVecs then
      dir = UE4.FIntVector(tonumber(dirVecs[1]), tonumber(dirVecs[2]), tonumber(dirVecs[3]))
    else
      Log.Error("arg2 is dir need x,y,z")
    end
  end
  if posVecsLen >= 3 and "" ~= args[3] then
    dist = tonumber(args[3])
  end
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_DEBUG_RAYCAST
  req.gm_op_type = ProtoEnum.SceneGmOpType.SGOT_QUERY
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.param1 = 0
  req.param2 = 0
  req.rpt_params = {
    pos.X,
    pos.Y,
    pos.Z,
    dir.X,
    dir.Y,
    dir.Z,
    dist
  }
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, false)
end

function DebugTabScene:OverlapTest(Name, Panel, InputText)
  local playerModule = self:GetModule("PlayerModule")
  local localPlayer = playerModule:GetLocalPlayer()
  local inputText
  if Panel then
    inputText = Panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local args = string.split(inputText, ";")
  local posVecsLen = #args
  local player_pos = localPlayer.viewObj:Abs_K2_GetActorLocation()
  local pos = UE4.FIntVector(math.ceil(player_pos.X), math.ceil(player_pos.Y), math.ceil(player_pos.Z))
  local extent = UE4.FIntVector(400, 400, 400)
  if posVecsLen >= 1 and "" ~= args[1] then
    local posVecs = string.split(args[1], ",")
    if 3 == #posVecs then
      pos = UE4.FIntVector(tonumber(posVecs[1]), tonumber(posVecs[2]), tonumber(posVecs[3]))
    else
      Log.Error("arg1 is pos need x,y,z")
    end
  end
  if posVecsLen >= 2 and "" ~= args[2] then
    local extentVecs = string.split(args[2], ",")
    if 3 == #extentVecs then
      extent = UE4.FIntVector(tonumber(extentVecs[1]), tonumber(extentVecs[2]), tonumber(extentVecs[3]))
    else
      Log.Error("arg2 is extent need x,y,z")
    end
  end
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_DEBUG_OVERLAP
  req.gm_op_type = ProtoEnum.SceneGmOpType.SGOT_QUERY
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.param1 = 0
  req.param2 = 0
  req.rpt_params = {
    pos.X,
    pos.Y,
    pos.Z,
    extent.X,
    extent.Y,
    extent.Z
  }
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, false)
end

function DebugTabScene:DrawSceneBoundBox(Name, Panel)
  if DebugTabScene.navBound == nil or not UE.UObject.IsValid(DebugTabScene.navBound) then
    local playerModule = self:GetModule("PlayerModule")
    local localPlayer = playerModule:GetLocalPlayer()
    local player_pos = localPlayer.viewObj:Abs_K2_GetActorLocation()
    local req = _G.ProtoMessage:newZoneGmShowNavBoundReq()
    req.avatar_pos.x = math.floor(player_pos.X)
    req.avatar_pos.y = math.floor(player_pos.Y)
    req.avatar_pos.z = math.floor(player_pos.Z)
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SHOW_NAV_BOUND_REQ, req, self, self.ShowNavBoundRsp, false, true)
  else
    DebugTabScene.navBound:K2_DestroyActor()
    DebugTabScene.navBound = nil
  end
end

function DebugTabScene:ShowNavBoundRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    return
  end
  local NavBoundClass = UE4.UClass.Load("/Game/ArtRes/BP/Scene/NPC_NavBound/BoundBox.BoundBox")
  DebugTabScene.navBound = UE4Helper.GetCurrentWorld():Abs_SpawnActor(NavBoundClass, UE4.FTransform(UE4.FQuat(), UE4.FVector(rsp.pos.x, rsp.pos.y, rsp.pos.z)))
  DebugTabScene.navBound:SetActorScale3D(UE4.FVector((rsp.extent.x + 10) / 250.0, (rsp.extent.y + 10) / 250.0, (rsp.extent.z + 10) / 250.0))
end

function DebugTabScene:ShowWorldOffset(Name, Panel)
  local World = _G.UE4Helper.GetCurrentWorld()
  local X = World:GetWorldOriginX()
  local Y = World:GetWorldOriginY()
  local Z = World:GetWorldOriginZ()
  self:Inspect({
    X = X,
    Y = Y,
    Z = Z
  }, "World Offset")
end

function DebugTabScene:CollectFoliageProfile(name, panel)
  UE4.UNRCStatics.KeyPositionFoliageProfile()
end

function DebugTabScene:CollectRockProfile(name, panel)
  UE4.UNRCStatics.KeyPositionRockProfile()
end

function DebugTabScene:FreezeLands(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeLands 1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeBuildings 1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeSmallThings 1")
end

function DebugTabScene:UnFreezeLands(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeLands 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeBuildings 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeSmallThings 0")
end

function DebugTabScene:FreezeNotLandAndHLOD(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeNotLand 1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeHLOD 1")
end

function DebugTabScene:FreeRenderTargetPool(name, panel)
  UE4.UNRCStatics.ReleaseUnuseSlateRenderResource()
end

function DebugTabScene:LocalModeCamTeleportToMT(name, panel)
  local player = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  player:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(402292, 653896, 1281))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:LocalModeCamTeleportToBus(name, panel)
  local player = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  player:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(440399, 669799, 1331))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:LocalModeCamTeleportToKingdom(name, panel)
  local player = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  player:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(603657, 588749, 6320))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:LocalModeCamTeleportToMaze(name, panel)
  local player = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  player:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(641025.8, 455987.4, 20278.3))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:LocalModeCamTeleportToGardon(name, panel)
  local player = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  player:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(628186.0, 527455.0, 1789.6))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:LocalModeCamTeleportToZero(name, panel)
  local player = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  player:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(0, 0, 450))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:TryToUnloadFirst(name, panel)
  UE4.UNRCStatics.ChangeLevelStreamingMode(1)
end

function DebugTabScene:LoginToNothingWorld()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCStatics.LoadLevelName NothingWorld")
end

function DebugTabScene:ProfileWorldActors()
  UE4.UNRCStatics.ProfileLevelActorDensity()
end

function DebugTabScene:LocalModeCamTeleportToMagic(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(0, 0, 800500))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:BornAtBus(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCustomPlayerStartX 440399")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCustomPlayerStartY 669799")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCustomPlayerStartZ 1331")
end

function DebugTabScene:BornAtKC(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCustomPlayerStartX 603657")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCustomPlayerStartY 588749")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCustomPlayerStartZ 6120")
end

function DebugTabScene:BornAtPR(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCustomPlayerStartX 399744")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCustomPlayerStartY 612192")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCustomPlayerStartZ 5575")
end

function DebugTabScene:EnterUITest(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  local levelPath = "/Game/NewRoco/Modules/System/TUI/Res/SubUMGTestMap.SubUMGTestMap"
  _G.LevelHelper:OpenLevel(levelPath)
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:AutoRunDDC(name, panel)
  NRCAutoDDC.AutoRun()
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:AutoRunWalkMap(name, panel)
  NRCAutoDDC.AutoMoveAnywhere()
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:AutoRunScanNPC(name, panel)
  NRCAutoDDC.ScanNPC()
  if panel then
    panel:DoClose()
  end
end

function DebugTabScene:AutoRunScanLevel(name, panel)
  NRCAutoDDC.ScanLevel()
  if panel then
    panel:DoClose()
  end
end

local bDrawSTGArea = false
local bDrawDeathArea = false
local DrawSTGColor = UE.FLinearColor(0.1, 0.8, 0.2, 1.0)

function DebugTabScene:DrawSTGArea(name, panel)
  bDrawSTGArea = not bDrawSTGArea
  local World = _G.UE4Helper.GetCurrentWorld()
  if bDrawSTGArea then
    local CurSceneID = SceneUtils.GetSceneID()
    local CurDungeonID
    local DungeonConfData = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.DUNGEON_CONF):GetAllDatas()
    for _, DungeonConf in pairs(DungeonConfData) do
      if DungeonConf.scene_id == CurSceneID then
        CurDungeonID = DungeonConf.id
        break
      end
    end
    local STGAreaConfIDs = {}
    local DungeonSTGConfData = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.DUNGEON_STAGE):GetAllDatas()
    for _, DungeonSTGConf in pairs(DungeonSTGConfData) do
      if DungeonSTGConf.dungeon_id == CurDungeonID and DungeonSTGConf.start_condition.type == _G.Enum.StageConditionType.STG_AREA then
        for _, AreaID in ipairs(DungeonSTGConf.start_condition.data1) do
          table.insert(STGAreaConfIDs, AreaID)
        end
      end
    end
    for _, STGAreaConfID in ipairs(STGAreaConfIDs) do
      local MinZ, MaxZ = math.maxinteger, math.mininteger
      local STGAreaConf = _G.DataConfigManager:GetAreaConf(STGAreaConfID)
      local AreaHeight = STGAreaConf.area_height
      AreaHeight = math.max(50, AreaHeight)
      local WorldOriginX = World:GetWorldOriginX()
      local WorldOriginY = World:GetWorldOriginY()
      local WorldOriginZ = World:GetWorldOriginZ()
      local Center = STGAreaConf.center_xyz
      local DebugString = tostring(STGAreaConf.id) .. " " .. table.concat(STGAreaConf.editor_name, "/")
      UE.UKismetSystemLibrary.DrawDebugString(World, UE.FVector(Center[1] - WorldOriginX, Center[2] - WorldOriginY, Center[3] - WorldOriginZ), DebugString, nil, DrawSTGColor, 9999)
      for index, Pos in ipairs(STGAreaConf.pos) do
        local Location = Pos.position_xyz
        if 3 ~= #Location then
        else
          MaxZ = math.max(Location[3], MaxZ)
          MinZ = math.min(Location[3], MinZ)
          local NextIndex = index % #STGAreaConf.pos + 1
          local NextLocation = STGAreaConf.pos[NextIndex].position_xyz
          local StartX = Location[1] - WorldOriginX
          local StartY = Location[2] - WorldOriginY
          local StartZ = Location[3] - WorldOriginZ
          local EndX = NextLocation[1] - WorldOriginX
          local EndY = NextLocation[2] - WorldOriginY
          local EndZ = NextLocation[3] - WorldOriginZ
          UE.UKismetSystemLibrary.DrawDebugLine(World, UE.FVector(StartX, StartY, StartZ), UE.FVector(EndX, EndY, EndZ), DrawSTGColor, 9999, 10)
          if 0 ~= AreaHeight then
            local HeightOffsetStart = UE.FVector(Location[1], Location[2], Location[3]) + UE.FVector(AreaHeight)
            local HeightOffsetEnd = UE.FVector(NextLocation[1], NextLocation[2], NextLocation[3]) + UE.FVector(AreaHeight)
            local HeightOffsetStartX = HeightOffsetStart.X - WorldOriginX
            local HeightOffsetStartY = HeightOffsetStart.Y - WorldOriginY
            local HeightOffsetStartZ = HeightOffsetStart.Z - WorldOriginZ
            local HeightOffsetEndX = HeightOffsetEnd.X - WorldOriginX
            local HeightOffsetEndY = HeightOffsetEnd.Y - WorldOriginY
            local HeightOffsetEndZ = HeightOffsetEnd.Z - WorldOriginZ
            UE.UKismetSystemLibrary.DrawDebugLine(World, UE.FVector(StartX, StartY, StartZ), UE.FVector(HeightOffsetStartX, HeightOffsetStartY, HeightOffsetStartZ), DrawSTGColor, 9999, 10)
            UE.UKismetSystemLibrary.DrawDebugLine(World, UE.FVector(HeightOffsetStartX, HeightOffsetStartY, HeightOffsetStartZ), UE.FVector(HeightOffsetEndX, HeightOffsetEndY, HeightOffsetEndZ), DrawSTGColor, 9999, 10)
          end
        end
      end
    end
  else
    UE.UKismetSystemLibrary.FlushDebugStrings(World)
    UE.UKismetSystemLibrary.FlushPersistentDebugLines(World)
    if bDrawDeathArea then
      bDrawDeathArea = false
      self:DrawDeathArea(name, panel)
    end
  end
end

local DrawDeathAreaColor = UE.FLinearColor(1, 0, 0, 1.0)

function DebugTabScene:DrawDeathArea(name, panel)
  local World = _G.UE4Helper.GetCurrentWorld()
  bDrawDeathArea = not bDrawDeathArea
  if bDrawDeathArea then
    local DeathAreaBPClass = UE4.UClass.Load("/Game/NewRoco/Modules/Core/Scene/BP_StaticDeathArea.BP_StaticDeathArea_C")
    if not DeathAreaBPClass then
      Log.Warning("\229\137\175\230\156\172\229\157\160\228\186\161\229\140\186\229\159\159\231\154\132BP\232\183\175\229\190\132\230\156\137\233\151\174\233\162\152")
      return
    end
    local DeathAreas = UE4.UGameplayStatics.GetAllActorsOfClass(World, DeathAreaBPClass)
    for _, DeathArea in tpairs(DeathAreas) do
      local BoxComp = DeathArea.DeathAreaBox
      local Center = BoxComp:K2_GetComponentLocation()
      local BoxExtent = BoxComp:GetScaledBoxExtent()
      local Rotation = BoxComp:K2_GetComponentRotation()
      UE.UKismetSystemLibrary.DrawDebugBox(World, Center, BoxExtent, DrawDeathAreaColor, Rotation, 9999, 100)
      UE.UKismetSystemLibrary.DrawDebugString(World, Center, DeathArea:GetName(), nil, DrawDeathAreaColor, 999)
    end
  else
    UE.UKismetSystemLibrary.FlushDebugStrings(World)
    UE.UKismetSystemLibrary.FlushPersistentDebugLines(World)
    if bDrawSTGArea then
      bDrawSTGArea = false
      self:DrawSTGArea(name, panel)
    end
  end
end

function DebugTabScene:SwitchLoadingEnable(name, panel)
  _G.GlobalConfig.SetFastLoadingWorldRendering = not _G.GlobalConfig.SetFastLoadingWorldRendering
  if _G.GlobalConfig.SetFastLoadingWorldRendering then
    Log.Warning("\229\188\128\229\144\175\228\186\134\229\138\160\232\189\189UI")
  else
    Log.Warning("\229\133\179\233\151\173\228\186\134\229\138\160\232\189\189UI")
  end
end

return DebugTabScene
