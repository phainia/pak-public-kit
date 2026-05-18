CRYSTAL_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.type = r.type
  CRYSTAL_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = CRYSTAL_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("CRYSTAL_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return CRYSTAL_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("CRYSTAL_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #CRYSTAL_CONF then
    return CRYSTAL_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return CRYSTAL_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("CRYSTAL_CONF")
end

return dataTable
