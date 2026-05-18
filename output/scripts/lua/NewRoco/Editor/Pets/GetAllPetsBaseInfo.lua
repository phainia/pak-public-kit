GetAllPetsInfo = {}
_G.GlobalConfig = require("GlobalConfig")
_G.SingletonMgr = require("Common.Singleton.SingletonMgr").Setup()
_G.CreateSingleton = _G.SingletonMgr.CreateSingleton
_G.NRCEditorEntranceEnable = true
_G.DataConfigManager = _G.CreateSingleton("DataConfigManager", "Common.DataConfigManagerNew")

function GetAllPetsInfo.GetAllPetBaseIDAndModel()
  local outMap = UE4.TMap(1, "")
  local allPets = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PETBASE_CONF):GetAllDatas()
  for k, v in pairs(allPets) do
    local petBaseConf = v
    local id = petBaseConf.id
    local model_conf = DataConfigManager:GetModelConf(petBaseConf.model_conf)
    outMap:Add(id, model_conf.path)
  end
  return outMap
end

function GetAllPetsInfo.GetPetModelPathByID(petBaseID)
  local petBaseConf = DataConfigManager:GetPetbaseConf(petBaseID)
  if petBaseConf then
    local model_conf = DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if model_conf then
      return model_conf.path
    end
  end
  return ""
end

function GetAllPetsInfo.GetPetAudioID(petBaseID)
  local petBaseConf = DataConfigManager:GetPetbaseConf(petBaseID)
  if petBaseConf and petBaseConf.audio_config_id then
    return petBaseConf.audio_config_id
  end
  return 0
end

return GetAllPetsInfo
