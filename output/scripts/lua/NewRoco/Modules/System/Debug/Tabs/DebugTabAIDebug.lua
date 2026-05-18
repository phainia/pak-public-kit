local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local AIDebuggerComponent = require("NewRoco.Modules.Core.Scene.Component.AI.AIDebuggerComponent")
local pb = require("pb")
local WorldCombatStatus = require("NewRoco.Modules.System.WorldCombat.WorldCombatStatus")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local PetInteractOptionComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PetInteractOptionComponent")
local Base = DebugTabBase
local DebugTabAIDebug = Base:Extend("DebugTabAIDebug")

function DebugTabAIDebug:Ctor()
  Base.Ctor(self)
end

function DebugTabAIDebug:SetupTabs()
  self:Add("\229\174\182\229\155\173\232\129\148\229\167\187\230\181\139\232\175\149", self.HomeMarriageTest, self, nil, nil, nil, nil, "", "", "HomeMarriageTest")
end

function DebugTabAIDebug:PrintStopReason()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    Log.Error("[PrintStopReason] no npc")
  end
  if not npc.AIComponent then
    Log.Error("[PrintStopReason] no AiComp")
  end
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Ctx = DialogContext()
  Ctx:SetContent(npc.AIComponent:GetStopReason())
  Ctx:SetMode(DialogContext.Mode.OK)
  Ctx:SetButtonText("\229\133\179\233\151\173")
  Ctx:SetClickAnywhereClose(true)
  Ctx:SetCloseOnOK(true)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
  self:ClosePanel()
end

function DebugTabAIDebug:ToggleGDT()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "EnableGDT")
end

function DebugTabAIDebug:ToggleGDTCategory(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local cmd = string.format("gdt.ToggleCategory %d", toNumber(inputText, 5))
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), cmd)
end

local DebugContext = {
  bEnabled = false,
  topKNum = 3,
  NpcList = {}
}

function DebugContext:UpdateDebugCandidate(num)
  if self.bEnabled then
    return
  end
  self.bEnabled = true
  self.topKNum = num or 3
  if self.topKNum <= 0 then
    self.topKNum = 3
  end
  self:GetTopKNpc()
end

function DebugContext:StopDebug()
  self.bEnabled = false
  for _, npc in ipairs(self.NpcList) do
    self:ChangeToInvalid(npc)
  end
  table.clear(self.NpcList)
end

function DebugContext:GetTopKNpc()
  if not self.bEnabled then
    return
  end
  local topKNpcs = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetTopKNpcInCpp, self.topKNum, 3000)
  local newNpcList = {}
  for _, topNpc in ipairs(topKNpcs) do
    if self:Validate(topNpc) then
      table.insert(newNpcList, topNpc)
    end
  end
  for _, npc in ipairs(self.NpcList) do
    if not table.contains(newNpcList, npc) then
      self:ChangeToInvalid(npc)
    end
  end
  for _, npc in ipairs(newNpcList) do
    if not table.contains(self.NpcList, npc) then
      self:ChangeToValid(npc)
    end
  end
  self.NpcList = newNpcList
  _G.DelayManager:DelaySeconds(0.2, self.GetTopKNpc, self)
end

function DebugContext:Validate(npc)
  if npc.AIComponent and npc.AIComponent.isServerAI and npc.AIComponent.AIController then
    return true
  end
  return false
end

function DebugContext:ChangeToValid(npc)
  Log.PrintScreenMsg("[ServerCandidate] ChangeToValid %s", npc:DebugNPCNameAndID())
  local Req = _G.ProtoMessage:newZoneSceneGmReq()
  Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_SVR_AI_DEBUG
  Req.param1 = _G.ProtoEnum.SceneSvrAIDebugType.SSADT_OPEN_AI_DEBUG
  Req.param2 = npc:GetServerId()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, self, function(this, rsp)
    if 0 == rsp.ret_info.ret_code then
      npc.AIComponent.AIController:CreateDebugEntity()
    end
  end, false, true)
