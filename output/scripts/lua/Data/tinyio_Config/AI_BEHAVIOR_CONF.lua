AI_BEHAVIOR_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.tree_name = r.tree_name
  if "" == r.tree_name then
    lua_record.tree_name = nil
  end
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
  _tick_input_key = {}
  for i = 0, #r.tick_input_key - 1 do
    table.insert(_tick_input_key, r.tick_input_key[i])
  end
  lua_record.tick_input_key = _tick_input_key
  AI_BEHAVIOR_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AI_BEHAVIOR_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AI_BEHAVIOR_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AI_BEHAVIOR_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AI_BEHAVIOR_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AI_BEHAVIOR_CONF then
    return AI_BEHAVIOR_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AI_BEHAVIOR_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AI_BEHAVIOR_CONF")
end

return dataTable
