AI_GROUP_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.group_id = r.group_id
  AI_GROUP_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AI_GROUP_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AI_GROUP_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AI_GROUP_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AI_GROUP_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AI_GROUP_CONF then
    return AI_GROUP_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AI_GROUP_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AI_GROUP_CONF")
end

return dataTable
