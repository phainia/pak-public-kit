AI_FSM_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  local _fsm_state = {}
  for i = 0, #r.fsm_state - 1 do
    local r_2 = r.fsm_state[i]
    local lua_record_2 = {}
    lua_record_2.next_state_id = r_2.next_state_id
    lua_record_2.cond_with = r_2.cond_with
    lua_record_2.state_cond_id = r_2.state_cond_id
    table.insert(_fsm_state, lua_record_2)
  end
  lua_record.fsm_state = _fsm_state
  lua_record.next_state_id = r.next_state_id
  AI_FSM_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AI_FSM_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AI_FSM_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AI_FSM_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AI_FSM_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AI_FSM_CONF then
    return AI_FSM_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AI_FSM_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AI_FSM_CONF")
end

return dataTable
