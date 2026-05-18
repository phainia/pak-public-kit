CAMERA_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  _state_type = {}
  for i = 0, #r.state_type - 1 do
    table.insert(_state_type, r.state_type[i])
  end
  lua_record.state_type = _state_type
  lua_record.threshold_1 = r.threshold_1
  lua_record.rotation_speed_1 = r.rotation_speed_1
  lua_record.threshold_2 = r.threshold_2
  lua_record.rotation_speed_2 = r.rotation_speed_2
  lua_record.threshold_3 = r.threshold_3
  CAMERA_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = CAMERA_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("CAMERA_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return CAMERA_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("CAMERA_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #CAMERA_CONF then
    return CAMERA_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return CAMERA_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("CAMERA_CONF")
end

return dataTable
