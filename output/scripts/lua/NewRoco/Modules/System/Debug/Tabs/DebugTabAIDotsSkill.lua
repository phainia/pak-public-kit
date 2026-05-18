local AIComponent = require("NewRoco.Modules.Core.Scene.Component.AI.AIComponent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local AIBlackboardKeyDefine = require("NewRoco.AI.BehaviorTree.Pet.AIBlackboardKeyDefine")
local DebugTabNpcCreateRef = require("NewRoco.Modules.System.Debug.Tabs.DebugTabNPCCreate")
local Base = DebugTabBase
local DebugTabAIDotsSkill = Base:Extend("DebugTabAIDotsSkill")

function DebugTabAIDotsSkill:Ctor()
  Base.Ctor(self)
end

function DebugTabAIDotsSkill:SetupTabs()
  self:Add("\230\156\141\229\138\161\229\153\168\230\138\128\232\131\189\233\135\138\230\148\190", self.GmDotsSkillCast, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "GmDotsSkillCast")
  self:Add("\230\156\141\229\138\161\229\153\168\230\138\128\232\131\189\233\135\138\230\148\190(\233\133\141\231\189\174\228\184\138\228\188\160)", self.GmDotsSkillCastByAsset, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "GmDotsSkillCastByAsset")
  self:Add("\230\156\141\229\138\161\229\153\168\230\138\128\232\131\189\229\191\171\231\133\167", self.GmDotsSkillSnapshot, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "GmDotsSkillSnapshot")
  self:Add("\230\156\141\229\138\161\229\153\168AI\232\161\140\228\184\186\230\160\145\233\135\138\230\148\190", self.GmDotsMfbtCast, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "GmDotsMfbtCast")
  self:Add("\230\156\141\229\138\161\229\153\168AI\232\161\168\230\188\148\231\187\132\233\135\138\230\148\190", self.GmDotsMfbtPerformGroupCast, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "GmDotsMfbtPerformGroupCast")
  self:Add("\230\156\141\229\138\161\229\153\168AI\232\161\140\228\184\186\230\160\145\233\135\138\230\148\190(\233\133\141\231\189\174\228\184\138\228\188\160)", self.GmDotsMfbtCastByAsset, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "GmDotsMfbtCastByAsset")
  self:Add("\229\136\155\229\187\186\230\156\141\229\138\161\229\153\168NPC", self.GmDotsCreateSvrNpc, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "GmDotsCreateSvrNpc")
  self:Add("\230\156\141\229\138\161\229\153\168\229\141\143\232\174\174\230\181\139\232\175\149(\228\184\141\232\166\129\231\148\168\239\188\140\230\156\141\229\138\161\229\153\168\230\181\139\232\175\149\229\141\143\232\174\174\231\148\168)", self.GmDotsSkillProtocolTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "GmDotsSkillProtocolTest")
end

function DebugTabAIDotsSkill:GmDotsSkillCast(name, panel)
  local inputText = panel.InputBox:GetText()
  if string.IsNilOrEmpty(inputText) then
    Log.Error("\229\143\130\230\149\176\230\160\188\229\188\143\239\188\154 SkillId, Interrupt time")
    return
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  local SkillId = 0
  local interruptTime = 0
  if #params > 0 then
    SkillId = tonumber(params[1]) or 0
  end
  if #params > 1 then
    interruptTime = tonumber(params[2]) or 0
  end
  Log.Warning("params ", SkillId, interruptTime)
  local npc = self:GetNearestBoss()
  if npc and npc.AIComponent and npc.AIComponent.isServerAI then
    local req = ProtoMessage:newZoneGmDotsSkillCastReq()
    req.actor_id = npc:GetServerId()
    if 0 ~= SkillId then
      req.skill_id = SkillId
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_DOTS_SKILL_CAST_REQ, req, self, self.GmDotsSkillCastRsp, false, true)
      Log.Warning("Interrupt time", interruptTime)
      if 0 ~= interruptTime then
        Log.Warning("Interrupt Hit", interruptTime)
        _G.DelayManager:DelaySeconds(interruptTime, self.GmDotsSkillStop, self, npc, SkillId)
      end
    end
  end
end

function DebugTabAIDotsSkill:GmDotsSkillCastRsp(rsp)
  Log.Warning("[SceneAI] npc dots skill cast test rsp:", rsp.ret_info.ret_code)
end

function DebugTabAIDotsSkill:GmDotsSkillStop(npc, SkillId)
  Log.Warning("GmDotsSkillStop Enter", SkillId)
  local req = ProtoMessage:newZoneGmDotsSkillStopReq()
  req.actor_id = npc:GetServerId()
  req.skill_id = SkillId
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_DOTS_SKILL_STOP_REQ, req, self, self.GmDotsSkillStopRsp, false, false)
end

