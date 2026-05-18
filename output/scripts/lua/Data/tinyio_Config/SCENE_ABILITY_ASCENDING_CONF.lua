SCENE_ABILITY_ASCENDING_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.allow_long_press = r.allow_long_press
  lua_record.vertical_accelerate = r.vertical_accelerate
  lua_record.max_upward_spd = r.max_upward_spd
  lua_record.max_speed_curve = r.max_speed_curve
  if r.max_speed_curve == "" then
    lua_record.max_speed_curve = nil
  end
  lua_record.accelerate = r.accelerate
  lua_record.turn_threshold = r.turn_threshold
  lua_record.fly_delta_angular_speed = r.fly_delta_angular_speed
  lua_record.vitality_id = r.vitality_id
  lua_record.ascend_start_vitality_cost = r.ascend_start_vitality_cost
  lua_record.min_duration = r.min_duration
  lua_record.ascending_vitality_cost = r.ascending_vitality_cost
  lua_record.ascend_cooldown = r.ascend_cooldown
  lua_record.maintain_press_time = r.maintain_press_time
  SCENE_ABILITY_ASCENDING_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SCENE_ABILITY_ASCENDING_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SCENE_ABILITY_ASCENDING_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SCENE_ABILITY_ASCENDING_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SCENE_ABILITY_ASCENDING_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SCENE_ABILITY_ASCENDING_CONF then
    return SCENE_ABILITY_ASCENDING_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SCENE_ABILITY_ASCENDING_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SCENE_ABILITY_ASCENDING_CONF")
end

return dataTable
