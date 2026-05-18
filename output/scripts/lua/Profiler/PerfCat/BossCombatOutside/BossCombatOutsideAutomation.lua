local Base = require("Profiler.PerfCat.Base.BaseAutomation")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BossCombatOutsideAutomation = Base:Extend("CinematicAutomation")
local configFileName = "BossCombatOutsideAutomationConfig"
local CHANNEL = "PerfBossCombatOutside"

function BossCombatOutsideAutomation:InitializeAutomation()
  self.boss_offset = UE4.FVector(0, 700, 200)
  self.hide_boss = true
  self.offset_each_play = UE4.FVector(1000, 0, 0)
  self.duration = 20
  self.boss_data = {}
  self.boss_indices = {}
  self.current_boss_index = 1
  self.current_skill_index = 1
  self.boss = nil
  self:InitInternal()
end

function BossCombatOutsideAutomation:InitInternal()
  local WorldCombatSkillConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_COMBAT_SKILL_CONF):GetAllDatas()
  local NpcRefreshContentConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.NPC_REFRESH_CONTENT_CONF):GetAllDatas()
  local NpcConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.NPC_CONF):GetAllDatas()
  local BossSkillsMapConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.BOSS_SKILLS_MAP_CONF):GetAllDatas()
  local allSkillWithoutConfig = {}
  local validSkillList = {}
  local invalidSkillList = {}
  for _, combatSkill in pairs(WorldCombatSkillConf) do
    if combatSkill.skill_ref then
      table.insert(allSkillWithoutConfig, combatSkill.id)
    end
  end
  local lastBoss_id = 0
  for _, ContentConf in pairs(NpcRefreshContentConf) do
    local Npc = NpcConf[ContentConf.npc_id]
    if Npc and (Npc.genre == Enum.ClientNpcType.CNT_PETBOSS or Npc.genre == Enum.ClientNpcType.CNT_BOSS_SKILL_ITEM) then
      local BossSkills = BossSkillsMapConf[ContentConf.id]
      if BossSkills and 0 ~= #BossSkills.skill_ids then
        local skill_refs = {}
        local skill_ids = {}
        for _, id in ipairs(BossSkills.skill_ids) do
          local skill_conf = WorldCombatSkillConf[id]
          if self:IsValidSkill(skill_conf) then
            local skill_info = string.format("%d:%s", id, skill_conf.skill_ref)
            if not table.indexOf(validSkillList, skill_info) then
              table.insert(validSkillList, skill_info)
              table.insert(skill_refs, skill_conf.skill_ref)
              table.insert(skill_ids, id)
            end
            local index = table.indexOf(allSkillWithoutConfig, id)
            if index then
              table.remove(allSkillWithoutConfig, index)
            end
          else
            table.insert(invalidSkillList, string.format("%d:%s[npc_id=%d]", id, Npc.name, Npc.id))
          end
        end
        if 0 ~= #skill_ids and 0 ~= #skill_refs then
          self.boss_data[Npc.id] = {
            id = ContentConf.id,
            name = Npc.name,
            npc_id = Npc.id,
            skills = skill_ids,
            skill_refs = skill_refs
          }
          lastBoss_id = Npc.id
        end
      end
    end
  end
  Log.Warning("Valid Skill List: " .. #validSkillList .. [[

	]] .. table.concat(validSkillList, [[

	]]))
  Log.Warning("Invalid Skill List: " .. #invalidSkillList .. [[

	]] .. table.concat(invalidSkillList, [[

	]]))
  if 0 ~= #allSkillWithoutConfig then
    skill_names = {}
    for _, id in ipairs(allSkillWithoutConfig) do
      local skill_conf = WorldCombatSkillConf[id]
      if skill_conf and skill_conf.skill_ref then
        table.insert(skill_names, string.format("%d:%s", id, skill_conf.skill_ref))
      else
        table.insert(skill_names, string.format("%d:Unknown", id))
      end
    end
    Log.Warning("Skills without Config List: " .. #allSkillWithoutConfig .. [[

	]] .. table.concat(skill_names, [[

	]]))
  end
  if 0 == lastBoss_id then
    lastBoss_id = 65571
    self.boss_data[65571] = {
      id = 31000026,
      name = "\229\143\172\229\148\164\230\129\182\233\173\148\231\139\188",
      npc_id = 65571,
      skills = {},
      skill_refs = {}
    }
  end
  if 0 ~= #allSkillWithoutConfig and 0 ~= lastBoss_id then
    for _, id in ipairs(allSkillWithoutConfig) do
      local skill_conf = WorldCombatSkillConf[id]
      if self:IsValidSkill(skill_conf) then
        table.insert(self.boss_data[lastBoss_id].skill_refs, skill_conf.skill_ref)
        table.insert(self.boss_data[lastBoss_id].skills, id)
      end
    end
  end
  for key, value in pairs(self.boss_data) do
    table.insert(self.boss_indices, key)
  end
  UE4.UNRCStatics.ExecConsoleCommand("log LogCollision off")