function DebugTabAIDotsSkill:GmDotsSkillStopRsp(rsp)
  Log.Warning("[SceneAI] npc dots skill stop test rsp:", rsp.ret_info.ret_code)
end

function DebugTabAIDotsSkill:GmDotsSkillCastByAsset(name, panel)
  local inputText = panel.InputBox:GetText()
  if string.IsNilOrEmpty(inputText) then
    Log.Error("\229\143\130\230\149\176\230\160\188\229\188\143\239\188\154 SkillId")
    return
  end
  local SkillId = tonumber(inputText)
  if nil == SkillId then
    Log.Error("\229\143\130\230\149\176\230\160\188\229\188\143\239\188\154 SkillId")
    return
  end
  local npc = self:GetNearestBoss()
  if npc and npc.AIComponent and npc.AIComponent.isServerAI then
    local Content = self:LoadWorldCombatSkillContent(SkillId)
    if nil ~= Content then
      local req = ProtoMessage:newZoneGmDotsSkillCastByAssetReq()
      req.actor_id = npc:GetServerId()
      req.skill_id = SkillId
      req.skill_asset_content = Content
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_DOTS_SKILL_CAST_BY_ASSET_REQ, req, self, self.GmDotsSkillCastByAssetRsp, false, true)
    end
  end
end

function DebugTabAIDotsSkill:GmDotsSkillCastByAssetRsp(rsp)
  Log.Warning("[SceneAI] npc dots skill snapshot test rsp:", rsp.ret_info.ret_code)
end

function DebugTabAIDotsSkill:GmDotsSkillSnapshot(name, panel)
  local npc = self:GetNearestBoss()
  if npc and npc.AIComponent and npc.AIComponent.isServerAI then
    local req = ProtoMessage:newZoneGmDotsSkillSnapshotReq()
    req.actor_id = npc:GetServerId()
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_DOTS_SKILL_SNAPSHOT_REQ, req, self, self.GmDotsSkillCastRsp, false, true)
  end
end

function DebugTabAIDotsSkill:GmDotsSkillSnapshotRsp(rsp)
  Log.Warning("[SceneAI] npc dots skill snapshot test rsp:", rsp.ret_info.ret_code)
end

local function IsBoss(npc)
  local WorldCombatDatas = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_COMBAT_CONF):GetAllDatas()
  for _, v in pairs(WorldCombatDatas) do
    if v.refresh_content_id == npc.serverData.npc_base.npc_content_cfg_id then
      return true
    end
  end
  return false
end

function DebugTabAIDotsSkill:GmDotsMfbtCast(name, panel)
  local inputText = panel.InputBox:GetText()
  if string.IsNilOrEmpty(inputText) then
    Log.Error("\229\143\130\230\149\176\230\160\188\229\188\143\239\188\154 SkillId, Interrupt time")
    return
  end
  local BehaviorId = tonumber(inputText)
  if nil == BehaviorId then
    Log.Error("\229\143\130\230\149\176\230\160\188\229\188\143\239\188\154 BehaviorId")
    return
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.AIComponent then
    local req = _G.ProtoMessage:newZoneGmDotsMfbtCastReq()
    req.actor_id = npc:GetServerId()
    req.behavior_id = BehaviorId
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_DOTS_MFBT_CAST_REQ, req, self, self.GmDotsMfbtCastRsp, false, true)
  end
end

function DebugTabAIDotsSkill:GmDotsMfbtCastRsp(rsp)
  Log.Warning("[SceneAI] npc dots mfbt cast test rsp:", rsp.ret_info.ret_code)
end

function DebugTabAIDotsSkill:GmDotsMfbtCastByAsset(name, panel)
  local inputText = panel.InputBox:GetText()
  if string.IsNilOrEmpty(inputText) then
    Log.Error("\229\143\130\230\149\176\230\160\188\229\188\143\239\188\154 BehaviorId")
    return
  end
  local BehaviorId = tonumber(inputText)
  if nil == BehaviorId then
    Log.Error("\229\143\130\230\149\176\230\160\188\229\188\143\239\188\154 BehaviorId")
    return
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.AIComponent then
    local Content = self:LoadBehaviorContent(BehaviorId)
    if nil ~= Content then
      local req = ProtoMessage:newZoneGmDotsMfbtCastByAssetReq()
      req.actor_id = npc:GetServerId()
      req.behavior_id = BehaviorId
      req.behavior_tree_asset_content = Content
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_DOTS_MFBT_CAST_BY_ASSET_REQ, req, self, self.GmDotsMfbtCastByAssetRsp, false, true)
    end
  end
end

