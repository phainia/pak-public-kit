AI_FSM_STATE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  local _fsm_cond = {}
  for i = 0, #r.fsm_cond - 1 do
    local r_2 = r.fsm_cond[i]
    local lua_record_2 = {}
    lua_record_2.cond_type = r_2.cond_type
    lua_record_2.cond_op = r_2.cond_op
    lua_record_2.cond_value = r_2.cond_value
    table.insert(_fsm_cond, lua_record_2)
  end
  lua_record.fsm_cond = _fsm_cond
  AI_FSM_STATE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AI_FSM_STATE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AI_FSM_STATE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AI_FSM_STATE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AI_FSM_STATE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AI_FSM_STATE_CONF then
    return AI_FSM_STATE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AI_FSM_STATE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AI_FSM_STATE_CONF")
end

return dataTable
