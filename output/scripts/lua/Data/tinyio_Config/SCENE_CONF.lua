SCENE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.scene_res_id = r.scene_res_id
  lua_record.scene_load_type = r.scene_load_type
  lua_record.born_pos_x = r.born_pos_x
  lua_record.born_pos_y = r.born_pos_y
  lua_record.born_pos_z = r.born_pos_z
  lua_record.born_spin_x = r.born_spin_x
  lua_record.born_spin_y = r.born_spin_y
  lua_record.born_spin_z = r.born_spin_z
  SCENE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SCENE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SCENE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SCENE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SCENE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SCENE_CONF then
    return SCENE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SCENE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SCENE_CONF")
end

return dataTable
