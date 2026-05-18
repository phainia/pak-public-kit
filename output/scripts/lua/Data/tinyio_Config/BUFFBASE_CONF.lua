BUFFBASE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.buffbase_order = r.buffbase_order
  lua_record.trigger_type = r.trigger_type
  lua_record.is_dam_param_change = r.is_dam_param_change
  _show_letters = {}
  for i = 0, #r.show_letters - 1 do
    table.insert(_show_letters, r.show_letters[i])
  end
  lua_record.show_letters = _show_letters
  _client_trigger_type = {}
  for i = 0, #r.client_trigger_type - 1 do
    table.insert(_client_trigger_type, r.client_trigger_type[i])
  end
  lua_record.client_trigger_type = _client_trigger_type
  local _buffbase_param = {}
  for i = 0, #r.buffbase_param - 1 do
    local r_2 = r.buffbase_param[i]
    local lua_record_2 = {}
    _params = {}
    for i = 0, #r_2.params - 1 do
      table.insert(_params, r_2.params[i])
    end
    lua_record_2.params = _params
    table.insert(_buffbase_param, lua_record_2)
  end
  lua_record.buffbase_param = _buffbase_param
  BUFFBASE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BUFFBASE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BUFFBASE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BUFFBASE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BUFFBASE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BUFFBASE_CONF then
    return BUFFBASE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BUFFBASE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BUFFBASE_CONF")
end

return dataTable