end

function DebugContext:ChangeToInvalid(npc)
  Log.PrintScreenMsg("[ServerCandidate] ChangeToInvalid %s", npc:DebugNPCNameAndID())
  local Req = _G.ProtoMessage:newZoneSceneGmReq()
  Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_SVR_AI_DEBUG
  Req.param1 = _G.ProtoEnum.SceneSvrAIDebugType.SSADT_OPEN_CLOSE_DEBUG
  Req.param2 = npc:GetServerId()
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req)
  if npc.AIComponent and npc.AIComponent.AIController then
    npc.AIComponent.AIController:RemoveDebugEntity()
  end
end

local LockDebugContext = {
  bEnabled = false,
  NpcList = {},
  TopKFinderId = "LockDebugContext:ServerCandidate",
  TopKNUm = 3
}

function LockDebugContext:UpdateDebugCandidate(num)
  if self.bEnabled then
    self:StopDebug()
  end
  if nil ~= num and type(num) == "number" then
    self.TopKNUm = math.floor(num)
    if self.TopKNUm <= 0 then
      self.TopKNUm = 3
    end
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  NPCModule:RegisterTopKFinder(self.TopKFinderId, self.TopKNUm, self, self.Validate, self, self.Validate, nil, nil, self, self.ChangeToValid, nil, nil)
  self.bEnabled = true
end

function LockDebugContext:StopDebug()
  if self.bEnabled then
    for _, npc in ipairs(self.NpcList) do
      self:ChangeToInvalid(npc)
    end
    table.clear(self.NpcList)
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    NPCModule:UnRegisterTopKFinder(self.TopKFinderId)
    self.bEnabled = false
  end
end

function LockDebugContext:Validate(npc)
  if npc.AIComponent and npc.AIComponent.isServerAI and npc.AIComponent.AIController then
    return true
  end
  return false
end

function LockDebugContext:ChangeToValid(npc)
  table.insert(self.NpcList, npc)
  if #self.NpcList >= self.TopKNUm then
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    NPCModule:UnRegisterTopKFinder(self.TopKFinderId)
  end
  Log.PrintScreenMsg("[LockDebugContext] ChangeToValid %s", npc:DebugNPCNameAndID())
  local Req = _G.ProtoMessage:newZoneSceneGmReq()
  Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_SVR_AI_DEBUG
  Req.param1 = _G.ProtoEnum.SceneSvrAIDebugType.SSADT_OPEN_AI_DEBUG
  Req.param2 = npc:GetServerId()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, self, function(this, rsp)
    if 0 == rsp.ret_info.ret_code then
      npc.AIComponent.AIController:CreateDebugEntity()
    end
  end, false, true)
end

function LockDebugContext:ChangeToInvalid(npc)
  Log.PrintScreenMsg("[LockDebugContext] ChangeToInvalid %s", npc:DebugNPCNameAndID())
  local Req = _G.ProtoMessage:newZoneSceneGmReq()
  Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_SVR_AI_DEBUG
  Req.param1 = _G.ProtoEnum.SceneSvrAIDebugType.SSADT_OPEN_CLOSE_DEBUG
  Req.param2 = npc:GetServerId()
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req)
  if npc.AIComponent and npc.AIComponent.AIController then
    npc.AIComponent.AIController:RemoveDebugEntity()
  end
end

function DebugTabAIDebug:BeginDebug(name, panel)
  UE4.UNewRocoHelperLibrary.EnsureGameDebuggerToolEnabled(UE4Helper.GetCurrentWorld())
  LockDebugContext:StopDebug()
  DebugContext:UpdateDebugCandidate(panel:GetInputNumber())
end

function DebugTabAIDebug:EndDebug(name, panel)
  DebugContext:StopDebug()
  LockDebugContext:StopDebug()
  local Req = _G.ProtoMessage:newZoneSceneGmReq()
  Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_SVR_AI_DEBUG
  Req.param1 = _G.ProtoEnum.SceneSvrAIDebugType.SSADT_OPEN_CLOSE_DEBUG
  Req.param2 = 0
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req)
end

