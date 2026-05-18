local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local atest = require("Common.Coroutine.async_test")
local pb = require("pb")
local AIComponent = require("NewRoco.Modules.Core.Scene.Component.AI.AIComponent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local AIBlackboardKeyDefine = require("NewRoco.AI.BehaviorTree.Pet.AIBlackboardKeyDefine")
local PendantComponent = require("NewRoco.Modules.Core.Scene.Component.Pendant.PendantComponent")
local Base = DebugTabBase
local allNpcSwitchToServer = false
local DebugTabAI = Base:Extend("DebugTabAI")

function DebugTabAI:Ctor()
  Base.Ctor(self)
  self.npcInsId = 0
  self.isLoggingPerception = false
  self.bDrawCircularPlots = false
end

local LoggingDotsPerformance = false
local RecordingLocalNpc = false

function DebugTabAI:SetupTabs()
  self:Add("\231\187\152\229\136\182\231\178\190\231\129\181\231\155\152\230\151\139\230\159\177", self.DrawCircularPlots, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabAI:NoMoreDamageFromPet()
  GlobalConfig.DisablePetDamage = not GlobalConfig.DisablePetDamage
  Log.WarningFunc(function()
    if GlobalConfig.DisablePetDamage then
      return "\231\178\190\231\129\181\230\148\187\229\135\187\228\188\164\229\174\179\230\151\160\230\149\136\239\188\154\229\183\178\229\144\175\231\148\168"
    else
      return "\231\178\190\231\129\181\230\148\187\229\135\187\228\188\164\229\174\179\230\151\160\230\149\136\239\188\154\229\183\178\229\133\179\233\151\173"
    end
  end)
end

function DebugTabAI:AddSmallPet(name, panel, id)
  if panel then
    local inputText = panel.InputBox:GetText()
    local npcModule = NRCModuleManager:GetModule("NPCModule")
    for i = 1, 1 do
      local num = toNumber(inputText, 10012)
      local npcInfo = self:CreateNpcInfo(num)
      local sceneNPC = npcModule:CreateNpc(npcInfo)
      sceneNPC:EnsureComponent(AIComponent)
      i = i + 1
    end
  elseif id then
    local inputText = id
    local npcModule = NRCModuleManager:GetModule("NPCModule")
    for i = 1, 1 do
      local num = toNumber(inputText, 10012)
      local npcInfo = self:CreateNpcInfo(num)
      local sceneNPC = npcModule:CreateNpc(npcInfo)
      sceneNPC:EnsureComponent(AIComponent)
      i = i + 1
    end
  end
end

function DebugTabAI:AddPetByParam(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if string.IsNilOrEmpty(inputText) then
    Log.Error("\229\143\130\230\149\176\230\160\188\229\188\143\239\188\154 x,y,z,npcId,refId;x,y,z,npcId,refId;...")
    return
  end
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  for item in string.gmatch(inputText, "([%d%.%,-]+)%;") do
    local configIter = string.gmatch(item, "[%d%.-]+")
    local npcInfo = ProtoMessage:newActorInfo_Npc()
    npcInfo.base.actor_id = npcModule:AcquireFakeID()
    npcInfo.base.lv = 1
    npcInfo.base.pt.pos = ProtoMessage:newPosition()
    npcInfo.base.pt.pos.x = tonumber(configIter())
    npcInfo.base.pt.pos.y = tonumber(configIter())
    npcInfo.base.pt.pos.z = tonumber(configIter())
    npcInfo.base.pt.dir = UE.FVector(0, 0, 1)
    npcInfo.npc_base.npc_cfg_id = tonumber(configIter())
    npcInfo.npc_base.npc_content_cfg_id = tonumber(configIter())
    npcModule:CreateNpc(npcInfo)
  end
end

function DebugTabAI:AddManyDotsPet(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText or "" == inputText then
    inputText = "100"
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  local ducknum = 0
  if 1 == #params then
    ducknum = tonumber(params[1])
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
  local ranposlist = self:CreatePosByPosition(player, ducknum)
  Log.Dump(ranposlist)
  local npcIds = {
    10014,
    10015,
    10016
  }
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  for _, pos in pairs(ranposlist) do
    local npcInfo = self:CreateNpcInfoAtPos(npcIds[1 + math.fmod(_, #npcIds)], pos)
    local sceneNPC = npcModule:CreateNpc(npcInfo)
    sceneNPC:EnsureComponent(AIComponent)
  end
end

function DebugTabAI:CreateNpcInfoAtDistance(npcId, distance)
  local npcInfo = ProtoMessage:newActorInfo_Npc()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  npcInfo.base.actor_id = npcModule:AcquireFakeID()
  npcInfo.base.lv = 1
  npcInfo.base.pt.pos = ProtoMessage:newPosition()
  local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
  npcInfo.base.pt.pos.x = player.X + math.random(100 + distance, 300 + distance)
  npcInfo.base.pt.pos.y = player.Y + math.random(100 + distance, 300 + distance)
  npcInfo.base.pt.pos.z = player.Z + 50
  npcInfo.base.pt.dir = UE.FVector(0, 0, 1)
  npcInfo.npc_base.npc_cfg_id = npcId
  npcInfo.npc_base.npc_content_cfg_id = 140382
  return npcInfo
end

function DebugTabAI:CreateNpcAtDistance(npcId, distance)
  local npcInfo = ProtoMessage:newActorInfo_Npc()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  local position = ProtoMessage:newPosition()
  local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
  position.x = player.X + math.random(100 + distance, 300 + distance)
  position.y = player.Y + math.random(100 + distance, 300 + distance)
  position.z = player.Z + 50
  return npcModule:CreateLocalNPC(npcId, position, 0, nil, nil)
end

function DebugTabAI:CreateNpcInfoAtPos(npcId, pos)
  local npcInfo = ProtoMessage:newActorInfo_Npc()
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  npcInfo.base.actor_id = npcModule:AcquireFakeID()
  npcInfo.base.lv = 1
  npcInfo.base.pt.pos = ProtoMessage:newPosition()
  npcInfo.base.pt.pos.x = pos.X
  npcInfo.base.pt.pos.y = pos.Y
  npcInfo.base.pt.pos.z = pos.Z
  npcInfo.base.pt.dir = UE.FVector(0, 0, 1)
  npcInfo.npc_base.npc_cfg_id = npcId
  npcInfo.npc_base.npc_content_cfg_id = 140382
  return npcInfo
end

function DebugTabAI:CreatePosByPosition(playerPos, num, dist)
  local PosDict = {}
  local diskLevel = 1
  local diskTheta = 0
  dist = dist or 200
  for _ = 1, num do
    local circular = 2 * math.pi * diskLevel * 100 + 100
    local theta = math.rad(360 * (diskTheta / circular))
    table.insert(PosDict, {
      X = playerPos.X + dist * diskLevel * math.cos(theta),
      Y = playerPos.Y + dist * diskLevel * math.sin(theta),
      Z = playerPos.Z + 50
    })
    diskTheta = diskTheta + 200
    if circular < diskTheta then
      diskLevel = diskLevel + 1
      diskTheta = 0
    end
  end
  return PosDict
end

function DebugTabAI:CreateNpcInfo(npcId)
  return self:CreateNpcInfoAtDistance(npcId, 0)
end

function DebugTabAI:AddMFBTPet(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText or "" == inputText then
    inputText = "../Test/MFBT_Test/BT_MFBT_UnitTest 750"
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  local distance = 0
  if #params > 1 then
    distance = tonumber(params[2])
  end
  local treePath = "/Game/NewRoco/Modules/AI/BehaviorTree/MFBT/" .. params[1]
  local num = 10012
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  local sceneNPC = self:CreateNpcAtDistance(num, distance)
  local aiComp = sceneNPC:EnsureComponent(AIComponent)
  aiComp._DebugTreePath = treePath
end

function DebugTabAI:AddMFBTPetWithId(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText or "" == inputText then
    inputText = "../Test/MFBT_Test/BT_MFBT_UnitTest 50432"
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  local num = 10047
  num = 10047
  if #params > 1 then
    num = tonumber(params[2])
  end
  local treePath = "/Game/NewRoco/Modules/AI/BehaviorTree/MFBT/" .. params[1]
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  local sceneNPC = self:CreateNpcAtDistance(num, 200)
  sceneNPC.AIComponent._DebugTreePath = treePath
end

function DebugTabAI:SwitchSyncConf(name, panel)
  GlobalConfig.bEnableAISync = not GlobalConfig.bEnableAISync
  if GlobalConfig.bEnableAISync then
    Log.Warning("\229\183\178\229\144\175\231\148\168\228\189\141\233\157\162\228\186\146\232\174\191AI\229\144\140\230\173\165")
  else
    Log.Warning("\229\183\178\231\166\129\231\148\168\228\189\141\233\157\162\228\186\146\232\174\191AI\229\144\140\230\173\165\239\188\140\228\191\157\231\149\153\230\156\172\229\156\176AI")
  end
end

function DebugTabAI:EnableDots(name, panel)
  GlobalConfig.EnableDotsAI = not GlobalConfig.EnableDotsAI
  if GlobalConfig.EnableDotsAI then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\229\183\178\229\144\175\231\148\168Dots\231\179\187\231\187\159")
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\229\183\178\229\133\179\233\151\173Dots\231\179\187\231\187\159")
  end
end

function DebugTabAI:ReleaseNearestNpc()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    return
  end
  if npc:IsLocal() then
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    NPCModule:OnNPCLeave(npc.serverData.base.actor_id)
  else
    local req = _G.ProtoMessage:newZoneSceneClientAiCommandReq()
    req.actor_id = npc:GetServerId()
    req.action_id = _G.ProtoEnum.NpcSceneCommandType.NSC_RELEASE
    local serverPos = ProtoMessage:newPosition()
    local pos = npc:GetActorLocation()
    serverPos.x = math.round(pos.X)
    serverPos.y = math.round(pos.Y)
    serverPos.z = math.round(pos.Z)
    req.pos = serverPos
    _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_CLIENT_AI_COMMAND_REQ, req, false)
  end
end

function DebugTabAI:VisualSpawnNpc()
  GlobalConfig.VisualSpawningNpc = not GlobalConfig.VisualSpawningNpc
  Log.Error("\229\136\135\230\141\162\229\149\134\229\186\151\232\161\151\229\150\181\229\150\181\231\148\159\230\136\144", GlobalConfig.VisualSpawningNpc)
end

function DebugTabAI:MarkDebugFocus()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc then
    Log.Warning("\230\160\135\230\179\168", npc:DebugNPCNameAndID())
    npc._debugFocused = true
  end
end

function DebugTabAI:AsyncTest()
  local test = a.sync(function(testName)
    a.wait(a.wrap(atest.test_case_overview)())
    a.wait(a.wrap(atest.test_case_custom_task)())
    a.wait(a.wrap(atest.test_case_params)())
    a.wait(a.wrap(atest.test_case_subtask)())
    a.wait(a.wrap(atest.test_case_class_port)())
    a.wait(a.wrap(atest.test_case_lifetime)())
    a.wait(a.wrap(atest.test_case_early_kill)())
    a.wait(a.wrap(atest.test_case_error_unchecked_task)())
    a.wait(a.wrap(atest.test_case_error_unchecked_awaitable)())
    a.wait(a.wrap(atest.test_case_error_handling)())
    a.wait(a.wrap(atest.test_case_error_timeout)())
    a.wait(a.wrap(atest.test_case_trace)())
    a.wait(a.wrap(atest.test_case_cmd)())
    a.wait(a.wrap(atest.test_case_async_load)())
    a.wait(a.wrap(atest.test_case_promise)())
    return string.format("%s completed.", testName)
  end)
  Log.Debug("AsyncTest Begin")
  au.LaunchWithTimeout(test("AsyncTest"), 60, function(status, messageOrResult)
    if status then
      Log.Debug(messageOrResult)
    else
      Log.Error(messageOrResult)
    end
    print("===ALL TEST END===")
  end)
end

function DebugTabAI:TableCalc()
  UE.NPCUtils.RecordCurrentObjects()
end

function DebugTabAI:FakeEnterByTag()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local actor = _G.ProtoMessage:newActorInfo()
  actor.npc.npc_base.npc_content_cfg_id = 120000010
  actor.npc.npc_base.npc_cfg_id = 63003
  actor.npc.npc_base.pos_need_adjust = false
  actor.npc.npc_base.weight = 100
  actor.npc.base.name = "\231\156\160\230\158\173test"
  actor.npc.base.actor_id = 130002149488
  actor.npc.base.lv = 1
  actor.npc.base.pt.pos.x = 378105
  actor.npc.base.pt.pos.y = 624058
  actor.npc.base.pt.pos.z = 630
  actor.npc.base.pt.dir.z = 0
  actor.npc.base.pt.dir.x = 0
  actor.npc.base.pt.dir.y = 0
  NPCModule:OnNPCEnter(actor, false)
end

function DebugTabAI:FakeLeaveByTag()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  NPCModule:OnNPCLeave(130002149488)
end

function DebugTabAI:FakePendantChange()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  local pendantComp = npc:GetComponent(PendantComponent)
  if pendantComp and #pendantComp.pendantGroups > 0 then
    local group = pendantComp.pendantGroups[1]
    local changelist = {}
    for _, item in pairs(group.pendantStates) do
      table.insert(changelist, {
        id = _,
        enable = math.random(1, 10) > 5
      })
    end
    pendantComp:ApplyGroupChange(group, not group.enabled, changelist, 1)
  end
end

function DebugTabAI:SwitchAIConfig(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if string.IsNilOrEmpty(inputText) then
    inputText = "10047"
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.AIComponent then
    npc.AIComponent:DebugOverrideAIInfo(tonumber(inputText) or inputText)
  end
end

function DebugTabAI:SwitchAI_CS(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.AIComponent then
    if npc.AIComponent.isServerAI then
      local req = ProtoMessage:newZoneGmSwitchServerAiToClientReq()
      table.insert(req.actor_list, npc:GetServerId())
      _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SWITCH_SERVER_AI_TO_CLIENT_REQ, req, false)
    else
      local req = _G.ProtoMessage:newZoneGmSwitchClientAiToServerReq()
      local DotsCompData = npc.AIComponent:GetDotsData()
      if DotsCompData then
        table.insert(req.actor_list, npc:GetServerId())
        local DotsDatas = _G.ProtoMessage:newDotsComponentData()
        for HashID, Data in pairs(DotsCompData) do
          local CompData = _G.ProtoMessage:newBytesData()
          CompData.id = HashID
          CompData.data = Data
          table.insert(DotsDatas.component_datas, CompData)
        end
        table.insert(req.comp_data_list, DotsDatas)
        table.insert(req.point_list, npc:GetServerPoint())
      end
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SWITCH_CLIENT_AI_TO_SERVER_REQ, req, self, self.SwitchClientToServerAiRsp, false, true)
    end
  end
end

function DebugTabAI:SwitchClientToServerAiRsp(rsp)
  if rsp.success_list then
    for _, actor_id in ipairs(rsp.success_list) do
      local npc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, actor_id)
      if npc and npc.AIComponent then
        npc.AIComponent:SwitchToServerAI()
        Log.Warning("[SceneAI] npc switch to server AI", npc:GetServerPoint())
      end
    end
  end
end

function DebugTabAI:SwitchAI_CS_All(name, panel)
  local req
  if allNpcSwitchToServer then
    req = _G.ProtoMessage:newZoneGmSwitchClientAiToServerReq()
  else
    req = _G.ProtoMessage:newZoneGmSwitchServerAiToClientReq()
  end
  if nil == req then
    return
  end
  req.isBatchSwitch = true
  local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
  for _, npc in pairs(npcs) do
    if npc and npc.AIComponent then
      if npc.AIComponent.isServerAI then
        if false == allNpcSwitchToServer then
          table.insert(req.actor_list, npc:GetServerId())
        end
      elseif allNpcSwitchToServer then
        local DotsCompData = npc.AIComponent:GetDotsData()
        if DotsCompData then
          table.insert(req.actor_list, npc:GetServerId())
          local DotsDatas = _G.ProtoMessage:newDotsComponentData()
          for HashID, Data in pairs(DotsCompData) do
            local CompData = _G.ProtoMessage:newBytesData()
            CompData.id = HashID
            CompData.data = Data
            table.insert(DotsDatas.component_datas, CompData)
          end
          table.insert(req.comp_data_list, DotsDatas)
          table.insert(req.point_list, npc:GetServerPoint())
        end
      end
    end
  end
  if allNpcSwitchToServer then
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SWITCH_CLIENT_AI_TO_SERVER_REQ, req, self, self.AllSwitchClientToServerAiRsp, false, true)
  else
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SWITCH_SERVER_AI_TO_CLIENT_REQ, req, self, self.AllSwitchServerAiToClientRsp, false, true)
  end
  local tipsContent = "\230\137\128\230\156\137npc\231\154\132ai\229\176\134\229\136\135\230\141\162\232\135\179\239\188\154"
  if allNpcSwitchToServer then
    tipsContent = tipsContent .. "\230\156\141\229\138\161\231\171\175"
  else
    tipsContent = tipsContent .. "\229\174\162\230\136\183\231\171\175"
  end
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, tipsContent, 1, nil, 5)
  allNpcSwitchToServer = not allNpcSwitchToServer
  UE4.UNewRocoHelperLibrary.EnsureGameDebuggerToolEnabled(UE4Helper.GetCurrentWorld())
end

function DebugTabAI:AllSwitchClientToServerAiRsp(rsp)
  if rsp.success_list then
    for _, actor_id in ipairs(rsp.success_list) do
      local npc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, actor_id)
      if npc and npc.AIComponent then
        npc.AIComponent:SwitchToServerAI()
        Log.Debug("[DebugTabAI] npc switch to server AI", actor_id, npc.config.id, npc:GetServerPoint())
      end
    end
  end
end

function DebugTabAI:AllSwitchServerAiToClientRsp(rsp)
  if rsp.success_list then
    for _, actor_id in ipairs(rsp.success_list) do
      local npc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, actor_id)
      if npc and npc.AIComponent then
        Log.Debug("[DebugTabAI] npc switch to client AI", actor_id, npc.config.id, npc:GetServerPoint())
      end
    end
  end
end

function DebugTabAI:CalcNavArea()
  UE.UNRCNavLibrary.CalculateNavCellCount(UE4Helper.GetCurrentWorld())
end

local DisabledPerceptionCone = false

function DebugTabAI:DisablePerceptionCone()
  if DisabledPerceptionCone then
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "ai.Dots.DisablePerceptionCone 0")
  else
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "ai.Dots.DisablePerceptionCone 1")
  end
