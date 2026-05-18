function _G.DataConfigManager:RequireAllConf()
  if UE4.UNRCStatics.EnableRequireAllConf() then
    Log.Debug("show me mem before:", collectgarbage("count"))
    
    local function TryLoad(k)
      Log.Debug("DoLoad:", k)
      _G.DataConfigManager:GetAllByName(k)
    end
    
    local ConfigTableIds = _G.DataConfigManager.ConfigTableId
    for k, v in pairs(ConfigTableIds) do
      local s, e = pcall(TryLoad, k)
      if not s then
        Log.Error("DoLoad fail:", k)
      end
    end
    Log.Debug("show me mem after:", collectgarbage("count"))
  end
end

function _G.DataConfigManager:GetGlobalConfigByKey(key)
  return self:GetGlobalConfig(key)
end

function _G.DataConfigManager:GetGlobalConfigByKeyType(key, type)
  return self:GetData(type, key)
end

function _G.DataConfigManager:GetGlobalConfigNumByKey(key, defaultValue)
  local cfg = self:GetGlobalConfigByKey(key)
  return cfg and cfg.num or defaultValue
end

function _G.DataConfigManager:GetGlobalConfigNumByKeyType(key, type, defaultValue)
  local cfg = self:GetGlobalConfigByKeyType(key, type)
  return cfg and cfg.num or defaultValue
end

function _G.DataConfigManager:GetGlobalConfigStrByKey(key, defaultValue)
  local cfg = self:GetGlobalConfigByKey(key)
  return cfg and cfg.str or defaultValue
end

function _G.DataConfigManager:GetGlobalConfigStrByKeyType(key, type, defaultValue)
  local cfg = self:GetGlobalConfigByKeyType(key, type)
  return cfg and cfg.str or defaultValue
end

function _G.DataConfigManager:GetAttributeCfgByType(type)
  return self:GetAttributeConf(type)
end

function _G.DataConfigManager:GetSkillColorByType(type)
  return self:GetSkillColorConf(type)
end

function _G.DataConfigManager:GetUIConfs()
  if not self.UI_CONFS then
    local cfgTbl = self:GetTable(self.ConfigTableId.UI_CONF)
    self.UI_CONFS = cfgTbl:GetAllDatas()
    if not self.UI_CONFS then
      Log.ErrorFormat("GetUiConf Error: confs table is nil")
      return nil
    end
  end
  return self.UI_CONFS
end

function _G.DataConfigManager:GetWorldGlobalConfigByKey(key)
  return self:GetWorldMapGlobalConf(key)
end

function _G.DataConfigManager:GetSceneResConfByName(key)
  if not self._SCENE_RES_CONFS then
    self._SCENE_RES_CONFS = {}
    local cfgTbl = self:GetTable(self.ConfigTableId.SCENE_RES_CONF)
    local SceneResConf = cfgTbl:GetAllDatas()
    for i, v in pairs(SceneResConf) do
      self._SCENE_RES_CONFS[v.main_source] = v
    end
  end
  return self._SCENE_RES_CONFS[key]
end

function _G.DataConfigManager:GetEnvTagConfByPhysName(key)
  if not self._ENV_TAG_CONFS then
    self._ENV_TAG_CONFS = {}
    local cfgTbl = self:GetTable(self.ConfigTableId.ENV_TAG_CONF)
    local EenTagConfs = cfgTbl:GetAllDatas()
    for i, v in pairs(EenTagConfs) do
      if v.physical_surface then
        self._ENV_TAG_CONFS[v.physical_surface] = v
      end
    end
  end
  return self._ENV_TAG_CONFS[key]
end

function _G.DataConfigManager:GetPetEvolutionChainCount()
  if not self.pet_evolution_chain_count then
    self.pet_evolution_chain_count = 0
    local table_BOOK = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_HANDBOOK)
    if table_BOOK then
      local evolutionMap = {}
      for k, v in pairs(table_BOOK:GetAllDatas()) do
        if v.include_petbase_id and #v.include_petbase_id > 0 then
          local baseIdData = v.include_petbase_id[1]
          if baseIdData and baseIdData.petbase_id and #baseIdData.petbase_id > 0 then
            local baseId = baseIdData.petbase_id[1]
            local basePetData = _G.DataConfigManager:GetPetbaseConf(baseId)
            if basePetData and basePetData.pet_evolution_id and #basePetData.pet_evolution_id > 0 then
              local evolutionId = basePetData.pet_evolution_id[1]
              local evolutionData = _G.DataConfigManager:GetPetEvolutionConf(evolutionId)
              if evolutionData then
                local evolutionGroupId = evolutionData.handbook_evolution_group
                if evolutionGroupId and not evolutionMap[evolutionGroupId] then
                  evolutionMap[evolutionGroupId] = evolutionGroupId
                  self.pet_evolution_chain_count = self.pet_evolution_chain_count + 1
                end
              end
            end
          end
        end
      end
    end
  end
  return self.pet_evolution_chain_count
end
