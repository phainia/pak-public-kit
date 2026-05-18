THROW_FUNC_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.throw_function = r.throw_function
  lua_record.throw_target = r.throw_target
  lua_record.throw_work_type = r.throw_work_type
  lua_record.throw_done = r.throw_done
  lua_record.throw_undone = r.throw_undone
  lua_record.retrieve = r.retrieve
  THROW_FUNC_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = THROW_FUNC_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("THROW_FUNC_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return THROW_FUNC_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("THROW_FUNC_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #THROW_FUNC_CONF then
    return THROW_FUNC_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return THROW_FUNC_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("THROW_FUNC_CONF")
end

return dataTable
