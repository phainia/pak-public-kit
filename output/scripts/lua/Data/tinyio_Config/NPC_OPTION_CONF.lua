NPC_OPTION_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.option_priority = r.option_priority
  lua_record.option_auto = r.option_auto
  lua_record.excute_delay = r.excute_delay
  lua_record.is_option_on = r.is_option_on
  lua_record.stamina_cost = r.stamina_cost
  lua_record.option_distance = r.option_distance
  lua_record.npc_interact_type = r.npc_interact_type
  lua_record.button_icon = r.button_icon
  if "" == r.button_icon then
    lua_record.button_icon = nil
  end
  lua_record.button_text = r.button_text
  if "" == r.button_text then
    lua_record.button_text = nil
  end
  lua_record.show_option_rotation = r.show_option_rotation
  lua_record.button_type = r.button_type
  lua_record.enablefix_distance = r.enablefix_distance
  lua_record.fix_distance = r.fix_distance
  lua_record.fix_rotation = r.fix_rotation
  lua_record.unmount_type = r.unmount_type
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
  lua_record.action = _action
  _pet_action = {}
  local r_pet_action = r.pet_action
  _pet_action.action_type = r_pet_action.action_type
  _pet_action.action_param1 = r_pet_action.action_param1
  if "" == r_pet_action.action_param1 then
    _pet_action.action_param1 = nil
  end
  _pet_action.action_param2 = r_pet_action.action_param2
  if "" == r_pet_action.action_param2 then
    _pet_action.action_param2 = nil
  end
  _pet_action.action_param3 = r_pet_action.action_param3
  if "" == r_pet_action.action_param3 then
    _pet_action.action_param3 = nil
  end
  lua_record.pet_action = _pet_action
  lua_record.option_times = r.option_times
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
  lua_record.option_deletnpc = r.option_deletnpc
  lua_record.option_deletnpc_times = r.option_deletnpc_times
  lua_record.option_tiems_done = r.option_tiems_done
  lua_record.option_changestatus = r.option_changestatus
  lua_record.exp_reward_type = r.exp_reward_type
  lua_record.exp_reward_value = r.exp_reward_value
  lua_record.ignore_reset = r.ignore_reset
  lua_record.trigger_guide = r.trigger_guide
  NPC_OPTION_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_OPTION_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_OPTION_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_OPTION_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_OPTION_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_OPTION_CONF then
    return NPC_OPTION_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_OPTION_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_OPTION_CONF")
end

return dataTable
