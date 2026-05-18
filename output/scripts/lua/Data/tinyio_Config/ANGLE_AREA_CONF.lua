ANGLE_AREA_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.straight_ahead_border = r.straight_ahead_border
  lua_record.front_border = r.front_border
  ANGLE_AREA_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = ANGLE_AREA_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("ANGLE_AREA_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return ANGLE_AREA_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("ANGLE_AREA_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #ANGLE_AREA_CONF then
    return ANGLE_AREA_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return ANGLE_AREA_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("ANGLE_AREA_CONF")
end

return dataTable
