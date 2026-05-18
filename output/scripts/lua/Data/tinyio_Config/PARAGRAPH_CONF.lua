PARAGRAPH_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.title = r.title
  if r.title == "" then
    lua_record.title = nil
  end
  lua_record.start_task = r.start_task
  lua_record.end_task = r.end_task
  lua_record.description = r.description
  if "" == r.description then
    lua_record.description = nil
  end
  lua_record.Reward = r.Reward
  PARAGRAPH_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PARAGRAPH_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("PARAGRAPH_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PARAGRAPH_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PARAGRAPH_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PARAGRAPH_CONF then
    return PARAGRAPH_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PARAGRAPH_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PARAGRAPH_CONF")
end

return dataTable
