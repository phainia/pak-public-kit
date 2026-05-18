AI_BEHAVIOR_GROUP_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.resist_capture = r.resist_capture
  local _behavior_info = {}
  for i = 0, #r.behavior_info - 1 do
    local r_2 = r.behavior_info[i]
    local lua_record_2 = {}
    lua_record_2.behavior_id = r_2.behavior_id
    lua_record_2.cond_type = r_2.cond_type
    _cond_param = {}
    for i = 0, #r_2.cond_param - 1 do
      table.insert(_cond_param, r_2.cond_param[i])
    end
    lua_record_2.cond_param = _cond_param
    lua_record_2.exec_count = r_2.exec_count
    table.insert(_behavior_info, lua_record_2)
  end
  lua_record.behavior_info = _behavior_info
  AI_BEHAVIOR_GROUP_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AI_BEHAVIOR_GROUP_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AI_BEHAVIOR_GROUP_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AI_BEHAVIOR_GROUP_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AI_BEHAVIOR_GROUP_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AI_BEHAVIOR_GROUP_CONF then
    return AI_BEHAVIOR_GROUP_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AI_BEHAVIOR_GROUP_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AI_BEHAVIOR_GROUP_CONF")
end

return dataTable
