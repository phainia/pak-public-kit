TASK_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.task_class = r.task_class
  lua_record.chapter_id = r.chapter_id
  lua_record.paragraph_id = r.paragraph_id
  lua_record.res_id = r.res_id
  if "" == r.res_id then
    lua_record.res_id = nil
  end
  lua_record.belong_place = r.belong_place
  if "" == r.belong_place then
    lua_record.belong_place = nil
  end
  lua_record.task_des = r.task_des
  if "" == r.task_des then
    lua_record.task_des = nil
  end
  lua_record.open = r.open
  lua_record.show = r.show
  lua_record.descontent = r.descontent
  if "" == r.descontent then
    lua_record.descontent = nil
  end
  lua_record.require_type = r.require_type
  lua_record.require_data = r.require_data
  _next_task = {}
  for i = 0, #r.next_task - 1 do
    table.insert(_next_task, r.next_task[i])
  end
  lua_record.next_task = _next_task
  lua_record.task_reset_cycle = r.task_reset_cycle
  lua_record.open_num = r.open_num
  local _task_condition = {}
  for i = 0, #r.task_condition - 1 do
    local r_2 = r.task_condition[i]
    local lua_record_2 = {}
    lua_record_2.descontent = r_2.descontent
    if "" == r_2.descontent then
      lua_record_2.descontent = nil
    end
    lua_record_2.complete_type = r_2.complete_type
    _data1 = {}
    for i = 0, #r_2.data1 - 1 do
      table.insert(_data1, r_2.data1[i])
    end
    lua_record_2.data1 = _data1
    _data2 = {}
    for i = 0, #r_2.data2 - 1 do
      table.insert(_data2, r_2.data2[i])
    end
    lua_record_2.data2 = _data2
    lua_record_2.count = r_2.count
    lua_record_2.count_operate = r_2.count_operate
    lua_record_2.count_reset_cycle = r_2.count_reset_cycle
    table.insert(_task_condition, lua_record_2)
  end
  lua_record.task_condition = _task_condition
  local _go_condition = {}
  for i = 0, #r.go_condition - 1 do
    local r_2 = r.go_condition[i]
    local lua_record_2 = {}
    lua_record_2.go_type = r_2.go_type
    _go_data1 = {}
    for i = 0, #r_2.go_data1 - 1 do
      table.insert(_go_data1, r_2.go_data1[i])
    end
    lua_record_2.go_data1 = _go_data1
    _go_data2 = {}
    for i = 0, #r_2.go_data2 - 1 do
      table.insert(_go_data2, r_2.go_data2[i])
    end
    lua_record_2.go_data2 = _go_data2
    lua_record_2.go_text = r_2.go_text
    if "" == r_2.go_text then
      lua_record_2.go_text = nil
    end
    table.insert(_go_condition, lua_record_2)
  end
  lua_record.go_condition = _go_condition
  lua_record.auto_finish = r.auto_finish
  lua_record.Reward = r.Reward
  local _accept_condition = {}
  for i = 0, #r.accept_condition - 1 do
    local r_2 = r.accept_condition[i]
    local lua_record_2 = {}
    lua_record_2.accept_type = r_2.accept_type
    lua_record_2.accept_data1 = r_2.accept_data1
    lua_record_2.accept_data2 = r_2.accept_data2
    lua_record_2.accept_text = r_2.accept_text
    if "" == r_2.accept_text then
      lua_record_2.accept_text = nil
    end
    table.insert(_accept_condition, lua_record_2)
  end
  lua_record.accept_condition = _accept_condition
  local _finish_condition = {}
  for i = 0, #r.finish_condition - 1 do
    local r_2 = r.finish_condition[i]
    local lua_record_2 = {}
    lua_record_2.finish_type = r_2.finish_type
    _finish_data1 = {}
    for i = 0, #r_2.finish_data1 - 1 do
      table.insert(_finish_data1, r_2.finish_data1[i])
    end
    lua_record_2.finish_data1 = _finish_data1
    _finish_data2 = {}
    for i = 0, #r_2.finish_data2 - 1 do
      table.insert(_finish_data2, r_2.finish_data2[i])
    end
    lua_record_2.finish_data2 = _finish_data2
    lua_record_2.finish_text = r_2.finish_text
    if "" == r_2.finish_text then
      lua_record_2.finish_text = nil
    end
    table.insert(_finish_condition, lua_record_2)
  end
  lua_record.finish_condition = _finish_condition
  lua_record.get_type = r.get_type
  lua_record.get_data1 = r.get_data1
  lua_record.get_data2 = r.get_data2
  lua_record.get_text = r.get_text
  if "" == r.get_text then
    lua_record.get_text = nil
  end
  lua_record.battle_ability = r.battle_ability
  lua_record.revive_point = r.revive_point
  TASK_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = TASK_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("TASK_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return TASK_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("TASK_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #TASK_CONF then
    return TASK_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return TASK_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("TASK_CONF")
end

return dataTable