function DebugTabAIDebug:ToggleLuaBTDebug(name, panel)
  _G.GlobalConfig.DebugLuaBTree = not _G.GlobalConfig.DebugLuaBTree
  UE.URocoMFBTUtils.SetEnableDebug(_G.GlobalConfig.DebugLuaBTree)
  if _G.GlobalConfig.DebugLuaBTree and _G.TipsModuleCmd then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\227\128\144ToggleLuaBTDebug\227\128\145 1 - \229\183\178\229\144\175\231\148\168LuaBT\232\176\131\232\175\149")
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\227\128\144ToggleLuaBTDebug\227\128\145 0 - \229\183\178\231\166\129\231\148\168LuaBT\232\176\131\232\175\149")
  end
end

function DebugTabAIDebug:SwitchPerceptionLogging(name, panel)
  GlobalConfig.LoggingPerception = not GlobalConfig.LoggingPerception
  if GlobalConfig.LoggingPerception then
    Log.Error("\229\188\128\229\144\175\230\132\159\231\159\165Log")
    DelayManager:DelaySeconds(1, self.LogPerception, self)
  else
    Log.Error("\229\133\179\233\151\173\230\132\159\231\159\165Log")
  end
end

function DebugTabAIDebug:LogPerception(name, panel)
  Log.Error("\230\173\164GM\229\138\159\232\131\189\229\183\178\232\162\171AI\233\157\162\230\157\191\232\166\134\231\155\150\239\188\140\232\175\183\228\189\191\231\148\168AI\233\157\162\230\157\191\232\167\130\230\181\139\230\132\159\231\159\165\229\128\188")
  if GlobalConfig.LoggingPerception then
    DelayManager:DelaySeconds(1, self.LogPerception, self)
  else
    return
  end
end

function DebugTabAIDebug:AiDebugRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    Log.Error(rsp.ret_info.ret_msg)
  else
    Log.Error("\232\142\183\229\143\150\230\156\141\229\138\161\229\153\168AI\230\132\159\231\159\165\228\191\161\230\129\175\229\164\177\232\180\165")
  end
end

function DebugTabAIDebug:ClearPerception(name, panel)
  UE.UDotsStatics.DebugClearPerception(_G.UE4Helper.GetCurrentWorld())
  local haveAnyServerAi = false
  local NPCs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPCInIter)
  for _, npc in pairs(NPCs) do
    if npc.AIComponent and npc.AIComponent.isServerAI then
      haveAnyServerAi = true
      break
    end
  end
  if haveAnyServerAi then
    local Req = _G.ProtoMessage:newZoneSceneGmReq()
    Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_SVR_AI_CLEAR_PERCEP
    _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, false)
  end
end

local RecordingLocalNpc = false

function DebugTabAIDebug:SwitchQueryFillLocActors()
  RecordingLocalNpc = not RecordingLocalNpc
  if RecordingLocalNpc then
    Log.Error("\229\188\128\229\167\139\229\144\140\230\173\165\233\184\159\231\158\176\229\155\190(1\231\167\146/\230\172\161)")
    DelayManager:DelaySeconds(1, self.QueryFullLocActors, self)
  else
    Log.Error("\229\129\156\230\173\162\229\144\140\230\173\165\233\184\159\231\158\176\229\155\190")
  end
end

