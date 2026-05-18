local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local rapidjson = require("rapidjson")
local BigMapModuleEvent = reload("NewRoco.Modules.System.BigMap.BigMapModuleEvent")
require("Test.NRCAutoDDC")
local Base = DebugTabBase
local DebugTabScenePublic = Base:Extend("DebugTabScenePublic")

function DebugTabScenePublic:Ctor()
  Base.Ctor(self)
end

local SegmentationFlag = false
local SegmentationWallFlag = false
local actor
local IsWaitMapMark = false
local Trace

function DebugTabScenePublic:SetupTabs()
  self:Add("\228\184\128\233\148\174\230\151\160\230\149\140", self.WuDi, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149\231\173\150\229\136\146", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\184\128\233\148\174\232\167\163\233\148\129\232\184\170\232\191\185", self.UnlockPetTrace, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149\231\173\150\229\136\146", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\188\128\229\133\179\231\189\151\231\155\152\230\132\159\229\186\148Debug", self.SwitchCompassSenseDebug, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "SwitchCompassSenseDebug")
  self:Add("\230\159\165\231\156\139\228\188\160\233\128\129\232\144\189\231\130\185\228\189\141\231\189\174", self.FindGroundPoint, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\229\136\134\229\137\178 103 \229\164\167\228\184\150\231\149\140\229\156\186\230\153\175\229\156\176\229\155\190", self.Segmentation103World, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\229\136\134\229\137\178 103 \229\164\167\228\184\150\231\149\140\229\156\186\230\153\175\231\169\186\230\176\148\229\162\153", self.Segmentation103WorldWall, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\229\188\128\229\144\175\232\182\138\231\149\140\233\135\141\231\148\159\230\163\128\230\181\139\239\188\136\229\144\142\229\143\176\239\188\137", self.OpenPlayerCheckPosDead, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\229\188\128\229\144\1753C\230\163\128\230\181\139\230\143\144\231\164\186\239\188\136\229\144\142\229\143\176\239\188\137", self.OpenPlayer3CCheckTips, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\232\191\155\229\133\165\232\167\146\232\137\178\230\159\165\231\156\139\229\153\168", self.EnterCharacterViewer, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\228\184\128\233\148\174\229\162\158\229\138\160\233\154\143\230\156\186\229\184\184\232\167\132\230\160\135\232\174\176\231\130\18550\228\184\170", self.AddRandomMarkPoint, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\228\184\128\233\148\174\229\136\160\233\153\164\233\154\143\230\156\186\229\184\184\232\167\132\230\160\135\232\174\176\231\130\18550\228\184\170", self.ReduceRandomMarkPoint, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\228\184\128\233\148\174\230\191\128\230\180\187\229\156\176\229\155\190 icon", self.OneKeyActiveMapIcons, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\230\152\190\231\164\186\230\151\182\233\151\180", self.ShowTimeAndWeather, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\159\165\231\156\139\231\149\153\231\151\149\230\160\188\229\173\144\232\140\131\229\155\180", self.ShowTraceScope, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\229\133\179\233\151\173\231\149\153\231\151\149\230\160\188\229\173\144\232\140\131\229\155\180", self.CloseTraceScope, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\230\152\190\231\164\186\229\156\176\229\159\142\229\189\147\229\137\141\233\152\182\230\174\181", self.ShowDungeonStageInfo, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\229\188\128\229\133\179\233\157\153\230\128\129\229\133\137\231\142\175\230\152\190\231\164\186", self.ShowAura, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\230\152\190\231\164\186\229\143\175\230\148\128\231\136\172\231\137\169(\230\143\143\232\190\185)", self.HighlightClimbableObjectsWithCustomDepthStencil, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
  self:Add("\230\152\190\231\164\186\229\143\175\230\148\128\231\136\172\231\137\169(\230\157\144\232\180\168)", self.HighlightClimbableObjectsWithMaterial, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\229\136\171\233\156\128\232\166\129", nil, "", "")
end

function DebugTabScenePublic:GetServerSceneAssetSvnVersionRsp(rsp)
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

function DebugTabScenePublic:EnterUniversalClassroom(name, panel)
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

function DebugTabScenePublic:EnterMagicSchool(name, panel)
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

function DebugTabScenePublic:RealEnterMagicSchool(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(278584, 429443, 27000))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScenePublic:EnterClothShop(name, panel)
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

function DebugTabScenePublic:RealEnterClothShop(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(4007, 753, 420))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScenePublic:EnterPropShop(name, panel)
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

function DebugTabScenePublic:LocalModeTeleport(name, panel)
  local inputText = string.gsub(self:GetInputString(), "^%s*(.-)%s*$", "%1")
  if "" == inputText then
    inputText = UE4.UNRCStatics.ClipboardPaste()
  end
  if string.IsNilOrEmpty(inputText) then
    Log.Warning("Please input teleport target")
    return
  end
  local result = self:ParseTeleportInput(inputText)
  if nil == result or nil == result.coords then
    Log.Warning("Please input three number vector")
    return
  end
  if PlayerModuleCmd then
    local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    player:SetActorLocation(UE4.FVector(result.coords.x, result.coords.y, result.coords.z))
  else
    Log.Error("PlayerModuleCmd Not Found")
  end
  if panel then
    panel:DoClose()
  end
end

function DebugTabScenePublic:LocalModeTeleportToKC(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(582400, 590300, 2900))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScenePublic:ParseTeleportInput(str)
  local scene_id, x, y, z, yaw
  x, y, z, yaw = str:match("^(%-?%d+%.?%d*)[ ,](%-?%d+%.?%d*)[ ,](%-?%d*%.?%d*)[ ,]?(%-?%d*%.?%d*)")
  if nil ~= x then
    local result = {}
    if "" ~= x and "" ~= y then
      if "" == z then
        z = "0"
      end
      result.coords = {
        x = tonumber(x),
        y = tonumber(y),
        z = tonumber(z)
      }
    end
    if "" ~= yaw then
      result.yaw = tonumber(yaw)
    end
    return result
  end
  scene_id = nil
  x, y, z = nil, nil, nil
  yaw = nil
  scene_id, x, y, z, yaw = str:match("^(%d*);(%-?%d+%.?%d*),(%-?%d+%.?%d*),?(%-?%d*%.?%d*),?(%-?%d*%.?%d*)")
  if nil ~= scene_id then
    local result = {}
    if "" ~= scene_id then
      result.sceneId = tonumber(scene_id)
    end
    if "" ~= x and "" ~= y then
      if "" == z then
        z = "0"
      end
      result.coords = {
        x = tonumber(x),
        y = tonumber(y),
        z = tonumber(z)
      }
    end
    if "" ~= yaw then
      result.yaw = tonumber(yaw)
    end
    return result
  end
  scene_id = nil
  x, y, z = nil, nil, nil
  yaw = nil
  rot_str = nil
  local rot_str
  x, y, z, rot_str = str:match("%(?X=(%-?%d+%.?%d*)[ ,]+Y=(%-?%d+%.?%d*)[ ,]+Z=(%-?%d+%.?%d*)%)?#?(.*)")
  if nil ~= x then
    local result = {
      coords = {
        x = tonumber(x),
        y = tonumber(y),
        z = tonumber(z)
      }
    }
    if "" ~= rot_str then
      yaw = rot_str:match(".*Y=(%-?%d+%.?%d*).*")
      if nil ~= yaw then
        result.yaw = tonumber(yaw)
      end
    end
    return result
  end
  return nil
end

function DebugTabScenePublic:GMCommandTeleport(x, y, z, sceneId)
  local teleReq = ProtoMessage.newZoneSceneGmTeleportReq()
  teleReq.to_scene_cfg_id = SceneUtils.GetSceneID()
  if sceneId then
    teleReq.to_scene_cfg_id = sceneId
  end
  if x then
    teleReq.to_point.pos.x = x
  end
  if y then
    teleReq.to_point.pos.y = y
  end
  if z then
    teleReq.to_point.pos.z = z
  end
  Log.DebugFormat("GMCommandTeleport, toSceneCfgId:%s, toPos:(%s,%s,%s), toDirZ:%s", teleReq.to_scene_cfg_id, teleReq.to_point.pos.x, teleReq.to_point.pos.y, teleReq.to_point.pos.z, teleReq.to_point.dir.z)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, teleReq, self, self._OnTeleportRsp, false, true)
end

function DebugTabScenePublic:Teleport(name, panel, x, y, z, sceneId)
  local teleReq = ProtoMessage.newZoneSceneGmTeleportReq()
  local inputText, abbreinputText
  if panel then
    inputText = panel.InputBox:GetText()
    abbreinputText = panel.AbbreInputBox:GetText()
  end
  if string.IsNilOrEmpty(inputText) and string.IsNilOrEmpty(abbreinputText) then
  elseif "" ~= abbreinputText then
    inputText = abbreinputText
  end
  if "" == inputText then
    inputText = UE4.UNRCStatics.ClipboardPaste()
  end
  local result = self:ParseTeleportInput(inputText)
  if nil == result then
    self:GMCommandTeleport(x, y, z, sceneId)
    Log.Warning("Please input teleport target")
    return
  end
  teleReq.to_scene_cfg_id = SceneUtils.GetSceneID()
  if result.sceneId then
    teleReq.to_scene_cfg_id = result.sceneId
  end
  if result.coords then
    teleReq.to_point.pos.x = result.coords.x
    teleReq.to_point.pos.y = result.coords.y
    teleReq.to_point.pos.z = result.coords.z
  end
  if result.yaw then
    teleReq.to_point.dir.x = 0
    teleReq.to_point.dir.y = 0
    teleReq.to_point.dir.z = result.yaw
  end
  local toPoint = teleReq.to_point
  Log.DebugFormat("Teleport, toSceneCfgId:%s, toPos:(%s,%s,%s), toDirZ:%s", teleReq.to_scene_cfg_id, toPoint.pos.x, toPoint.pos.y, toPoint.pos.z, toPoint.dir.z)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, teleReq, self, self._OnTeleportRsp, false, true)