end

local MarkedPointA = _G.ProtoMessage:newPosition()

function DebugTabAI:ValidatePathPointA(name, panel)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    Log.Error("ValidatePath: cant find local player")
    return
  end
  local Pos = player:GetActorLocation()
  MarkedPointA.x = Pos.X
  MarkedPointA.y = Pos.Y
  MarkedPointA.z = Pos.Z
  Log.PrintScreenMsg("\229\183\178\231\187\143\232\174\176\229\189\149\231\130\185A\239\188\140\232\175\183\231\167\187\229\138\168\229\136\176B\231\130\185\232\191\155\232\161\140\232\183\175\229\190\132\230\163\128\230\181\139")
end

function DebugTabAI:ValidatePathPointB(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local Req = _G.ProtoMessage:newZoneSceneGmReq()
  if string.IsNilOrEmpty(inputText) and MarkedPointA.x and 0 ~= MarkedPointA.x then
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if not player then
      Log.Error("ValidatePath: cant find local player")
      return
    end
    table.insert(Req.rpt_params, math.floor(MarkedPointA.x))
    table.insert(Req.rpt_params, math.floor(MarkedPointA.y))
    table.insert(Req.rpt_params, math.floor(MarkedPointA.z))
    local CurPos = player:GetActorLocation()
    table.insert(Req.rpt_params, math.floor(CurPos.X))
    table.insert(Req.rpt_params, math.floor(CurPos.Y))
    table.insert(Req.rpt_params, math.floor(CurPos.Z))
  else
    for w in string.gmatch(inputText, "%S+") do
      table.insert(Req.rpt_params, math.floor(tonumber(w)))
    end
    if #Req.rpt_params < 6 then
      Log.Error("ValidatePath: invalid input")
      return
    end
  end
  Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_GEN_NAV_FIND_PATH
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, self, self.NavFindPathRsp, false, true)
end

