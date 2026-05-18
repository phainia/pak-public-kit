BOTTLE_VOLUME_CONF = {}
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
  BOTTLE_VOLUME_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BOTTLE_VOLUME_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BOTTLE_VOLUME_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BOTTLE_VOLUME_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BOTTLE_VOLUME_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BOTTLE_VOLUME_CONF then
    return BOTTLE_VOLUME_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BOTTLE_VOLUME_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BOTTLE_VOLUME_CONF")
end

return dataTable
