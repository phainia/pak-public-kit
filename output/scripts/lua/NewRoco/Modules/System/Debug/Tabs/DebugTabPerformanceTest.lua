local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local EnvSystemModuleCmd = require("NewRoco.Modules.System.EnvSystem.EnvSystemModuleCmd")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = DebugTabBase
local DebugTabPerformanceTest = Base:Extend("DebugTabPerformanceTest")
local CurrentConf, InitPetID
local RewardIndex = 0

function DebugTabPerformanceTest:SetupTabs()
  self:Add("\229\188\128\229\167\139stutter", self.TestStartStutter, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\187\147\230\157\159stutter", self.TestStopStutter, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\141\176\232\174\190\229\164\135\231\160\129", self.PrintDeviceCode, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("SkipLoginMovie", self.SkipLoginMovie, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\154\144\232\151\143\229\156\176\229\155\190\232\191\183\233\155\190", self.HideMainMapMask, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\228\189\147\229\138\155\230\182\136\232\128\151\229\188\128\229\133\179", self.FreeVitality, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\177\143\232\148\189\230\156\172\229\156\176\231\154\132\230\137\163\232\161\128", self.UseLocalRoleHp, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\177\143\232\148\189\230\156\172\229\156\176\229\143\151\229\135\187", self.SwitchPlayerHit, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\148\128\230\175\129\230\137\128\230\156\137NPC(\229\174\162\230\136\183\231\171\175\229\146\140\230\156\141\229\138\161\229\153\168)", self.DestroyAllNPCClientAndServer, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\228\189\191\228\186\164\228\186\146\228\184\141\229\134\141\231\148\159\230\149\136", self.ToggleNpcOptionInvalid, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\167\163\233\148\129npc(\229\144\142\229\143\176)", self.ServerUnlockNPC, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\186\229\136\182\229\143\150\230\182\136\228\186\164\228\186\146\233\148\129\232\161\140\229\138\168", self.UnLockPlayer, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\133\179\230\142\165\232\167\166\232\191\155\230\136\152\230\150\151", self.ToggleTouchBattle, self, nil, "\231\190\142\230\156\175\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\142\165\229\143\151\228\187\187\229\138\161(\229\144\142\229\143\176)", self.AcceptTask, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\174\140\230\136\144\229\189\147\229\137\141\228\187\187\229\138\161", self.FinishCurrentTask, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\230\179\155\231\148\168", nil, "\233\161\190\229\144\141\230\128\157\228\185\137", "")
  self:SetUpBornPlaceLocation()
  self:Add("\228\188\160\233\128\129", self.TeleportNew, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129", self.LocalModeTeleport, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173\230\137\128\230\156\137\231\169\186\230\176\148\229\162\153", self.CloseAllAirWall, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\228\184\128\233\148\174\233\148\129\229\174\154\230\173\163\229\141\136", self.LockNoon, self, nil, "\231\190\142\230\156\175\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\174\190\231\189\174\231\142\169\229\174\182\230\156\157\229\144\145", self.SetPlayerRotation, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\174\190\231\189\174\231\155\184\230\156\186\230\156\157\229\144\145", self.SetCameraRotation, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\185\233\135\143\229\143\145\233\128\129\232\153\154\231\169\186\229\165\189\229\143\139", self.BatchSendFriends, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\185\233\135\143\231\148\159\230\136\144\229\165\189\229\143\139", self.BatchCreateFriends, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\185\233\135\143\231\148\159\230\136\144\233\187\145\229\144\141\229\141\149", self.BatchCreateBlackList, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("GC", self.GC, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("GCUE", self.GCUE, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\144\175LuaProfile", self.EnableLuaProfile, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173LuaProfile", self.DisableLuaProfile, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:SetUpCEButtons()
end

function DebugTabPerformanceTest:Run(Conf)
  CurrentConf = Conf
  self:Teleport()
end

function DebugTabPerformanceTest:TestStartStutter(name, panel)
  if panel then
    panel:DoClose()
  end
  _G.NRCSDKManager:StartCustomStutter()
end

function DebugTabPerformanceTest:TestStopStutter(name, panel)
  if panel then
    panel:DoClose()
  end
  local stutter = _G.NRCSDKManager:StopCustomStutter()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowPerfStutter, stutter)
end

function DebugTabPerformanceTest:PrintDeviceCode()
  _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, UE4.UKismetSystemLibrary.GetDeviceId())
end

function DebugTabPerformanceTest:SkipLoginMovie()
  NRCEventCenter:DispatchEvent(LoginModuleEvent.SkipLoginMovie)
end

function DebugTabPerformanceTest:HideMainMapMask()
  _G.GlobalConfig.bHideMainMapMask = not _G.GlobalConfig.bHideMainMapMask
  _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.HideMainMapMask, _G.GlobalConfig.bHideMainMapMask)