end

local oneKeyCEProgress = 0

function DebugTabScenePublic:OneKeyCE(name, panel)
  if 0 ~= oneKeyCEProgress then
    Log.Error("OneKey CE in progress...")
    return
  end
  Log.Debug("OneKey CE: Teleport")
  self:_OneKeyCE_Teleport()
end

function DebugTabScenePublic:_OneKeyCE_Teleport()
  local _DCM = DataConfigManager
  self:_TeleToGlobalCfgPt(_DCM.ConfigTableId.ROLE_GLOBAL_CONFIG, "special_role_born_point", self._OnOneKeyCE_TeleportRsp)
  oneKeyCEProgress = 1
end

function DebugTabScenePublic:_OnOneKeyCE_TeleportRsp(rsp)
  oneKeyCEProgress = 0
  local retCode = rsp.ret_info.ret_code
  if 0 ~= retCode then
    Log.ErrorFormat("OneKey CE: Teleport failed, retCode:%s", retCode)
    self:_ShowOKMsgBox(string.format("\228\184\128\233\148\174CE\230\137\167\232\161\140\229\164\177\232\180\165: \233\152\182\230\174\181:\228\188\160\233\128\129, \233\148\153\232\175\175\231\160\129:%s", retCode))
    return
  end
  self:_OneKeyCE_SendReward()
end

function DebugTabScenePublic:_OneKeyCE_SendReward()
  local _DCM = DataConfigManager
  local cfgTableId = _DCM.ConfigTableId.ROLE_GLOBAL_CONFIG
  local rewardId = _DCM:GetGlobalConfigByKeyType("special_role_reward", cfgTableId).num
  local opItemReq = ProtoMessage.newZoneGmOperateItemReq()
  opItemReq.op_type = ProtoEnum.OpType.OT_ADD
  opItemReq.item_type = ProtoEnum.GoodsType.GT_REWARD
  opItemReq.item_id = rewardId
  opItemReq.item_num = 1
  Log.DebugFormat("OneKey CE:Send reward: rewardId:%s, num:%s", rewardId, opItemReq.item_num)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPERATE_ITEM_REQ, opItemReq, self, self._OnOneKeyCE_SendRewardRsp, true, true)
  oneKeyCEProgress = 2
end

function DebugTabScenePublic:_OnOneKeyCE_SendRewardRsp(rsp)
  oneKeyCEProgress = 0
  local retCode = rsp.ret_info.ret_code
  if 0 ~= retCode then
    Log.ErrorFormat("OneKey CE: Send Reward failed, retCode:%d", retCode)
    self:_ShowOKMsgBox(string.format("\228\184\128\233\148\174CE\230\137\167\232\161\140\229\164\177\232\180\165: \233\152\182\230\174\181:\229\143\145\230\148\190\229\165\150\229\138\177, \233\148\153\232\175\175\231\160\129:%s", retCode))
    return
  end
  self:_OneKeyCE_AcceptTask()
end

function DebugTabScenePublic:_OneKeyCE_AcceptTask()
  local _DCM = DataConfigManager
  local cfgTableId = _DCM.ConfigTableId.ROLE_GLOBAL_CONFIG
  local specTaskId = _DCM:GetGlobalConfigByKeyType("special_role_task", cfgTableId).num
  Log.DebugFormat("OneKey CE: Accept task %s", specTaskId)
  local acceptTaskReq = ProtoMessage.newZoneGmTaskAddReq()
  acceptTaskReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  acceptTaskReq.task_id = specTaskId
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, acceptTaskReq, self, self._OnOneKeyCE_AcceptTaskRsp, true, true)
  oneKeyCEProgress = 3
end