function DebugTabAI:NavFindPathRsp(rsp)
  Log.PrintScreenMsg("A\231\130\185\229\136\176\229\189\147\229\137\141\228\189\141\231\189\174\231\154\132\232\183\175\229\190\132\230\163\128\230\181\139\229\174\140\230\136\144")
  if 0 ~= rsp.ret_info.ret_code then
    Log.PrintScreenMsg("result: \230\151\160\230\179\149\230\137\190\229\136\176\232\183\175\229\190\132")
    return
  end
  local info = pb.decode(".Next.NavFindPathInfo", rsp.ret_value)
  if #info.pos < 2 then
    Log.PrintScreenMsg("result: \228\184\141\229\144\136\230\179\149\239\188\140\229\155\158\229\140\133\229\143\170\230\156\1371\228\184\170\231\130\185")
    return
  end
  local lastPoint = SceneUtils.ServerPos2ClientPos(info.pos[1])
  for i = 2, #info.pos do
    local point = SceneUtils.ServerPos2ClientPos(info.pos[i])
    UE.UKismetSystemLibrary.Abs_DrawDebugLine(UE4Helper.GetCurrentWorld(), lastPoint, point, UE.FLinearColor(0, 1, 0, 1), 30.0, 5)
    lastPoint = point
  end
  Log.PrintScreenMsg("result: \229\183\178\230\152\190\231\164\186\232\183\175\229\190\132")