end

function DebugTabPerformanceTest:FreeVitality()
  GlobalConfig.FreeVitality = not GlobalConfig.FreeVitality
  local Req = _G.ProtoMessage:newZoneSceneGmOperateStaminaReq()
  Req.op_type = _G.ProtoEnum.ZoneSceneGmOperateStaminaReq.OpType.OT_FORIBID
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_OPERATE_STAMINA_REQ, Req, self, self.OnRsp)
end

function DebugTabPerformanceTest:UseLocalRoleHp()
  GlobalConfig.UseLocalRoleHp = true
end

function DebugTabPerformanceTest:SwitchPlayerHit()
  GlobalConfig.IgnorePlayerHit = not GlobalConfig.IgnorePlayerHit
  GlobalConfig.DisablePetAttack = not GlobalConfig.DisablePetAttack
end

function DebugTabPerformanceTest:DestroyAllNPCClientAndServer()
  self:DestroyByClass()
  local gmReq = _G.ProtoMessage:newZoneGmForbidCreateNpcReq()
  gmReq.uin = 0
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FORBID_CREATE_NPC_REQ, gmReq, self, self._OnDestroyAllNPCClientAndServerRsp)
end

function DebugTabPerformanceTest:_OnDestroyAllNPCClientAndServerRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("Forbidden Create Npc failed!")
  else
    Log.Debug("Forbidden Create Npc succeed!")
  end
end

function DebugTabPerformanceTest:DestroyByClass(className)
  local function filter(npc)
    if className then
      if npc.viewObj and npc.viewObj.name == className then
        return true
      end
    else
      return true
    end
  end
  
  self:DestroyByFilter(filter)
end

function DebugTabPerformanceTest:DestroyByFilter(filter)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcDic
  local needToRemove = {}
  local inDisplay = 0
  for id, npc in pairs(npcDict) do
    if filter(npc) then
      table.insert(needToRemove, id)
      if npc.distanceRatio < 1 then
        inDisplay = inDisplay + 1
      end
    end
  end
  SceneUtils.debugDestroy = true
  for _, id in pairs(needToRemove) do
    NPCModule:RemoveNpc(id, true, true)
  end
  Log.Error(string.format("\233\148\128\230\175\129npc\230\149\176\233\135\143%d,\232\167\134\233\135\142\229\134\133\230\149\176\233\135\143%d", #needToRemove, inDisplay))
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format("\233\148\128\230\175\129npc\230\149\176\233\135\143%d,\232\167\134\233\135\142\229\134\133\230\149\176\233\135\143%d", #needToRemove, inDisplay))
end

function DebugTabPerformanceTest:ToggleNpcOptionInvalid()
  SceneUtils.debugForceNpcOptionInvalid = not SceneUtils.debugForceNpcOptionInvalid
end

function DebugTabPerformanceTest:ServerUnlockNPC(Name, Panel, npcRefreshCfgId)
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

function DebugTabPerformanceTest:OnServerUnlockNPC(_rsp)
  _G.NRCModuleManager:DoCmd(BigMapModuleCmd.BonfireFinishNotify)
end

function DebugTabPerformanceTest:UnLockPlayer()
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  _G.GlobalConfig.DisableBattle = true
  localPlayer.inputComponent:SetInputEnable(self, true)
end

function DebugTabPerformanceTest:ToggleTouchBattle()
  GlobalConfig.DisableTouchBattle = not GlobalConfig.DisableTouchBattle
  local tips = string.format("\229\183\178\231\187\143\228\184\186\230\130\168%s\230\142\165\232\167\166\232\191\155\230\136\152\230\150\151\231\154\132\229\138\159\232\131\189", GlobalConfig.DisableTouchBattle and "\229\129\156\231\148\168" or "\230\129\162\229\164\141")
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, tips)
end

function DebugTabPerformanceTest:AcceptTask(name, panel, id)
  if panel then
    local taskId = panel:GetInputNumber()
    if 0 == taskId then
      taskId = tonumber(id)
    end
    Log.DebugFormat("Accept task %s", taskId)
    self:AcceptTaskByID(taskId)
  else
    self:AcceptTaskByID(id)
  end
end

function DebugTabPerformanceTest:AcceptTaskByID(id)
  local acceptTaskReq = ProtoMessage.newZoneGmTaskAddReq()
  acceptTaskReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  acceptTaskReq.task_id = id
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, acceptTaskReq, self, self._OnAcceptTaskRsp)
end

function DebugTabPerformanceTest:_OnAcceptTaskRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("Accept task failed!")
  else
    Log.Debug("Accept task succeed")
    self:ClosePanel()
  end
end

function DebugTabPerformanceTest:FinishCurrentTask(Name, Panel)
  local Module = NRCModuleManager:GetModule("TaskModule")
  local AllTasks = Module.data.TaskMap
  local TrackTask
  for _, TaskObject in pairs(AllTasks) do
    if TaskObject.isTrack then
      TrackTask = TaskObject
    end
  end
  if not TrackTask then
    self:ShowTips("\231\142\176\229\156\168\230\178\161\230\156\137\229\188\186\232\191\189\232\184\170\228\184\173\231\154\132\228\187\187\229\138\161")
    return
  end
  local MaxValue = 1
  for _, Value in ipairs(TrackTask.Config.task_condition) do
    MaxValue = math.max(Value.count, MaxValue)
  end
  self:ModifyTaskProgressByID(TrackTask.Info.id, MaxValue)
end

function DebugTabPerformanceTest:ModifyTaskProgressByID(id, progress)
  local modifyTaskProgReq = ProtoMessage.newZoneGmTaskModifyProgressReq()
  modifyTaskProgReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  modifyTaskProgReq.task_id = id
  modifyTaskProgReq.task_progress = progress
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_MODIFY_PROGRESS_REQ, modifyTaskProgReq, self, self._OnModifyTaskProgressRsp)
end

