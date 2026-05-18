NPC_REFRESH_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  _editor_name = {}
  for i = 0, #r.editor_name - 1 do
    table.insert(_editor_name, r.editor_name[i])
  end
  lua_record.editor_name = _editor_name
  lua_record.disable = r.disable
  lua_record.refresh_type = r.refresh_type
  lua_record.refresh_param = r.refresh_param
  lua_record.patrol_belong_type = r.patrol_belong_type
  lua_record.patrol_param = r.patrol_param
  lua_record.trigger_type = r.trigger_type
  lua_record.version = r.version
  lua_record.refresh_update_type = r.refresh_update_type
  lua_record.available_time_enum = r.available_time_enum
  _available_weather_enum = {}
  for i = 0, #r.available_weather_enum - 1 do
    table.insert(_available_weather_enum, r.available_weather_enum[i])
  end
  lua_record.available_weather_enum = _available_weather_enum
  lua_record.survive_time = r.survive_time
  _refresh_quantity = {}
  for i = 0, #r.refresh_quantity - 1 do
    table.insert(_refresh_quantity, r.refresh_quantity[i])
  end
  lua_record.refresh_quantity = _refresh_quantity
  lua_record.refresh_gap = r.refresh_gap
  lua_record.max_num = r.max_num
  lua_record.storage_num = r.storage_num
  lua_record.storage_reset_type = r.storage_reset_type
  lua_record.storage_reset_param = r.storage_reset_param
  if r.storage_reset_param == "" then
    lua_record.storage_reset_param = nil
  end
  lua_record.npc_level_script = r.npc_level_script
  _level_param = {}
  for i = 0, #r.level_param - 1 do
    table.insert(_level_param, r.level_param[i])
  end
  lua_record.level_param = _level_param
  lua_record.delete_quantity = r.delete_quantity
  lua_record.delete_gap = r.delete_gap
  lua_record.lock_on_ground = r.lock_on_ground
  lua_record.adjust_dir = r.adjust_dir
  lua_record.permanent = r.permanent
  _init_status = {}
  for i = 0, #r.init_status - 1 do
    table.insert(_init_status, r.init_status[i])
  end
  lua_record.init_status = _init_status
  _init_property_types = {}
  for i = 0, #r.init_property_types - 1 do
    table.insert(_init_property_types, r.init_property_types[i])
  end
  lua_record.init_property_types = _init_property_types
  lua_record.init_option_available = r.init_option_available
  lua_record.show_in_world_map = r.show_in_world_map
  lua_record.icon_show_map_time = r.icon_show_map_time
  _evolution_lv_filter = {}
  for i = 0, #r.evolution_lv_filter - 1 do
    table.insert(_evolution_lv_filter, r.evolution_lv_filter[i])
  end
  lua_record.evolution_lv_filter = _evolution_lv_filter
  lua_record.exclusive_type = r.exclusive_type
  lua_record.condition_refresh = r.condition_refresh
  local _npcs = {}
  for i = 0, #r.npcs - 1 do
    local r_2 = r.npcs[i]
    local lua_record_2 = {}
    lua_record_2.npc_id = r_2.npc_id
    lua_record_2.prob = r_2.prob
    table.insert(_npcs, lua_record_2)
  end
  lua_record.npcs = _npcs
  NPC_REFRESH_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_REFRESH_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_REFRESH_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_REFRESH_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_REFRESH_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_REFRESH_CONF then
    return NPC_REFRESH_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_REFRESH_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_REFRESH_CONF")
end

return dataTable