function DebugTabAIDebug:QueryFullLocActors()
  if RecordingLocalNpc then
    DelayManager:DelaySeconds(1, self.QueryFullLocActors, self)
  else
    return
  end
  local DotsInsightsSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(UE4Helper.GetCurrentWorld(), UE.UDotsInsightsSubSystem)
  local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPCInIter)
  for _, v in pairs(npcs) do
    local tag = 0
    local lod = 0
    if v.AIComponent and v.AIComponent:IsAILoaded() then
      tag = tag | AIDefines.EInsightsUnitTag.EInsightsUnitTag_AI
      if v.AIComponent.AIController and v.AIComponent.AIController.enableDots then
        tag = tag + AIDefines.EInsightsUnitTag.EInsightsUnitTag_Dots
      else
        lod = lod + 1
      end
      if v.AIComponent.isServerAI then
        tag = tag + AIDefines.EInsightsUnitTag.EInsightsUnitTag_Server
      end
    else
      lod = lod + 1
    end
    DotsInsightsSubSystem:RecordUnit(v.serverData.base.actor_id, v:GetActorLocation(), tag, v.config.id, lod, false)
  end
end

function DebugTabAIDebug:QueryFullSvrActors(name, panel, InputText)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  if NPCModule.client_vis_nty_count and NPCModule.client_vis_nty_count > 0 then
    Log.Error("\228\187\141\230\156\137\230\149\176\230\141\174\230\173\163\229\156\168\228\188\160\232\190\147\228\184\173\239\188\140\232\175\183\229\139\191\233\135\141\230\150\176\229\143\145\232\181\183\232\175\183\230\177\130")
  end
  NPCModule.client_vis_nty_count = 1
  local queryScene = SceneUtils.GetSceneID()
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if not string.IsNilOrEmpty(inputText) then
    queryScene = tonumber(inputText)
  end
  local Req = _G.ProtoMessage:newZoneSceneGmReq()
  Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_SVR_AI_VISUALIZATION
  Req.param1 = queryScene
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, self, self.QueryFullSvrActorsRsp, false, false)
end

function DebugTabAIDebug:QueryFullSvrActorsRsp(rsp)
  if rsp and 0 == rsp.ret_info.ret_code then
    local info = pb.decode(".Next.DotsServerAIVisualizationInfo", rsp.ret_value)
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    if 0 == info.cur_rsp_index then
      local DotsInsightsSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(UE4Helper.GetCurrentWorld(), UE.UDotsInsightsSubSystem)
      DotsInsightsSubSystem:RecordUnitCount(info.total_ai_count, true)
      NPCModule.client_vis_nty_count = info.total_rsp_num
    end
    NPCModule:OnNet_ClientVisualizationNty(info)
  end
end

function DebugTabAIDebug:PrintCurrentBehavior(name, panel)
  do return Log.Error("\228\189\191\231\148\168ai\232\176\131\232\175\149\233\157\162\230\157\191\228\187\163\230\155\191") end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.AIComponent and npc.AIComponent:IsActive() then
    local index, behaviorGroupId = npc.AIComponent.AIController:GetCurrentBehaviorGroup()
    local conf = _G.DataConfigManager:GetNrcAiBehaviorGroupConf(behaviorGroupId, true)
    if conf then
      Log.Error(npc.config.name, "\230\173\163\229\156\168\230\137\167\232\161\140\232\161\140\228\184\186\231\187\132", behaviorGroupId, conf.editor_name)
      local behaviorId = conf.behavior_info[index + 1].behavior_id
      local conf1 = _G.DataConfigManager:GetNrcAiBehaviorConf(behaviorId, true)
      Log.Error(npc.config.name, "\230\173\163\229\156\168\230\137\167\232\161\140\232\161\140\228\184\186", behaviorId, conf1.editor_name, conf1.tree_name)
      npc.AIComponent:OverrideBehavior(behaviorId, 0)
    else
      Log.Error(npc.config.name, "\230\173\163\229\156\168\230\137\167\232\161\140\230\156\170\231\159\165\232\161\140\228\184\186\231\187\132", behaviorGroupId)
    end
  else
    Log.Error("\233\153\132\232\191\145\230\178\161\230\156\137npc with ai")
  end
end

function DebugTabAIDebug:ShowControlFlagAndBattleStatus()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc then
    local hasComp = npc:GetComponent(AIDebuggerComponent)
    if hasComp then
      npc:RemoveComponent(AIDebuggerComponent)
    else
      npc:EnsureComponent(AIDebuggerComponent)
    end
  end