function DebugTabPerformanceTest:_OnModifyTaskProgressRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("Modify task progress failed!")
  else
    Log.Debug("Modify task progress succeed")
    self:ClosePanel()
  end
end

function DebugTabPerformanceTest:TeleportNew(name, panel, x, y, z)
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
  teleReq.to_scene_cfg_id = SceneUtils.GetSceneID()
  local sceneCfgIdSepPos, firstPosVecSepPos
  if inputText then
    sceneCfgIdSepPos = string.find(inputText, ";")
    firstPosVecSepPos = string.find(inputText, ",")
  end
  if sceneCfgIdSepPos or not firstPosVecSepPos then
    if sceneCfgIdSepPos then
      teleReq.to_scene_cfg_id = tonumber(string.sub(inputText, 1, sceneCfgIdSepPos - 1))
      inputText = string.sub(inputText, sceneCfgIdSepPos + 1)
    elseif tonumber(inputText) then
      teleReq.to_scene_cfg_id = tonumber(inputText)
      inputText = ""
    end
  end
  local posVecs, posVecsLen
  if inputText then
    posVecs = string.split(inputText, ",")
    posVecsLen = #posVecs
  end
  local toPoint = teleReq.to_point
  if posVecsLen and posVecsLen >= 2 then
    toPoint.pos.x = tonumber(posVecs[1])
    toPoint.pos.y = tonumber(posVecs[2])
  elseif tonumber(x) and tonumber(y) then
    toPoint.pos.x = tonumber(x)
    toPoint.pos.y = tonumber(y)
  end
  if posVecsLen and posVecsLen >= 3 then
    toPoint.pos.z = tonumber(posVecs[3])
  elseif tonumber(z) then
    toPoint.pos.z = tonumber(z)
  end
  if posVecsLen and posVecsLen >= 4 then
    toPoint.dir.x = 0
    toPoint.dir.y = 0
    toPoint.dir.z = tonumber(posVecs[4])
  end
  Log.DebugFormat("Teleport, toSceneCfgId:%s, toPos:(%s,%s,%s), toDirZ:%s", teleReq.to_scene_cfg_id, toPoint.pos.x, toPoint.pos.y, toPoint.pos.z, toPoint.dir.z)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, teleReq, self, self._OnTeleportRsp, false, true)
end

function DebugTabPerformanceTest:_OnTeleportRsp(rsp)
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