function DebugTabAIDotsSkill:GmDotsMfbtCastByAssetRsp(rsp)
  Log.Warning("[SceneAI] npc dots mfbt cast by asset rsp:", rsp.ret_info.ret_code)
end

function DebugTabAIDotsSkill:GmDotsMfbtPerformGroupCast(name, panel)
  local inputText = panel.InputBox:GetText()
  if string.IsNilOrEmpty(inputText) then
    Log.Error("\229\143\130\230\149\176\230\160\188\229\188\143\239\188\154 SkillId, Interrupt time")
    return
  end
  local PerformID = tonumber(inputText)
  if nil == PerformID then
    Log.Error("\229\143\130\230\149\176\230\160\188\229\188\143\239\188\154 PerformID")
    return
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.AIComponent then
    local req = _G.ProtoMessage:newZoneGmDotsMfbtCastReq()
    req.actor_id = npc:GetServerId()
    req.perform_group_id = PerformID
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_DOTS_MFBT_CAST_REQ, req, self, self.GmDotsMfbtPerformGroupCast, false, true)
  end
end

function DebugTabAIDotsSkill:GmDotsMfbtPerformGroupCastRsp(rsp)
  Log.Warning("[SceneAI] npc dots mfbt perform group cast test rsp:", rsp.ret_info.ret_code)
end

function DebugTabNpcCreateRef:GetInputNumber()
  return 0
end

function DebugTabAIDotsSkill:GmDotsCreateSvrNpc(name, panel)
  local inputText = panel.InputBox:GetText()
  local RefreshID = toNumber(inputText, 3800034)
  DebugTabNpcCreateRef:InterDebugCreateNPC(0, RefreshID)
end

function DebugTabAIDotsSkill:OnServerCreateDebugNPC(rsp)
end

function DebugTabAIDotsSkill:GmDotsSkillProtocolTest(name, panel)
  local req = ProtoMessage:newZoneSceneHomePlantCropReq()
  req.land_id = 2
  req.seed_gid = 1
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_HOME_PLANT_CROP_REQ, req, false)
end

function DebugTabAIDotsSkill:GetNearestBoss()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local bosses = NPCModule:GetNpcsByFilter(nil, IsBoss)
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ans
  local dist = math.huge
  local playerPos = player:GetActorLocationFrameCache()
  for _, npc in pairs(bosses) do
    local d = UE4.FVector.DistSquared2D(npc:GetActorLocation(), playerPos)
    if dist > d then
      ans = npc
      dist = d
    end
  end
  return ans
end

function DebugTabAIDotsSkill:LoadWorldCombatSkillContent(SkillId)
  local SkillPath = self:LoadWorldCombatSkillPath(SkillId)
  if nil == SkillPath then
    Log.Warning("[SceneAI] LoadWorldCombatSkillContent failed:", SkillId)
    return nil
  end
  local SkillAsset = SkillPath:match("([^/]+)$")
  local File = string.format("%sDots/DotsSkill/WorldCombat/%s.non", UE4.UBlueprintPathsLibrary.ProjectContentDir(), SkillAsset)
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local Result, Success = UE4.UNRCStatics.LoadToString(File)
  if not Success then
    Result = nil
  end
  return Result
end

function DebugTabAIDotsSkill:LoadWorldCombatSkillPath(SkillId)
  local WorldCombatSkillConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_COMBAT_SKILL_CONF):GetAllDatas()
  for _, SkillConf in pairs(WorldCombatSkillConf) do
    if SkillConf.id == SkillId then
      return SkillConf.skill_ref
    end
  end
  return nil
end

function DebugTabAIDotsSkill:LoadBehaviorContent(BehaviorId)
  local BehaviorPath = self:LoadBehaviorPath(BehaviorId)
  if nil == BehaviorPath then
    Log.Warning("[SceneAI] LoadBehaviorContent failed:", BehaviorId)
    return nil
  end
  local Prefix = "^/Game"
  local BehaviorAsset = BehaviorPath:gsub(Prefix, "")
  local File = string.format("%s/%s.non", UE4.UBlueprintPathsLibrary.ProjectContentDir(), BehaviorAsset)
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local Result, Success = UE4.UNRCStatics.LoadToString(File)
  if not Success then
    Result = nil
  end
  return Result
end

function DebugTabAIDotsSkill:LoadBehaviorPath(BehaviorId)
  local BehaviorConfDatas = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.NRC_AI_BEHAVIOR_CONF):GetAllDatas()
  for _, BehaviorConf in pairs(BehaviorConfDatas) do
    if BehaviorConf.id == BehaviorId then
      return BehaviorConf.tree_name
    end
  end
  return nil
end

return DebugTabAIDotsSkill