end

function DebugTabAIDebug:DrawPointSet(name, panel, id)
  if panel then
    local idRec
    local inputText = panel.InputBox:GetText()
    if not string.IsNilOrEmpty(inputText) then
      idRec = tonumber(inputText)
    end
    if not idRec then
      Log.Error("\232\175\183\232\190\147\229\133\165\230\173\163\231\161\174\231\154\132AreaId")
      return
    end
    local areaConf = _G.DataConfigManager:GetAreaConf(idRec, true)
    if not areaConf then
      Log.Error("AreaId\228\184\141\229\173\152\229\156\168")
      return
    end
    local prevVec
    for _, pos in ipairs(areaConf.pos) do
      local vec = UE.FVector(pos.position_xyz[1], pos.position_xyz[2], pos.position_xyz[3])
      if prevVec then
        UE.UKismetSystemLibrary.Abs_DrawDebugString(UE4Helper.GetCurrentWorld(), vec + UE.FVector(0, 0, 50), tostring(_), nil, UE.FLinearColor.White, 130)
        UE.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), vec, 10, 3, UE.FLinearColor(1, 0, 0), 130, 3)
        UE.UKismetSystemLibrary.Abs_DrawDebugLine(UE4Helper.GetCurrentWorld(), prevVec, vec, UE.FLinearColor.White, 130, 3)
      end
      prevVec = vec
    end
  elseif id then
    local idRec
    idRec = id
    if not idRec then
      Log.Error("\232\175\183\232\190\147\229\133\165\230\173\163\231\161\174\231\154\132AreaId")
      return
    end
    local areaConf = _G.DataConfigManager:GetAreaConf(idRec, true)
    if not areaConf then
      Log.Error("AreaId\228\184\141\229\173\152\229\156\168")
      return
    end
    local prevVec
    for _, pos in ipairs(areaConf.pos) do
      local vec = UE.FVector(pos.position_xyz[1], pos.position_xyz[2], pos.position_xyz[3])
      if prevVec then
        UE.UKismetSystemLibrary.Abs_DrawDebugLine(UE4Helper.GetCurrentWorld(), prevVec, vec, UE.FLinearColor.White, 30, 3)
      end
      prevVec = vec
    end
  end
end

function DebugTabAIDebug:DebugNearBlackboard(Name, Panel)
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    Log.Debug("WorldCombatModule:GetNearestBlackboard. GetNearestNPC is nil")
    return
  end
  
  local function callback(caller, rsp)
    if 0 ~= rsp.ret_info.ret_code then
      Log.Debug("ZoneSceneGmQueryNpcBlackboardRsp ret_code error", rsp.ret_info.ret_code)
      return
    end
    if rsp.blackboard_infos == nil or #rsp.blackboard_infos <= 0 then
      Log.Debug("ZoneSceneGmQueryNpcBlackboardRsp blackboard_infos length is invalid ", #rsp.blackboard_infos)
      return
    end
    local blackboardInfo = rsp.blackboard_infos[1]
    local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, blackboardInfo.actor_id)
    if not npc then
      Log.Debug("ZoneSceneGmQueryNpcBlackboardRsp npc is invalid ", blackboardInfo.actor_id)
      return
    end
    local blackboardStrings = string.split(blackboardInfo.blackboard_str, ";")
    local blackboardStr = ""
    for _, str in pairs(blackboardStrings) do
      blackboardStr = blackboardStr .. str .. "\n"
    end
    blackboardStr = string.sub(blackboardStr, 1, -1)
    local Info = string.format("npc\228\191\161\230\129\175: %d, %s", npc.serverData.base.actor_id, npc.serverData.base.name)
    Info = Info .. string.format("\nnpc\233\133\141\231\189\174: %d, %s", npc.config.id, npc.config.name)
    Info = Info .. string.format("\nnpc\228\189\141\231\189\174: (%f, %f, %f)", npc.serverData.base.pt.pos.x, npc.serverData.base.pt.pos.y, npc.serverData.base.pt.pos.z)
    Info = Info .. string.format("\n\233\187\145\230\157\191\228\191\161\230\129\175: %s", blackboardStr)
    local Ctx = DialogContext()
    Ctx:SetContent(Info)
    Ctx:SetMode(DialogContext.Mode.OK)
    Ctx:SetButtonText("\231\161\174\232\174\164")
    Ctx:SetClickAnywhereClose(true)
    Ctx:SetCloseOnOK(true)
    Ctx:SetCloseOnCancel(true)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
    UE4.UNRCStatics.ClipboardCopy(Info)
    Log.Debug("\230\137\147\229\141\176\230\156\128\232\191\145\233\187\145\230\157\191\229\128\188", Info)
  end
  
  local req = _G.ProtoMessage.newZoneSceneGmQueryNpcBlackboardReq()
  table.insert(req.actor_list, npc:GetServerId())
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_QUERY_NPC_BLACKBOARD_REQ, req, npc, callback, true, true)
end

