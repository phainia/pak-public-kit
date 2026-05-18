HP_MAX_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.lower_limit = r.lower_limit
  lua_record.upper_limit = r.upper_limit
  lua_record.exchange_conf = r.exchange_conf
  HP_MAX_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = HP_MAX_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("HP_MAX_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return HP_MAX_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("HP_MAX_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #HP_MAX_CONF then
    return HP_MAX_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return HP_MAX_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("HP_MAX_CONF")
end

return dataTable
