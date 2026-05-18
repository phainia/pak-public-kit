NATURE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.positive_effect = r.positive_effect
  lua_record.positive_effect_proportion = r.positive_effect_proportion
  lua_record.negative_effect = r.negative_effect
  lua_record.negative_effect_proportion = r.negative_effect_proportion
  lua_record.prob = r.prob
  NATURE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NATURE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("NATURE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NATURE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NATURE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NATURE_CONF then
    return NATURE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NATURE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NATURE_CONF")
end

return dataTable
