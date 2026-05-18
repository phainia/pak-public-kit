NPC_REFRESH_CONTENT_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  _editor_name = {}
  for i = 0, #r.editor_name - 1 do
    table.insert(_editor_name, r.editor_name[i])
  end
  lua_record.editor_name = _editor_name
  lua_record.refresh_type = r.refresh_type
  lua_record.refresh_param = r.refresh_param
  lua_record.refresh_rule = r.refresh_rule
  _specify_area_number = {}
  for i = 0, #r.specify_area_number - 1 do
    table.insert(_specify_area_number, r.specify_area_number[i])
  end
  lua_record.specify_area_number = _specify_area_number
  lua_record.max_num = r.max_num
  lua_record.storage_num = r.storage_num
  lua_record.patrol_belong_type = r.patrol_belong_type
  lua_record.patrol_param = r.patrol_param
  lua_record.npc_id = r.npc_id
  lua_record.npc_level_script = r.npc_level_script
  _level_param = {}
  for i = 0, #r.level_param - 1 do
    table.insert(_level_param, r.level_param[i])
  end
  lua_record.level_param = _level_param
  lua_record.lock_on_ground = r.lock_on_ground
  lua_record.adjust_dir = r.adjust_dir
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
  NPC_REFRESH_CONTENT_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_REFRESH_CONTENT_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_REFRESH_CONTENT_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_REFRESH_CONTENT_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_REFRESH_CONTENT_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_REFRESH_CONTENT_CONF then
    return NPC_REFRESH_CONTENT_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_REFRESH_CONTENT_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_REFRESH_CONTENT_CONF")
end

return dataTable