function DebugTabPerformanceTest:_ShowOKMsgBox(txt)
  local dlgCtx = DialogContext()
  dlgCtx:SetContent(txt)
  dlgCtx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dlgCtx)
end

function DebugTabPerformanceTest:LocalModeTeleport(name, panel)
  local inputText = string.gsub(self:GetInputString(), " ", "")
  if string.IsNilOrEmpty(inputText) then
    Log.Warning("Please input teleport target")
    return
  end
  local posVecs = string.split(inputText, ",")
  local posVecsLen = #posVecs
  if 3 ~= posVecsLen then
    Log.Warning("Please input three number vector, use , to split numbers")
    return
  end
  if PlayerModuleCmd then
    local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    player:SetActorLocation(UE4.FVector(tonumber(posVecs[1]), tonumber(posVecs[2]), tonumber(posVecs[3])))
  else
    Log.Error("PlayerModuleCmd Not Found")
  end
  if panel then
    panel:DoClose()
  end
end

function DebugTabPerformanceTest:CloseAllAirWall(Name, Panel)
  local AirWallClass = _G.NRCResourceManager:LoadForDebugOnly("/Game/NewRoco/Modules/System/WorldCombat/AirWalls/BP_AirWall_Gen.BP_AirWall_Gen")
  local Array = UE.TArray(UE.AActor)
  UE.UGameplayStatics.GetAllActorsOfClass(_G.UE4Helper.GetCurrentWorld(), AirWallClass, Array)
  for Index, Actor in tpairs(Array) do
    Actor:SetActorEnableCollision(false)
    Actor:SetActorHiddenInGame(true)
    Log.ErrorFormat("\229\133\179\233\151\173\231\169\186\230\176\148\229\162\153", UE.UObject.GetName(Actor))
  end
end

function DebugTabPerformanceTest:LockNoon(name, panel)
  local Time = 43200
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  self:ClosePanel()
end

function DebugTabPerformanceTest:SetPlayerRotation(Name, Panel)
  local Player = self:GetPlayer()
  local Yaw = self:GetInputNumber(0)
  Player:SetActorRotation(UE.FRotator(0, Yaw, 0))
end

function DebugTabPerformanceTest:SetCameraRotation(Name, Panel)
  local Player = self:GetPlayer()
  local Controller = Player:GetUEController()
  local Yaw = self:GetInputNumber(0)
  Controller:SetControlRotation(UE.FRotator(0, Yaw, 0))
end

function DebugTabPerformanceTest:BatchSendFriends(Name, Panel, CreateNumber)
  local create_num
  if Panel then
    create_num = Panel:GetInputNumber()
  else
    create_num = tonumber(CreateNumber)
  end
  if create_num <= 0 then
    create_num = 20
  end
  local req = _G.ProtoMessage:newZoneGmFriendOperReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.type = 1
  req.name_prefix = string.format("\233\135\143\228\186\167\229\176\143\230\180\155\229\133\139%d\229\143\183\230\156\186", math.random(0, 99999999))
  req.num = create_num
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FRIEND_OPER_REQ, req, self, self.batchSendFriendRsp)
end

function DebugTabPerformanceTest:BatchCreateFriends(Name, Panel, CreateNumber)
  local create_num
  if Panel then
    create_num = Panel:GetInputNumber()
  else
    create_num = tonumber(CreateNumber)
  end
  if create_num <= 0 then
    create_num = 20
  end
  local req = _G.ProtoMessage:newZoneGmFriendOperReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.type = 2
  req.name_prefix = string.format("\233\135\143\228\186\167\229\176\143\230\180\155\229\133\139%d\229\143\183\230\156\186", math.random(0, 99999999))
  req.num = create_num
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FRIEND_OPER_REQ, req, self, self.batchSendFriendRsp)
end

function DebugTabPerformanceTest:BatchCreateBlackList(Name, Panel, CreateNumber)
  local create_num
  if Panel then
    create_num = Panel:GetInputNumber()
  else
    create_num = tonumber(CreateNumber)
  end
  if create_num <= 0 then
    create_num = 20
  end
  local req = _G.ProtoMessage:newZoneGmFriendOperReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.type = 3
  req.name_prefix = string.format("\233\135\143\228\186\167\229\176\143\230\180\155\229\133\139%d\229\143\183\230\156\186", math.random(0, 99999999))
  req.num = create_num
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FRIEND_OPER_REQ, req, self, self.batchSendFriendRsp)
end

function DebugTabPerformanceTest:GC()
  collectgarbage("collect")
