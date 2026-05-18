PET_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.base_id = r.base_id
  lua_record.exp = r.exp
  lua_record.gender = r.gender
  lua_record.nature_id = r.nature_id
  lua_record.hp_max_talent = r.hp_max_talent
  lua_record.phy_attack_talent = r.phy_attack_talent
  lua_record.spe_attack_talent = r.spe_attack_talent
  lua_record.phy_defence_talent = r.phy_defence_talent
  lua_record.spe_defence_talent = r.spe_defence_talent
  lua_record.speed_talent = r.speed_talent
  lua_record.learn_skill_id = r.learn_skill_id
  PET_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PET_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("PET_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PET_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PET_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PET_CONF then
    return PET_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PET_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PET_CONF")
end

return dataTable
