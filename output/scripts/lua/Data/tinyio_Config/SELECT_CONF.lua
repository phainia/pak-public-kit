SELECT_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.text = r.text
  if "" == r.text then
    lua_record.text = nil
  end
  lua_record.color = r.color
  lua_record.select_icon = r.select_icon
  if "" == r.select_icon then
    lua_record.select_icon = nil
  end
  _initial_flags = {}
  for i = 0, #r.initial_flags - 1 do
    table.insert(_initial_flags, r.initial_flags[i])
  end
  lua_record.initial_flags = _initial_flags
  lua_record.enable_cond = r.enable_cond
  lua_record.enable_cond_params = r.enable_cond_params
  if "" == r.enable_cond_params then
    lua_record.enable_cond_params = nil
  end
  lua_record.times = r.times
  lua_record.times_decrease_cond = r.times_decrease_cond
  lua_record.times_decrease_cond_params = r.times_decrease_cond_params
  if "" == r.times_decrease_cond_params then
    lua_record.times_decrease_cond_params = nil
  end
  lua_record.reset_type = r.reset_type
  lua_record.reset_time = r.reset_time
  if "" == r.reset_time then
    lua_record.reset_time = nil
  end
  _obtain_story_flags = {}
  for i = 0, #r.obtain_story_flags - 1 do
    table.insert(_obtain_story_flags, r.obtain_story_flags[i])
  end
  lua_record.obtain_story_flags = _obtain_story_flags
  _lost_story_flags = {}
  for i = 0, #r.lost_story_flags - 1 do
    table.insert(_lost_story_flags, r.lost_story_flags[i])
  end
  lua_record.lost_story_flags = _lost_story_flags
  lua_record.notimes_disable = r.notimes_disable
  lua_record.notimes_dialogue = r.notimes_dialogue
  lua_record.select_deletnpc = r.select_deletnpc
  lua_record.select_deletnpc_times = r.select_deletnpc_times
  lua_record.select_next_dialogue = r.select_next_dialogue
  lua_record.select_mark = r.select_mark
  SELECT_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SELECT_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SELECT_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SELECT_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SELECT_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SELECT_CONF then
    return SELECT_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SELECT_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SELECT_CONF")
end

return dataTable
