FIELD_LAYER_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.power_up = r.power_up
  lua_record.res_id = r.res_id
  if r.res_id == "" then
    lua_record.res_id = nil
  end
  FIELD_LAYER_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = FIELD_LAYER_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("FIELD_LAYER_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return FIELD_LAYER_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("FIELD_LAYER_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #FIELD_LAYER_CONF then
    return FIELD_LAYER_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return FIELD_LAYER_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("FIELD_LAYER_CONF")
end

return dataTable
