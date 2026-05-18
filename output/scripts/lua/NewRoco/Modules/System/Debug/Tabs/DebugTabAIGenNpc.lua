local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local AIComponent = require("NewRoco.Modules.Core.Scene.Component.AI.AIComponent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local treePath = "/Game/NewRoco/Modules/AI/BehaviorTree/Test/MFBT_Test/BT_MFBT_UnitTest"
local DebugTabAIGenNpc = Base:Extend("DebugTabAIGenNpc")

function DebugTabAIGenNpc:Ctor()
  Base.Ctor(self)
  self.npcInsId = 0
  self.isLoggingPerception = false
end

function DebugTabAIGenNpc:SetupTabs()
  local models = DebugTabAIGenNpc.GetAllModelConfWithPath("Blueprint'/Game/ArtRes/BP/Scene/", 6)
  local models3 = DebugTabAIGenNpc.GetAllModelConfWithPath("Blueprint'/Game/ArtRes/BP/Pets/", 5)
  for _, item in pairs(models3) do
    models[_] = item
  end
  local NpcConfs = _G.DataConfigManager:GetAllByName("NPC_CONF")
  local npc_ids = {}
  local npcCount = 0
  for model_id, path in pairs(models) do
    for npc_id, npc_conf in pairs(NpcConfs) do
      if npc_conf.model_conf == model_id then
        npc_ids[npc_id] = path
        npcCount = npcCount + 1
        break
      end
    end
  end
  for npc_id, name in pairs(npc_ids) do
    local holders = string.split(name, "/")
    local text = string.format("%s/%s", holders[2], holders[3])
    local str = string.format([[
%d
%s]], npc_id, text)
    self:Add(str, function()
      local npcModule = NRCModuleManager:GetModule("NPCModule")
      local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
      local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
      local npcInfo = self:CreateNpcInfoAtPos(npc_id, player + localPlayer.viewObj:GetActorForwardVector() * 300)
      local sceneNPC = npcModule:CreateNpc(npcInfo)
      local aiComp = sceneNPC:EnsureComponent(AIComponent)
      aiComp._DebugTreePath = treePath
    end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  end
end

function DebugTabAIGenNpc:CreateAllNPC()
  Log.Warning("\230\173\163\229\156\168\229\136\155\229\187\186npc\239\188\140\230\149\176\233\135\143\239\188\154", npcCount)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
  local ranposlist = self:CreatePosByPosition(player, npcCount, 500)
  a.task(function()
    local c = 1
    for npc_id, name in pairs(npc_ids) do
      local npcModule = NRCModuleManager:GetModule("NPCModule")
      local pos = ranposlist[c]
      c = c + 1
      local npcInfo = self:CreateNpcInfoAtPos(npc_id, pos)
      local sceneNPC = npcModule:CreateNpc(npcInfo)
      local aiComp = sceneNPC:EnsureComponent(AIComponent)
      aiComp._DebugTreePath = treePath
      a.wait(au.NextTick())
    end
  end)()
end

function DebugTabAIGenNpc:CreateNpcInfoAtPos(npcId, pos)
  UE.NPCBaseCommon.ToggleNPCCheck(true)
  local npcInfo = ProtoMessage:newActorInfo_Npc()
  self.npcInsId = self.npcInsId + 1
  npcInfo.base.actor_id = self.npcInsId
  npcInfo.base.lv = 1
  npcInfo.base.pt.pos = ProtoMessage:newPosition()
  npcInfo.base.pt.pos.x = pos.X
  npcInfo.base.pt.pos.y = pos.Y
  npcInfo.base.pt.pos.z = pos.Z
  npcInfo.base.pt.dir = UE.FVector(0, 0, 1)
  npcInfo.npc_base.npc_cfg_id = npcId
  npcInfo.npc_base.npc_content_cfg_id = 140193
  return npcInfo
end

function DebugTabAIGenNpc:CreatePosByPosition(playerPos, num, dist)
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

function DebugTabAIGenNpc.GetAllModelConfWithPath(path, prefix_num)
  prefix_num = prefix_num or 0
  local RawConfs = _G.DataConfigManager:GetAllByName("MODEL_CONF")
  local ids = {}
  for model_id, model_conf in pairs(RawConfs) do
    if string.StartsWith(model_conf.path, path) then
      ids[model_id] = string.sub(model_conf.path, #path - prefix_num)
    end
  end
  return ids
end

return DebugTabAIGenNpc