function DebugTabScenePublic:_OnOneKeyCE_AcceptTaskRsp(rsp)
  oneKeyCEProgress = 0
  local retCode = rsp.ret_info.ret_code
  if 0 ~= retCode then
    Log.ErrorFormat("OneKey CE: Accept task failed, retCode:%d", retCode)
    self:_ShowOKMsgBox(string.format("\228\184\128\233\148\174CE\230\137\167\232\161\140\229\164\177\232\180\165: \233\152\182\230\174\181:\230\142\165\229\143\151\228\187\187\229\138\161, \233\148\153\232\175\175\231\160\129:%s", retCode))
    return
  end
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLoc = player.viewObj:Abs_K2_GetActorLocation()
  local promptTxt = string.format("\228\184\128\233\148\174CE\230\137\167\232\161\140\230\136\144\229\138\159!\n\n" .. "\230\130\168\229\189\147\229\137\141\230\137\128\229\156\168\229\156\186\230\153\175:%d\n\228\189\141\231\189\174:(%.0f, %.0f, %.0f)", SceneUtils.GetSceneID(), playerLoc.X, playerLoc.Y, playerLoc.Z)
  UE4.UNRCStatics.ClipboardCopy(string.format("(X=%.0f,Y=%.0f,Z=%.0f)", playerLoc.X, playerLoc.Y, playerLoc.Z))
  self:_ShowOKMsgBox(promptTxt)
end

function DebugTabScenePublic:UseLocalRoleHp()
  GlobalConfig.UseLocalRoleHp = true
end

function DebugTabScenePublic:SetEnableTeleport()
  GlobalConfig.EnableDeahTeleport = not GlobalConfig.EnableDeahTeleport
  Log.Debug("EnableDeathTeleport=", GlobalConfig.EnableDeahTeleport)
end

function DebugTabScenePublic:_TeleToGlobalCfgPt(cfgTableId, cfgKey, rspHandler)
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

function DebugTabScenePublic:_OnTeleportRsp(rsp)
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

function DebugTabScenePublic:_ShowOKMsgBox(txt)
  local dlgCtx = DialogContext()
  dlgCtx:SetContent(txt)
  dlgCtx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dlgCtx)
end

function DebugTabScenePublic:ShowTemperature()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTemperature)
end

function DebugTabScenePublic:ShowcurLocation()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowPlayerLoction, true)
end

function DebugTabScenePublic:ShowTimeAndWeather()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTimeAndWeather)
end

function DebugTabScenePublic:SlanText(Name, Panel)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Pos = Player:GetActorLocation()
  local outText = string.format("%d;%d;%d", math.round(Pos.X), math.round(Pos.Y), math.round(Pos.Z))
  UE4.UNRCStatics.ClipboardCopy(outText)
end

function DebugTabScenePublic:UnlockPetTrace(name, panel, id)
  local campId
  if panel then
    campId = panel:GetInputNumber()
  else
    campId = tonumber(id)
  end
  local UnlockCampPetsReq = ProtoMessage.newZoneGmUnlockCampPetsReq()
  UnlockCampPetsReq.camp_id = campId
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_UNLOCK_CAMP_PETS_REQ, UnlockCampPetsReq, self, self.NewZoneGmUnlockCampPetsRsp)
end

function DebugTabScenePublic:NewZoneGmUnlockCampPetsRsp(rsp)
end

function DebugTabScenePublic:WuDi()
  local playerController = UE4.UGameplayStatics.GetPlayerController(_G.UE4Helper.GetCurrentWorld(), 0)
  GlobalConfig.WuDi = not GlobalConfig.WuDi
  if GlobalConfig.WuDi then
    UE4.UNRCStatics.ExecConsoleCommand("gm wudi 1", playerController)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\231\187\143\232\191\155\229\133\165\230\151\160\230\149\140\230\168\161\229\188\143")
  else
    UE4.UNRCStatics.ExecConsoleCommand("gm wudi 0", playerController)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\231\187\143\233\128\128\229\135\186\230\151\160\230\149\140\230\168\161\229\188\143")
  end
end

function DebugTabScenePublic:GhostMode()
  local playerController = UE4.UGameplayStatics.GetPlayerController(_G.UE4Helper.GetCurrentWorld(), 0)
  GlobalConfig.GhostMode = not GlobalConfig.GhostMode
  if GlobalConfig.GhostMode then
    UE4.UNRCStatics.ExecConsoleCommand("NRCGhost 3000", playerController)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\231\187\143\232\191\155\229\133\165ghost\230\168\161\229\188\143")
  else
    UE4.UNRCStatics.ExecConsoleCommand("NRCGhost 0", playerController)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\231\187\143\233\128\128\229\135\186ghost\230\168\161\229\188\143")
  end
end

function DebugTabScenePublic:ToggleTouchBattle()
  GlobalConfig.DisableTouchBattle = not GlobalConfig.DisableTouchBattle
  local tips = string.format("\229\183\178\231\187\143\228\184\186\230\130\168%s\230\142\165\232\167\166\232\191\155\230\136\152\230\150\151\231\154\132\229\138\159\232\131\189", GlobalConfig.DisableTouchBattle and "\229\129\156\231\148\168" or "\230\129\162\229\164\141")
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, tips)
end

function DebugTabScenePublic:LocalModeCamTeleportToMT(name, panel)
  local player = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  player:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(402292, 653896, 1281))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScenePublic:LocalModeCamTeleportToMagic(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(0, 0, 800500))
  if panel then
    panel:DoClose()
  end
end

function DebugTabScenePublic:ServerUnlockNPC(Name, Panel, npcRefreshCfgId)
  local MapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if MapModule:HasPanel("MainBigMap") then
    local panel = MapModule:GetPanel("MainBigMap")
    if panel then
      Log.Error("\232\175\183\229\133\179\233\151\173\229\156\176\229\155\190\229\144\142\228\189\191\231\148\168\232\175\165GM")
      return
    end
  end
  local req = ProtoMessage:newZoneGmUnlockWorldMapStaticNpcReq()
  if Panel then
    req.npc_refresh_cfg_id = Panel:GetInputNumber()
  else
    req.npc_refresh_cfg_id = tonumber(npcRefreshCfgId)
  end
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_UNLOCK_WORLD_MAP_STATIC_NPC_REQ, req, self, self.OnServerUnlockNPC)
end

function DebugTabScenePublic:HideMainMapMask()
  _G.GlobalConfig.bHideMainMapMask = not _G.GlobalConfig.bHideMainMapMask
  _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.HideMainMapMask, _G.GlobalConfig.bHideMainMapMask)
end

local function Box2DAddVector2D(Box2D, Vector2D)
  Box2D.Min.X = math.min(Box2D.Min.X, Vector2D.X)
  Box2D.Min.Y = math.min(Box2D.Min.Y, Vector2D.Y)
  Box2D.Max.X = math.max(Box2D.Max.X, Vector2D.X)
  Box2D.Max.Y = math.max(Box2D.Max.Y, Vector2D.Y)
end

local function IsPointInPolygon(Point, Polygon)
  local NumPoints = Polygon:Length()
  local Inside = false
  local X, Y = Point.X, Point.Y
  for i = 1, NumPoints do
    local j = i % NumPoints + 1
    local PointA = Polygon[i]
    local PointB = Polygon[j]
    local XA, YA = PointA.X, PointA.Y
    local XB, YB = PointB.X, PointB.Y
    if Y < YA ~= (Y < YB) and X < (XB - XA) * (Y - YA) / (YB - YA) + XA then
      Inside = not Inside
    end
  end
  return Inside
end

