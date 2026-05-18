POINT_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.scene_id = r.scene_id
  lua_record.pos_x = r.pos_x
  lua_record.pos_y = r.pos_y
  lua_record.pos_z = r.pos_z
  lua_record.rotation = r.rotation
  POINT_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = POINT_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("POINT_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return POINT_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("POINT_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #POINT_CONF then
    return POINT_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return POINT_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("POINT_CONF")
end

return dataTable