end

function DebugTabAI:ChangeBossBarrierVal(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  local args = string.split(inputText, " ")
  local argsLen = #args
  if argsLen >= 1 and "" ~= args[1] then
    table.insert(req.rpt_params, tonumber(args[1]))
  end
  if argsLen >= 2 and "" ~= args[2] then
    table.insert(req.rpt_params, tonumber(args[2]))
  end
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_CHANGE_BOSS_BARRIER_BUFF_VAL
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, false)
end

function DebugTabAI:AddOffsetToDebugBornTime(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local offset_min = tonumber(inputText)
  if offset_min then
    _G.SceneAIUtils.DEBUG_BORN_TIME_OFFSET_SEC = math.floor(offset_min * 60000)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format("\228\189\191\231\148\168\233\154\143\230\156\186\230\177\160\229\136\155\229\187\186AI\230\151\182\239\188\140\229\129\135\232\174\190\229\135\186\231\148\159\230\151\182\233\151\180\229\156\168%d\229\136\134\233\146\159\228\185\139\229\137\141", offset_min))
  end
end

local Tracer = NRCClass("Tracer")

function Tracer:Ctor()
  self.Step = 5
  self.Count = 200
  self.TraceWard = UE.FVector(0, 0, -500)
  self.Location = nil
  self.Forward = nil
  self.enabled = false
