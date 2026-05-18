TRIGGER_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.respond_field_shape = r.respond_field_shape
  lua_record.respond_field_length = r.respond_field_length
  lua_record.respond_field_wide = r.respond_field_wide
  lua_record.respond_z_scale = r.respond_z_scale
  _respond_player_state = {}
  for i = 0, #r.respond_player_state - 1 do
    table.insert(_respond_player_state, r.respond_player_state[i])
  end
  lua_record.respond_player_state = _respond_player_state
  lua_record.cooldown = r.cooldown
  lua_record.next_behav_id = r.next_behav_id
  TRIGGER_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = TRIGGER_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("TRIGGER_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return TRIGGER_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("TRIGGER_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #TRIGGER_CONF then
    return TRIGGER_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return TRIGGER_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("TRIGGER_CONF")
end

return dataTable
