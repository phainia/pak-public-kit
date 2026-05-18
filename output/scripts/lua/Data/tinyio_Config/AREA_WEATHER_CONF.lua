AREA_WEATHER_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  local _rand_weather = {}
  for i = 0, #r.rand_weather - 1 do
    local r_2 = r.rand_weather[i]
    local lua_record_2 = {}
    lua_record_2.weather_type = r_2.weather_type
    lua_record_2.weight = r_2.weight
    table.insert(_rand_weather, lua_record_2)
  end
  lua_record.rand_weather = _rand_weather
  AREA_WEATHER_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AREA_WEATHER_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AREA_WEATHER_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AREA_WEATHER_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AREA_WEATHER_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AREA_WEATHER_CONF then
    return AREA_WEATHER_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AREA_WEATHER_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AREA_WEATHER_CONF")
end

return dataTable