end

function DebugTabPerformanceTest:GCUE()
  UE4.UNRCStatics.ForceGarbageCollection(true)
end

function DebugTabPerformanceTest:EnableLuaProfile(Name, Panel)
  UE.UNRCStatics.EnableLuaProfile(true)
end

function DebugTabPerformanceTest:DisableLuaProfile(Name, Panel)
  UE.UNRCStatics.EnableLuaProfile(false)
end

function DebugTabPerformanceTest:batchSendFriendRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("\229\165\189\229\143\139\230\137\185\233\135\143\229\164\132\231\144\134\229\164\177\232\180\165\239\188\140\230\137\190\229\144\142\229\143\176\229\144\140\229\173\166\233\151\174\233\151\174\229\144\167", table.tostring(rsp))
  end
end

function DebugTabPerformanceTest:Teleport()
  local Conf = CurrentConf
  local Req = _G.ProtoMessage:newZoneSceneGmTeleportReq()
  Req.to_scene_cfg_id = SceneUtils.GetSceneID()
  Req.to_point.pos.x = Conf.position[1] or 0
  Req.to_point.pos.y = Conf.position[2] or 0
  Req.to_point.pos.z = Conf.position[3] or 0
  if #Conf.position > 3 then
    Req.to_point.dir.x = Conf.position[4] or 0
    Req.to_point.dir.y = Conf.position[5] or 0
    Req.to_point.dir.z = Conf.position[6] or 0
  end
  self.bGMTeleportRsp = false
  self.bEnterSceneFinishNtyAck = false
  _G.NRCEventCenter:RegisterEvent("DebugTabCEConfg", self, _G.SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, Req, self, self.OnZoneSceneGmTeleportRsp, true, false)
end

function DebugTabPerformanceTest:OnZoneSceneGmTeleportRsp(rsp)
  if not self:CheckRetValid(rsp, "\232\183\179\232\189\172\229\156\186\230\153\175\230\137\167\232\161\140\229\164\177\232\180\165...") then
    _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
    return
  end
  self.bGMTeleportRsp = true
  if self.bGMTeleportRsp and self.bEnterSceneFinishNtyAck then
    self:AcquirePet()
  end
end

function DebugTabPerformanceTest:OnEnterSceneFinishNtyAck()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
  self.bEnterSceneFinishNtyAck = true
  if self.bGMTeleportRsp and self.bEnterSceneFinishNtyAck then
    self:AcquirePet()
  end
end

function DebugTabPerformanceTest:AcquirePet()
  local Conf = CurrentConf
  local Pets = Conf.magic_book_pet
  if not Pets or 0 == #Pets then
    self:SetRoleLevel(nil, "")
    return
  end
  local Index = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin % 3 + 1
  Log.Error("Show Index", Index)
  InitPetID = Pets[Index]
  local opItemReq = ProtoMessage.newZoneGmOperateItemReq()
  opItemReq.op_type = ProtoEnum.OpType.OT_ADD
  opItemReq.item_type = ProtoEnum.GoodsType.GT_PET
  opItemReq.item_id = InitPetID
  opItemReq.item_num = 1
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPERATE_ITEM_REQ, opItemReq, self, self.AcquireMagicBook, true, false)
end

function DebugTabPerformanceTest:AcquireMagicBook(rsp)
  if not self:CheckRetValid(rsp, "\229\143\145\233\128\129\229\136\157\229\167\139\231\178\190\231\129\181\229\164\177\232\180\165...") then
    return
  end
  local req = _G.ProtoMessage:newZoneGmSelectAdventurePetReq()
  req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  req.pet_conf_id = InitPetID
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SELECT_ADVENTURE_PET_REQ, req, self, self.SetRoleLevel, true, false)
end

function DebugTabPerformanceTest:SetRoleLevel(rsp)
  if not self:CheckRetValid(rsp, "\232\167\163\233\148\129\233\173\148\229\138\155\228\185\139\230\186\144\229\164\177\232\180\165...") then
    return
  end
  local Conf = CurrentConf
  if 0 == Conf.role_level then
    self:SetWorldLevel()
    return
  end
  local Req = ProtoMessage:newZoneGmSetPlayerLevelReq()
  Req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  Req.level = Conf.role_level
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SET_PLAYER_LEVEL_REQ, Req, self, self.SetWorldLevel, true, false)
end