function DebugTabAIDebug:LockNearBlackboard(Name, Panel)
  UE4.UNewRocoHelperLibrary.EnsureGameDebuggerToolEnabled(UE4Helper.GetCurrentWorld())
  DebugContext:StopDebug()
  LockDebugContext:UpdateDebugCandidate(Panel:GetInputNumber())
end

function DebugTabAIDebug:ShowReasonNotEnterBattle(Name, Panel)
  local WorldCombatModule = _G.NRCModuleManager:GetModule("WorldCombatModule")
  if nil == WorldCombatModule then
    return
  end
  local Info = string.format("WorldCombatStatus\229\128\188\228\184\186: %s", table.getKeyName(WorldCombatStatus, WorldCombatModule.Status))
  Info = Info .. string.format("\nbInBattle\229\128\188\228\184\186: %s", tostring(WorldCombatModule.bInBattle))
  Info = Info .. string.format("\nCheckCanEnterWorldCombat\229\128\188\228\184\186: %s", tostring(WorldCombatModule:CheckCanEnterWorldCombat()))
  Info = Info .. string.format("\nIsInNightmare\229\128\188\228\184\186: %s", tostring(_G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsInNightmare)))
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if LocalPlayer and LocalPlayer.LogicStatusComponent then
    local StatusInfo = "\n\231\142\169\229\174\182\231\154\132\231\138\182\230\128\129\230\152\175\239\188\154"
    for _, status in pairs(LocalPlayer.LogicStatusComponent.StatusInfo) do
      StatusInfo = StatusInfo .. string.format("\t%s", table.getKeyName(_G.Enum.SpaceActorLogicStatus, status.status))
    end
    Info = Info .. StatusInfo
  end
  local Ctx = DialogContext()
  Ctx:SetContent(Info)
  Ctx:SetMode(DialogContext.Mode.OK)
  Ctx:SetButtonText("\229\183\178\233\152\133")
  Ctx:SetClickAnywhereClose(true)
  Ctx:SetCloseOnOK(true)
  Ctx:SetCloseOnCancel(true)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
  self:ClosePanel()
end

function DebugTabAIDebug:WorldCombatDrawDebug()
  local WorldCombatModule = _G.NRCModuleManager:GetModule("WorldCombatModule")
  if nil == WorldCombatModule then
    return
  end
  WorldCombatModule.bDrawDebugFlag = not WorldCombatModule.bDrawDebugFlag
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("debug\231\138\182\230\128\129\239\188\154%s", tostring(WorldCombatModule.bDrawDebugFlag)), 1, nil, 5)
end

function DebugTabAIDebug:GetAIServerError()
  local WorldCombatModule = _G.NRCModuleManager:GetModule("WorldCombatModule")
  if nil == WorldCombatModule then
    return
  end
  WorldCombatModule:SwitchAIServerError()
