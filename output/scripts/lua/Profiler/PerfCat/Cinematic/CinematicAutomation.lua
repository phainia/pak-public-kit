local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local Base = require("Profiler.PerfCat.Base.BaseAutomation")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local CinematicAutomation = Base:Extend("CinematicAutomation")
local configFileName = "CinematicAutomationConfig"

function CinematicAutomation:InitializeAutomation()
  self.sequences = {}
  self.sequences_playlist = {}
  self.should_change_level = true
  self.current_scene_id = 103
  local sequence_conf_data = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SEQUENCE_CONF):GetAllDatas()
  for k, v in pairs(sequence_conf_data) do
    local X = v.act_x
    local Y = v.act_y
    local Z = v.act_z
    local scene_id = 103
    if 0 ~= v.scene_id then
      scene_id = v.scene_id
    end
    if math.abs(X) + math.abs(Y) + math.abs(Z) + scene_id > 103 and v.sequence_path ~= nil and (nil == self.config.white_list or 0 == #self.config.white_list or nil ~= table.indexOf(self.config.white_list, v.id) or nil ~= table.indexOf(self.config.white_list, tostring(v.id)) or nil ~= table.indexOf(self.config.white_list, self:GetAssetName(v.sequence_path))) then
      self.sequences[v.id] = v
    end
  end
end

function CinematicAutomation:GetConfigName()
  return configFileName
end

function CinematicAutomation:LoadDefaultConfig()
  return {
    is_local_mode = true,
    play_onsite = true,
    hide_hud = true,
    hide_env = true,
    overdraw_mode = false,
    disable_screen_msg = true
  }
end

function CinematicAutomation:EnterTestWorld()
  if self.config.world_path == nil then
    self.should_change_level = false
    if nil == self.config.hide_env then
      self.config.hide_env = true
    end
  end
  self.local_modules = {
    "CinematicModule",
    "FunctionBanModule",
    "LoadingUIModule"
  }
  Base.EnterTestWorld(self)
end

function CinematicAutomation:GetDefaultMapPath()
  return "/Game/ArtRes/Level/Performance/BigWorldEnvOnly"
end

function CinematicAutomation:LockEnv()
  local Time = 43200
  if NRCEnv:IsLocalMode() then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeGameTimeLocal, Time, false)
  else
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, Time, true)
  end
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0.001)
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeWeather, 1, true)
end

function CinematicAutomation:StartAutomation()
  PerfCatCmd.ExecCmdCurrentWorld("g.GNRCCollisionLODReleaseRenderData 0")
  Base.StartAutomation(self)
end