function DebugTabScenePublic:CancelPlayerMoveCheckTest()
  local Wall = _G.NRCModuleManager:DoCmd(_G.AirWallModuleCmd.GetWall, 71030018)
  local SplineLength = Wall.Spline:GetSplineLength()
  local Resolution = 200
  local GridSize = 1000
  local Vertices = {}
  local Vertices2D = UE.TArray(UE.FVector2D)
  for i = 0, SplineLength, Resolution do
    local Loc = Wall.Spline:GetLocationAtDistanceAlongSpline(i, UE.ESplineCoordinateSpace.World)
    table.insert(Vertices, Loc)
    Vertices2D:Add(UE4.FVector2D(Loc.X, Loc.Y))
  end
  local InitBox = UE4.FVector2D(Vertices[1].X, Vertices[1].Y)
  local Box2D = UE4.FBox2D(InitBox, InitBox)
  for i = 2, #Vertices do
    UE4.UKismetSystemLibrary.DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), Vertices[i - 1], Vertices[i], UE4.FLinearColor(0, 0, 1, 1), 1000)
    Box2DAddVector2D(Box2D, UE4.FVector2D(Vertices[i].X, Vertices[i].Y))
  end
  local Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerZ = Player:GetActorLocation().Z
  local Size = (Box2D.Max - Box2D.Min) * 0.5
  local Center2D = (Box2D.Min + Box2D.Max) * 0.5
  local Center = UE4.FVector(Center2D.X, Center2D.Y, PlayerZ)
  UE4.UKismetSystemLibrary.DrawDebugBox(_G.UE4Helper.GetCurrentWorld(), Center, UE4.FVector(Size.X, Size.Y, 10), UE4.FLinearColor(1, 0, 1, 1), nil, 1000)
  local GridXCount = 2 * Size.X / GridSize
  local GridYCount = 2 * Size.Y / GridSize
  local Aqa = SceneUtils.ConvertRelativeToAbsolute(Vertices[#Vertices])
  local Aa = SceneUtils.ConvertRelativeToAbsolute(Vertices[#Vertices - 1])
  local Aasa = SceneUtils.ConvertRelativeToAbsolute(Vertices[#Vertices - 2])
  local Aaa = SceneUtils.ConvertRelativeToAbsolute(Vertices[#Vertices - 3])
  local B = SceneUtils.ConvertRelativeToAbsolute(UE4.FVector(Box2D.Min.X, Box2D.Min.Y, 0))
  for i = 0, GridXCount do
    for j = 0, GridYCount do
      local Point = Box2D.Min + UE4.FVector2D(GridSize * i, GridSize * j)
      local PointLT = Point + UE4.FVector2D(-0.5 * GridSize, -0.5 * GridSize)
      local PointLB = Point + UE4.FVector2D(-0.5 * GridSize, 0.5 * GridSize)
      local PointRT = Point + UE4.FVector2D(0.5 * GridSize, -0.5 * GridSize)
      local PointRB = Point + UE4.FVector2D(0.5 * GridSize, 0.5 * GridSize)
      if IsPointInPolygon(PointLT, Vertices2D) or IsPointInPolygon(PointLB, Vertices2D) or IsPointInPolygon(PointRT, Vertices2D) or IsPointInPolygon(PointRB, Vertices2D) then
        local Center = UE4.FVector(Point.X, Point.Y, PlayerZ)
        UE4.UKismetSystemLibrary.DrawDebugBox(_G.UE4Helper.GetCurrentWorld(), Center, UE4.FVector(500, 500, 10), UE4.FLinearColor(1, 1, 0, 1), nil, 1000)
      else
        UE.UKismetSystemLibrary.DrawDebugString(_G.UE4Helper.GetCurrentWorld(), Center, i .. "&" .. j, nil, UE4.FLinearColor(0, 1, 1, 1), 1000)
      end
    end
  end
end

function DebugTabScenePublic:OpenPlayerCheckPosDead()
  local Req = _G.ProtoMessage:newZoneGmPlayerMoveCheckModifyReq()
  Req.open_airwall_dead = true
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_PLAYER_MOVE_CHECK_MODIFY_REQ, Req, self, self.OnZoneGmPlayerMoveCheckModifyRsp)
end

function DebugTabScenePublic:OpenPlayer3CCheckTips()
  local Req = _G.ProtoMessage:newZoneGmPlayerMoveCheckModifyReq()
  Req.enable_tips = true
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_PLAYER_MOVE_CHECK_MODIFY_REQ, Req, self, self.OnZoneGmPlayerMoveCheckModifyRsp)
end

function DebugTabScenePublic:EnterCharacterViewer()
  NRCEventCenter:RegisterEvent("OnMapLoaded", self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnCharacterViewerWorldLoaded)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/AnimSequence/LookDevLevel/L_CharacterViewer")
end

function DebugTabScenePublic:OnCharacterViewerWorldLoaded()
  Log.Warning("OnCharacterViewerWorldLoaded OnMapLoaded:")
  NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnCharacterViewerWorldLoaded)
  local localMode = NRCModeManager:GetMode("LocalMode")
  if localMode then
    Log.Warning("OnCharacterViewerWorldLoaded OnSceneLoaded:")
    localMode:OnSceneLoaded()
  end
end

function DebugTabScenePublic:OnZoneGmPlayerMoveCheckModifyRsp(Rsp)
  if 0 ~= Rsp.ret_info.ret_code then
    Log.Error("amonsu: GM \229\133\179\233\151\173\231\169\186\230\176\148\229\162\153\230\147\141\228\189\156\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129", Rsp.ret_info.ret_code)
  end
end

local function ReadBinaryFile(FilePath)
  local Vectors = {}
  local File = io.open(FilePath, "rb")
  if File then
    while true do
      local XBytes = File:read(4)
      local YBytes = File:read(4)
      if not (XBytes and YBytes) then
        break
      end
      local X = string.unpack("f", XBytes)
      local Y = string.unpack("f", YBytes)
      table.insert(Vectors, UE4.FVector2D(X, Y))
    end
    File:close()
    return Vectors
  end
end

local function readCoordinatesFromFile(filename)
  local Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerZ = Player:GetActorLocation().Z
  local file = io.open(filename, "r")
  if not file then
    return nil
  end
  local coordinates = {}
  for line in file:lines() do
    local x, y = line:match("X=([%d%.]+)%s+Y=([%d%.]+)")
    if x and y then
      table.insert(coordinates, UE4.FVector(tonumber(x), tonumber(y), PlayerZ))
    else
      print("\230\151\160\230\179\149\232\167\163\230\158\144\229\157\144\230\160\135: " .. line)
    end
  end
  file:close()
  return coordinates
end

function DebugTabScenePublic:DrawServerAirWall(Name, Panel, blockId)
  local BlockID
  if Panel then
    BlockID = Panel:GetInputNumber()
  else
    BlockID = tonumber(blockId)
  end
  if BlockID then
    local FileName = string.format("/ExportedSplinePoints_%d.spline", BlockID)
    local FilePath = UE.UBlueprintPathsLibrary.Combine({
      UE.UBlueprintPathsLibrary.ProjectDir(),
      "Tools",
      "AirWallSpline"
    }) .. FileName
    local Vectors = ReadBinaryFile(FilePath)
    if Vectors then
      local Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
      local PlayerZ = Player:GetActorLocation().Z
      for i = 1, #Vectors do
        local Center = UE4.FVector(Vectors[i].X, Vectors[i].Y, PlayerZ)
        UE4.UKismetSystemLibrary.Abs_DrawDebugBox(_G.UE4Helper.GetCurrentWorld(), Center, UE4.FVector(500, 500, 10), UE4.FLinearColor(1, 0, 0, 1), nil, 1000)
      end
    end
  end
end

function DebugTabScenePublic:SwitchCompassSenseDebug()
  _G.GlobalConfig.ShowCompassSensing = not _G.GlobalConfig.ShowCompassSensing
  Log.Error("\229\189\147\229\137\141\231\189\151\231\155\152\230\132\159\231\159\165Debug\231\138\182\230\128\129", _G.GlobalConfig.ShowCompassSensing)
end

function DebugTabScenePublic:FindGroundPoint(Name, Panel, inputString)
  local InputString
  if Panel then
    InputString = Panel:GetInputString()
  else
    InputString = tostring(inputString)
  end
  local params = {}
  for w in string.gmatch(InputString, "%S+") do
    table.insert(params, w)
  end
  if 3 == #params then
    params[1] = tonumber(params[1])
    params[2] = tonumber(params[2])
    params[3] = tonumber(params[3])
  else
    self:ShowTips("\229\157\144\230\160\135\231\130\185\229\143\130\230\149\176\228\184\141\229\144\136\230\179\149")
    return
  end
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local TargetLoc = UE4.FVector(params[1], params[2], params[3])
  player:SetActorLocation(TargetLoc)
  UE.UKismetSystemLibrary.Abs_DrawDebugPoint(player.viewObj, TargetLoc, 20, UE4.FLinearColor(1, 1, 0, 1), 99999)
  UE.UNRCStatics.ExecConsoleCommand("n.DrawNpcFixCoordinateDebugLine 1")
  UE.UNRCStatics.GetPosInNearLand(player.viewObj, TargetLoc, 0)
  UE.UNRCStatics.ExecConsoleCommand("n.DrawNpcFixCoordinateDebugLine 0")
end

function DebugTabScenePublic:ShowTraceScope()
  local req = _G.ProtoMessage:newZoneGmFeedGridPosReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FEED_GRID_POS_REQ, req, self, self.CreateWall)
end

function DebugTabScenePublic:CreateWall(Rsp)
  if not Rsp or 0 ~= Rsp.ret_info.ret_code then
    Log.Error("amonsu: GM \229\136\155\229\187\186\231\169\186\230\176\148\229\162\153\230\147\141\228\189\156\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129", Rsp.ret_info.ret_code)
    return
  end
  self:CloseTraceScope()
  Trace = self:CreatePlane()
  local RetrievedMeshComponent = Trace:GetComponentByClass(UE.UProceduralMeshComponent)
  if Trace and RetrievedMeshComponent then
    local FVector = UE.FVector
    local Vertices = {}
    for _, v in pairs(Rsp.grid_pos) do
      table.insert(Vertices, FVector(v.pos[1].x, v.pos[1].y, 0))
      table.insert(Vertices, FVector(v.pos[2].x, v.pos[2].y, 0))
      table.insert(Vertices, FVector(v.pos[2].x, v.pos[2].y, 55000))
      table.insert(Vertices, FVector(v.pos[1].x, v.pos[1].y, 55000))
      table.insert(Vertices, FVector(v.pos[2].x, v.pos[2].y, 0))
      table.insert(Vertices, FVector(v.pos[3].x, v.pos[3].y, 0))
      table.insert(Vertices, FVector(v.pos[3].x, v.pos[3].y, 55000))
      table.insert(Vertices, FVector(v.pos[2].x, v.pos[2].y, 55000))
      table.insert(Vertices, FVector(v.pos[3].x, v.pos[3].y, 0))
      table.insert(Vertices, FVector(v.pos[4].x, v.pos[4].y, 0))
      table.insert(Vertices, FVector(v.pos[4].x, v.pos[4].y, 55000))
      table.insert(Vertices, FVector(v.pos[3].x, v.pos[3].y, 55000))
      table.insert(Vertices, FVector(v.pos[4].x, v.pos[4].y, 0))
      table.insert(Vertices, FVector(v.pos[1].x, v.pos[1].y, 0))
      table.insert(Vertices, FVector(v.pos[1].x, v.pos[1].y, 55000))
      table.insert(Vertices, FVector(v.pos[4].x, v.pos[4].y, 55000))
    end
    local Triangles = {}
    for i = 0, 144, 4 do
      table.insert(Triangles, i + 0)
      table.insert(Triangles, i + 1)
      table.insert(Triangles, i + 2)
      table.insert(Triangles, i + 2)
      table.insert(Triangles, i + 3)
      table.insert(Triangles, i + 0)
      table.insert(Triangles, i + 0)
      table.insert(Triangles, i + 3)
      table.insert(Triangles, i + 2)
      table.insert(Triangles, i + 2)
      table.insert(Triangles, i + 1)
      table.insert(Triangles, i + 0)
    end
    UE.UAirWallStatics.BuildSegmentationWall(RetrievedMeshComponent, Vertices, Triangles)
  end
end

function DebugTabScenePublic:CloseTraceScope()
  if Trace and Trace:IsValid() then
    Trace:K2_DestroyActor()
  end
end

function DebugTabScenePublic:ShowDungeonStageInfo()
  local req = _G.ProtoMessage:newZoneGmGetDungeonCurStageReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_GET_DUNGEON_CUR_STAGE_REQ, req, self, self.OnZoneGmGetDungeonCurStageRsp)
  _G.GlobalConfig.bShouldShowRevivePointInfo = not _G.GlobalConfig.bShouldShowRevivePointInfo
end

function DebugTabScenePublic:OnZoneGmGetDungeonCurStageRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    if rsp.cur_stage then
      _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowDungeonStageInfo, rsp.cur_stage)
    end
  elseif _G.DataModelMgr.PlayerDataModel.playerInfo.common_info.in_dungeon_id and _G.DataModelMgr.PlayerDataModel.playerInfo.common_info.in_dungeon_id[1] then
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowOrHideDungeonStageInfoText, true)
  else
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowOrHideDungeonStageInfoText, false)
  end
  if _G.GlobalConfig.bShouldShowRevivePointInfo then
    Log.Error("\229\188\128\229\144\175\230\152\190\231\164\186\229\156\176\229\159\142\233\135\141\231\148\159\231\130\185 ID\229\138\159\232\131\189")
  else
    Log.Error("\229\133\179\233\151\173\230\152\190\231\164\186\229\156\176\229\159\142\233\135\141\231\148\159\231\130\185 ID\229\138\159\232\131\189")
  end
