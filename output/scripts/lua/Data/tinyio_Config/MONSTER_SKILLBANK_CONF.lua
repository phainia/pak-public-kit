MONSTER_SKILLBANK_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  local _level = {}
  for i = 0, #r.level - 1 do
    local r_2 = r.level[i]
    local lua_record_2 = {}
    lua_record_2.level_limit = r_2.level_limit
    lua_record_2.is_random = r_2.is_random
    lua_record_2.skill_id = r_2.skill_id
    table.insert(_level, lua_record_2)
  end
  lua_record.level = _level
  MONSTER_SKILLBANK_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = MONSTER_SKILLBANK_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("MONSTER_SKILLBANK_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return MONSTER_SKILLBANK_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("MONSTER_SKILLBANK_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #MONSTER_SKILLBANK_CONF then
    return MONSTER_SKILLBANK_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return MONSTER_SKILLBANK_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("MONSTER_SKILLBANK_CONF")
end

return dataTable