function CinematicAutomation:OnAutomationBegin()
  self:LockEnv()
  for k, v in pairs(self.sequences) do
    local sequence = self.sequences[v.id]
    if nil == sequence then
      Log.Error(string.format("Sequence not found: %s", v.id))
    else
      table.insert(self.sequences_playlist, v.id)
    end
  end
  table.sort(self.sequences_playlist, function(a, b)
    return self.sequences[a].scene_id < self.sequences[b].scene_id
  end)
  Log.Debug("Playing all sequences, playlist left: ", #self.sequences_playlist)
  PerfCatCmd.Sequence.Start()
  self:AddTask(5, self.PlayNext)
  self:ProcessTaskQueue()
end

function CinematicAutomation:OnAutomationEnd()
  PerfCatCmd.Sequence.Stop()
  self.sequences_playlist = {}
  self.sequences = {}
  self.should_change_level = true
  self.current_scene_id = 103
end

function CinematicAutomation:StartAutomationWithWhiteList(list)
  local config = self:LoadConfig()
  config.white_list = string.split(list, ",")
  self:Init(config, callback)
  self:StartAutomation()
end

function CinematicAutomation:IsPlaying()
  return #self.sequences_playlist > 0
end

function CinematicAutomation:GetAssetName(sequence_name)
  if nil == sequence_name then
    return "unknown"
  end
  local str = string.match(sequence_name, ".*/(.*)'")
  Log.Debug("str = ", str)
  return string.Split(str, ".")[1]
end

function CinematicAutomation:PrePlaySequenceStart(sequence)
  if not self.config.play_onsite then
    Log.Debug("\229\133\136\232\183\179\232\189\172\229\136\176", sequence.act_x, sequence.act_y, sequence.act_z, "\229\134\141\232\191\155\232\161\140\230\146\173\231\137\135")
    DebugTabBase:SetPlayerLocation(sequence.act_x, sequence.act_y, sequence.act_z)
  end
  local asset_name = self:GetAssetName(sequence.sequence_path)
  local perf_command = string.format("%d#%s#%s", sequence.id, asset_name, "PrePlay")
  PerfCatCmd.Sequence.Start(perf_command)
end

function CinematicAutomation:OnPlaySequenceStart(sequence)
  local asset_name = self:GetAssetName(sequence.sequence_path)
  local perf_command = string.format("%d#%s#%s", sequence.id, asset_name, "OnPlay")
  PerfCatCmd.Sequence.Start(perf_command)
end

function CinematicAutomation:OnPlaySequenceEnd(sequence_id)
  PerfCatCmd.Sequence:Pause()
  for i, v in ipairs(self.sequences_playlist) do
    if v == sequence_id then
      table.remove(self.sequences_playlist, i)
      break
    end
  end
  self:PlayNext()
end

function CinematicAutomation:StartCinematicSequence(sequence_id, callback)
  Log.Debug("Seq ID ", sequence_id)
  local sequence = self.sequences[sequence_id]
  self:OnPlaySequenceStart(sequence)
  NRCModuleManager:DoCmd(CinematicModuleCmd.StartCinematic, sequence_id, self, callback)
end

function CinematicAutomation:PlayNext()
  if 0 == #self.sequences_playlist then
    Log.Debug("No more sequences to play")
    self:StopAutomation()
    return
  end
  if self.config.hide_player then
    self:HidePlayer()
  end
  Log.DebugFormat("PlayNext, playlist left: %d", #self.sequences_playlist)
  local sequence_id = self.sequences_playlist[1]
  local sequence = self.sequences[sequence_id]
  local scene_id = sequence.scene_id
  if 0 == scene_id then
    scene_id = 103
  end
  if self.should_change_level and self.current_scene_id ~= scene_id then
    self.current_scene_id = scene_id
    _G.NRCEventCenter:RegisterEvent("CinematicAutomation", self, _G.SceneEvent.LoadMapFinish, self.OnSceneReady)
    NRCModuleManager:DoCmd(PlayerModuleCmd.CLEAR_ALL)
    local level_name = self:GetSequenceSceneSource(scene_id)
    Log.WarningFormat("Open Level: %s", level_name)
    LevelHelper:OpenLevel(level_name)
  else
    self:AddTask(1, self.PrePlaySequenceStart, sequence)
    self:AddTask(5, PerfCatCmd.Sequence.Pause)
    self:AddTask(5, self.StartCinematicSequence, sequence.id, function()
      self:OnPlaySequenceEnd(sequence.id)
    end)
    self:ProcessTaskQueue()
  end
end

function CinematicAutomation:GetSequenceSceneSource(scene_id)
  local conf = _G.DataConfigManager:GetSceneConf(scene_id)
  local res_config = _G.DataConfigManager:GetSceneResConf(conf.scene_res_id)
  return res_config.source
end

function CinematicAutomation:OnSceneReady()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.LoadMapFinish, self.OnSceneReady)
  local sequence_id = self.sequences_playlist[1]
  local sequence = self.sequences[sequence_id]
  self:AddTask(1, self.PrePlaySequenceStart, sequence)
  self:AddTask(5, PerfCatCmd.Sequence.Pause)
  self:AddTask(5, self.StartCinematicSequence, sequence.id, self.OnPlaySequenceEnd)
  self:ProcessTaskQueue()
end

return CinematicAutomation
