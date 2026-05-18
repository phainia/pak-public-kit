local Base = require("Profiler.PerfCat.Base.BaseAutomation")
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local JsonUtils = require("Common.JsonUtils")
local Queue = require("Utils.Queue")
local Array = require("Utils.Array")
local ActorShowroomAutomation = Base:Extend("ActorShowroomAutomation")
local AutomationConfigFileName = "ActorShowroom/AutomationConfig"
local AutomationNpcDataFileName = "ActorShowroom/NPC_CONF"
local PerfCatChannelName = "ActorShowroom"
local PerfCatCsvFilename = "ActorShowroom"

function ActorShowroomAutomation:InitializeAutomation()
  local npc_conf_table = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NPC_CONF)
  self.npc_conf_list = npc_conf_table:GetAllDatas()
  self.npc_queue = Queue()
  self.alive_npc_queue = Queue()
  self.is_profiling = false
  self.seconds_to_play = self.config.play_duration or 5
  self.debug_config = self.config.debug_config or nil
  self.num_played = 0
  local models = {}
  for k, v in pairs(self.npc_conf_list) do
    if not (v.model_conf > 0) or models[v.model_conf] or self.debug_config and self.debug_config.whitelist and not table.contains(self.debug_config.whitelist, v.id) then
    else
      models[v.model_conf] = true
      self.npc_queue:Enqueue(v)
    end
  end
  Log.InfoFormat("[ActorShowroomAutomation:InitializeAutomation] NPC_CONF size = %d, NPC queued = %d", npc_conf_table:GetDataCount(), self.npc_queue:Size())
  local npc_data = {}
  for k, v in pairs(self.npc_conf_list) do
    if v.model_conf > 0 then
      npc_data[tostring(v.id)] = v
      npc_data[tostring(v.id)] = {
        name = v.name,
        model_conf = _G.DataConfigManager:GetModelConf(v.model_conf).path or nil
      }
    end
  end
  JsonUtils.DumpSaved(AutomationNpcDataFileName, npc_data)
  self:RegisterAutomator()
end

function ActorShowroomAutomation:GetNPCModule()
  return NRCModuleManager:GetModule("NPCModule")
end

function ActorShowroomAutomation:OnTick(DeltaTime)
  if not self.is_finished and 0 == self.npc_queue:Size() then
    self:StopAutomation()
  end
  local fx_comp = self.player.viewObj.BP_SceneFxComponent
  if fx_comp and fx_comp:IsValid() then
    Log.Info("[ActorShowroomAutomation:OnTick] bird bird gonna die")
    fx_comp:Stop()
    fx_comp:DestroyBirds()
    fx_comp:K2_DestroyComponent(fx_comp)
  end
  if not self.is_profiling and self.npc_queue:Size() > 0 then
    Log.InfoFormat("[ActorShowroomAutomation:OnTick] Spawn npc queue left %d", self.npc_queue:Size())
    self:ProfileNPC()
    self.num_played = self.num_played + 1
    if self.debug_config and self.num_played >= self.debug_config.max_play then
      Log.InfoFormat("[ActorShowroomAutomation:OnTick] Max play = %d reached, clear NPC queue", self.num_played)
      self.num_played = 0
      self.npc_queue:Clear()
    end
  end
end

function ActorShowroomAutomation:OnAutomationBegin()
  self.player:SetActorRotation(UE.FRotator(0, 0, 0))
  self.player:GetUEController():SetControlRotation(UE.FRotator(0, 0, 0))
  PerfCatCmd.Channel.Start(PerfCatCsvFilename)
end

function ActorShowroomAutomation:OnAutomationEnd()
  PerfCatCmd.Channel.Pause(PerfCatChannelName)
  PerfCatCmd.Channel.Stop()
  Log.InfoFormat("[ActorShowroomAutomation:OnAutomationEnd] Automation Finished")
end

function ActorShowroomAutomation:ForceStop()
  self.num_played = 0
  self.npc_queue:Clear()
  PerfCatCmd.Channel.Pause(PerfCatChannelName)
  PerfCatCmd.Channel.Stop()
end

function ActorShowroomAutomation:GetConfigName()
  return AutomationConfigFileName
end

function ActorShowroomAutomation:SpawnNPC(npc_id, position, direction)
  local NPCModule = self:GetNPCModule()
  local npc = NPCModule:CreateLocalNPC(npc_id, position, direction)
  if npc then
    self.alive_npc_queue:Enqueue(npc)
  end
  return npc
end

function ActorShowroomAutomation:DestroyNPC(scene_npc)
  if not scene_npc then
    return
  end
  local NPCModule = self:GetNPCModule()
  if scene_npc.serverData then
    Log.InfoFormat("[ActorShowroomAutomation:DestroyNPC] Destroy npc %s", scene_npc.serverData.base.name)
  else
    Log.InfoFormat("[ActorShowroomAutomation:DestroyNPC] Destroy npc %s", scene_npc.classUrl)
  end
  NPCModule:DeleteLocalNPC(scene_npc)
end

function ActorShowroomAutomation:DestroyAllAliveNPCs()
  while self.alive_npc_queue:Size() > 0 do
    local npc = self.alive_npc_queue:Dequeue()
    self:DestroyNPC(npc)
  end
end

function ActorShowroomAutomation:ProfileNPC()
  local npc_conf = self.npc_queue:Dequeue()
  local pos = self.player:GetActorLocation()
  local camera_rot = self.player:GetUEController():GetControlRotation()
  local dir = (camera_rot.Yaw + 180.0) * 10
  self:AddTask(0, function()
    Log.InfoFormat("[ActorShowroomAutomation:ProfileNPC] Spawn npc id = %d, name = %s", npc_conf.id, npc_conf.name)
    PerfCatCmd.Channel.Begin(string.format("%s %d#%d", PerfCatChannelName, npc_conf.id, 0))
    self:SpawnNPC(npc_conf.id, pos, dir)
  end)
  self:AddTask(self.seconds_to_play, function()
    PerfCatCmd.Channel.Pause(PerfCatChannelName)
    self:DestroyAllAliveNPCs()
    self.is_profiling = false
  end)
  self:ProcessTaskQueue()
  self.is_profiling = true
  return
end

return ActorShowroomAutomation
