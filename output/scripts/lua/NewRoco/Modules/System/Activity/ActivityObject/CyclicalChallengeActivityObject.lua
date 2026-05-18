local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local CyclicalChallengeActivityObject = Base:Extend("CyclicalChallengeActivityObject")

local function CreateCyclicalChallengeItemObject(_owner, _CyclicalChallengeConf, ActivityType, npc_challenge_data, boss_challenge_data)
  local CyclicalChallengeItemObject = Class("CyclicalChallengeItemObject")
  
  function CyclicalChallengeItemObject:Ctor(_itemOwner, _conf, _ActivityType, _npc_challenge_data, _boss_challenge_data)
    self.owner = _itemOwner
    self.conf = _conf
    self.ActivityType = _ActivityType
    self.npc_challenge_data = _npc_challenge_data
    self.boss_challenge_data = _boss_challenge_data
  end
  
  function CyclicalChallengeItemObject:GetOwner()
    return self.owner
  end
  
  function CyclicalChallengeItemObject:GetCyclicalChallengeConfId()
    return self.conf.id
  end
  
  function CyclicalChallengeItemObject:GetCyclicalChallengeConf()
    return self.conf
  end
  
  function CyclicalChallengeItemObject:GetCyclicalChallengeConfName()
    return self.conf.part_name
  end
  
  function CyclicalChallengeItemObject:GetActivityType()
    return self.ActivityType
  end
  
  function CyclicalChallengeItemObject:GetNpcChallengeData()
    return self.npc_challenge_data
  end
  
  function CyclicalChallengeItemObject:GetBossChallengeData()
    return self.boss_challenge_data
  end
  
  function CyclicalChallengeItemObject:GetNPCChallengeEventStarNum()
    local MaxStarNum = 0
    for i, star in ipairs(self.conf.star_reward) do
      if MaxStarNum < star.star_required then
        MaxStarNum = star.star_required
      end
    end
    return MaxStarNum
  end
  
  function CyclicalChallengeItemObject:GetNPCChallengeEventSchedule()
    local MaxSchedule = 0
    local battle_Set = self.conf.battle_set
    local NpcChallengeConfList = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NPC_CHALLENGE_CONF):GetAllDatas()
    for i, battleId in pairs(battle_Set) do
      for j, NpcChallengeConf in pairs(NpcChallengeConfList) do
        if battleId == NpcChallengeConf.module_id then
          MaxSchedule = MaxSchedule + 1
        end
      end
    end
    return MaxSchedule
  end
  
  function CyclicalChallengeItemObject:GetFinishNPCChallengeEventSchedule(_IsTargets)
    local FinishSchedule = 0
    if self.npc_challenge_data then
      local NpcChallengeData = self.npc_challenge_data
      for i, module in ipairs(NpcChallengeData.modules) do
        for j, level in ipairs(module.levels) do
          if level.is_finish then
            FinishSchedule = FinishSchedule + 1
          end
          if _IsTargets and level.targets and #level.targets > 0 then
            for k, _ in ipairs(level.targets) do
              if k.is_finish then
                FinishSchedule = FinishSchedule + 1
              end
            end
          end
        end
      end
    end
    return FinishSchedule
  end
  
  function CyclicalChallengeItemObject:GetBossChallengeEventSchedule()
    local MaxSchedule = 0
    local battle_Set = self.conf.battle_set
    local NpcChallengeConfList = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BOSS_CHALLENGE_CONF):GetAllDatas()
    for i, battleId in pairs(battle_Set) do
      for j, NpcChallengeConf in pairs(NpcChallengeConfList) do
        if battleId == NpcChallengeConf.id then
          MaxSchedule = MaxSchedule + 1
        end
      end
    end
    return MaxSchedule
  end
  
  function CyclicalChallengeItemObject:GetFinishBossChallengeEventSchedule(_IsTargets)
    local FinishSchedule = 0
    if self.boss_challenge_data then
      local BossChallengeData = self.boss_challenge_data
      for i, level in ipairs(BossChallengeData.levels) do
        if level.is_finish then
          FinishSchedule = FinishSchedule + 1
        end
        if _IsTargets and level.targets and #level.targets > 0 then
          for k, _ in ipairs(level.targets) do
            if k.is_finish then
              FinishSchedule = FinishSchedule + 1
            end
          end
        end
      end
    end
    return FinishSchedule
  end
  
  return CyclicalChallengeItemObject(_owner, _CyclicalChallengeConf, ActivityType, npc_challenge_data, boss_challenge_data)
