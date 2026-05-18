EVOLUTION_ACTION_DATA = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.action_lower_limit = r.action_lower_limit
  lua_record.action_upper_limit = r.action_upper_limit
  lua_record.increase = r.increase
  EVOLUTION_ACTION_DATA[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = EVOLUTION_ACTION_DATA[_key]
  if nil == r then
    local r = TinyData.GetRecord("EVOLUTION_ACTION_DATA", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return EVOLUTION_ACTION_DATA[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("EVOLUTION_ACTION_DATA", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #EVOLUTION_ACTION_DATA then
    return EVOLUTION_ACTION_DATA
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return EVOLUTION_ACTION_DATA
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("EVOLUTION_ACTION_DATA")
end

return dataTable
