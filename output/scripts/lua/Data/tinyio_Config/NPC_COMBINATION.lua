NPC_COMBINATION = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.npc_comb_type = r.npc_comb_type
  local _option = {}
  for i = 0, #r.option - 1 do
    local r_2 = r.option[i]
    local lua_record_2 = {}
    _option_cond_npc = {}
    for i = 0, #r_2.option_cond_npc - 1 do
      table.insert(_option_cond_npc, r_2.option_cond_npc[i])
    end
    lua_record_2.option_cond_npc = _option_cond_npc
    lua_record_2.option_cond_type = r_2.option_cond_type
    _con_param = {}
    for i = 0, #r_2.con_param - 1 do
      table.insert(_con_param, r_2.con_param[i])
    end
    lua_record_2.con_param = _con_param
    table.insert(_option, lua_record_2)
  end
  lua_record.option = _option
  _lock_npc = {}
  for i = 0, #r.lock_npc - 1 do
    table.insert(_lock_npc, r.lock_npc[i])
  end
  lua_record.lock_npc = _lock_npc
  lua_record.Is_Keep = r.Is_Keep
  local _result_struct = {}
  for i = 0, #r.result_struct - 1 do
    local r_2 = r.result_struct[i]
    local lua_record_2 = {}
    lua_record_2.result = r_2.result
    _result_param = {}
    for i = 0, #r_2.result_param - 1 do
      table.insert(_result_param, r_2.result_param[i])
    end
    lua_record_2.result_param = _result_param
    _result_param2 = {}
    for i = 0, #r_2.result_param2 - 1 do
      table.insert(_result_param2, r_2.result_param2[i])
    end
    lua_record_2.result_param2 = _result_param2
    table.insert(_result_struct, lua_record_2)
  end
  lua_record.result_struct = _result_struct
  local _unkeep_result_struct = {}
  for i = 0, #r.unkeep_result_struct - 1 do
    local r_2 = r.unkeep_result_struct[i]
    local lua_record_2 = {}
    lua_record_2.unkeep_result = r_2.unkeep_result
    _unkeep_result_param = {}
    for i = 0, #r_2.unkeep_result_param - 1 do
      table.insert(_unkeep_result_param, r_2.unkeep_result_param[i])
    end
    lua_record_2.unkeep_result_param = _unkeep_result_param
    _unkeep_result_param2 = {}
    for i = 0, #r_2.unkeep_result_param2 - 1 do
      table.insert(_unkeep_result_param2, r_2.unkeep_result_param2[i])
    end
    lua_record_2.unkeep_result_param2 = _unkeep_result_param2
    table.insert(_unkeep_result_struct, lua_record_2)
  end
  lua_record.unkeep_result_struct = _unkeep_result_struct
  lua_record.result_times = r.result_times
  lua_record.reset_type = r.reset_type
  lua_record.reset_time = r.reset_time
  if "" == r.reset_time then
    lua_record.reset_time = nil
  end
  lua_record.total_time = r.total_time
  lua_record.npc_guide = r.npc_guide
  lua_record.initial_check = r.initial_check
  NPC_COMBINATION[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_COMBINATION[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_COMBINATION", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_COMBINATION[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_COMBINATION", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_COMBINATION then
    return NPC_COMBINATION
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_COMBINATION
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_COMBINATION")
end

return dataTable
