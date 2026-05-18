AREA_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.scene_id = r.scene_id
  _editor_name = {}
  for i = 0, #r.editor_name - 1 do
    table.insert(_editor_name, r.editor_name[i])
  end
  lua_record.editor_name = _editor_name
  lua_record.area_type = r.area_type
  lua_record.is_visible = r.is_visible
  lua_record.is_special = r.is_special
  lua_record.is_teleport = r.is_teleport
  lua_record.is_bt_use = r.is_bt_use
  lua_record.area_layer = r.area_layer
  lua_record.stealth_on = r.stealth_on
  lua_record.is_open = r.is_open
  local _pos = {}
  for i = 0, #r.pos - 1 do
    local r_2 = r.pos[i]
    local lua_record_2 = {}
    _position_xyz = {}
    for i = 0, #r_2.position_xyz - 1 do
      table.insert(_position_xyz, r_2.position_xyz[i])
    end
    lua_record_2.position_xyz = _position_xyz
    _rotation_xyz = {}
    for i = 0, #r_2.rotation_xyz - 1 do
      table.insert(_rotation_xyz, r_2.rotation_xyz[i])
    end
    lua_record_2.rotation_xyz = _rotation_xyz
    lua_record_2.number = r_2.number
    table.insert(_pos, lua_record_2)
  end
  lua_record.pos = _pos
  local _pos_empty = {}
  for i = 0, #r.pos_empty - 1 do
    local r_2 = r.pos_empty[i]
    local lua_record_2 = {}
    _position_xyz = {}
    for i = 0, #r_2.position_xyz - 1 do
      table.insert(_position_xyz, r_2.position_xyz[i])
    end
    lua_record_2.position_xyz = _position_xyz
    _rotation_xyz = {}
    for i = 0, #r_2.rotation_xyz - 1 do
      table.insert(_rotation_xyz, r_2.rotation_xyz[i])
    end
    lua_record_2.rotation_xyz = _rotation_xyz
    lua_record_2.number = r_2.number
    table.insert(_pos_empty, lua_record_2)
  end
  lua_record.pos_empty = _pos_empty
  AREA_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AREA_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AREA_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AREA_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AREA_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AREA_CONF then
    return AREA_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AREA_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AREA_CONF")
end

return dataTable
