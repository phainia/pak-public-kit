WEATHER_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.weather_type = r.weather_type
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.weather_params = r.weather_params
  if "" == r.weather_params then
    lua_record.weather_params = nil
  end
  local _tod_param = {}
  for i = 0, #r.tod_param - 1 do
    local r_2 = r.tod_param[i]
    local lua_record_2 = {}
    lua_record_2.available_time_enum = r_2.available_time_enum
    lua_record_2.field_type = r_2.field_type
    lua_record_2.field_layer = r_2.field_layer
    lua_record_2.des = r_2.des
    if "" == r_2.des then
      lua_record_2.des = nil
    end
    table.insert(_tod_param, lua_record_2)
  end
  lua_record.tod_param = _tod_param
  lua_record.temperature = r.temperature
  WEATHER_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = WEATHER_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("WEATHER_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return WEATHER_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("WEATHER_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #WEATHER_CONF then
    return WEATHER_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return WEATHER_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("WEATHER_CONF")
end

return dataTable