end

function BossCombatOutsideAutomation:IsValidSkill(skill_conf)
  if nil == skill_conf or nil == skill_conf.skill_ref then
    return false
  end
  if skill_conf.effective == false then
    return false
  end
  local ref = skill_conf.skill_ref
  local index = ref:match("^.*()/")
  local skill_name = ref:sub(index + 1)
  if self.config.white_list and #self.config.white_list > 0 then
    return table.contains(self.config.white_list, skill_conf.id) or table.contains(self.config.white_list, skill_name)
  end
  return true
end

function BossCombatOutsideAutomation:GetConfigName()
  return configFileName
end

function BossCombatOutsideAutomation:IsPlaying()
  return self.is_profiling
end

function BossCombatOutsideAutomation:LoadDefaultConfig()
  return {
    is_local_mode = true,
    hide_hud = true,
    overdraw_mode = false,
    disable_screen_msg = true,
    hide_player = true,
    vfx_quality = "high",
    pos = {
      0,
      600,
      0
    },
    hide_boss = true
  }
end

function BossCombatOutsideAutomation:EnterTestWorld()
  self.local_modules = {
    "CollisionModule"
  }
  Base.EnterTestWorld(self)
end

function BossCombatOutsideAutomation:GetDefaultMapPath()
  return "/Game/ArtRes/Level/SkillPerform/TestWorld2"
end

function BossCombatOutsideAutomation:OnAutomationBegin()
  PerfCatCmd.Channel.Start(CHANNEL)
  self:AddTask(1, self.PlayNext)
  self:ProcessTaskQueue()
  self.is_profiling = true
  SceneUtils.debugCloseCreateAIComp = true
end

function BossCombatOutsideAutomation:OnAutomationEnd()
  PerfCatCmd.Channel.Stop()
end

function BossCombatOutsideAutomation:GetCurrentBossID()
  return self.boss_indices[self.current_boss_index]
end

function BossCombatOutsideAutomation:GetCurrentBossName()
  return self.boss_data[self:GetCurrentBossID()].name
end

function BossCombatOutsideAutomation:GetCurrentSkillID()
  return self.boss_data[self:GetCurrentBossID()].skills[self.current_skill_index]
end

function BossCombatOutsideAutomation:GetCurrentSkillName()
  local ref = self.boss_data[self:GetCurrentBossID()].skill_refs[self.current_skill_index]
  if not ref then
    return "Unknown"
  end
  local index = ref:match("^.*()/")
  return ref:sub(index + 1)
end

function BossCombatOutsideAutomation:PrepareBoss()
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local pos = player:GetActorLocation() + self.boss_offset
  self.boss = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.CreateLocalNPC, self:GetCurrentBossID(), SceneUtils.ClientPos2ServerPos(pos), nil, PriorityEnum.Passive_World_NPC_Close_BP)
  self.boss:EnsureComponent(WorldCombatSkillComponent)
  if not self.boss.viewObj then
    self.boss:AddEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.PlayNext)
  else
    self:PlayNext()
  end