end

function DebugTabAIDebug:WorldCombatServerDebugDraw()
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_DEBUG_DRAW
  req.param1 = 0
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, false)
end

function DebugTabAIDebug:WorldCombatOneKeyDebug()
  self:WorldCombatDrawDebug()
  self:GetAIServerError()
  self:WorldCombatServerDebugDraw()
end

local HomePetAttributeComponent

function DebugTabAIDebug:PrintFriendliness()
  if nil == HomePetAttributeComponent then
    HomePetAttributeComponent = require("NewRoco.Modules.System.Home.HomePetFeed.HomePetAttributeComponent")
  end
  local homePetInfo = {}
  local npcs = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
  for _, npc in pairs(npcs) do
    if npc.config.npc_role_type == _G.Enum.PetRoleTypeInNPCConf.PRTINC_HOME then
      table.insert(homePetInfo, npc.serverData)
    elseif npc:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_HOME_PET_GUARD) then
      table.insert(homePetInfo, npc.serverData)
    end
  end
  if #homePetInfo > 0 then
    local PlayerModule = _G.NRCModuleManager:GetModule("PlayerModule")
    local players = PlayerModule._playerDic
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if not npcs then
      Log.PrintScreenMsgRed("[\229\143\139\229\165\189\229\186\166] \230\178\161\230\156\137NPC")
      return
    end
    local Lines = {}
    local PlayerList = {}
    local PlayerIdList = {}
    table.insert(PlayerList, "local")
    table.insert(PlayerIdList, localPlayer:GetServerId())
    for _, player in pairs(players) do
      if not player.isLocal then
        table.insert(PlayerList, player:GetLogicId())
        table.insert(PlayerIdList, player:GetServerId())
      end
    end
    table.insert(Lines, string.format("[\229\143\139\229\165\189\229\186\166] \229\174\182\229\155\173\230\137\128\230\156\137\231\178\190\231\129\181\229\175\185\230\137\128\230\156\137\231\142\169\229\174\182\231\154\132\229\143\139\229\165\189\229\186\166\n%-10s| %-20s| %-10s", "\231\178\190\231\129\181", "ID", string.format(("%-10s"):rep(#PlayerList), table.unpack(PlayerList))))
    for _, petInfo in pairs(homePetInfo) do
      local npc = npcs[petInfo.base.actor_id]
      if npc then
        local AttrComp = npc:EnsureComponent(HomePetAttributeComponent)
        local fmt = ""
        local arg = {}
        for _, playerId in ipairs(PlayerIdList) do
          local val = AttrComp:GetFriendlinessCurrent(playerId)
          table.insert(arg, val)
        end
        table.insert(Lines, string.format("%-10s| %-20s| %-10s", tostring(npc.config.name), string.format("%ul", npc:GetServerId()), string.format(("%-10s"):rep(#arg), table.unpack(arg))))
      end
    end
    Log.PrintScreenMsg(table.concat(Lines, "\n"))
  else
    Log.PrintScreenMsgRed("[\229\143\139\229\165\189\229\186\166] \230\178\161\230\156\137\231\178\190\231\129\181")
  end
end

function DebugTabAIDebug:ToggleBehaviorGroupCdAndRand()
  if _G.SceneAIUtils.SkipBehaviorGroupCdAndRand then
    _G.SceneAIUtils.SkipBehaviorGroupCdAndRand = false
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "ai.dots.debug.SkipCdAndRandCheck 0")
  else
    _G.SceneAIUtils.SkipBehaviorGroupCdAndRand = true
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "ai.dots.debug.SkipCdAndRandCheck 1")
  end
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\232\176\131\232\175\149\239\188\154\229\183\178 %s \232\161\140\228\184\186\231\187\132\230\151\160\232\167\134\230\166\130\231\142\135\228\184\142CD\230\168\161\229\188\143", _G.SceneAIUtils.SkipBehaviorGroupCdAndRand == true and "\229\188\128\229\144\175" or "\229\133\179\233\151\173"), 1, nil, 5)
end

function DebugTabAIDebug:ToggleServerBehaviorGroupCdAndRand()
  if _G.SceneAIUtils.SkipServerBehaviorGroupCdAndRand then
    _G.SceneAIUtils.SkipServerBehaviorGroupCdAndRand = false
  else
    _G.SceneAIUtils.SkipServerBehaviorGroupCdAndRand = true
  end
  local Req = _G.ProtoMessage:newZoneSceneGmReq()
  Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_AI_SKIP_CD_RAND_CHECK
  Req.param1 = _G.SceneAIUtils.SkipServerBehaviorGroupCdAndRand == true and 1 or 0
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\232\176\131\232\175\149\239\188\154\229\183\178 %s \232\129\148\230\156\186\228\184\139\232\161\140\228\184\186\231\187\132\230\151\160\232\167\134\230\166\130\231\142\135\228\184\142CD\230\168\161\229\188\143\239\188\136\229\133\168\230\156\141\231\148\159\230\149\136\239\188\137", _G.SceneAIUtils.SkipServerBehaviorGroupCdAndRand == true and "\229\188\128\229\144\175" or "\229\133\179\233\151\173"), 1, nil, 5)
end

function DebugTabAIDebug:TriggerHomeAiGroupConf(name, panel, gmIn)
  local id = self.Get1NumArg(name, panel, gmIn)
  if not id then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "Error: \232\175\183\232\190\147\229\133\165 NRC_HOME_AI_CONF \231\154\132 id", 1, nil, 5)
    return
  end
  local homeid = _G.HomeIndoorSandbox and _G.HomeIndoorSandbox.HomeAIServ and _G.HomeIndoorSandbox.HomeAIServ.MasterUid
  if homeid then
    UE.UHomeAIHelper.DebugSkipCooldown(UE4Helper.GetCurrentWorld(), 1, id)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("Debug: \229\183\178\229\176\157\232\175\149\232\167\166\229\143\145\229\174\182\229\155\173AI\231\190\164\232\144\189 id=%d", id), 1, nil, 5)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("Debug: \229\165\189\229\131\143\228\184\141\229\156\168\229\174\182\229\155\173\228\184\173.."), 1, nil, 5)
  end
end

function DebugTabAIDebug.Get1NumArg(name, panel, id)
  if panel then
    local inputText = panel.InputBox:GetText()
    if not string.IsNilOrEmpty(inputText) then
      return tonumber(inputText)
    end
  else
    return id
  end
end

function DebugTabAIDebug:HomeMarriageTest(name, panel, gmIn)
  local NpcModule = NRCModuleManager:GetModule("NPCModule")
  local mls = NpcModule:GetNpcsByFilter(nil, function(npc)
    return npc.config.genre == Enum.ClientNpcType.CNT_HOME_NPC and 1 == npc.serverData.base.gender
  end)
  local fms = NpcModule:GetNpcsByFilter(nil, function(npc)
    return npc.config.genre == Enum.ClientNpcType.CNT_HOME_NPC and 2 == npc.serverData.base.gender
  end)
  local pairs = {}
  for i = 1, math.min(#mls, #fms) do
    NpcModule.SceneAIManager:ApplyRelationship(1, 1, 1, mls[i]:GetServerId(), fms[i]:GetServerId())
  end
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("Debug: \229\183\178\229\176\157\232\175\149\229\136\155\229\187\186\229\174\182\229\186\173\229\133\179\231\179\187 %d\229\175\185", math.min(#mls, #fms)), 1, nil, 5)
  Log.PrintScreenMsg("\229\188\128\229\144\175\233\157\162\230\157\191\229\144\142\239\188\140\228\189\191\231\148\168 ai.Dots.ShowRelationship \230\157\165\230\159\165\231\156\139\229\174\182\229\186\173\229\133\179\231\179\187")
end

return DebugTabAIDebug
