DIALOGUE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.name = r.name
  if "" == r.name then
    lua_record.name = nil
  end
  lua_record.title = r.title
  if "" == r.title then
    lua_record.title = nil
  end
  lua_record.text = r.text
  if "" == r.text then
    lua_record.text = nil
  end
  lua_record.speed = r.speed
  lua_record.ui_source = r.ui_source
  if "" == r.ui_source then
    lua_record.ui_source = nil
  end
  lua_record.ui_source_type = r.ui_source_type
  lua_record.source_param = r.source_param
  if "" == r.source_param then
    lua_record.source_param = nil
  end
  lua_record.type_sound = r.type_sound
  if "" == r.type_sound then
    lua_record.type_sound = nil
  end
  lua_record.camera_switch_type = r.camera_switch_type
  lua_record.interact_camera_type = r.interact_camera_type
  lua_record.interact_camera_param1 = r.interact_camera_param1
  lua_record.interact_camera_param2 = r.interact_camera_param2
  lua_record.interact_camera_param3 = r.interact_camera_param3
  lua_record.dialogue_sound = r.dialogue_sound
  if "" == r.dialogue_sound then
    lua_record.dialogue_sound = nil
  end
  local _actor_perform = {}
  for i = 0, #r.actor_perform - 1 do
    local r_2 = r.actor_perform[i]
    local lua_record_2 = {}
    lua_record_2.actor = r_2.actor
    lua_record_2.turn_to = r_2.turn_to
    lua_record_2.action = r_2.action
    if "" == r_2.action then
      lua_record_2.action = nil
    end
    lua_record_2.expression = r_2.expression
    if "" == r_2.expression then
      lua_record_2.expression = nil
    end
    table.insert(_actor_perform, lua_record_2)
  end
  lua_record.actor_perform = _actor_perform
  lua_record.next_dialog_id = r.next_dialog_id
  _action = {}
  local r_action = r.action
  _action.action_type = r_action.action_type
  _action.action_param1 = r_action.action_param1
  if "" == r_action.action_param1 then
    _action.action_param1 = nil
  end
  _action.action_param2 = r_action.action_param2
  if "" == r_action.action_param2 then
    _action.action_param2 = nil
  end
  _action.action_param3 = r_action.action_param3
  if "" == r_action.action_param3 then
    _action.action_param3 = nil
  end
  _action.success_dialogue = r_action.success_dialogue
  _action.failure_dialogue = r_action.failure_dialogue
  lua_record.action = _action
  local _expand_dialogs = {}
  for i = 0, #r.expand_dialogs - 1 do
    local r_2 = r.expand_dialogs[i]
    local lua_record_2 = {}
    lua_record_2.action_result_type = r_2.action_result_type
    lua_record_2.expand_dialog_id = r_2.expand_dialog_id
    table.insert(_expand_dialogs, lua_record_2)
  end
  lua_record.expand_dialogs = _expand_dialogs
  _select_ids = {}
  for i = 0, #r.select_ids - 1 do
    table.insert(_select_ids, r.select_ids[i])
  end
  lua_record.select_ids = _select_ids
  lua_record.select_auto_on = r.select_auto_on
  DIALOGUE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = DIALOGUE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("DIALOGUE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return DIALOGUE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("DIALOGUE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #DIALOGUE_CONF then
    return DIALOGUE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return DIALOGUE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("DIALOGUE_CONF")
end

return dataTable
