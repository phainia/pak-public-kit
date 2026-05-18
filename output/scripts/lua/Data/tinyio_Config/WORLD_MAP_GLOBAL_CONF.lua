WORLD_MAP_GLOBAL_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.key = r.key
  if r.key == "" then
    lua_record.key = nil
  end
  lua_record.num = r.num
  _numList = {}
  for i = 0, #r.numList - 1 do
    table.insert(_numList, r.numList[i])
  end
  lua_record.numList = _numList
  lua_record.str = r.str
  if "" == r.str then
    lua_record.str = nil
  end
  WORLD_MAP_GLOBAL_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = WORLD_MAP_GLOBAL_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("WORLD_MAP_GLOBAL_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return WORLD_MAP_GLOBAL_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("WORLD_MAP_GLOBAL_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #WORLD_MAP_GLOBAL_CONF then
    return WORLD_MAP_GLOBAL_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.key, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return WORLD_MAP_GLOBAL_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("WORLD_MAP_GLOBAL_CONF")
end

return dataTable
