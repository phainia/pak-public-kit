SCENE_ABILITY_SLIDING_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.allow_long_press = r.allow_long_press
  lua_record.speed_curve = r.speed_curve
  if r.speed_curve == "" then
    lua_record.speed_curve = nil
  end
  lua_record.slide_accelerate = r.slide_accelerate
  lua_record.vitality_cost_curve = r.vitality_cost_curve
  if "" == r.vitality_cost_curve then
    lua_record.vitality_cost_curve = nil
  end
  lua_record.acc_curve = r.acc_curve
  if "" == r.acc_curve then
    lua_record.acc_curve = nil
  end
  lua_record.deacc_curve = r.deacc_curve
  if "" == r.deacc_curve then
    lua_record.deacc_curve = nil
  end
  lua_record.vitality_id = r.vitality_id
  lua_record.slide_start_vitality_cost = r.slide_start_vitality_cost
  lua_record.slide_cooldown = r.slide_cooldown
  lua_record.slide_rotate_speed = r.slide_rotate_speed
  lua_record.slide_required_speed = r.slide_required_speed
  lua_record.slide_start_speed = r.slide_start_speed
  lua_record.slide_joystick_sensity = r.slide_joystick_sensity
  lua_record.slide_trigger_delay = r.slide_trigger_delay
  lua_record.slide_ability_maintain_time = r.slide_ability_maintain_time
  lua_record.slide_ability_cooldown_time = r.slide_ability_cooldown_time
  lua_record.slide_min_angle = r.slide_min_angle
  lua_record.slide_max_angle = r.slide_max_angle
  lua_record.maintain_press_time = r.maintain_press_time
  SCENE_ABILITY_SLIDING_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SCENE_ABILITY_SLIDING_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SCENE_ABILITY_SLIDING_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SCENE_ABILITY_SLIDING_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SCENE_ABILITY_SLIDING_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SCENE_ABILITY_SLIDING_CONF then
    return SCENE_ABILITY_SLIDING_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SCENE_ABILITY_SLIDING_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SCENE_ABILITY_SLIDING_CONF")
end

return dataTable
