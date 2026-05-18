BATTLE_RANDOM_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  local _battle = {}
  for i = 0, #r.battle - 1 do
    local r_2 = r.battle[i]
    local lua_record_2 = {}
    lua_record_2.battle_id = r_2.battle_id
    lua_record_2.prob = r_2.prob
    table.insert(_battle, lua_record_2)
  end
  lua_record.battle = _battle
  BATTLE_RANDOM_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BATTLE_RANDOM_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BATTLE_RANDOM_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BATTLE_RANDOM_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BATTLE_RANDOM_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BATTLE_RANDOM_CONF then
    return BATTLE_RANDOM_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BATTLE_RANDOM_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BATTLE_RANDOM_CONF")
end

return dataTable
