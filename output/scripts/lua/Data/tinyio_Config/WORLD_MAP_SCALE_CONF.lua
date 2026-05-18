WORLD_MAP_SCALE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.min_scale = r.min_scale
  lua_record.max_scale = r.max_scale
  WORLD_MAP_SCALE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = WORLD_MAP_SCALE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("WORLD_MAP_SCALE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return WORLD_MAP_SCALE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("WORLD_MAP_SCALE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #WORLD_MAP_SCALE_CONF then
    return WORLD_MAP_SCALE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return WORLD_MAP_SCALE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("WORLD_MAP_SCALE_CONF")
end

return dataTable
