NPC_AURA_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.aura_type = r.aura_type
  lua_record.leader_battle_distance = r.leader_battle_distance
  lua_record.leader_battle_delay = r.leader_battle_delay
  lua_record.aura_area_type = r.aura_area_type
  _aura_distance = {}
  for i = 0, #r.aura_distance - 1 do
    table.insert(_aura_distance, r.aura_distance[i])
  end
  lua_record.aura_distance = _aura_distance
  lua_record.aura_target_type = r.aura_target_type
  _aura_target = {}
  for i = 0, #r.aura_target - 1 do
    table.insert(_aura_target, r.aura_target[i])
  end
  lua_record.aura_target = _aura_target
  lua_record.time_last = r.time_last
  lua_record.time_tick = r.time_tick
  lua_record.next_aura_id = r.next_aura_id
  local _aura_effect = {}
  for i = 0, #r.aura_effect - 1 do
    local r_2 = r.aura_effect[i]
    local lua_record_2 = {}
    lua_record_2.aura_effect_type = r_2.aura_effect_type
    _params = {}
    for i = 0, #r_2.params - 1 do
      table.insert(_params, r_2.params[i])
    end
    lua_record_2.params = _params
    table.insert(_aura_effect, lua_record_2)
  end
  lua_record.aura_effect = _aura_effect
  lua_record.is_die_delete = r.is_die_delete
  lua_record.bound_create_actor = r.bound_create_actor
  lua_record.remove_aura_distance = r.remove_aura_distance
  NPC_AURA_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_AURA_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_AURA_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_AURA_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_AURA_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_AURA_CONF then
    return NPC_AURA_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_AURA_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_AURA_CONF")
end

return dataTable
