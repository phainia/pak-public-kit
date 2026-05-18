EVOLUTION_LEVEL_DATA = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.level_lower_limit = r.level_lower_limit
  lua_record.level_upper_limit = r.level_upper_limit
  lua_record.chance = r.chance
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  EVOLUTION_LEVEL_DATA[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = EVOLUTION_LEVEL_DATA[_key]
  if nil == r then
    local r = TinyData.GetRecord("EVOLUTION_LEVEL_DATA", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return EVOLUTION_LEVEL_DATA[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("EVOLUTION_LEVEL_DATA", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #EVOLUTION_LEVEL_DATA then
    return EVOLUTION_LEVEL_DATA
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return EVOLUTION_LEVEL_DATA
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("EVOLUTION_LEVEL_DATA")
end

return dataTable