end

function DebugTabScenePublic:Segmentation103World()
  local MapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if MapModule:HasPanel("MainBigMap") then
    local panel = MapModule:GetPanel("MainBigMap")
    if panel and panel.mapLayer2:GetChildAt(7) then
      local DebugGrid = panel.mapLayer2:GetChildAt(7)
      DebugGrid:ToggleGrid()
    end
  end
end

function DebugTabScenePublic:Segmentation103WorldWall()
  if SegmentationWallFlag then
    if actor and actor:IsValid() then
      actor:K2_DestroyActor()
    end
    SegmentationWallFlag = false
  else
    actor = self:CreatePlane()
    local RetrievedMeshComponent = actor:GetComponentByClass(UE.UProceduralMeshComponent)
    if actor and RetrievedMeshComponent then
      local FVector = UE.FVector
      local Vertices = {}
      local MIN = 4800
      local MAX = MIN + 856800
      for i = 0, 17 do
        table.insert(Vertices, FVector(4800 + i * 50400, MIN, 0))
        table.insert(Vertices, FVector(4800 + i * 50400, MAX, 0))
        table.insert(Vertices, FVector(4800 + i * 50400, MAX, 55000))
        table.insert(Vertices, FVector(4800 + i * 50400, MIN, 55000))
      end
      for i = 0, 17 do
        table.insert(Vertices, FVector(MIN, 4800 + i * 50400, 0))
        table.insert(Vertices, FVector(MAX, 4800 + i * 50400, 0))
        table.insert(Vertices, FVector(MAX, 4800 + i * 50400, 55000))
        table.insert(Vertices, FVector(MIN, 4800 + i * 50400, 55000))
      end
      local Triangles = {}
      for i = 0, 136, 4 do
        table.insert(Triangles, i + 0)
        table.insert(Triangles, i + 1)
        table.insert(Triangles, i + 2)
        table.insert(Triangles, i + 2)
        table.insert(Triangles, i + 3)
        table.insert(Triangles, i + 0)
        table.insert(Triangles, i + 0)
        table.insert(Triangles, i + 3)
        table.insert(Triangles, i + 2)
        table.insert(Triangles, i + 2)
        table.insert(Triangles, i + 1)
        table.insert(Triangles, i + 0)
      end
      UE.UAirWallStatics.BuildSegmentationWall(RetrievedMeshComponent, Vertices, Triangles)
    end
    SegmentationWallFlag = true
  end
