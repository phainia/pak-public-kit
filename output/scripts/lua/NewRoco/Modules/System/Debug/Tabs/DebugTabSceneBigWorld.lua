local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local rapidjson = require("rapidjson")
require("Test.NRCAutoDDC")
local Base = DebugTabBase
local DebugTabSceneBigWorld = Base:Extend("DebugTabSceneBigWorld")

function DebugTabSceneBigWorld:Ctor()
  Base.Ctor(self)
end

function DebugTabSceneBigWorld:SetupTabs()
  self:Add("\231\188\150\232\190\145\229\153\168\229\156\186\230\153\175\228\184\157\230\187\145", self.SceneQuickLoad, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\233\135\141\231\189\174\230\156\172\229\156\176\230\168\161\229\188\143\229\135\186\231\148\159\231\130\185", self.ResetPlayerStartToHere, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\141\176Actors\230\149\176\233\135\143\228\191\161\230\129\175", self.ProfileLevelActorDensity, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\231\153\187\229\189\149\232\191\155\229\133\165\233\173\148\230\179\149\229\173\166\233\153\162", self.LoginToMagicAcademy, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\232\191\155\229\133\165\233\173\148\230\179\149\229\173\166\233\153\162", self.EnterMagicAcademy, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\232\191\155\229\133\165\229\164\167\228\184\150\231\149\140", self.EnterBigWorld, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\189\141\231\167\187\232\135\179\230\152\159\233\156\156\229\180\150\230\180\158", self.TransportToCave_A1_01, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\189\141\231\167\187\232\135\179\229\149\134\229\186\151\232\161\151", self.TransportToBusinessStreet, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\189\141\231\167\187\232\135\179\231\142\139\229\155\189\229\159\142\229\160\161", self.TransportToKingDownCity, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\189\141\231\167\187\232\135\179\229\189\188\229\190\151\229\164\167\233\129\147", self.TransportToPeterRoad, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\189\141\231\167\187\232\135\179\233\173\148\230\179\149\229\173\166\233\153\162", self.TransportToMagicAcademy, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\232\191\155\229\133\165\231\169\186\229\156\186\230\153\175", self.EnterNothingWorld, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\232\135\170\229\138\168\229\140\150\229\156\186\230\153\175\232\181\132\230\186\144\229\175\134\229\186\166\230\181\139\232\175\149", self.AutoDensityTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\232\180\180\229\156\176\230\181\139\232\175\149", self.LandTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\232\191\155\229\133\165\232\167\146\232\137\178\229\138\168\228\189\156\229\142\139\230\181\139\229\156\186\230\153\175", self.EnterNRCLookDevCharPerformance, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\231\171\139\229\141\179\229\138\160\232\189\189\229\137\167\230\131\133\229\133\179\229\141\161", self.LoadPlotNow, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\231\171\139\229\141\179\229\141\184\232\189\189\229\137\167\230\131\133\229\133\179\229\141\161", self.UnLoadPlotNow, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\183\187\229\138\160\229\137\167\230\131\133\229\133\179\229\141\161", self.AddPlotLevel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\231\167\187\233\153\164\229\137\167\230\131\133\229\133\179\229\141\161", self.RemovePlotLevel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
end

function DebugTabSceneBigWorld:LoadPlotNow(name, panel)
  UE4.UNRCStatics.ImmediateLoadPlotStreamingLevel("Plot_Homeworld_DerelictHouse")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:UnLoadPlotNow(name, panel)
  UE4.UNRCStatics.ImmediateRemovePlotStreamingLevel("Plot_Homeworld_DerelictHouse")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:AddPlotLevel(name, panel)
  UE4.UNRCStatics.CreatePlotStreamingLevel("Plot_Homeworld_DerelictHouse")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:RemovePlotLevel(name, panel)
  UE4.UNRCStatics.SetStreamingLevelAutoRemove("Plot_Homeworld_DerelictHouse")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:SceneQuickLoad(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "PhysicsStreaming.EditorRuntimeRecook 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.SetLayer Physics 3000 20000")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.SetLayer Landscape 10000 -1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCBlockTill.Load")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:LandTest(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:Land()
end

function DebugTabSceneBigWorld:AutoDensityTest(name, panel)
  _G.GlobalConfig.KeyPointAutoTest = true
end

function DebugTabSceneBigWorld:ResetPlayerStartToHere(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerPos = player:GetActorLocation()
  local PositionX = tostring(PlayerPos.X)
  local PositionY = tostring(PlayerPos.Y)
  local PositionZ = tostring(PlayerPos.Z)
  local BornLocationXCommand = "NRCCustomPlayerStartX " .. PositionX
  local BornLocationYCommand = "NRCCustomPlayerStartY " .. PositionY
  local BornLocationZCommand = "NRCCustomPlayerStartZ " .. PositionZ
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, BornLocationXCommand)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, BornLocationYCommand)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, BornLocationZCommand)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:ProfileLevelActorDensity(ActorType, panel)
  local value = panel.InputBox:GetText()
  local Num = UE4.UNRCStatics.ProfileLayerActorDensity(value)
  local Total = UE4.UNRCStatics.ProfileLayerActorDensity("AllActors")
  if 0 == Total then
    Log.Warning(string.format("[Asset Density] \229\189\147\229\137\141\230\128\187Actors\230\149\176\233\135\143\228\184\1860"))
  else
    Log.Debug(Num)
    Log.Debug(Total)
    local Percent = Num / Total * 100
    Log.Warning(string.format("[Asset Density] \232\181\132\228\186\167\231\177\187\229\158\139[%s]\231\154\132\230\149\176\233\135\143\228\184\186[%d], \230\128\187Actors\230\149\176\233\135\143\228\184\186[%d] \229\141\160\229\189\147\229\137\141\232\181\132\228\186\167\230\128\187\230\149\176\231\154\132\231\153\190\229\136\134\228\185\139[%f]", value, Num, Total, Percent))
  end
