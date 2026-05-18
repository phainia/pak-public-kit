PETFREE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.petfree_sort = r.petfree_sort
  lua_record.level_low = r.level_low
  lua_record.level_high = r.level_high
  lua_record.reward = r.reward
  PETFREE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PETFREE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("PETFREE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PETFREE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PETFREE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PETFREE_CONF then
    return PETFREE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PETFREE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PETFREE_CONF")
end

return dataTable
