local Base = require("Profiler.PerfCat.Base.BaseAutomation")
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local MagicSkillAutomation = Base:Extend("MagicSkillAutomation")
local CHANNEL = "MagicSkillProfilerChannel"
local MAGIC_SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/Jineng/Magic/"
local configFileName = "MagicSkillAutomationConfig"

function MagicSkillAutomation:InitializeAutomation()
  self.skill_res_list = {}
  self.skill_id_list = {}
  self.played_skill_list = {}
  local AllSkill = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SKILL_CONF):GetAllDatas()
  for _, SkillConf in pairs(AllSkill) do
    if self:IsValidSkill(SkillConf) then
      table.insert(self.skill_res_list, SkillConf.res_id)
      table.insert(self.skill_id_list, SkillConf.id)
    end
  end
  Log.Warning("Valid Skill List: " .. #self.skill_res_list .. [[

	]] .. table.concat(self.skill_res_list, [[

	]]))
  self.current_skill_index = 1
end

function MagicSkillAutomation:IsValidSkill(skill_conf)
  if not skill_conf then
    return false
  end
  if skill_conf.type ~= Enum.SkillActiveType.SAT_PLAYERSKILL or skill_conf.type ~= Enum.SkillActiveType.SAT_PLAYERSKILL then
    return false
  end
  local ref = skill_conf.res_id
  local index = ref:match("^.*()/")
  local skill_name = ref:sub(index + 1)
  if self.config.white_list and #self.config.white_list > 0 then
    return table.contains(self.config.white_list, skill_conf.id) or table.contains(self.config.white_list, skill_name)
  end
  return true
end

function MagicSkillAutomation:GetConfigName()
  return configFileName
end

function MagicSkillAutomation:LoadDefaultConfig()
  return {
    is_local_mode = true,
    hide_hud = true,
    hide_env = true,
    overdraw_mode = false,
    disable_screen_msg = true,
    vfx_quality = "high"
  }
end

function MagicSkillAutomation:GetDefaultMapPath()
  return "/Game/ArtRes/Level/Performance/BigWorldEnvOnly"
end

function MagicSkillAutomation:PlayNext()
  local res_id = self.skill_res_list[self.current_skill_index]
  BattleResourceManager:LoadClassAsync(self, res_id, self.PrePlaySkill)
end

function MagicSkillAutomation:OnAutomationBegin()
  PerfCatCmd.Channel.Start("PerfMagicSkill")
  self.player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.player.viewObj.Mesh:SetEnableGravity(false)
  self.player.viewObj.CapsuleComponent:SetEnableGravity(false)
  self.player:SetCharacterMovementTickEnable(self, false)
  local anim_conf_path = "Blueprint'/Game/NewRoco/Modules/Core/Battle/Player/C001_0001/AC_Battle_C001_0001.AC_Battle_C001_0001_C'"
  self.player.viewObj.AnimComponent:SetAnimConfig(_G.NRCBigWorldPreloader:Get(anim_conf_path))
  local SkillComp = self.player.viewObj:GetComponentByClass(UE4.URocoSkillComponent)
  if not SkillComp then
    self.player.viewObj:AddComponentByClass(UE4.URocoSkillComponent, false, UE4.FTransform(), false)
  end
  local pet_klass = _G.NRCBigWorldPreloader:Get("/Game/ArtRes/BP/Pets/Com_YaJiJi1_001/BP_Com_YaJiJi1_001.BP_Com_YaJiJi1_001_C")
  self.pet = _G.UE4Helper.GetCurrentWorld():SpawnActor(pet_klass)
  self:AddTask(5, self.PlayNext)
  self:ProcessTaskQueue()
end

function MagicSkillAutomation:OnAutomationEnd()
  PerfCatCmd.Channel.Stop()
  self.skill_res_list = {}
  self.skill_id_list = {}
  self.played_skill_list = {}
end

function MagicSkillAutomation:PrePlaySkill(skillClass)
  Log.DebugFormat("Loaded: %s", skillClass)
  local skill_id = self.skill_id_list[self.current_skill_index]
  local res_id = self.skill_res_list[self.current_skill_index]
  local package_name = res_id:sub(res_id:match("^.*()/") + 1)
  if table.contains(self.played_skill_list, package_name) then
    self:EndPlaySkill()
    return
  end
  table.insert(self.played_skill_list, package_name)
  local npc_id = string.match(res_id, "NPC_(%d+)")
  local SkillComp = self.player.viewObj:GetComponentByClass(UE4.URocoSkillComponent)
  local skillObj = SkillComp:FindOrAddSkillObj(skillClass)
  if not skillObj then
    Log.ErrorFormat("Failed to find skill: [%s] %s", skill_id, res_id)
    self:EndPlaySkill()
    return
  end
  skillObj:RegisterEventCallback("PreEnd", self, self.EndPlaySkill)
  skillObj:RegisterEventCallback("End", self, self.EndPlaySkill)
  skillObj:SetCaster(self.player.viewObj)
  self.player.viewObj:SetActorHiddenInGame(false)
  local Result = UE4.FHitResult()
  self.pet:K2_SetActorLocation(UE4.FVector(0, 100, 0), false, Result, true)
  self.player.viewObj:K2_SetActorLocation(UE4.FVector(0, 0, -12.849903), false, Result, true)
  skillObj:SetTargets({
    self.pet
  })
  
  local function start_play()
    PerfCatCmd.Channel.Begin(string.format("%s %d#%s", CHANNEL, skill_id, package_name))
    SkillComp:LoadAndPlaySkill(skillObj)
  end
  
  if npc_id then
    local Klass = _G.NRCBigWorldPreloader:Get(string.format("/Game/ArtRes/BP/Battle/NPC_%s/BP_Battle_NPC_%s.BP_Battle_NPC_%s_C", npc_id, npc_id, npc_id))
    if not Klass then
      Log.ErrorFormat("Failed to find npc: [%s], using player instead", npc_id)
    else
      self.npc = _G.UE4Helper.GetCurrentWorld():SpawnActor(Klass)
      self.npc:InitOutSceneAsync(nil, start_play)
      self.npc:K2_SetActorLocation(UE4.FVector(-1000, 0, 0), false, Result, true)
      self.npc.EmojiWidget:SetHiddenInGame(true)
      skillObj:SetCaster(self.npc)
      self.player.viewObj:SetActorHiddenInGame(true)
      return
    end
  end
  start_play()
end

function MagicSkillAutomation:EndPlaySkill()
  PerfCatCmd.Channel.Pause(string.format("%s", CHANNEL))
  if self.npc then
    self.npc:K2_DestroyActor()
    self.npc = nil
  end
  self.current_skill_index = self.current_skill_index + 1
  if self.current_skill_index > #self.skill_id_list then
    self.current_skill_index = 1
    self.is_profiling = false
    self:StopAutomation()
    return
  end
  self:AddTask(5, self.PlayNext)
  self:ProcessTaskQueue()
end

function MagicSkillAutomation:IsPlaying()
  return self.is_profiling
end

return MagicSkillAutomation