end

function Tracer:ToggleEnable()
  self:SetEnable(not self.enabled)
end

function Tracer:SetEnable(e)
  if self.enabled ~= e then
    self.enabled = e
    if e then
      UpdateManager:Register(self)
    else
      UpdateManager:UnRegister(self)
    end
  end
end

function Tracer:OnTick()
  if not self.Location then
    return
  end
  if not self.Forward then
    return
  end
  for i = 1, self.Count do
    local Start = self.Location + self.Forward * (i - 1) * self.Step
    local End = Start + self.TraceWard
    self:TraceAndDraw(Start, End)
  end
end

local HitResult = UE.FHitResult()

function Tracer:TraceAndDraw(Start, End)
  local world = UE4Helper.GetCurrentWorld()
  local TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel5)
  UE.UKismetSystemLibrary.LineTraceSingle(world, Start, End, TraceChannel, false, nil, nil, HitResult, true)
  if HitResult.bBlockingHit then
    UE.UKismetSystemLibrary.DrawDebugLine(world, Start, HitResult.ImpactPoint, UE.FLinearColor(1, 1, 0, 1), 0, 1)
    UE.UKismetSystemLibrary.DrawDebugLine(world, HitResult.ImpactPoint, End, UE.FLinearColor(1, 0, 0, 1), 0, 1)
  else
    UE.UKismetSystemLibrary.DrawDebugLine(world, Start, End, UE.FLinearColor(0, 1, 0, 1), 0, 1)
  end
