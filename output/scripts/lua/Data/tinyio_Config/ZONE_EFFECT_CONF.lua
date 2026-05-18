ZONE_EFFECT_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.type = r.type
  _area_id = {}
  for i = 0, #r.area_id - 1 do
    table.insert(_area_id, r.area_id[i])
  end
  lua_record.area_id = _area_id
  ZONE_EFFECT_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = ZONE_EFFECT_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("ZONE_EFFECT_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return ZONE_EFFECT_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("ZONE_EFFECT_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #ZONE_EFFECT_CONF then
    return ZONE_EFFECT_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return ZONE_EFFECT_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("ZONE_EFFECT_CONF")
end

return dataTable
