NPC_REFRESH_RULE_CONF = {}
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
  lua_record.version = r.version
  lua_record.refresh_update_type = r.refresh_update_type
  lua_record.trigger_type = r.trigger_type
  lua_record.available_time_enum = r.available_time_enum
  _available_weather_enum = {}
  for i = 0, #r.available_weather_enum - 1 do
    table.insert(_available_weather_enum, r.available_weather_enum[i])
  end
  lua_record.available_weather_enum = _available_weather_enum
  local _condition = {}
  for i = 0, #r.condition - 1 do
    local r_2 = r.condition[i]
    local lua_record_2 = {}
    lua_record_2.condition_type = r_2.condition_type
    lua_record_2.condition_param = r_2.condition_param
    if r_2.condition_param == "" then
      lua_record_2.condition_param = nil
    end
    table.insert(_condition, lua_record_2)
  end
  lua_record.condition = _condition
  _refresh_quantity = {}
  for i = 0, #r.refresh_quantity - 1 do
    table.insert(_refresh_quantity, r.refresh_quantity[i])
  end
  lua_record.refresh_quantity = _refresh_quantity
  lua_record.refresh_gap = r.refresh_gap
  lua_record.survive_time = r.survive_time
  lua_record.storage_reset_type = r.storage_reset_type
  lua_record.storage_reset_param = r.storage_reset_param
  if "" == r.storage_reset_param then
    lua_record.storage_reset_param = nil
  end
  lua_record.delete_quantity = r.delete_quantity
  lua_record.delete_gap = r.delete_gap
  _evolution_lv_filter = {}
  for i = 0, #r.evolution_lv_filter - 1 do
    table.insert(_evolution_lv_filter, r.evolution_lv_filter[i])
  end
  lua_record.evolution_lv_filter = _evolution_lv_filter
  lua_record.exclusive_type = r.exclusive_type
  lua_record.condition_refresh = r.condition_refresh
  lua_record.rand_type = r.rand_type
  lua_record.rand_param = r.rand_param
  local _contents = {}
  for i = 0, #r.contents - 1 do
    local r_2 = r.contents[i]
    local lua_record_2 = {}
    lua_record_2.content_id = r_2.content_id
    lua_record_2.prob = r_2.prob
    table.insert(_contents, lua_record_2)
  end
  lua_record.contents = _contents
  NPC_REFRESH_RULE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_REFRESH_RULE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_REFRESH_RULE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_REFRESH_RULE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_REFRESH_RULE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_REFRESH_RULE_CONF then
    return NPC_REFRESH_RULE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_REFRESH_RULE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_REFRESH_RULE_CONF")
end

return dataTable
