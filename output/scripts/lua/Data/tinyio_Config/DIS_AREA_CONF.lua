DIS_AREA_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.near_border = r.near_border
  lua_record.mid_border = r.mid_border
  lua_record.far_border = r.far_border
  lua_record.too_far_border = r.too_far_border
  DIS_AREA_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = DIS_AREA_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("DIS_AREA_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return DIS_AREA_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("DIS_AREA_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #DIS_AREA_CONF then
    return DIS_AREA_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return DIS_AREA_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("DIS_AREA_CONF")
end

return dataTable