end

function DebugTabScenePublic:CreatePlane()
  local ActorClass = UE.AActor
  local ProceduralMeshComponent = UE.UProceduralMeshComponent
  local FTransform = UE.FTransform
  local World = _G.UE4Helper.GetCurrentWorld()
  if World then
    local NewActor = World:SpawnActor(ActorClass)
    if NewActor then
      local MeshComponent = NewActor:AddComponentByClass(ProceduralMeshComponent, false, FTransform(), false)
      NewActor:Abs_K2_SetActorLocation(UE.FVectorZero, false, nil, false)
      if MeshComponent then
        print("Successfully created an Actor with a procedural mesh component named 'Block'.")
        return NewActor
      else
        print("Failed to create ProceduralMeshComponent.")
      end
    else
      print("Failed to create Actor.")
    end
  else
    print("World is nil.")
  end
end

function DebugTabScenePublic:ShowPetInfoByDistance(d)
  local dis = d or 2000
  local DebugModule = _G.NRCModuleManager:GetModule("DebugModule")
  if DebugModule then
    local flg = not DebugModule.bShowHudPetInfo
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.SetShowHudPetInfoFlg, flg)
  end
end

function DebugTabScenePublic:AddRandomMarkPoint(Name, Panel, Num)
  if IsWaitMapMark then
    return
  end
  IsWaitMapMark = true
  local MapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if MapModule:HasPanel("MainBigMap") then
    local panel = MapModule:GetPanel("MainBigMap")
    if panel then
      Log.Error("\232\175\183\229\133\179\233\151\173\229\156\176\229\155\190\229\144\142\228\189\191\231\148\168\232\175\165GM")
      IsWaitMapMark = false
      return
    end
  end
  local num
  if Panel then
    num = Panel:GetInputNumber()
  else
    num = tonumber(Num)
  end
  if 0 == num then
    num = 50
  end
  local Req = _G.ProtoMessage:newZoneSceneGmMapMarkOperateReq()
  Req.op_type = _G.ProtoEnum.MapMarkOpType.MMOT_ADD_MARK
  Req.num = num
  Req.world_map_cfg_id = nil
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_MAP_MARK_OPERATE_REQ, Req, self, self.OnZoneAddSceneGmMapMarkOperateRsp)
end

function DebugTabScenePublic:OnZoneAddSceneGmMapMarkOperateRsp(Rsp)
  if 0 ~= Rsp.ret_info.ret_code then
    Log.Error("\228\184\128\233\148\174\229\162\158\229\138\160\233\154\143\230\156\186\229\184\184\232\167\132\230\160\135\232\174\176\231\130\18550\228\184\170\230\147\141\228\189\156\229\164\177\232\180\165", Rsp.ret_info.ret_code)
    IsWaitMapMark = false
  end
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if bigMapModule and Rsp.mark_entry and #Rsp.mark_entry > 0 then
    for _, markPoint in ipairs(Rsp.mark_entry) do
      bigMapModule.data:SetNewCustomPointInfo(markPoint)
      _G.DataModelMgr.PlayerDataModel:UpdateWorldMapMarkEntryInfo(markPoint, false)
    end
  end
  IsWaitMapMark = false
end

function DebugTabScenePublic:ReduceRandomMarkPoint(Name, Panel, Num)
  if IsWaitMapMark then
    return
  end
  IsWaitMapMark = true
  local MapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if MapModule:HasPanel("MainBigMap") then
    local panel = MapModule:GetPanel("MainBigMap")
    if panel then
      Log.Error("\232\175\183\229\133\179\233\151\173\229\156\176\229\155\190\229\144\142\228\189\191\231\148\168\232\175\165GM")
      IsWaitMapMark = false
      return
    end
  end
  local num
  if Panel then
    num = Panel:GetInputNumber()
  else
    num = tonumber(Num)
  end
  if 0 == num then
    num = 50
  end
  local Req = _G.ProtoMessage:newZoneSceneGmMapMarkOperateReq()
  Req.op_type = _G.ProtoEnum.MapMarkOpType.MMOT_REMOVE_MARK
  Req.num = num
  Req.world_map_cfg_id = nil
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_MAP_MARK_OPERATE_REQ, Req, self, self.OnZoneReduceSceneGmMapMarkOperateRsp)
end

function DebugTabScenePublic:OnZoneReduceSceneGmMapMarkOperateRsp(Rsp)
  if 0 ~= Rsp.ret_info.ret_code then
    Log.Error("\228\184\128\233\148\174\229\135\143\229\176\145\233\154\143\230\156\186\229\184\184\232\167\132\230\160\135\232\174\176\231\130\18550\228\184\170\230\147\141\228\189\156\229\164\177\232\180\165", Rsp.ret_info.ret_code)
    IsWaitMapMark = false
    return
  end
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if bigMapModule then
    for _, markPoint in ipairs(Rsp.mark_entry) do
      bigMapModule.data:RemoveNewCustomPointByMarkId(markPoint.mark_id)
    end
  end
  IsWaitMapMark = false
end