end

local TracerInstance

function DebugTabAI:CollisionTest(_, _, _)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    Log.Error("CollisionTest: cant find local player")
    return
  end
  local Pos = player.viewObj:K2_GetActorLocation()
  local Forward = player.viewObj:GetActorForwardVector()
  if not TracerInstance or TracerInstance.enabled then
  end
  TracerInstance = TracerInstance or Tracer()
  TracerInstance.Location = Pos
  TracerInstance.Forward = Forward
  TracerInstance:ToggleEnable()
end

local NavDrawer = NRCClass("NavDrawer")

function NavDrawer:Ctor()
  self.enabled = false
end

function NavDrawer:ToggleEnable()
  self:SetEnable(not self.enabled)
end

function NavDrawer:SetEnable(e)
  if self.enabled ~= e then
    self.enabled = e
    if e then
      UpdateManager:Register(self)
    else
      UpdateManager:UnRegister(self)
    end
  end
end

function NavDrawer:OnTick()
  self:DrawPlayerSideNavmesh()
end

function NavDrawer:DrawPlayerSideNavmesh()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:GetActorLocation()
  UE.URocoAIHelper.DrawNeighborNavPoly(player.viewObj, player:GetActorLocation(), 7)
end

local NavDrawerInstance

function DebugTabAI:NavDrawerTest(_, _, _)
  NavDrawerInstance = NavDrawerInstance or NavDrawer()
  NavDrawerInstance:ToggleEnable()
