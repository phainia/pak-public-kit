local Enum = require("Data.Config.Enum")
local LevelUpUtils = {}

function LevelUpUtils.GetStarListData()
  local worldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  local starData = {}
  for i = 1, 10 do
    if i < worldLevel then
      table.insert(starData, {isStar = true})
    elseif i == worldLevel then
      table.insert(starData, {isNext = true})
    elseif i > worldLevel then
      table.insert(starData, {isEmpty = true})
    end
  end
  return starData
end

function LevelUpUtils.GetTargetWorldLevelConf()
  local playerLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  if playerLevel then
    local worldLevelConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_LEVEL_CONF):GetAllDatas()
    for index, item in ipairs(worldLevelConf) do
      if item.update_grade_level == playerLevel then
        return item
      end
    end
  end
  return nil
end

function LevelUpUtils.GetWorldLevelConf()
  local worldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  if worldLevel then
    local worldLevelConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_LEVEL_CONF):GetAllDatas()
    for index, item in ipairs(worldLevelConf) do
      if item.world_level == worldLevel then
        return item
      end
    end
  end
  return nil
end

function LevelUpUtils.GetWorldLevelConfByWorldLevel(WorldLevel)
  if WorldLevel then
    local worldLevelConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_LEVEL_CONF):GetAllDatas()
    for index, item in ipairs(worldLevelConf) do
      if item.world_level == WorldLevel then
        return item
      end
    end
  end
  return nil
end

function LevelUpUtils.GetMagicianTitle()
  local worldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  if worldLevel then
    local worldLevelConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_LEVEL_CONF):GetAllDatas()
    for index, item in ipairs(worldLevelConf) do
      if item.world_level == worldLevel then
        return item.title
      end
    end
  end
  return string.format(LuaText.leveluputils_1, worldLevel)
end

function LevelUpUtils.GetExpAndMax()
  local Exp = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_ROLEEXP) or 0
  local Level = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  local RoleExpConf = LevelUpUtils.GetRoleExpConfByPlayerLevel(Level)
  local MaxExp = RoleExpConf and RoleExpConf.need_exp or -1
  MaxExp = math.max(0, MaxExp)
  return Exp, MaxExp
end

function LevelUpUtils.GetRoleExpConfByPlayerLevel(playerLevel)
  return _G.DataConfigManager:GetRoleExpConf(playerLevel)
end

function LevelUpUtils.GetRoleExpConfByWorldLevel(worldLevel)
  return _G.DataConfigManager:GetLevelRewardsConf(worldLevel)
end

function LevelUpUtils.CanGetUpgradeWorldLevelTask()
  local worldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  local targetWorldLevelConf = LevelUpUtils.GetTargetWorldLevelConf()
  if not targetWorldLevelConf then
    return false
  end
  if worldLevel == targetWorldLevelConf.world_level then
    return false
  end
  local taskObj = _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.getTaskByID, targetWorldLevelConf.update_task_id)
  _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  if taskObj then
    return false
  else
    return true
  end
end

return LevelUpUtils
