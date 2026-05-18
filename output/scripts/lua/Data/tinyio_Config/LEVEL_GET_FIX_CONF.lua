LEVEL_GET_FIX_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.level_diff = r.level_diff
  lua_record.level_grade_fix = r.level_grade_fix
  LEVEL_GET_FIX_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = LEVEL_GET_FIX_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("LEVEL_GET_FIX_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return LEVEL_GET_FIX_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("LEVEL_GET_FIX_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #LEVEL_GET_FIX_CONF then
    return LEVEL_GET_FIX_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return LEVEL_GET_FIX_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("LEVEL_GET_FIX_CONF")
end

return dataTable