function DebugTabScenePublic:OneKeyActiveMapIcons(Name, Panel, npcRefreshCfgId)
  local MapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if MapModule:HasPanel("MainBigMap") then
    local panel = MapModule:GetPanel("MainBigMap")
    if panel then
      Log.Error("\232\175\183\229\133\179\233\151\173\229\156\176\229\155\190\229\144\142\228\189\191\231\148\168\232\175\165GM")
      return
    end
  end
  local req = ProtoMessage:newZoneGmUnlockWorldMapStaticNpcReq()
  if Panel then
    req.npc_refresh_cfg_id = Panel:GetInputNumber()
  else
    req.npc_refresh_cfg_id = tonumber(npcRefreshCfgId)
  end
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_UNLOCK_WORLD_MAP_STATIC_NPC_REQ, req, self, self.OnActiveMapIconsRsp)
end

function DebugTabScenePublic:OnActiveMapIconsRsp(Rsp)
  _G.NRCModuleManager:DoCmd(BigMapModuleCmd.BonfireFinishNotify)
end

local AuraFlag = false
local SphereColor = UE.FLinearColor(1, 0, 0, 1)
local CylinderColor = UE.FLinearColor(0, 1, 0, 1)

function DebugTabScenePublic:ShowAura()
  AuraFlag = not AuraFlag
  local World = _G.UE4Helper.GetCurrentWorld()
  if AuraFlag then
    local AllNpc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    for _, Npc in pairs(AllNpc) do
      local NpcConf = _G.DataConfigManager:GetNpcConf(Npc:GetConfigId())
      local AuraIDs = NpcConf.aura_id
      if AuraIDs and #AuraIDs > 0 then
        for _, AuraID in ipairs(AuraIDs) do
          local AuraConf = _G.DataConfigManager:GetNpcAuraConf(AuraID)
          if not AuraConf then
          else
            local DebugStr = string.format("%d-%d-%s", NpcConf.id, AuraConf.id, AuraConf.editor_name)
            if AuraConf.aura_area_type == Enum.AuraAreaType.AURA_AREA_TYPE_NONE then
              goto lbl_146
            elseif AuraConf.aura_area_type == Enum.AuraAreaType.AURA_AREA_TYPE_SPHERE then
              local Radius = AuraConf.aura_distance[1]
              UE.UKismetSystemLibrary.Abs_DrawDebugSphere(World, Npc:GetActorLocation(), Radius, 24, SphereColor, 99999, 2)
              UE.UKismetSystemLibrary.Abs_DrawDebugString(World, Npc:GetActorLocation(), DebugStr, nil, SphereColor, 99999)
            elseif AuraConf.aura_area_type == Enum.AuraAreaType.AURA_AREA_TYPE_CYLINDER then
              local Radius = AuraConf.aura_distance[1]
              local Height = AuraConf.aura_distance[2]
              local Center = Npc:GetActorLocation()
              local Start = Center - UE.FVector(0, 0, Height / 2)
              local End = Center + UE.FVector(0, 0, Height / 2)
              UE.UKismetSystemLibrary.Abs_DrawDebugCylinder(World, Start, End, Radius, 24, CylinderColor, 99999, 2)
              UE.UKismetSystemLibrary.Abs_DrawDebugString(World, Npc:GetActorLocation(), DebugStr, nil, CylinderColor, 99999)
            end
          end
          ::lbl_146::
        end
      end
    end
  else
    UE.UKismetSystemLibrary.FlushDebugStrings(World)
    UE.UKismetSystemLibrary.FlushPersistentDebugLines(World)
  end
end

function DebugTabScenePublic:CreateDebugBlockAirWall(name, panel)
  if not panel then
    return
  end
  local blockID = tonumber(panel.InputBox:GetText())
  if nil == blockID then
    return
  end
  local BlockConf = _G.DataConfigManager:GetBlockConf(blockID, true)
  if not BlockConf then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\228\184\141\229\173\152\229\156\168\231\169\186\230\176\148\229\162\153\239\188\154%d", blockID), 1, nil, 5)
    return
  end
  if self.debugBlocks and self.debugBlocks[blockID] then
    local debugBlock = self.debugBlocks[blockID]
    if UE4.UObject.IsValid(debugBlock) then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\231\169\186\230\176\148\229\162\153\229\183\178\229\173\152\229\156\168\239\188\154%d", blockID), 1, nil, 5)
      return
    end
  end
  local Klass = _G.NRCBigWorldPreloader:Get("AirWall")
  if not Klass then
    Log.Debug("CreateDebugBlockAirWall AirWall Preload Failed...", blockID)
    return
  end
  local World = _G.UE4Helper.GetCurrentWorld()
  local Pos = UE.FVector(BlockConf.position[1], BlockConf.position[2], BlockConf.position[3])
  local Scale = UE.FVector(BlockConf.scale[1], BlockConf.scale[2], BlockConf.scale[3])
  local Rot = UE.FRotator(BlockConf.rotation[2], BlockConf.rotation[3], BlockConf.rotation[1])
  local Transform = UE.FTransform(Rot:ToQuat(), Pos, Scale)
  local Always = UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn
  local AirWall = World:Abs_SpawnActor(Klass, Transform, Always, nil, nil, nil, BlockConf)
  if not AirWall or not UE4.UObject.IsValid(AirWall) then
    Log.Debug("CreateDebugBlockAirWall AirWall Spawn Failed...", blockID)
    return
  end
  Log.Debug("CreateDebugBlockAirWall AirWall Spawn Success...", blockID)
  if not self.debugBlocks then
    self.debugBlocks = {}
  end
  self.debugBlocks[blockID] = AirWall
  if RocoEnv.IS_EDITOR then
    AirWall:SetActorLabelNoFlush(string.format("Debug_Block_%d", blockID), false)
  end
  
  local function setDebugMesh(mesh, color)
    if mesh and UE4.UObject.IsValid(mesh) then
      local material = UE4.UKismetMaterialLibrary.CreateDynamicMaterialInstance(World, AirWall.EnableMat)
      if color then
        material:SetVectorParameterValue("Color", color)
      end
      mesh:SetMaterial(0, material)
      mesh:SetCollisionEnabled(UE4.ECollisionEnabled.NoCollision)
    end
  end
  
  setDebugMesh(AirWall.Block, UE4.FLinearColor(0.171441, 0.708376, 1, 0.6))
  setDebugMesh(AirWall.Enable)
  setDebugMesh(AirWall.Disable)
end

function DebugTabScenePublic:DestroyDebugBlockAirWall(name, panel)
  if not panel then
    return
  end
  local blockID = tonumber(panel.InputBox:GetText())
  if not blockID then
    return
  end
  if not self.debugBlocks then
    return
  end
  local AirWall = self.debugBlocks[blockID]
  if not AirWall then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\228\184\141\229\173\152\229\156\168\231\169\186\230\176\148\229\162\153\239\188\154%d", blockID), 1, nil, 5)
    return
  end
  if not UE4.UObject.IsValid(AirWall) then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\228\184\141\229\173\152\229\156\168\231\169\186\230\176\148\229\162\153\239\188\154%d", blockID), 1, nil, 5)
    self.debugBlocks[blockID] = nil
    return
  end
  AirWall:K2_DestroyActor()
  self.debugBlocks[blockID] = nil
  Log.Debug("DestroyDebugBlockAirWall ", blockID)
end

