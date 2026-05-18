DECISION_MATRIX_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.tree_type = r.tree_type
  lua_record.tree_name = r.tree_name
  if r.tree_name == "" then
    lua_record.tree_name = nil
  end
  lua_record.abort_mode = r.abort_mode
  lua_record.random_trigger = r.random_trigger
  _player_state_oper = {}
  for i = 0, #r.player_state_oper - 1 do
    table.insert(_player_state_oper, r.player_state_oper[i])
  end
  lua_record.player_state_oper = _player_state_oper
  _player_state_val = {}
  for i = 0, #r.player_state_val - 1 do
    table.insert(_player_state_val, r.player_state_val[i])
  end
  lua_record.player_state_val = _player_state_val
  _self_state_oper = {}
  for i = 0, #r.self_state_oper - 1 do
    table.insert(_self_state_oper, r.self_state_oper[i])
  end
  lua_record.self_state_oper = _self_state_oper
  _self_state_val = {}
  for i = 0, #r.self_state_val - 1 do
    table.insert(_self_state_val, r.self_state_val[i])
  end
  lua_record.self_state_val = _self_state_val
  _group_state_oper = {}
  for i = 0, #r.group_state_oper - 1 do
    table.insert(_group_state_oper, r.group_state_oper[i])
  end
  lua_record.group_state_oper = _group_state_oper
  _group_state_val = {}
  for i = 0, #r.group_state_val - 1 do
    table.insert(_group_state_val, r.group_state_val[i])
  end
  lua_record.group_state_val = _group_state_val
  _dis_area_oper = {}
  for i = 0, #r.dis_area_oper - 1 do
    table.insert(_dis_area_oper, r.dis_area_oper[i])
  end
  lua_record.dis_area_oper = _dis_area_oper
  _dis_area_val = {}
  for i = 0, #r.dis_area_val - 1 do
    table.insert(_dis_area_val, r.dis_area_val[i])
  end
  lua_record.dis_area_val = _dis_area_val
  _angle_area_oper = {}
  for i = 0, #r.angle_area_oper - 1 do
    table.insert(_angle_area_oper, r.angle_area_oper[i])
  end
  lua_record.angle_area_oper = _angle_area_oper
  _angle_area_val = {}
  for i = 0, #r.angle_area_val - 1 do
    table.insert(_angle_area_val, r.angle_area_val[i])
  end
  lua_record.angle_area_val = _angle_area_val
  _input_key = {}
  for i = 0, #r.input_key - 1 do
    table.insert(_input_key, r.input_key[i])
  end
  lua_record.input_key = _input_key
  _output_key = {}
  for i = 0, #r.output_key - 1 do
    table.insert(_output_key, r.output_key[i])
  end
  lua_record.output_key = _output_key
  _begin_event = {}
  for i = 0, #r.begin_event - 1 do
    table.insert(_begin_event, r.begin_event[i])
  end
  lua_record.begin_event = _begin_event
  _end_event = {}
  for i = 0, #r.end_event - 1 do
    table.insert(_end_event, r.end_event[i])
  end
  lua_record.end_event = _end_event
  DECISION_MATRIX_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = DECISION_MATRIX_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("DECISION_MATRIX_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return DECISION_MATRIX_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("DECISION_MATRIX_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #DECISION_MATRIX_CONF then
    return DECISION_MATRIX_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return DECISION_MATRIX_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("DECISION_MATRIX_CONF")
end

return dataTable
