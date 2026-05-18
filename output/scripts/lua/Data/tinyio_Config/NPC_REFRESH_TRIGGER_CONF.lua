NPC_REFRESH_TRIGGER_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  local _condition = {}
  for i = 0, #r.condition - 1 do
    local r_2 = r.condition[i]
    local lua_record_2 = {}
    lua_record_2.condition_type = r_2.condition_type
    lua_record_2.condition_param = r_2.condition_param
    if "" == r_2.condition_param then
      lua_record_2.condition_param = nil
    end
    table.insert(_condition, lua_record_2)
  end
  lua_record.condition = _condition
  lua_record.refresh_rand_type = r.refresh_rand_type
  lua_record.refresh_param = r.refresh_param
  local _refresh_reset = {}
  for i = 0, #r.refresh_reset - 1 do
    local r_2 = r.refresh_reset[i]
    local lua_record_2 = {}
    lua_record_2.refresh_reset_type = r_2.refresh_reset_type
    lua_record_2.refresh_reset_param = r_2.refresh_reset_param
    if "" == r_2.refresh_reset_param then
      lua_record_2.refresh_reset_param = nil
    end
    table.insert(_refresh_reset, lua_record_2)
  end
  lua_record.refresh_reset = _refresh_reset
  local _refresh_ids = {}
  for i = 0, #r.refresh_ids - 1 do
    local r_2 = r.refresh_ids[i]
    local lua_record_2 = {}
    lua_record_2.refresh_id = r_2.refresh_id
    lua_record_2.prob = r_2.prob
    table.insert(_refresh_ids, lua_record_2)
  end
  lua_record.refresh_ids = _refresh_ids
  NPC_REFRESH_TRIGGER_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_REFRESH_TRIGGER_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_REFRESH_TRIGGER_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_REFRESH_TRIGGER_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_REFRESH_TRIGGER_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_REFRESH_TRIGGER_CONF then
    return NPC_REFRESH_TRIGGER_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_REFRESH_TRIGGER_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_REFRESH_TRIGGER_CONF")
end

return dataTable
