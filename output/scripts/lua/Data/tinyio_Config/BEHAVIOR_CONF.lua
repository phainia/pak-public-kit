BEHAVIOR_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.behavior_type = r.behavior_type
  lua_record.action_param1 = r.action_param1
  if r.action_param1 == "" then
    lua_record.action_param1 = nil
  end
  BEHAVIOR_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BEHAVIOR_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BEHAVIOR_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BEHAVIOR_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BEHAVIOR_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BEHAVIOR_CONF then
    return BEHAVIOR_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BEHAVIOR_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BEHAVIOR_CONF")
end

return dataTable