end

function BossCombatOutsideAutomation:PlayNext()
  if self.boss == nil then
    self:PrepareBoss()
    return
  end
  self:AddTask(1, self.StartPlaySkill)
  self:ProcessTaskQueue()
end

function BossCombatOutsideAutomation:PrePlaySkill()
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local new_player_location = player:GetActorLocation() + self.offset_each_play
  local new_boss_location = new_player_location + self.boss_offset
  local dir = new_player_location - new_boss_location
  dir:Normalize()
  player.viewObj:Abs_K2_SetActorLocation_WithoutHit(new_player_location, false, true)
  self.boss.viewObj:Abs_K2_SetActorLocationAndRotation_WithoutHit(new_boss_location, dir:ToRotator(), false, true)
  local PrimComps = player.viewObj:K2_GetComponentsByClass(UE.UPrimitiveComponent)
  player.viewObj:SetActorHiddenInGame(self.config.hide_player)
  for _, Comp in pairs(PrimComps) do
    Comp:SetRenderInMainPass(not self.config.hide_player)
  end
  local PrimComps2 = self.boss.viewObj:K2_GetComponentsByClass(UE.UPrimitiveComponent)
  self.boss.viewObj:SetActorHiddenInGame(self.config.hide_boss)
  for _, Comp in pairs(PrimComps2) do
    Comp:SetRenderInMainPass(not self.config.hide_boss)
  end
end

function BossCombatOutsideAutomation:StartPlaySkill()
  self:PrePlaySkill()
  local current_skill_id = self:GetCurrentSkillID()
  local current_skill_name = self:GetCurrentSkillName()
  PerfCatCmd.Channel.Begin(string.format("%s %d#%s", CHANNEL, current_skill_id, current_skill_name))
  Log.WarningFormat("Start Play Skill: [%d] %s", current_skill_id, self:GetCurrentSkillName())
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.boss:EnsureComponent(WorldCombatSkillComponent):ClientTryCastSkill(current_skill_id, player.viewObj, player:GetActorLocation(), function(skillid, success)
    if not success then
      Log.Error("Play Skill Failed: [%s %d] %d", self:GetCurrentBossName(), self:GetCurrentBossID(), skillid)
    end
    self:AddTask(5, self.EndPlaySkill, current_skill_id, current_skill_name)
    self:ProcessTaskQueue()
  end)
  self.timer = _G.TimerManager:CreateTimer(self, "OnEffectExceedDuration", self.duration, nil, function()
    self:EndPlaySkill(current_skill_id, current_skill_name)
  end, 99999)
end

function BossCombatOutsideAutomation:EndPlaySkill(skill_id, skill_name)
  if self.is_profiling == false or self:GetCurrentSkillID() ~= skill_id or self:GetCurrentSkillName() ~= skill_name then
    return
  end
  if self.timer then
    _G.TimerManager:RemoveTimer(self.timer)
    self.timer = nil
  end
  PerfCatCmd.Channel.Pause(string.format("%s", CHANNEL))
  Log.WarningFormat("End Play Skill: [%d] %s", self:GetCurrentSkillID(), self:GetCurrentSkillName())
  self.current_skill_index = self.current_skill_index + 1
  if self.current_skill_index > #self.boss_data[self.boss_indices[self.current_boss_index]].skills then
    self.current_skill_index = 1
    self.current_boss_index = self.current_boss_index + 1
    if nil ~= self.boss then
      self.boss:Destroy()
      self.boss = nil
    end
    if self.current_boss_index > #self.boss_indices then
      self.is_profiling = false
      self:StopAutomation()
      return
    end
  end
  self:AddTask(1, self.PlayNext)
  self:ProcessTaskQueue()
end

return BossCombatOutsideAutomation