function DebugTabScenePublic:HighlightClimbableObjects_Update()
  local World = _G.UE4Helper.GetCurrentWorld()
  if not World then
    print("HighlightClimbableObjects_Update: World is nil")
    return
  end
  local Character = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not Character then
    print("HighlightClimbableObjects_Update: Character is nil")
    return
  end
  if not Character.viewObj then
    print("HighlightClimbableObjects_Update: Character.viewObj is nil")
    return
  end
  local MoveComp = Character.viewObj:GetMovementComponent()
  if not MoveComp then
    print("HighlightClimbableObjects_Update: MoveComp is nil")
    return
  end
  local PositionDiffThresholdSq = 2500.0
  local DifaultDistance = 5000.0
  local CustomDepthStencilValue = 100
  local CharacterObj = Character.viewObj or Character
  local Start = CharacterObj:K2_GetActorLocation()
  if self.LastStartPosition and PositionDiffThresholdSq > UE4.FVector.DistSquared(self.LastStartPosition, Start) then
    return
  end
  local Capsule = CharacterObj:GetComponentByClass(UE4.UCapsuleComponent)
  if not Capsule then
    print("HighlightClimbableObjects: Capsule is nil")
    return
  end
  self.HighlightClimbableObjectsDistance = self.HighlightClimbableObjectsDistance or self:GetInputNumber(DifaultDistance)
  local hits, result = UE4.UKismetSystemLibrary.SphereTraceMulti(World, Start, Start, self.HighlightClimbableObjectsDistance, Capsule:GetCollisionObjectType(), false, nil)
  self.LastStartPosition = Start
  for i = 1, hits:Length() do
    local hit = hits:Get(i)
    local Component = hit.Component
    if not Component then
    elseif self.HighlightedComponents and self.HighlightedComponents[Component] then
    elseif self.UnclimbableComponents and self.UnclimbableComponents[Component] then
    elseif MoveComp.CheckPrimitiveComponentCanClimbOn and MoveComp:CheckPrimitiveComponentCanClimbOn(Component) then
      if not self.HighlightWithMaterial then
        local bWasRenderCustomDepth = Component.bRenderCustomDepth
        local OriginalStencilValue = Component.CustomDepthStencilValue
        local Sign = bWasRenderCustomDepth and 1 or -1
        self.HighlightedComponents[Component] = OriginalStencilValue * Sign
        Component:SetRenderCustomDepth(true)
        Component:SetCustomDepthStencilValue(CustomDepthStencilValue)
      else
        local DebugMaterial = UE.UMaterial.Load("/Game/ArtRes/Material/Test/NeedCook/M_T_Wireframe.M_T_Wireframe")
        for i = 1, Component:GetNumMaterials() do
          local MaterialIndex = i - 1
          local Material = Component:GetMaterial(MaterialIndex)
          if Material then
            self.HighlightedComponents[Component] = self.HighlightedComponents[Component] or {}
            self.HighlightedComponents[Component][MaterialIndex] = Material
            local DynamicMaterial = Component:CreateDynamicMaterialInstance(MaterialIndex, DebugMaterial)
            if DynamicMaterial then
              Component:SetMaterial(MaterialIndex, DynamicMaterial)
            end
          end
        end
      end
    else
      self.UnclimbableComponents = self.UnclimbableComponents or {}
      self.UnclimbableComponents[Component] = true
    end
  end
end

function DebugTabScenePublic:HighlightClimbableObjects(name, panel)
  if not panel then
    return
  end
  local World = _G.UE4Helper.GetCurrentWorld()
  if not World then
    return
  end
  local Character = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not Character then
    return
  end
  if not Character.viewObj then
    return
  end
  local MoveComp = Character.viewObj:GetMovementComponent()
  if not MoveComp then
    return
  end
  if not self.HighlightedComponents then
    self.HighlightedComponents = {}
  end
  if not self.HighlightObjTimerHandle then
    self.HighlightObjTimerHandle = {}
  end
  
  local function ClearAllHighlightedComponents()
    if not self.HighlightWithMaterial then
      for Component, OriginalValue in pairs(self.HighlightedComponents) do
        if Component and Component:IsValid() then
          local bShouldRender = OriginalValue >= 0
          local StencilValue = math.abs(OriginalValue)
          Component:SetRenderCustomDepth(bShouldRender)
          Component:SetCustomDepthStencilValue(StencilValue)
        end
      end
    else
      for Component, OriginalMaterials in pairs(self.HighlightedComponents) do
        if Component and Component:IsValid() then
          for i = 1, Component:GetNumMaterials() do
            local OriginalMaterial = OriginalMaterials[i - 1]
            if OriginalMaterial then
              Component:SetMaterial(i - 1, OriginalMaterial)
            end
          end
        end
      end
    end
    self.HighlightedComponents = {}
  end
  
  local isHighlighting = self.isHighlightingClimbable or false
  if isHighlighting then
    ClearAllHighlightedComponents()
    if self.HighlightObjTimerHandle then
      _G.TimerManager:RemoveTimer(self.HighlightObjTimerHandle)
      self.HighlightObjTimerHandle = nil
    end
    self.isHighlightingClimbable = false
    if self.PostProcessVolume then
      self.PostProcessVolume:K2_DestroyActor()
      self.PostProcessVolume = nil
    end
    self.HighlightClimbableObjectsDistance = nil
    self.LastStartPosition = nil
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\229\133\179\233\151\173\229\143\175\230\148\128\231\136\172\231\137\169\228\189\147\233\171\152\228\186\174")
    return
  end
  if not self.HighlightWithMaterial then
    local SpawnInfo = UE.FActorSpawnParameters()
    self.PostProcessVolume = World:SpawnActor(UE.APostProcessVolume, SpawnInfo)
    if self.PostProcessVolume then
      local Stack = self.PostProcessVolume.Settings.WeightedBlendables.Array
      local PostProcessMat = UE.UMaterial.Load("/Game/ArtRes/Material/Test/NeedCook/M_T_PP_Highlight_Stencil.M_T_PP_Highlight_Stencil")
      if PostProcessMat then
        local MatInst = UE4.UKismetMaterialLibrary.CreateDynamicMaterialInstance(World, PostProcessMat)
        local WeightedBlendable = UE.FWeightedBlendable()
        WeightedBlendable.Weight = 1.0
        WeightedBlendable.Object = MatInst
        Stack:Add(WeightedBlendable)
      end
      self.PostProcessVolume.bUnbound = true
    end
  end
  self.HighlightObjTimerHandle = _G.TimerManager:CreateTimer(self, "HighlightClimbableObjects_Update", math.maxinteger, self.HighlightClimbableObjects_Update, nil, 0.01)
  self.isHighlightingClimbable = true
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\229\188\128\229\144\175\229\143\175\230\148\128\231\136\172\231\137\169\228\189\147\233\171\152\228\186\174")
end

function DebugTabScenePublic:HighlightClimbableObjectsWithCustomDepthStencil(name, panel)
  if not self.isHighlightingClimbable then
    self.HighlightWithMaterial = false
  end
  self:HighlightClimbableObjects(name, panel)
end

function DebugTabScenePublic:HighlightClimbableObjectsWithMaterial(name, panel)
  if not self.isHighlightingClimbable then
    self.HighlightWithMaterial = true
  end
  self:HighlightClimbableObjects(name, panel)
end

return DebugTabScenePublic