end

function DebugTabAI:stuck()
  local start = os.msTime()
  while not (os.msTime() - start > 1000) do
  end
end

function DebugTabAI:DrawCircularPlots()
  self.bDrawCircularPlots = not self.bDrawCircularPlots
  if self.bDrawCircularPlots then
    _G.UpdateManager:Register(self, true)
    local Info = string.format("CircularPlot \231\187\152\229\136\182\229\183\178\229\188\128\229\144\175\239\188\136\230\175\143\229\184\167\229\136\183\230\150\176\239\188\137")
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
  else
    _G.UpdateManager:UnRegister(self)
    local Info = string.format("CircularPlot \231\187\152\229\136\182\229\183\178\229\133\179\233\151\173")
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
  end
end

function DebugTabAI:OnTick(DeltaTime)
  if self.bDrawCircularPlots then
    self:DrawAllCircularPlots()
  end
end

function DebugTabAI:DrawAllCircularPlots()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local World = _G.UE4Helper.GetCurrentWorld()
  if not NPCModule or not World then
    return
  end
  for _, n in pairs(NPCModule._npcDic) do
    local npc = n
    if npc and npc.BezierFlyComponent then
      local bezFlyComp = npc.BezierFlyComponent
      if bezFlyComp and bezFlyComp.CircularPlot and UE.UObject.IsValid(bezFlyComp.CircularPlot) then
        local plot = bezFlyComp.CircularPlot
        local plotLocation = plot:Abs_K2_GetActorLocation()
        local radius = plot.Radius
        local innerRadius = plot.InnerRadius
        local npcLocation = npc.viewObj and npc.viewObj:Abs_K2_GetActorLocation()
        if npcLocation then
          UE4.UKismetSystemLibrary.Abs_DrawDebugLine(World, plotLocation, npcLocation, UE4.FLinearColor(1, 1, 0, 1), 0, 2)
        end
        local boxCenter = plotLocation + UE4.FVector(0, 0, innerRadius / 2.0)
        local scaleRadius = (radius - innerRadius) * plot.ScaleRatio + innerRadius
        local halfSize = UE4.FVector(scaleRadius, scaleRadius, innerRadius / 2.0)
        UE4.UKismetSystemLibrary.Abs_DrawDebugBox(World, boxCenter, halfSize, UE4.FRotator(0, 0, 0), UE4.FLinearColor(1, 0, 1, 1), 0, 10)
      end
    end
  end
end

return DebugTabAI