function DebugTabPerformanceTest:SetWorldLevel(rsp)
  if not self:CheckRetValid(rsp, "\232\174\190\231\189\174\233\173\148\230\179\149\231\173\137\231\186\167\229\164\177\232\180\165...") then
    return
  end
  local Conf = CurrentConf
  if 0 == Conf.world_level then
    self:GetRewards()
    return
  end
  local Req = ProtoMessage:newZoneGmSetPlayerWorldLevelReq()
  Req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  Req.world_level = Conf.world_level
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SET_PLAYER_WORLD_LEVEL_REQ, Req, self, self.GetRewards, true, false)
end

function DebugTabPerformanceTest:GetRewards(rsp)
  if not self:CheckRetValid(rsp, "\232\174\190\231\189\174\231\142\169\229\174\182\230\152\159\233\152\182\231\173\137\231\186\167\229\164\177\232\180\165...") then
    return
  end
  local opItemReq = ProtoMessage.newZoneGmOperateItemReq()
  opItemReq.op_type = ProtoEnum.OpType.OT_ADD
  opItemReq.item_type = ProtoEnum.GoodsType.GT_REWARD
  opItemReq.item_id = CurrentConf.reward_id
  opItemReq.item_num = 1
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPERATE_ITEM_REQ, opItemReq, self, self.AcceptTaskRsp, true, false)
end

function DebugTabPerformanceTest:AcceptTaskRsp(rsp)
  if not self:CheckRetValid(rsp, "\233\162\134\229\143\150\229\136\157\229\167\139\231\164\188\229\140\133\229\164\177\232\180\165...") then
    return
  end
  local acceptTaskReq = ProtoMessage.newZoneGmTaskAddReq()
  acceptTaskReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  acceptTaskReq.task_id = CurrentConf.task_id
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, acceptTaskReq, self, self.UnlockCamp, true, false)
end

function DebugTabPerformanceTest:UnlockCamp(rsp)
  if not self:CheckRetValid(rsp, "\229\143\145\233\128\129\229\136\157\229\167\139\231\178\190\231\129\181\229\164\177\232\180\165...") then
    return
  end
  local Conf = CurrentConf
  local Camps = Conf.unlock_camp
  if not Camps or 0 == #Camps then
    self:AllDone(nil)
    return
  end
  local Req = ProtoMessage:newZoneSceneGmReq()
  Req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  Req.gm_type = ProtoEnum.SceneGmType.SGT_ACTIVE_BONFIRE
  Req.gm_op_type = 1
  Req.rpt_params = Camps
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, self, self.AllDone, true, false)
end

function DebugTabPerformanceTest:AllDone(rsp)
  if not self:CheckRetValid(rsp, "\233\162\134\229\143\150\228\187\187\229\138\161\229\164\177\232\180\165...") then
    return
  end
  self:ClosePanel()
  self:ShowTips(string.format("\230\137\167\232\161\140%s\229\174\140\230\136\144\239\188\129", CurrentConf.button_string))
  CurrentConf = nil
end

function DebugTabPerformanceTest:CheckRetValid(rsp, desc)
  if rsp and rsp.ret_info and 0 ~= rsp.ret_info.ret_code then
    Log.Dump(rsp, 5, "Dump Rsp.............")
    Log.Error(CurrentConf.button_string, rsp.ret_info.ret_code, desc)
    CurrentConf = nil
    self:ClosePanel()
    return false
  end
  return true
end

function DebugTabPerformanceTest:SetUpBornPlaceLocation()
  local SCENE_CONF = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SCENE_CONF):GetAllDatas()
  for ID, SceneConf in pairs(SCENE_CONF) do
    if 103 == SceneConf.id then
      self:Add(string.format("\229\135\186\231\148\159\231\130\185:%d", SceneConf.id), function(Owner)
        self:ClosePanel()
        Owner:SetPlayerLocation(SceneConf.born_pos_x, SceneConf.born_pos_y, SceneConf.born_pos_z)
      end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\228\188\160\233\128\129\232\135\179\229\135\186\231\148\159\231\130\185")
    end
  end
end

function DebugTabPerformanceTest:SetUpCEButtons()
  local GM_BUTTON_CONF = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_BUTTON_CONF)
  for Index, Conf in pairs(GM_BUTTON_CONF:GetAllDatas()) do
    self:Add(Conf.button_string, function()
      self:Run(Conf)
    end, self)
  end
end

return DebugTabPerformanceTest