end

function DebugTabSceneBigWorld:LoginToMagicAcademy(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.LoadLevelPath /Game/ArtRes/Level/Game/MagicAcademy/Release/MA_Release")
end

function DebugTabSceneBigWorld:EnterMagicAcademy(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/MagicAcademy/Release/MA_Release")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:EnterNothingWorld(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/NothingWorld")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
end

function DebugTabSceneBigWorld:EnterNRCLookDevCharPerformance(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/ShowRoom/L_ShowRoom_CharPerformance")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
end

function DebugTabSceneBigWorld:EnterBigWorld(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:TransportToCave_A1_01(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(411635, 523717, 29382))
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:TransportToBusinessStreet(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(440411, 669873, 3687))
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:TransportToKingDownCity(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(589347, 609122, 3687))
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:TransportToPeterRoad(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(552509, 670766, 1411))
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:TransportToMagicAcademy(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(296302, 429460, 129479))
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:GetServerSceneAssetSvnVersionRsp(rsp)
  self:ClosePanel()
  if 0 ~= rsp.ret_info.ret_code then
    return
  end
  Log.InfoFormat("[Asset SVN version] asset_type [%d] svn info: %s", rsp.asset_type, rsp.svn_version)
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

function DebugTabSceneBigWorld:_TeleToGlobalCfgPt(cfgTableId, cfgKey, rspHandler)
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

function DebugTabSceneBigWorld:_OnTeleportRsp(rsp)
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

function DebugTabSceneBigWorld:_ShowOKMsgBox(txt)
  local dlgCtx = DialogContext()
  dlgCtx:SetContent(txt)
  dlgCtx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dlgCtx)
end

function DebugTabSceneBigWorld:NewLocalModeTeleport(posX, posY, posZ)
  local _DCM = DataConfigManager
  local teleReq = ProtoMessage.newZoneSceneGmTeleportReq()
  local bornSceneCfgId = _DCM:GetGlobalConfigByKeyType("novice_pt", _DCM.ConfigTableId.ROLE_GLOBAL_CONFIG).num
  if SceneUtils.GetSceneID() ~= bornSceneCfgId then
    teleReq.to_scene_cfg_id = bornSceneCfgId
  else
    teleReq.to_scene_cfg_id = SceneUtils.GetSceneID()
  end
  local toPos = teleReq.to_point.pos
  toPos.x = posX
  toPos.y = posY
  toPos.z = posZ
  teleReq.to_point.dir.x = 0
  teleReq.to_point.dir.y = 0
  teleReq.to_point.dir.z = 174
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, teleReq, self, rspHandler or self._OnTeleportRsp, true, true)
end

function DebugTabSceneBigWorld:LocalModeTeleportToStar(name, panel)
  self:NewLocalModeTeleport(409765, 528129, 29089)
end

function DebugTabSceneBigWorld:LocalModeTeleportToBus(name, panel)
  self:NewLocalModeTeleport(440399, 669799, 1231)
end

function DebugTabSceneBigWorld:LocalModeTeleportToSnowMountain(name, panel)
  self:NewLocalModeTeleport(398280, 548388, 47701)
end

function DebugTabSceneBigWorld:LocalModeTeleportToMagicianHome(name, panel)
  self:NewLocalModeTeleport(435167, 691032, 2389)
end

function DebugTabSceneBigWorld:LocalModeTeleportToLake(name, panel)
  self:NewLocalModeTeleport(420869, 625410, 573)
end

function DebugTabSceneBigWorld:LocalModeTeleportToMountain(name, panel)
  self:NewLocalModeTeleport(391032, 629461, 6088)
end

function DebugTabSceneBigWorld:LocalModeTeleportToPeterRoad(name, panel)
  self:NewLocalModeTeleport(563911.31, 681997.43, 3199.02)
end

function DebugTabSceneBigWorld:LocalModeTeleportToCrescentTown(name, panel)
  self:NewLocalModeTeleport(401068, 651779, 1698)
end

function DebugTabSceneBigWorld:LocalModeTeleportToKingdomCastle(name, panel)
  self:NewLocalModeTeleport(603657, 588749, 6120)
end

function DebugTabSceneBigWorld:LocalModeTeleportToKC(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(582400, 590300, 2900))
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:LocalModeCamTeleportToMT(name, panel)
  local player = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  player:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(402292, 653896, 1281))
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneBigWorld:LocalModeCamTeleportToMagic(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(0, 0, 800500))
  if panel then
    panel:DoClose()
  end
end

return DebugTabSceneBigWorld
