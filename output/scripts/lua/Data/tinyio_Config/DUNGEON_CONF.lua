DUNGEON_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.scene_id = r.scene_id
  lua_record.type = r.type
  lua_record.type_name = r.type_name
  if "" == r.type_name then
    lua_record.type_name = nil
  end
  local _require_cond = {}
  for i = 0, #r.require_cond - 1 do
    local r_2 = r.require_cond[i]
    local lua_record_2 = {}
    lua_record_2.require_type = r_2.require_type
    _require_data = {}
    for i = 0, #r_2.require_data - 1 do
      table.insert(_require_data, r_2.require_data[i])
    end
    lua_record_2.require_data = _require_data
    lua_record_2.is_consume = r_2.is_consume
    table.insert(_require_cond, lua_record_2)
  end
  lua_record.require_cond = _require_cond
  _dungn_task = {}
  for i = 0, #r.dungn_task - 1 do
    table.insert(_dungn_task, r.dungn_task[i])
  end
  lua_record.dungn_task = _dungn_task
  lua_record.complete_count = r.complete_count
  _complete_task = {}
  for i = 0, #r.complete_task - 1 do
    table.insert(_complete_task, r.complete_task[i])
  end
  lua_record.complete_task = _complete_task
  lua_record.hide_tag = r.hide_tag
  lua_record.main_exit = r.main_exit
  DUNGEON_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = DUNGEON_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("DUNGEON_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return DUNGEON_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("DUNGEON_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #DUNGEON_CONF then
    return DUNGEON_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return DUNGEON_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("DUNGEON_CONF")
end

return dataTable
