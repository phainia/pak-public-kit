MONSTER_CATCH_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.Catch_Threshold = r.Catch_Threshold
  lua_record.Catch_Ball_level = r.Catch_Ball_level
  local _catch_param = {}
  for i = 0, #r.catch_param - 1 do
    local r_2 = r.catch_param[i]
    local lua_record_2 = {}
    _params = {}
    for i = 0, #r_2.params - 1 do
      table.insert(_params, r_2.params[i])
    end
    lua_record_2.params = _params
    table.insert(_catch_param, lua_record_2)
  end
  lua_record.catch_param = _catch_param
  MONSTER_CATCH_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = MONSTER_CATCH_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("MONSTER_CATCH_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return MONSTER_CATCH_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("MONSTER_CATCH_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #MONSTER_CATCH_CONF then
    return MONSTER_CATCH_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return MONSTER_CATCH_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("MONSTER_CATCH_CONF")
end

return dataTable
