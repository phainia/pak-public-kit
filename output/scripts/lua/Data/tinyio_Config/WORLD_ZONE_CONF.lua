WORLD_ZONE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.scene_id = r.scene_id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.region_name = r.region_name
  if "" == r.region_name then
    lua_record.region_name = nil
  end
  lua_record.region_priority = r.region_priority
  lua_record.battle_source = r.battle_source
  if "" == r.battle_source then
    lua_record.battle_source = nil
  end
  local _refresh_reset = {}
  for i = 0, #r.refresh_reset - 1 do
    local r_2 = r.refresh_reset[i]
    local lua_record_2 = {}
    lua_record_2.start_time = r_2.start_time
    lua_record_2.end_time = r_2.end_time
    lua_record_2.bgm_id = r_2.bgm_id
    table.insert(_refresh_reset, lua_record_2)
  end
  lua_record.refresh_reset = _refresh_reset
  lua_record.amb_id = r.amb_id
  _area_id = {}
  for i = 0, #r.area_id - 1 do
    table.insert(_area_id, r.area_id[i])
  end
  lua_record.area_id = _area_id
  WORLD_ZONE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = WORLD_ZONE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("WORLD_ZONE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return WORLD_ZONE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("WORLD_ZONE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #WORLD_ZONE_CONF then
    return WORLD_ZONE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return WORLD_ZONE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("WORLD_ZONE_CONF")
end

return dataTable
