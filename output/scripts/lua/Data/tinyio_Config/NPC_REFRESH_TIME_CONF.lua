NPC_REFRESH_TIME_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  local _available_time = {}
  for i = 0, #r.available_time - 1 do
    local r_2 = r.available_time[i]
    local lua_record_2 = {}
    lua_record_2.available_time_type = r_2.available_time_type
    lua_record_2.available_time_param1 = r_2.available_time_param1
    if r_2.available_time_param1 == "" then
      lua_record_2.available_time_param1 = nil
    end
    lua_record_2.available_time_param2 = r_2.available_time_param2
    if "" == r_2.available_time_param2 then
      lua_record_2.available_time_param2 = nil
    end
    table.insert(_available_time, lua_record_2)
  end
  lua_record.available_time = _available_time
  NPC_REFRESH_TIME_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_REFRESH_TIME_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_REFRESH_TIME_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_REFRESH_TIME_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_REFRESH_TIME_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_REFRESH_TIME_CONF then
    return NPC_REFRESH_TIME_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_REFRESH_TIME_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_REFRESH_TIME_CONF")
end

return dataTable