end

function CyclicalChallengeActivityObject:OnConstruct(_conf)
  self.CyclicalChallengeItems = {}
  self.CyclicalChallengeItemMap = _G.MakeWeakTable({}, "v")
  local _updateData = {
    npc_challenge_data = {
      event_id = 1300001,
      modules = {
        {
          levels = {
            {is_finish = true},
            {is_finish = true},
            {is_finish = false}
          }
        }
      },
      rewards = {}
    },
    boss_challenge_data = {
      event_id = 1400001,
      levels = {
        {is_finish = true},
        {is_finish = false},
        {is_finish = false}
      },
      rewards = {}
    }
  }
  self:OnSvrUpdateActivityData(966, _updateData)
end

function CyclicalChallengeActivityObject:GetCyclicalChallengeItems(_uniqueData)
  return _uniqueData and ActivityUtils.ShallowCopyElements(self.CyclicalChallengeItems) or self.CyclicalChallengeItems
end

function CyclicalChallengeActivityObject:GetCyclicalChallengeItem(_partId)
  return self.CyclicalChallengeItemMap[_partId]
end

function CyclicalChallengeActivityObject:ActiveCyclicalChallengeItems(_activeItems, Conf)
  local hasNewActiveItems = false
  for _, id in ipairs(_activeItems) do
    if not self.CyclicalChallengeItemMap[id] then
      local CyclicalChallengeObj = Conf and CreateCyclicalChallengeItemObject(self, Conf)
      if CyclicalChallengeObj then
        table.insert(self.CyclicalChallengeItems, CyclicalChallengeObj)
        self.CyclicalChallengeItemMap[id] = CyclicalChallengeObj
        hasNewActiveItems = true
      end
    end
  end
end

function CyclicalChallengeActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.CyclicalChallengeItems = {}
    self.CyclicalChallengeItemMap = _G.MakeWeakTable({}, "v")
    local _activityData = _updateData
    local npc_challenge_data = _activityData.npc_challenge_data
    local _curEventId, Conf
    if npc_challenge_data then
      self.npc_challenge_data = npc_challenge_data
      _curEventId = npc_challenge_data.event_id
      if _curEventId then
        Conf = _G.DataConfigManager:GetNpcChallengeEventConf(_curEventId)
        local CyclicalChallengeObj = Conf and CreateCyclicalChallengeItemObject(self, Conf, Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT, npc_challenge_data)
        if CyclicalChallengeObj then
          table.insert(self.CyclicalChallengeItems, CyclicalChallengeObj)
          self.CyclicalChallengeItemMap[_curEventId] = CyclicalChallengeObj
        end
      end
    end
    local boss_challenge_data = _activityData.boss_challenge_data
    if boss_challenge_data then
      self.boss_challenge_data = boss_challenge_data
      _curEventId = boss_challenge_data.event_id
      if _curEventId then
        Conf = _G.DataConfigManager:GetBossChallengeEventConf(_curEventId)
        local CyclicalChallengeObj = Conf and CreateCyclicalChallengeItemObject(self, Conf, Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT, nil, boss_challenge_data)
        if CyclicalChallengeObj then
          table.insert(self.CyclicalChallengeItems, CyclicalChallengeObj)
          self.CyclicalChallengeItemMap[_curEventId] = CyclicalChallengeObj
        end
      end
    end
    if #self.CyclicalChallengeItems > 0 then
      table.sort(self.CyclicalChallengeItems, function(a, b)
        local timeStamp1 = ActivityUtils.ToTimestamp(a.conf.start_time)
        local timeStamp2 = ActivityUtils.ToTimestamp(b.conf.start_time)
        return timeStamp1 < timeStamp2
      end)
    end
  end
end

return CyclicalChallengeActivityObject
