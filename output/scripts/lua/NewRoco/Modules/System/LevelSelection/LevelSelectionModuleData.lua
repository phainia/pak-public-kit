local LevelSelectionModuleData = _G.NRCData:Extend("LevelSelectionModuleData")
local PetUtils = require("NewRoco.Utils.PetUtils")

function LevelSelectionModuleData:Ctor()
  NRCData.Ctor(self)
  self.allTeamDataList = nil
  self.curSelectRuleBuffId = 0
  self.ChallengeLevelData = nil
  self.cacheTeamData = nil
  self.cacheSalonDataDic = {}
end

function LevelSelectionModuleData:SetCacheSalonDataDic(battleAppearanceInfo)
  if battleAppearanceInfo then
    self.cacheSalonDataDic[battleAppearanceInfo.uid] = battleAppearanceInfo
  end
end

function LevelSelectionModuleData:GetCacheSalonDataDic(uid)
  if self.cacheSalonDataDic[uid] == nil then
    return nil
  end
  return self.cacheSalonDataDic[uid]
end

function LevelSelectionModuleData:SetCurSelectRuleBuffId(id)
  self.curSelectRuleBuffId = id
end

function LevelSelectionModuleData:GetCurSelectRuleBuffId()
  return self.curSelectRuleBuffId
end

function LevelSelectionModuleData:SetCacheTeamData(_cacheTeamData)
  self.cacheTeamData = _cacheTeamData
end

function LevelSelectionModuleData:GetCacheTeamData()
  return self.cacheTeamData
end

function LevelSelectionModuleData:CreateDefaultTeamDatas()
  self.allTeamDataList = {}
  local mainTeamData = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfoByTeamType(_G.Enum.PlayerTeamType.PTT_BIG_WORLD)
  local activeTeamData = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfoByTeamType(_G.Enum.PlayerTeamType.PTT_PVE_CHALLENGE_ALTER)
  local curNpcTeamData = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfoByTeamType(_G.Enum.PlayerTeamType.PTT_PVE_NPC_CHALLENGE_FIGHT)
  local curBossTeamData = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfoByTeamType(_G.Enum.PlayerTeamType.PTT_PVE_BOSS_CHALLENGE_FIGHT)
  local default_name = _G.DataConfigManager:GetPetGlobalConfig("mainworld_team_default_name").str
  if mainTeamData and mainTeamData.teams and #mainTeamData.teams > 0 then
    for i = 1, #mainTeamData.teams do
      if mainTeamData.teams[i].pet_infos and #mainTeamData.teams[i].pet_infos > 0 then
        local mainTeam = {}
        mainTeam.type = _G.Enum.PlayerTeamType.PTT_BIG_WORLD
        mainTeam.title = mainTeamData.teams[i].team_name or string.format(default_name, i)
        mainTeam.teams = mainTeamData.teams[i].pet_infos or {}
        mainTeam.magicGid = self:GetBigWordTeamMagicGid(i)
        mainTeam.idx = i - 1
        table.insert(self.allTeamDataList, mainTeam)
      end
    end
  else
    local mainTeam = {}
    mainTeam.type = _G.Enum.PlayerTeamType.PTT_BIG_WORLD
    mainTeam.idx = 0
    mainTeam.title = string.format(default_name, 1)
    mainTeam.teams = {}
    mainTeam.magicGid = 0
    table.insert(self.allTeamDataList, mainTeam)
  end
  self.curNpcTeamData = {}
  self.curNpcTeamData.type = _G.Enum.PlayerTeamType.PTT_PVE_NPC_CHALLENGE_FIGHT
  self.curNpcTeamData.idx = 0
  if curNpcTeamData and curNpcTeamData.teams[1] then
    self.curNpcTeamData.title = curNpcTeamData.teams[1].team_name or LuaText.challenge_text_20
    self.curNpcTeamData.teams = curNpcTeamData.teams[1].pet_infos or {}
    self.curNpcTeamData.magicGid = curNpcTeamData.teams[1].role_magic_gid
  else
    self.curNpcTeamData.title = LuaText.challenge_text_20
    self.curNpcTeamData.teams = {}
    self.curNpcTeamData.magicGid = 0
  end
  self.curBossTeamData = {}
  self.curBossTeamData.type = _G.Enum.PlayerTeamType.PTT_PVE_BOSS_CHALLENGE_FIGHT
  self.curBossTeamData.idx = 0
  if curBossTeamData and curBossTeamData.teams[1] then
    self.curBossTeamData.title = curBossTeamData.teams[1].team_name or LuaText.challenge_text_9
    self.curBossTeamData.teams = curBossTeamData.teams[1].pet_infos or {}
    self.curBossTeamData.magicGid = curBossTeamData.teams[1].role_magic_gid
  else
    self.curBossTeamData.title = LuaText.challenge_text_9
    self.curBossTeamData.teams = {}
    self.curBossTeamData.magicGid = 0
  end
  if activeTeamData then
    for i, team in pairs(activeTeamData.teams) do
      local activieTeam = {}
      if team.team_name == "" or team.team_name == nil then
        local teamNameCfg = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_name")
        activieTeam.title = string.format(teamNameCfg.str, i)
      else
        activieTeam.title = team.team_name
      end
      activieTeam.type = _G.Enum.PlayerTeamType.PTT_PVE_CHALLENGE_ALTER
      activieTeam.idx = i - 1
      activieTeam.teams = team.pet_infos or {}
      activieTeam.magicGid = team.role_magic_gid
      table.insert(self.allTeamDataList, activieTeam)
    end
  else
    for i = 1, 8 do
      local activieTeam = {}
      local teamNameCfg = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_name")
      activieTeam.type = _G.Enum.PlayerTeamType.PTT_PVE_CHALLENGE_ALTER
      activieTeam.idx = i - 1
      activieTeam.title = string.format(teamNameCfg.str, i)
      activieTeam.teams = {}
      activieTeam.magicGid = 0
      table.insert(self.allTeamDataList, activieTeam)
    end
  end
  return self.allTeamDataList
end

function LevelSelectionModuleData:GetBigWordTeamMagicGid(index)
  local gid = 0
  local petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local teamInfo = PetUtils.PlayerPetInfoGetTeamInfo(petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  local items = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemArrayByType, _G.Enum.BagItemType.BI_PLAYERSKILL)
  local teamIndex = index or teamInfo.main_team_idx + 1
  if items then
    for i, item in pairs(items) do
      if teamInfo and teamInfo.teams and teamInfo.teams[teamIndex] and item.gid == teamInfo.teams[teamIndex].role_magic_gid then
        gid = item.gid
        break
      end
    end
  else
    Log.Error("LevelSelectionModuleData:GetBigWordTeamMagicGid items is nil")
  end
  return gid
end

function LevelSelectionModuleData:SetChallengeLevelData(_ChallengeLevelData)
  self.ChallengeLevelData = _ChallengeLevelData
end

function LevelSelectionModuleData:GetChallengeLevelData()
  return self.ChallengeLevelData
end

return LevelSelectionModuleData
