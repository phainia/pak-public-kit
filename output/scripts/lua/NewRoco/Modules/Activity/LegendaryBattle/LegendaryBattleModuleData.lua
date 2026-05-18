local LegendaryBattleModuleData = _G.NRCData:Extend("LegendaryBattleModuleData")

function LegendaryBattleModuleData:Ctor()
  NRCData.Ctor(self)
  self:Init()
end

function LegendaryBattleModuleData:Init()
  self:Reset()
  self.battleIdToActionParamMap = {}
  self:GenerateBattleIdToActionParamMap()
end

function LegendaryBattleModuleData:Reset()
  self.catchSuccReward = nil
end

function LegendaryBattleModuleData:GetLegendaryBattleAwards(star, petBaseId)
  local TeamBattleAwardTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.TEAM_BATTLE_AWARD)
  local TeamBattleAwardDatas = TeamBattleAwardTable:GetAllDatas()
  for k, v in pairs(TeamBattleAwardDatas) do
    if v.star == star and v.is_legendary_reward == petBaseId then
      return v.show_award
    end
  end
  self:LogError("cannot found battle awards by star:", star)
  return {}
end

function LegendaryBattleModuleData:GetLegendaryBattleAwardId(star, petBaseId)
  local TeamBattleAwardTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.TEAM_BATTLE_AWARD)
  local TeamBattleAwardDatas = TeamBattleAwardTable:GetAllDatas()
  for k, v in pairs(TeamBattleAwardDatas) do
    if v.star == star and v.is_legendary_reward == petBaseId then
      return v.reward
    end
  end
  self:LogError("cannot found battle awards by star:", star)
  return {}
end

function LegendaryBattleModuleData:GetLegendaryBattlePetBaseID(content_cfg_id)
  local seasonLegendaryID
  if content_cfg_id then
    seasonLegendaryID = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetSeasonLegendaryID, content_cfg_id)
    if seasonLegendaryID then
      local seasonLegendaryDataConf = _G.DataConfigManager:GetSeasonLegendaryBattleEvent(seasonLegendaryID)
      if seasonLegendaryDataConf then
        return seasonLegendaryDataConf.pet_base_id
      end
    else
      local LegendaryBattleEventConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.LEGENDARY_BATTLE_EVENT):GetAllDatas()
      for k, v in pairs(LegendaryBattleEventConf or {}) do
        if v.refresh_content_id_2 == content_cfg_id then
          return v.pet_base_id
        end
      end
    end
  end
  return 0
end

function LegendaryBattleModuleData:GetLegendaryBattleStar(content_cfg_id)
  local unLockLevel = 0
  local StarList = {}
  local startStarNum = 0
  local seasonLegendaryID
  if content_cfg_id then
    seasonLegendaryID = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetSeasonLegendaryID, content_cfg_id)
    if seasonLegendaryID then
      local seasonLegendaryDataConf = _G.DataConfigManager:GetSeasonLegendaryBattleEvent(seasonLegendaryID)
      if seasonLegendaryDataConf then
        StarList = seasonLegendaryDataConf.battle_id
        unLockLevel = seasonLegendaryDataConf.world_level
        startStarNum = seasonLegendaryDataConf.start_difficulty
      end
    else
      local LegendaryBattleEventConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.LEGENDARY_BATTLE_EVENT):GetAllDatas()
      for k, v in pairs(LegendaryBattleEventConf or {}) do
        if v.refresh_content_id_2 == content_cfg_id then
          StarList = v.battle_id
          local ActivityConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ACTIVITY_CONF):GetAllDatas()
          for _, value in pairs(ActivityConf) do
            if value.base_id and #value.base_id > 0 and value.base_id[1] == k then
              unLockLevel = value.world_level_required or 0
              break
            end
          end
          unLockLevel = v.world_level
          startStarNum = v.start_difficulty
        end
      end
    end
  end
  local visitorList = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorList)
  local playerWorldLv = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  if visitorList and #visitorList > 0 then
    playerWorldLv = visitorList[1].world_lv
  end
  local maxLevel = unLockLevel + #StarList
  local curChooseStarNum = 0
  if playerWorldLv >= maxLevel then
    curChooseStarNum = startStarNum + #StarList - 1
  else
    curChooseStarNum = startStarNum + (playerWorldLv - unLockLevel)
  end
  return curChooseStarNum
end

function LegendaryBattleModuleData:GenerateBattleIdToActionParamMap()
  local LegendaryGlobalCfg = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.LEGENDARY_BATTLE_EVENT):GetAllDatas()
  for k, v in pairs(LegendaryGlobalCfg) do
    if v.battle_id then
      for i, j in pairs(v.battle_id) do
        if self.battleIdToActionParamMap[j] == nil then
          self.battleIdToActionParamMap[j] = {}
        end
        self.battleIdToActionParamMap[j] = v.battle_key
      end
    end
  end
end

function LegendaryBattleModuleData:GetActionParamByBattleId(battleId)
  return self.battleIdToActionParamMap[battleId] or ""
end

function LegendaryBattleModuleData:SetCatchSuccReward(data)
  self.catchSuccReward = data
end

function LegendaryBattleModuleData:GetCatchSuccReward()
  return self.catchSuccReward
end

return LegendaryBattleModuleData
