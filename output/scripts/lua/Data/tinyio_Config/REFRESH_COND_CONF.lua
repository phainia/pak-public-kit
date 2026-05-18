REFRESH_COND_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.allow_random = r.allow_random
  local _npcs = {}
  for i = 0, #r.npcs - 1 do
    local r_2 = r.npcs[i]
    local lua_record_2 = {}
    lua_record_2.npc_id = r_2.npc_id
    lua_record_2.ratio = r_2.ratio
    lua_record_2.editor_name = r_2.editor_name
    if r_2.editor_name == "" then
      lua_record_2.editor_name = nil
    end
    table.insert(_npcs, lua_record_2)
  end
  lua_record.npcs = _npcs
  lua_record.available_time_enum = r.available_time_enum
  lua_record.altitude_min = r.altitude_min
  lua_record.altitude_max = r.altitude_max
  lua_record.depth_min = r.depth_min
  lua_record.depth_max = r.depth_max
  local _tiles = {}
  for i = 0, #r.tiles - 1 do
    local r_2 = r.tiles[i]
    local lua_record_2 = {}
    lua_record_2.tile_type = r_2.tile_type
    lua_record_2.num_need = r_2.num_need
    table.insert(_tiles, lua_record_2)
  end
  lua_record.tiles = _tiles
  local _tags = {}
  for i = 0, #r.tags - 1 do
    local r_2 = r.tags[i]
    local lua_record_2 = {}
    lua_record_2.tag = r_2.tag
    lua_record_2.tag_power_min = r_2.tag_power_min
    lua_record_2.tag_power_max = r_2.tag_power_max
    lua_record_2.num_need = r_2.num_need
    table.insert(_tags, lua_record_2)
  end
  lua_record.tags = _tags
  REFRESH_COND_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = REFRESH_COND_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("REFRESH_COND_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return REFRESH_COND_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("REFRESH_COND_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #REFRESH_COND_CONF then
    return REFRESH_COND_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return REFRESH_COND_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("REFRESH_COND_CONF")
end

return dataTable
